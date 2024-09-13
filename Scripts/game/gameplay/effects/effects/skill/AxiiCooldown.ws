class W3Effect_AxiiCooldown extends CBaseGameplayEffect
{
	default effectType = EET_AxiiCooldown;
	default isNegative = true;
	default dontAddAbilityOnTarget = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		if(!isOnPlayer)
			return;
		if(sourceName == "alt_cast")
			duration = theGame.params.GetAltSignCooldownDuration();
		else
			duration = theGame.params.GetSignCooldownDuration();
		if(setInitialDuration)
			initialDuration = duration;
	}
}