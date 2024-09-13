class W3Effect_UndyingSkillCooldown extends CBaseGameplayEffect
{
	default effectType = EET_UndyingSkillCooldown;
	default isNegative = true;
	default dontAddAbilityOnTarget = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		if(!isOnPlayer)
			return;
		duration = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s18, 'trigger_delay', false, true));
		if(setInitialDuration)
			initialDuration = duration;
	}
}