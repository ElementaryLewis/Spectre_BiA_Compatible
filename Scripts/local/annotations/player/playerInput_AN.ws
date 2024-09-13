@wrapMethod(CPlayerInput) function OnSelectSign(action : SInputAction)
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if( IsPressed( action ) )
	{
		
		if(altSignCasting)
		{
			switch( action.aName )
			{				
				case 'SelectAard' :
					AltCastSign(ST_Aard);
					break;
				case 'SelectYrden' :
					AltCastSign(ST_Yrden);
					break;
				case 'SelectIgni' :
					AltCastSign(ST_Igni);
					break;
				case 'SelectQuen' :
					AltCastSign(ST_Quen);
					break;
				case 'SelectAxii' :
					AltCastSign(ST_Axii);
					break;
				default :
					break;
			}
		}
		
		else
		{
			switch( action.aName )
			{
				case 'SelectAard' :
					GetWitcherPlayer().SetEquippedSign(ST_Aard);
					break;
				case 'SelectYrden' :
					GetWitcherPlayer().SetEquippedSign(ST_Yrden);
					break;
				case 'SelectIgni' :
					GetWitcherPlayer().SetEquippedSign(ST_Igni);
					break;
				case 'SelectQuen' :
					GetWitcherPlayer().SetEquippedSign(ST_Quen);
					break;
				case 'SelectAxii' :
					GetWitcherPlayer().SetEquippedSign(ST_Axii);
					break;
				default :
					break;
			}
			if( spectreInstantCastingAllowed() )
			{
				thePlayer.SetCastSignHoldTimestamp( theGame.GetEngineTimeAsSeconds() );
				return CastSign();
			}
		}
	}
	
	else if (IsReleased( action ) && altSignCasting && GetWitcherPlayer().IsCurrentSignChanneled())
	{
		thePlayer.AbortSign();
	}
	
}

@wrapMethod(CPlayerInput) function OnCbtSpecialAttackLight( action : SInputAction )
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if(!theInput.LastUsedPCInput() && IsPressed( action ) && theInput.GetActionValue( 'CastSign' ) > 0)
	{
		return false;
	}
	

	if ( IsReleased( action )  )
	{
		thePlayer.CancelHoldAttacks();
		return true;
	}
	if(thePlayer.HasBuff(EET_WhirlCooldown))
	{
		thePlayer.SoundEvent("gui_no_adrenaline");
		return false;
	}
	
	if ( !IsPlayerAbleToPerformSpecialAttack() )
		return false;
	
	if( !IsActionAllowed(EIAB_LightAttacks) ) 
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_LightAttacks);
		return false;
	}
	if(!IsActionAllowed(EIAB_SpecialAttackLight) )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackLight);
		return false;
	}
	
	if( IsPressed(action) && thePlayer.CanUseSkill(S_Sword_s01) )	
	{			
		thePlayer.PrepareToAttack();
		thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
		thePlayer.AddTimer( 'IsSpecialLightAttackInputHeld', 0.00001, true );
	}
}

@wrapMethod(CPlayerInput) function OnCbtSpecialAttackHeavy( action : SInputAction )
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if(!theInput.LastUsedPCInput() && IsPressed( action ) && theInput.GetActionValue( 'CastSign' ) > 0)
	{
		return false;
	}
	

	if ( IsReleased( action )  )
	{
		thePlayer.CancelHoldAttacks();
		return true;
	}
	
	if(thePlayer.HasBuff(EET_RendCooldown))
	{
		thePlayer.SoundEvent("gui_no_adrenaline");
		return false;
	}
	
	if ( !IsPlayerAbleToPerformSpecialAttack() || GetWitcherPlayer().IsInCombatAction_SpecialAttackHeavy() ) 
		return false;
	
	if( !IsActionAllowed(EIAB_HeavyAttacks))
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_HeavyAttacks);
		return false;
	}		
	if(!IsActionAllowed(EIAB_SpecialAttackHeavy))
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_SpecialAttackHeavy);
		return false;
	}
	
	if( IsPressed(action) && thePlayer.CanUseSkill(S_Sword_s02) )	
	{	
		thePlayer.PrepareToAttack();
		thePlayer.SetPlayedSpecialAttackMissingResourceSound(false);
		thePlayer.AddTimer( 'IsSpecialHeavyAttackInputHeld', 0.00001, true );
	}
	else if ( IsPressed(action) )
	{
		if ( theInput.IsActionPressed('AttackHeavy') )
			theInput.ForceDeactivateAction('AttackHeavy');
		else if ( theInput.IsActionPressed('AttackWithAlternateHeavy') )
			theInput.ForceDeactivateAction('AttackWithAlternateHeavy');
	}
}

