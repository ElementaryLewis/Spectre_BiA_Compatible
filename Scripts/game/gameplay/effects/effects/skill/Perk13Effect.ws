/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_Perk13Effect extends CBaseGameplayEffect //modSpectre
{
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default effectType = EET_Perk13Effect;
	default dontAddAbilityOnTarget = true;
}