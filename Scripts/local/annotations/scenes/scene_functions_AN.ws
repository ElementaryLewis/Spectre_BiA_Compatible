@replaceMethod function ShowMeGoods( player: CStoryScenePlayer, merchantTag : CName )
{
	var initDataObject : W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	var shopOwner : CNewNPC;
	var merchants : array<CActor>;
	var i : int;
	var shopInventory : CInventoryComponent;
	
	if ( merchantTag == ''  )
	{
	    return;
	}
	
	
	merchants = GetActorsInRange(thePlayer, 2.0f, 100000, '', true);

	for(i=0; i < merchants.Size(); i+= 1 )
	{
		if( merchants[i].HasTag( merchantTag ) )
		{
			shopOwner = (CNewNPC) merchants[i];
			break;
		}	
		
	}
	
	
	if ( !shopOwner )
	{
		shopOwner = theGame.GetNPCByTag( merchantTag );
		
		if( !shopOwner )
			return;
		
	}
	
	if( !shopOwner.HasTag('Merchant' ) ) 
	{
		shopOwner.AddTag('Merchant');
	}
	
	shopInventory = shopOwner.GetInventory();
	if( shopInventory )
	{
		if( merchantTag == 'sq108_blacksmith_woman' )
		{
			shopInventory.AddMasterArmorerItems();
		}
		shopInventory.AutoBalanaceItemsWithPlayerLevel();
	}
		
	initDataObject.containerNPC = (CGameplayEntity)shopOwner;
	OpenGUIPanelForScene( 'InventoryMenu', 'CommonMenu', shopOwner, initDataObject );
	
}