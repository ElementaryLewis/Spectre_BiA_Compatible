@addField(W3Effect_AutoStaminaRegen)
private var wasLoaded : bool;

@wrapMethod(W3Effect_AutoStaminaRegen) function OnLoad(t : CActor, eff : W3EffectManager)
{
	if(false) 
	{
		wrappedMethod(t, eff);
	}

	super.OnLoad(t, eff);
	if(isOnPlayer)
		cachedPlayer = (CR4Player)target;
	wasLoaded = true;
}

@wrapMethod(W3Effect_AutoStaminaRegen) function OnUpdate(dt : float)
{
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	if(wasLoaded)
	{
		SetEffectValue();
		wasLoaded = false;
	}
	
	if(isOnPlayer)
	{
		
		if ( regenModeIsCombat != cachedPlayer.IsInCombat() )
		{
			regenModeIsCombat = !regenModeIsCombat;
			if(regenModeIsCombat)
				attributeName = RegenStatEnumToName(regenStat);
			else
				attributeName = 'staminaOutOfCombatRegen';
				
			SetEffectValue();			
		}
		
		
		if ( cachedPlayer.IsInCombat() )
		{
			attributeName = RegenStatEnumToName(regenStat);
			SetEffectValue();
		}
	}
	
	super.OnUpdate( dt );
	
	if( isOnPlayer )
	{
		((CR4Player)target).CheckForLowStamina();
	}
	else
	{
		target.CheckShouldWaitForStaminaRegen();
	}
	
	if( target.GetStatPercents( BCS_Stamina ) >= 1.0f )
	{
		target.StopStaminaRegen();
	}
}

@wrapMethod(W3Effect_AutoStaminaRegen) function SetEffectValue()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	effectValue = target.GetAttributeValue(attributeName);
	if(isOnPlayer && GetWitcherPlayer())
	{
		spectreModRegenValue(attributeName, effectValue);
		if(GetWitcherPlayer().IsGuarded())
		{
			effectValue.valueAdditive *= 0.5;
			effectValue.valueMultiplicative *= 0.5;
		}
	}
}