@wrapMethod(CPlayerInput) function AltCastSign(signType : ESignType)
{
	var signSkill : ESkill;	
	
	if(false) 
	{
		wrappedMethod(signType);
	}
	
	if( !thePlayer.GetBIsInputAllowed() )
	{	
		return;
	}

	if( !IsActionAllowed(EIAB_Signs) || GetWitcherPlayer().IsSignBlocked(signType) )
	{				
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs);
		return;
	}
	if ( thePlayer.IsHoldingItemInLHand() && thePlayer.IsUsableItemLBlocked() )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
		return;
	}

	if(IsSignOnCooldown(thePlayer.GetEquippedSign()))
	{
		thePlayer.SoundEvent("gui_no_adrenaline");
		return;
	}

	signSkill = SignEnumToSkillEnum(signType);
	if( signSkill != S_SUndefined )
	{
		if(!thePlayer.CanUseSkill(signSkill))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs, false, false, true);
			return;
		}
	
		if( thePlayer.HasStaminaToUseSkill( signSkill, false ) )
		{
			GetWitcherPlayer().SetEquippedSign(signType);				
			thePlayer.SetupCombatAction( EBAT_CastSign, BS_Pressed );
		}
		else
		{
			thePlayer.SoundEvent("gui_no_stamina");
		}
	}
}

@wrapMethod(CPlayerInput) function OnCastSign( action : SInputAction )
{
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if( !thePlayer.GetBIsInputAllowed() )
	{	
		return false;
	}
	
	if( IsPressed(action) )
	{
		return CastSign();
	}
}

@addMethod(CPlayerInput) function CastSign() : bool
{
	var signSkill : ESkill;
	
	if( GetWitcherPlayer().IsInCombatAction() && thePlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_CastSign )
	{
		return false;
	}

	if( !IsActionAllowed(EIAB_Signs) )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs);
		return false;
	}
	if ( thePlayer.IsHoldingItemInLHand() && thePlayer.IsUsableItemLBlocked() )
	{
		thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
		return false;
	}

	signSkill = SignEnumToSkillEnum( thePlayer.GetEquippedSign() );
	if( signSkill != S_SUndefined )
	{
		if(!thePlayer.CanUseSkill(signSkill))
		{
			thePlayer.DisplayActionDisallowedHudMessage(EIAB_Signs, false, false, true);
			return false;
		}

		if(IsSignOnCooldown(thePlayer.GetEquippedSign()))
		{
			thePlayer.SoundEvent("gui_no_adrenaline");
			return false;
		}
	
		if( thePlayer.HasStaminaToUseSkill( signSkill, false ) )
		{
			thePlayer.SetupCombatAction( EBAT_CastSign, BS_Pressed );
		}
		else
		{
			thePlayer.SoundEvent("gui_no_stamina");
		}
	}
	return true;
}

@addMethod(CPlayerInput) function IsSignOnCooldown(signType : ESignType) : bool
{
	switch(signType)
	{
		case ST_Aard: 	return thePlayer.HasBuff(EET_AardCooldown);
		case ST_Igni: 	return thePlayer.HasBuff(EET_IgniCooldown);
		case ST_Yrden: 	return thePlayer.HasBuff(EET_YrdenCooldown);
		case ST_Quen: 	return thePlayer.HasBuff(EET_QuenCooldown);
		case ST_Axii: 	return thePlayer.HasBuff(EET_AxiiCooldown);
		default:		return true;
	}
	return true;
}

@wrapMethod(CPlayerInput) function OnThrowBomb(action : SInputAction)
{
	var selectedItemId : SItemUniqueId;
	
	selectedItemId = thePlayer.GetSelectedItemId();
	if(!thePlayer.inv.IsItemBomb(selectedItemId))
		return false;
	
	if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 || !thePlayer.HasStaminaToUseAction(ESAT_UsableItem) )
	{
		
		if(IsPressed(action))
		{			
			thePlayer.SoundEvent( "gui_ingame_low_stamina_warning" );
		}
		
		return false;
	}
	
	wrappedMethod(action);
	
	return false;
}

@wrapMethod(CPlayerInput) function OnThrowBombHold(action : SInputAction)
{
	var selectedItemId : SItemUniqueId;
	
	selectedItemId = thePlayer.GetSelectedItemId();
	if(!thePlayer.inv.IsItemBomb(selectedItemId))
		return false;
	
	if( thePlayer.inv.SingletonItemGetAmmo(selectedItemId) == 0 || !thePlayer.HasStaminaToUseAction(ESAT_UsableItem) )
	{
		return false;
	}
	
	wrappedMethod(action);
		
	return false;
}

@wrapMethod(CPlayerInput) function OnCbtThrowItem( action : SInputAction )
{	
	if(!thePlayer.HasStaminaToUseAction(ESAT_UsableItem))
	{
		return false;
	}	
	
	wrappedMethod(action);
	
	return false;
}