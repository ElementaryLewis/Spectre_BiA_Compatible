@addField(W3BlindnessEffect)
private var critBonus : float;

@addMethod(W3BlindnessEffect) function GetCritChanceBonus() : float
{
	return critBonus;
}

@addMethod(W3BlindnessEffect) function CacheCritChanceBonus()
{
	var dm : CDefinitionsManagerAccessor;
	var min, max : SAbilityAttributeValue;
	
	dm = theGame.GetDefinitionsManager();		
	dm.GetAbilityAttributeValue(abilityName, 'critical_hit_chance', min, max);
	critBonus = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
}

@wrapMethod(W3BlindnessEffect) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	if(false) 
	{
		wrappedMethod(customParams);
	}
	
	dontAddAbilityOnTarget = true;
	
	super.OnEffectAdded(customParams);
	
	CacheCritChanceBonus();
	
	if(isOnPlayer)
	{
		thePlayer.HardLockToTarget( false );
	}
}