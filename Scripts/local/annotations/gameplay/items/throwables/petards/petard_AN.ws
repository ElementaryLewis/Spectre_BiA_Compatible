@wrapMethod(W3Petard) function ThrowProjectile( targetPosIn : Vector )
{		
	var phantom : CPhantomComponent;
	var inv : CInventoryComponent;
		
	if(false) 
	{
		wrappedMethod(targetPosIn);
	}
	
	phantom = (CPhantomComponent)GetComponent('snappingCollisionGroupNames');
	if(phantom)
	{
		phantom.GetTriggeringCollisionGroupNames(snapCollisionGroupNames);
	}
	else
	{
		snapCollisionGroupNames.PushBack('Terrain');
		snapCollisionGroupNames.PushBack('Static');
	}
	
	
	LoadDataFromItemXMLStats();		

	targetPos = targetPosIn;
	
	isProximity = false;
	
	
	AddTimer( 'ReleaseProjectile', 0.01, false, , , true );
	
	
	if ( GetOwner() != thePlayer )
	{
		inv = GetOwner().GetInventory();
		if(inv)
			inv.RemoveItem( itemId );
	}
	else
	{
		
		if(!FactsDoesExist("debug_fact_inf_bombs"))
			thePlayer.inv.SingletonItemRemoveAmmo(itemId, 1);
		thePlayer.DrainStamina(ESAT_UsableItem);
			
		
		if( thePlayer.inv.GetItemQuantity(itemId) < 1 )		
			thePlayer.ClearSelectedItemId();
		
		
		
		else if( !GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 ) )
		
		{
			GetWitcherPlayer().AddBombThrowDelay(itemId);
		}
			
		if(GetOwner() == GetWitcherPlayer())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
	}
}