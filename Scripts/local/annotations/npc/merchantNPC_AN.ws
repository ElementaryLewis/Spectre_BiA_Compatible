@addMethod(W3MerchantNPC) function BalisseFruitTempFix()
{
	var l_merchantComponent : W3MerchantComponent;
	
	l_merchantComponent = (W3MerchantComponent)GetComponentByClassName('W3MerchantComponent');
	invComp = GetInventory();
	if(invComp && l_merchantComponent && l_merchantComponent.GetMapPinType() == 'Herbalist')
	{
		if(!invComp.HasItem('Balisse fruit'))
			invComp.AddAnItem('Balisse fruit', 10);
	}
}

@replaceMethod(W3MerchantNPC) function OnSpawned( spawnData : SEntitySpawnData )
{
	var tags : array< name >;
	var ids : array< SItemUniqueId >;
	var i : int;
	
	super.OnSpawned( spawnData );
	
	if (embeddedScenes.Size() > 0) {
		if (StrBeginsWith(embeddedScenes[0].storyScene.GetPath(), "living_world\dialogue\generic_merchants\shop_generic_merchant")) 
		{
			tags = embeddedScenes[0].storyScene.GetRequiredPositionTags();
			ArrayOfNamesAppendUnique(tags, GetTags());
			SetTags(tags);
		}
	}

	if ( theGame.IsActive() )
	{
		if ( !HasTag( 'ShopkeeperEntity' ) )
		{
			tags = GetTags();
			tags.PushBack( 'ShopkeeperEntity' );
			SetTags( tags );
		}
	}

	invComp = GetInventory();
	if ( invComp )
	{
		if ( spawnData.restored == true )
		{
			invComp.ClearTHmaps();
			invComp.ClearGwintCards();
			invComp.ClearKnownRecipes();
			if ( questBonus == true )
			{
				invComp.ActivateQuestBonus();
			}
		}
		else
		{
			invComp.SetupFunds();
			lastDayOfInteraction = GameTimeDays( theGame.GetGameTime() );
		}
		if ( invComp.GetMoney() < 100 )
		{
			invComp.SetupFunds();
		}
		invComp.GetAllItems(ids);
		for(i=0; i<ids.Size(); i+=1)
		{
			
			if ( invComp.GetItemModifierInt(ids[i], 'ItemQualityModified') <= 0 )
				invComp.AddRandomEnhancementToItem(ids[i], invComp.GetItemLevel(ids[i]));
		}
		BalisseFruitTempFix();
	}
	else
	{
		Log( "<<< ERROR - W3MERCHANTNPC ATTEMPTED TO USE INVALID INVENTORY COMPONENT >>>" );
	}
}

@wrapMethod(W3MerchantNPC) function OnInteraction( actionName : string, activator : CEntity )
{	
	var timeElapsed : int;
	var gameTimeDay : int;
	
	wrappedMethod(actionName, activator);

	if ( actionName == "Talk" )
	{
		invComp = GetInventory();
		
		if ( invComp )
		{
			if ( timeElapsed >= invComp.GetDaysToIncreaseFunds() || timeElapsed < 0 )
			{
				BalisseFruitTempFix();
				invComp.ClearLowLevelWeapons();
			}
		}
	}
}