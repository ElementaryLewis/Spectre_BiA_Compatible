@wrapMethod(W3Boat) function OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
{
	var player : CR4Player;
	
	if(false) 
	{
		wrappedMethod(area, activator);
	}

	player = (CR4Player)activator.GetEntity();
	
	if( player )	
	{
		if( area.GetName() == "FirstDiscoveryTrigger" )
		{
			area.SetEnabled( false );
		}
		else if( area.GetName() == "OnBoatTrigger" )
		{
			player.SetIsOnBoat( true );
			player.BlockAction( EIAB_RunAndSprint, 'OnBoatTrigger', false, false, true );
			player.BlockAction( EIAB_CallHorse, 'OnBoatTrigger', false, false, true );
			
			if( !HasDrowned() )
			{
				if( theGame.params.GetBoatSinkOption() && boatComp && theGame.GetLoadGameProgress() == 0 && GetCanBeDestroyed() && CheckPlayerEncumbrance((W3PlayerWitcher)player) )
				{
					boatComp.TriggerDrowning( player.GetWorldPosition() );
					SetHasDrowned( true );
					SoundEvent( "boat_sinking" );
					thePlayer.DisplayHudMessage( GetLocStringByKeyExt( "spectre_geralt_too_heavy" ) );
				}
				else
				{
					needEnableInteractions = true;
					
					if( mountInteractionComp )
						mountInteractionComp.SetEnabled( true );
					if( mountInteractionCompPassenger && boatComp.user )	
						mountInteractionCompPassenger.SetEnabled( true );
				}
			}
		}
	}
}	

@addMethod(W3Boat) function CheckPlayerEncumbrance(witcher : W3PlayerWitcher) : bool
{
	var tmpBool : bool;
	if( !witcher || !witcher.HasBuff(EET_OverEncumbered) )
		return false;
	return ClampF(witcher.GetEncumbrance()/witcher.GetMaxRunEncumbrance(tmpBool) - 1, 0, 1) * 100 > theGame.params.GetBoatSinkOverEncumbranceOption();
}