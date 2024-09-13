@wrapMethod(W3Effect_KnockdownTypeApplicator) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var appliedType			: EEffectType;
	var sp, abl				: SAbilityAttributeValue;
	var params				: SCustomEffectParams;
	var witcher				: W3PlayerWitcher;
	var rawSP, aardPower	: float;
	var chance, startingChance : float;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}
	
	if(isOnPlayer)
	{
		thePlayer.OnRangedForceHolster( true, true, false );
	}

	if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)
		sp = effectValue;
	else

	rawSP = sp.valueMultiplicative;

	aardPower = SignPowerStatToPowerBonus(MaxF(0.0, rawSP - resistancePts/100));

	witcher = (W3PlayerWitcher)GetCreator();
	if(witcher)
		startingChance = CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Magic_1, 'starting_knockdown_chance', false, false));
	else
		startingChance = 0.5;
	chance = ClampF(startingChance * (1 + aardPower) * (1 - resistance), 0.1, 1.0);

	if(witcher && witcher.IsMutationActive(EPMT_Mutation12))
		chance *= MaxF(1.0f, 1.0f + witcher.Mutation12GetBonus());
	
	if(RandF() < chance)
	{
		chance = 0.15;
		if(witcher && witcher.GetCurrentlyCastSign() == ST_Aard && witcher.CanUseSkill(S_Magic_s12))
		{
			abl = witcher.GetSkillAttributeValue(S_Magic_s12, 'heavy_knockdown_chance_bonus', false, false);
			chance += abl.valueMultiplicative * witcher.GetSkillLevel(S_Magic_s12);
		}
		if(RandF() < chance)
			appliedType = EET_HeavyKnockdown;
		else
			appliedType = EET_Knockdown;
	}
	else
	{
		chance = 0.66;

		if(RandF() < chance)
			appliedType = EET_LongStagger;
		else
			appliedType = EET_Stagger;
	}

	appliedType = ModifyKnockdownSeverity(target, GetCreator(), appliedType);

	params.effectType = appliedType;
	params.creator = GetCreator();
	params.sourceName = sourceName;
	params.isSignEffect = isSignEffect;
	params.customPowerStatValue = creatorPowerStat;
	params.customAbilityName = customAbilityName;
	params.duration = customDuration;
	params.effectValue = customEffectValue;	
	
	target.AddEffectCustom(params);
	
	isActive = true;
	duration = 0;
}