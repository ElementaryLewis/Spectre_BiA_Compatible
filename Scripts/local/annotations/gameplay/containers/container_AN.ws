@replaceMethod(W3Container) function RebalanceItems()
{
	var i : int;
	var items : array<SItemUniqueId>;
	
	if( inv && !disableLooting)
	{
		inv.AutoBalanaceItemsWithPlayerLevel();
		inv.GetAllItems( items );
	}
	
	for(i=0; i<items.Size(); i+=1)
	{
		
		if ( inv.GetItemModifierInt(items[i], 'ItemQualityModified') > 0 )
				continue;
				
		inv.AddRandomEnhancementToItem(items[i], inv.GetItemLevel(items[i]));
	}
}

@wrapMethod(W3Container) function ProcessLoot()
{
	if(false) 
	{
		wrappedMethod();
	}

	if(disableLooting)
		return;
		
	if(skipInventoryPanel || usedByCiri)
	{
		
		if( !thePlayer.IsAnyWeaponHeld() && !thePlayer.IsHoldingItemInLHand() )
			thePlayer.RaiseEvent('LootHerb');
		

		TakeAllItems();
		OnContainerClosed();			
	}
	else
	{
		ShowLoot();
	}
}