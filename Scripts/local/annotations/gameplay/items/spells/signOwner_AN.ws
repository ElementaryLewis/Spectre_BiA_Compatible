@wrapMethod(W3SignOwnerPlayer) function ChangeAspect( signEntity : W3SignEntity, newSkill : ESkill ) : bool
{
	var newTarget : CActor;
	var ret : bool;
	var shouldAltCast : bool;
	var altInputHeld : bool;
	
	if(false) 
	{
		wrappedMethod(signEntity, newSkill);
	}

	if(!theInput.LastUsedPCInput() && thePlayer.GetInputHandler().GetIsAltSignCasting())
	{
		if( ((W3AardEntity)signEntity) && (theInput.IsActionPressed('Sprint') || theInput.IsActionPressed('CbtRoll')) )
		{
			shouldAltCast = true;
		} 
		else if( ((W3IgniEntity)signEntity) && (theInput.IsActionPressed('LockAndGuard') || theInput.IsActionPressed('Focus')) )
		{
			shouldAltCast = true;
		}
		else if( ((W3YrdenEntity)signEntity) && theInput.IsActionPressed('AttackHeavy') )
		{
			shouldAltCast = true;
		}
		else if( ((W3QuenEntity)signEntity) && (theInput.IsActionPressed('AltQuenCasting') || theInput.IsActionPressed('Dodge')) )
		{
			shouldAltCast = true;
		}
		else if( ((W3AxiiEntity)signEntity) && theInput.IsActionPressed('AttackLight') )
		{
			shouldAltCast = true;
		}
	}
	else if(theInput.LastUsedPCInput() && thePlayer.GetInputHandler().GetIsAltSignCasting())
	{
		if( ((W3AardEntity)signEntity) && (theInput.IsActionPressed('SelectAard') || theInput.IsActionPressed( 'CastSign' )) )
		{
			shouldAltCast = true;
			altInputHeld = true;
		} 
		else if( ((W3IgniEntity)signEntity) && (theInput.IsActionPressed('SelectIgni') || theInput.IsActionPressed( 'CastSign' )) )
		{
			shouldAltCast = true;
			altInputHeld = true;
		}
		else if( ((W3YrdenEntity)signEntity) && (theInput.IsActionPressed('SelectYrden') || theInput.IsActionPressed( 'CastSign' )) )
		{
			shouldAltCast = true;
			altInputHeld = true;
		}
		else if( ((W3QuenEntity)signEntity) && (theInput.IsActionPressed('SelectQuen') || theInput.IsActionPressed( 'CastSign' )) )
		{
			shouldAltCast = true;
			altInputHeld = true;
		}
		else if( ((W3AxiiEntity)signEntity) && (theInput.IsActionPressed('SelectAxii') || theInput.IsActionPressed( 'CastSign' )) )
		{
			shouldAltCast = true;
			altInputHeld = true;
		}
	}
	else
	{
		shouldAltCast = true;
	}
	

	if ( !player.CanUseSkill( newSkill ) )
	{
		ret = false;
	}	
	else if ( spectreTestCastSignHold() )
	{
		if ( !player.IsCombatMusicEnabled() && !player.CanAttackWhenNotInCombat( EBAT_CastSign, true, newTarget ) )
		{
			ret = false;
		}
		else
		{
			signEntity.SetAlternateCast( newSkill );
			player.SetBehaviorVariable( 'alternateSignCast', 1 );
			ret = true;
		}
	}
	else 
	{
		ret = false;
	}
	
	if(!ret)
		signEntity.OnNormalCast();
	
	return ret;
}