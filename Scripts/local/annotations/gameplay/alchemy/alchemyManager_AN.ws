@wrapMethod( W3AlchemyManager ) function CookItem(recipeName : name)
{
	var i, j, quantity, removedIngQuantity, maxAmmo : int;
	var recipe : SAlchemyRecipe;
	var dm : CDefinitionsManagerAccessor;
	var crossbowID : SItemUniqueId;
	var min, max : SAbilityAttributeValue;
	var uiStateAlchemy : W3TutorialManagerUIHandlerStateAlchemy;
	var uiStateAlchemyMutagens : W3TutorialManagerUIHandlerStateAlchemyMutagens;
	var ids : array<SItemUniqueId>;
	var items, alchIngs  : array<SItemUniqueId>;
	var isPotion, isSingletonItem : bool;
	var witcher : W3PlayerWitcher;
	var equippedOnSlot : EEquipmentSlots;
	var itemName:name;
	
	if (false)
	{
		wrappedMethod( recipeName );
	}
	
	GetRecipe(recipeName, recipe);
	
	
	equippedOnSlot = EES_InvalidSlot;
	dm = theGame.GetDefinitionsManager();
	dm.GetItemAttributeValueNoRandom(recipe.cookedItemName, true, 'ammo', min, max);
	quantity = (int)CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	
	if(recipe.cookedItemType == EACIT_Bomb && GetWitcherPlayer().CanUseSkill(S_Alchemy_s08))
		quantity += GetWitcherPlayer().GetSkillLevel(S_Alchemy_s08);
	
	
	isSingletonItem = dm.IsItemSingletonItem(recipe.cookedItemName);
	if(isSingletonItem && thePlayer.inv.GetItemQuantityByName(recipe.cookedItemName) > 0 )
	{
		items = thePlayer.inv.GetItemsByName(recipe.cookedItemName);
		
		if (items.Size() == 1 && thePlayer.inv.ItemHasTag(items[0], 'NoShow'))
		{
			thePlayer.inv.RemoveItemTag(items[i], 'NoShow');
		}
	}
	else
	{
		if( recipe.cookedItemType == EACIT_Edibles )
			quantity = recipe.cookedItemQuantity;
		ids = thePlayer.inv.AddAnItem(recipe.cookedItemName, quantity);
		if(isSingletonItem)
		{
			maxAmmo = thePlayer.inv.SingletonItemGetMaxAmmo(ids[0]);
			for(i=0; i<ids.Size(); i+=1)
				thePlayer.inv.SingletonItemSetAmmo(ids[i], maxAmmo);
		}
	}
	
	
	for(i=0; i<recipe.requiredIngredients.Size(); i+=1)
	{
		itemName = recipe.requiredIngredients[i].itemName;
		
		
		
		if( dm.ItemHasTag( itemName, 'MutagenIngredient' ) )
		{
			thePlayer.inv.RemoveUnusedMutagensCount( itemName, recipe.requiredIngredients[i].quantity);
		}
		else if( dm.IsItemAlchemyItem( itemName ))
		{
			removedIngQuantity = 0;
			alchIngs = thePlayer.inv.GetItemsByName(itemName);
			witcher = GetWitcherPlayer();
			
			for(j=0; j<alchIngs.Size(); j+=1)
			{
				equippedOnSlot = witcher.GetItemSlot(alchIngs[j]);
				
				if(equippedOnSlot != EES_InvalidSlot)
				{
					witcher.UnequipItem(alchIngs[j]);
				}
				
				removedIngQuantity += 1;
				witcher.inv.RemoveItem(alchIngs[j], 1);
				
				if(removedIngQuantity >= recipe.requiredIngredients[i].quantity)
					break;
			}
		}
		else
		{
			
			thePlayer.inv.RemoveItemByName(itemName, recipe.requiredIngredients[i].quantity);
		}
	}
	
	RemoveLowerLevelItems(recipe);
	
	if( ids.Size() > 0  && thePlayer.inv.IsItemPotion( ids[0] ) )
	{
		isPotion = true;
	}
	else if( items.Size() > 0  && thePlayer.inv.IsItemPotion( items[0] ) )
	{
		isPotion = true;
	}
	else
	{
		isPotion = false;
	}
	
	if( isPotion )
	{
		theTelemetry.LogWithLabelAndValue( TE_ITEM_COOKED, recipe.cookedItemName, 1 );
	}
	else
	{
		theTelemetry.LogWithLabelAndValue( TE_ITEM_COOKED, recipe.cookedItemName, 0 );
	}
	
	
	if(equippedOnSlot != EES_InvalidSlot)
	{
		witcher.EquipItemInGivenSlot(ids[0], equippedOnSlot, false);
	}
	
	LogAlchemy("Item <<" + recipe.cookedItemName + ">> cooked x" + recipe.cookedItemQuantity);
	
	
	if(ShouldProcessTutorial('TutorialAlchemyCook'))
	{
		uiStateAlchemy = (W3TutorialManagerUIHandlerStateAlchemy)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if(uiStateAlchemy)
		{
			uiStateAlchemy.CookedItem(recipeName);
		}
		else
		{
			uiStateAlchemyMutagens = (W3TutorialManagerUIHandlerStateAlchemyMutagens)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiStateAlchemyMutagens)
				uiStateAlchemyMutagens.CookedItem(recipeName);
		}
	}
}