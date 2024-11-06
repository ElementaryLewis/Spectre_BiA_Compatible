function ModifyKnockdownSeverity(target : CActor, attacker : CGameplayEntity, type : EEffectType) : EEffectType
{
	var severityReduction, severity : int;
	var npcTarget : CNewNPC;
	var witcherTarget, witcherAttacker : W3PlayerWitcher;

	npcTarget = (CNewNPC)target;
	witcherTarget = (W3PlayerWitcher)target;

	if(target.HasAbility('WeakToAard') || (npcTarget && npcTarget.IsFlying()))
	{
		if((W3MonsterHuntNPC)npcTarget)
			return EET_Knockdown;
		else
			return EET_HeavyKnockdown;
	}
	
	switch(type)
	{
		case EET_HeavyKnockdown : 	severity = 4; break;
		case EET_Knockdown :		severity = 3; break;
		case EET_LongStagger : 		severity = 2; break;
		case EET_Stagger :			severity = 1; break;
		default :					return EET_Undefined;
	}

	if(target.GetStaminaPercents() < 0.3)
	{
		severity += 1;
		if( target.GetStaminaPercents() < 0.1 )
		{
			severity += 1;
		}
	}

	if(npcTarget && npcTarget.IsShielded(attacker) && severity > 2)
	{
		severity -= 2;
	}

	if(target.HasAbility('mon_type_huge') && severity > 2)
	{
		severity -= 2;
	}

	if(severity >= 4 && target.IsImmuneToBuff(EET_HeavyKnockdown))		severity = 3;
	if(severity == 3 && target.IsImmuneToBuff(EET_Knockdown))			severity = 2;
	if(severity == 2 && target.IsImmuneToBuff(EET_LongStagger))			severity = 1;
	if(severity == 1 && target.IsImmuneToBuff(EET_Stagger))				severity = 0;

	if((W3MonsterHuntNPC)target && severity >= 4)
		severity = 3;

	if(severity >= 4)
		return EET_HeavyKnockdown;
	else if(severity == 3)
		return EET_Knockdown;
	else if(severity == 2)
		return EET_LongStagger;
	else if(severity == 1)
		return EET_Stagger;
	else
		return EET_Undefined;
}