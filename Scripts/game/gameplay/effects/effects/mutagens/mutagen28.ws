/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


class W3Mutagen28_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen28;
	var dmgMult : float;
	var dmgRed : float;
	
	public function GetDmgMultiplier() : float
	{
		if(dmgMult <= 0)
		{
			dmgMult = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen28Effect', 'mutagen28_dmg_mult'));
		}
		return dmgMult;
	}
	
	public function GetDmgReduction() : float
	{
		if(dmgRed <= 0)
		{
			dmgRed = CalculateAttributeValue(thePlayer.GetAbilityAttributeValue('Mutagen28Effect', 'mutagen28_dmg_reduction'));
		}
		return dmgRed;
	}
}