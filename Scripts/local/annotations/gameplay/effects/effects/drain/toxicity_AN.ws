@addField(W3Effect_Toxicity)
private var mutation4factor				: float;

@addField(W3Effect_Toxicity)
private var playerHadQuen : bool;

@wrapMethod(W3Effect_Toxicity) function OnUpdate(deltaTime : float)
{
	var min, max : SAbilityAttributeValue;
	var dmg, toxicity, threshold, drainVal : float;
	var currentStateName 	: name;
	var currentThreshold	: int;
	
	if(false) 
	{
		wrappedMethod(deltaTime);
	}

	super.OnUpdate(deltaTime);
	
	toxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false) / GetWitcherPlayer().GetStatMax(BCS_Toxicity);
	threshold = GetWitcherPlayer().GetToxicityDamageThreshold();
	
	if( toxicity >= threshold && !isPlayingCameraEffect)
		switchCameraEffect = true;
	else if(toxicity < threshold && isPlayingCameraEffect)
		switchCameraEffect = true;

	if( delayToNextVFXUpdate <= 0 )
	{		
		UpdateHeadEffect(toxThresholdEffect, ToxPrc2EffectIdx(toxicity), GetWitcherPlayer().IsAnyQuenActive() || playerHadQuen);
		delayToNextVFXUpdate = 2;
		playerHadQuen = GetWitcherPlayer().IsAnyQuenActive();
	}
	else
	{
		delayToNextVFXUpdate -= deltaTime;
	}
			
	if(toxicity >= threshold)
	{
		currentStateName = thePlayer.GetCurrentStateName();
		if(currentStateName != 'Meditation' && currentStateName != 'MeditationWaiting')
		{
			dmg = GetWitcherPlayer().GetToxicityDamage();
			dmg = MaxF(0, deltaTime * dmg);
			
			if(dmg > 0)
				effectManager.CacheDamage(dmgTypeName,dmg,NULL,this,deltaTime,true,CPS_Undefined,false);
			else
				LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
		}
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain))
			target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');

		if(thePlayer.CanUseSkill(S_Alchemy_s16) && !thePlayer.HasAbility(SkillEnumToName(S_Alchemy_s16)))
			thePlayer.AddAbilityMultiple(SkillEnumToName(S_Alchemy_s16), thePlayer.GetSkillLevel(S_Alchemy_s16));

		if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation10) && !thePlayer.HasBuff(EET_Mutation10) && thePlayer.IsInCombat())
			thePlayer.AddEffectDefault(EET_Mutation10, NULL, "Mutation 10");
	}
	else
	{
		
		target.RemoveBuff(EET_IgnorePain);
		
		thePlayer.RemoveAbilityAll(SkillEnumToName(S_Alchemy_s16));

		thePlayer.RemoveBuff(EET_Mutation10);
	}
		
	if(GetWitcherPlayer().GetStat(BCS_Toxicity, true) > 0)
	{
		drainVal = deltaTime * (effectValue.valueAdditive + (effectValue.valueMultiplicative * (effectValue.valueBase + target.GetStatMax(BCS_Toxicity)) ) );
		
	
		if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation4))
		{
			if(mutation4factor <= 0)
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation4', 'toxicityRegenFactor', min, max);
				mutation4factor = min.valueAdditive;
			}
			drainVal *= MaxF(0.01, 1 - mutation4factor);
		}
		
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
	}
}

@addMethod(W3Effect_Toxicity) function ToxPrc2EffectIdx(toxPrc : float) : int
{
	if(toxPrc < 0.25f)		return 0;
	else if(toxPrc < 0.5f)	return 1;
	else if(toxPrc < 0.75f)	return 2;
	else					return 3;
}

@addMethod(W3Effect_Toxicity) function EffectIdx2EffectName(effectIdx : int) : name
{
	switch(effectIdx)
	{
		case 0: return 'toxic_000_025';
		case 1: return 'toxic_025_050';
		case 2: return 'toxic_050_075';
		case 3: return 'toxic_075_100';
	}
	return '';
}

@addMethod(W3Effect_Toxicity) function UpdateHeadEffect( prevEffectIdx : int, nextEffectIdx : int, forceUpdate : bool )
{
	var prevEffect, nextEffect : name;
	
	if(target.IsEffectActive('invisible') || (prevEffectIdx == nextEffectIdx && !forceUpdate))
		return;
	
	prevEffect = EffectIdx2EffectName(prevEffectIdx);
	nextEffect = EffectIdx2EffectName(nextEffectIdx);

	if(prevEffect != '') PlayHeadEffect(prevEffect, true);
	if(nextEffect != '') PlayHeadEffect(nextEffect);
	
	toxThresholdEffect = nextEffectIdx;
}

@wrapMethod(W3Effect_Toxicity) function OnEffectRemoved()
{
	if(false) 
	{
		wrappedMethod();
	}

	super.OnEffectRemoved();
	
	if(target.HasBuff(EET_IgnorePain))
		target.RemoveBuff(EET_IgnorePain);

	if(thePlayer.HasAbility(SkillEnumToName(S_Alchemy_s16)))
		thePlayer.RemoveAbilityAll(SkillEnumToName(S_Alchemy_s16));
		
	PlayHeadEffect( 'toxic_000_025', true );
	PlayHeadEffect( 'toxic_025_050', true );
	PlayHeadEffect( 'toxic_050_075', true );
	PlayHeadEffect( 'toxic_075_100', true );
	
	PlayHeadEffect( 'toxic_025_000', true );
	PlayHeadEffect( 'toxic_050_025', true );
	PlayHeadEffect( 'toxic_075_050', true );
	PlayHeadEffect( 'toxic_100_075', true );
	
	toxThresholdEffect = 0;
}

@wrapMethod(W3Effect_Toxicity) function RecalcEffectValue()
{
	var min, max : SAbilityAttributeValue;
	var dm : CDefinitionsManagerAccessor;
	
	wrappedMethod();
	
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
	effectValue = GetAttributeRandomizedValue(min, max);

	if(thePlayer.HasAbility('ArmorTypeMediumSetBonusAbility'))
	{
		dm.GetAbilityAttributeValue('ArmorTypeMediumSetBonusAbility', 'toxicityRegen', min, max);
		effectValue += min;
	}
}