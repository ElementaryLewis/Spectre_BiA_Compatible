@wrapMethod( Crossbow ) function PlayOwnerReloadAnim() : bool
{
	var shouldPlayAnim : bool;

	if(false)
	{
		wrappedMethod();
	}

	if (ownerPlayerWitcher.GetSkillLevel(S_Sword_s15) >= 10)
	{
		return false;
	}
		
	if(ownerPlayerWitcher.CanUseSkill(S_Perk_17) && shotCount >= (1 + shotCountLimit) )
		shouldPlayAnim = true;
	else if (!ownerPlayerWitcher.CanUseSkill(S_Perk_17) && shotCount >= shotCountLimit )
		shouldPlayAnim = true;
	else if ( previousAmmoItemName != 'Bodkin Bolt' && previousAmmoItemName != 'Harpoon Bolt' && GetSpecialAmmoCount() <= 0 )
		shouldPlayAnim = true;
	else if ( previousAmmoItemName == '' )
		shouldPlayAnim = true;
	else
		shouldPlayAnim = false;
	
	if ( shouldPlayAnim )
	{
		SetBehaviorGraphVariables( 'isWeaponLoaded', false );
		return true;	
	}
	else
		return false;
}