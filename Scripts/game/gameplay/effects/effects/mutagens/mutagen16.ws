/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen16_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen16;

	var healthPrc : float;
	
	public function Mutagen16ModifyHitAnim(out action : W3DamageAction)
	{
		if(action.IsDoTDamage())
			return;

		if(healthPrc <= 0)
		{
			healthPrc = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen16Effect', 'mutagen16_health_prc'));
		}
		
		if(action.GetDamageDealt() <= healthPrc * target.GetMaxHealth())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
	}
}