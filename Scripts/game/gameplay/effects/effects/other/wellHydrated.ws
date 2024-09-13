/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class W3Effect_WellHydrated extends CBaseGameplayEffect
{
	private var level : int;

	default effectType = EET_WellHydrated;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
	}

	//modSpectre
	event OnPerk15Unequipped()
	{
		var timeLeftPrc : float; //modSpectre
		
		timeLeftPrc = timeLeft / duration; //modSpectre
		SetTimeLeft( initialDuration * timeLeftPrc ); //modSpectre
		duration = initialDuration;
	}
	
	//modSpectre
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		if( isOnPlayer && GetWitcherPlayer() )
		{	
			
			//modSpectre
			if( sourceName == "alcohol" && GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
			{
				min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration_bonus', false, false );
				duration *= 1 + min.valueMultiplicative;
			}
			if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
				duration *= 1 + min.valueMultiplicative;
			}
		}
	}
	
	//modSpectre
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		var dm : CDefinitionsManagerAccessor;
		var thisLevel, otherLevel : int;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		eff = (W3Effect_WellFed)e;
		dm.GetAbilityAttributeValue(abilityName, 'level', min, max);
		thisLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		dm.GetAbilityAttributeValue(eff.abilityName, 'level', min, max);
		otherLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		
		if(otherLevel >= thisLevel)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
	
	protected function SetEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		
		super.SetEffectValue();
		
		if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
			effectValue.valueAdditive *= ( 1 + min.valueMultiplicative );
		}
		
	}
	
}