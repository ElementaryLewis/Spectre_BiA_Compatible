class W3Effect_WhirlCooldown extends CBaseGameplayEffect
{
	default effectType = EET_WhirlCooldown;
	default isNegative = true;
	default dontAddAbilityOnTarget = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		if(!isOnPlayer)
			return;
		duration = theGame.params.GetMeleeSpecialCooldownDuration();
		if(setInitialDuration)
			initialDuration = duration;
	}
}