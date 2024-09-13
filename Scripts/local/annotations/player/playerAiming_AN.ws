function modSpectreSloMo(speed: float, owner : CR4Player, aimType: EAimType)
{
	var min, max : SAbilityAttributeValue;
	
	if (!(owner))
		return;

	if (aimType == AT_Bolt && owner.CanUseSkill(S_Sword_s13) )
		speed -= CalculateAttributeValue( ((CR4Player)owner).GetSkillAttributeValue(S_Sword_s13, 'slowdown_mod', false, true) ) * owner.GetSkillLevel(S_Sword_s13);
	else if (aimType == AT_Bomb && owner.CanUseSkill(S_Alchemy_s09) )
		speed -= CalculateAttributeValue( ((CR4Player)owner).GetSkillAttributeValue(S_Alchemy_s09, 'slowdown_mod', false, true) ) * owner.GetSkillLevel(S_Alchemy_s09);
	
	if( ((W3PlayerWitcher)owner) && aimType == AT_Bolt && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && GetWitcherPlayer().GetStat(BCS_Toxicity, false) > 0 )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'mut9_slowdown', min, max);
		speed -= min.valueAdditive;
	}
	
	speed = MaxF(speed, 0.1);
	
		theSound.SoundEvent( "gui_slowmo_start" );

	theGame.SetTimeScale(speed, theGame.GetTimescaleSource(ETS_ThrowingAim), theGame.GetTimescalePriority(ETS_ThrowingAim), false );	
}