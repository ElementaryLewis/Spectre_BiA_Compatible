/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends CBaseGameplayEffect
{
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	private var dmgBonus : float;
	private var lastPlayedTime : float;
	
	public function SetDmgBonus(b : float)
	{
		dmgBonus = b;
	}
	
	public function GetDmgBonus() : float
	{
		return dmgBonus;
	}
	
	public function PlayFX()
	{
		if(theGame.GetEngineTimeAsSeconds() - lastPlayedTime > 1.f)
		{
			target.PlayEffect('yrden_shock');
			lastPlayedTime = theGame.GetEngineTimeAsSeconds();
		}
	}
}