@wrapMethod(W3RefillableContainer) function Refill(td : float, id : int)
{
	var inv : CInventoryComponent;
	var oldMoney, i : int;
	var oldItems : array<SItemUniqueId>;
	var oldItemsCounts : array<int>;
	var herbBonusChance : float;
	var isBalisse : bool;
	
	if (false)
	{
		wrappedMethod( td, id );
	}
	
	isBalisse = StrEndsWith( GetReadableName(), "balisse_fruit.w2ent" );
	
	inv = GetInventory();
	
	if ( inv && ( inv.IsLootRenewable() || isBalisse ) )
	{
		if( inv.IsReadyToRenew() )
		{
			PreRefillContainer();
		}
		
		
		if(isPlayerInActivationRange)
		{
			oldMoney = inv.GetMoney();
			herbBonusChance = CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_herb_chance'));
			
			if(herbBonusChance > 0)
			{
				inv.GetAllItems(oldItems);
				oldItemsCounts.Resize(oldItems.Size());
				for(i=0; i<oldItems.Size(); i+=1)
					oldItemsCounts[i] = inv.GetItemQuantity(oldItems[i]);
			}
		}
		
		inv.UpdateLoot();
		
		if( isBalisse && inv.IsEmpty() )
			inv.AddAnItem('Balisse fruit', 1);
		
		checkedForBonusMoney = false;
		checkedForBonusHerbs = false;
		
		
		if(isPlayerInActivationRange)
		{
			checkedForBonusMoney = true;
			checkedForBonusHerbs = true;
			CheckForBonusMoney(oldMoney);
			
			if(herbBonusChance > 0)
				CheckForBonusHerbs(oldItems, oldItemsCounts, herbBonusChance);
		}
				
		if ( !inv.IsEmpty() )
		{
			isEmpty = false;
			
			SetFocusModeVisibility( FMV_Interactive );			
			ApplyAppearance( "1_full" );
			Enable( true );
			RemoveTimer( 'Refill' );
		}
	}
	else
	{
		RemoveTimer( 'Refill' );
	}
}