@addField(W3Effect_AutoVitalityRegen)
private var wasLoaded : bool;

@wrapMethod(W3Effect_AutoVitalityRegen) function OnLoad(t : CActor, eff : W3EffectManager)
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

@wrapMethod(W3Effect_AutoVitalityRegen) function OnUpdate(deltaTime : float)
{
	if(false) 
	{
		wrappedMethod(deltaTime);
	}
	
	if(wasLoaded)
	{
		SetEffectValue();
		wasLoaded = false;
	}
	
	if(isOnPlayer)
	{
		
		regenModeIsCombat = cachedPlayer.IsInCombat();
		if(regenModeIsCombat)
			attributeName = 'vitalityCombatRegen';
		else
			attributeName = RegenStatEnumToName(regenStat);
			
		SetEffectValue();
	}
	
	super.OnUpdate(deltaTime);
	
	if( target.GetStatPercents( BCS_Vitality ) >= 1.0f && !((W3PlayerWitcher)target).HasRunewordActive('Runeword 4 _Stats'))
	{
		target.StopVitalityRegen();
	}
}

@wrapMethod(W3Effect_AutoVitalityRegen) function SetEffectValue()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	effectValue = target.GetAttributeValue(attributeName);
	if(isOnPlayer && GetWitcherPlayer())
		spectreModRegenValue(attributeName, effectValue);
}