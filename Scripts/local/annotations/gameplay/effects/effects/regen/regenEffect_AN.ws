@wrapMethod(W3RegenEffect) function OnUpdate(dt : float)
{
	var regenPoints : float;
	var canRegen : bool;
	var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
	var pauseRegenVal, armorModVal : SAbilityAttributeValue;
	var baseStaminaRegenVal : float;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	super.OnUpdate(dt);
	
	if(stat == BCS_Vitality && isOnPlayer && target == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats'))
	{
		canRegen = true;
	}
	else
	{
		canRegen = (target.GetStatPercents(stat) < 1);
	}
	
	if(canRegen && ShouldApplyRegenEH() )//---===modBIA===---// *Thanks to skyliner390*
	{
		
		regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
		
		if(theGame.params.IsArmorRegenPenaltyEnabled())
		{
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && GetWitcherPlayer())
			{
				baseStaminaRegenVal = GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
				
				regenPoints *= 1 + baseStaminaRegenVal;
			}
		}
		
		if(!(isOnPlayer && target.HasBuff(EET_UndyingSkillImmortal)))
		{
			if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}
		}
		
		if( regenPoints > 0 )
			effectManager.CacheStatUpdate(stat, regenPoints * dt);
	}
}	

//---===modBIA===---// *Thanks to skyliner390*
@addMethod(W3RegenEffect) private function ShouldApplyRegenEH() : bool
	{
		var auto_effect : EEffectType;

		switch (effectType)
		{	case EET_AutoVitalityRegen:
			case EET_AutoStaminaRegen:
			case EET_AutoEssenceRegen:
			case EET_AutoMoraleRegen:
			case EET_AutoAirRegen:
			case EET_AutoPanicRegen:
			case EET_AutoSwimmingStaminaRegen:
				return (true);
			default:
				switch (regenStat)
				{	case CRS_Vitality:			auto_effect = EET_AutoVitalityRegen;			break ;
					case CRS_Stamina:			auto_effect = EET_AutoStaminaRegen;				break ;
					case CRS_Essence:			auto_effect = EET_AutoEssenceRegen;				break ;
					case CRS_Morale:			auto_effect = EET_AutoMoraleRegen;				break ;
					case CRS_Air:				auto_effect = EET_AutoAirRegen;					break ;
					case CRS_Panic:				auto_effect = EET_AutoPanicRegen;				break ;
					case CRS_SwimmingStamina:	auto_effect = EET_AutoSwimmingStaminaRegen;		break ;
					default:
						return (true);
				}
				return (!effectManager.HasEffect(auto_effect) );
		}
	}
	//---===modBIA===---//