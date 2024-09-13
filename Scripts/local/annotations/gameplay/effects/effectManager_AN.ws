@wrapMethod( W3EffectManager ) function FilterAutoBuff(out autoEffects : array<name>, regenStat : ECharacterRegenStats, effectType : EEffectType)
{
	var autoName : name;
	var effectValue, null : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(autoEffects, regenStat, effectType);
	}
	
	effectValue = owner.GetAttributeValue( RegenStatEnumToName(regenStat) );	
	spectreModRegenValue(RegenStatEnumToName(regenStat), effectValue);															  
	autoName = EffectTypeToName(effectType);		
	
	if(!autoEffects.Contains(autoName) && effectValue != null)
	{
		autoEffects.PushBack(autoName);
	}
	else if(autoEffects.Contains(autoName) && effectValue == null)
	{
		autoEffects.Remove(autoName);
	}
}

@replaceMethod( W3EffectManager ) function OnBuffAdded(effect : CBaseGameplayEffect)
{
	var signEffects : array < CBaseGameplayEffect >;
	var npcOwner : CNewNPC;
	var i, doneBuffs : int;
	var effectType : EEffectType;
	
	effectType = effect.GetEffectType();
	
	if(!hasCriticalStateSaveLock && owner == thePlayer && IsCriticalEffectType(effectType) )
	{
		 theGame.CreateNoSaveLock("critical_state", criticalStateSaveLockId);
		 hasCriticalStateSaveLock = true;
	}
	
	
	npcOwner = (CNewNPC)owner;
	if(npcOwner && (effectType == EET_Burning || effectType == EET_Bleeding || effectType == EET_Poison || effectType == EET_PoisonCritical) && !npcOwner.WasBurnedBleedingPoisoned())
	{
		if( owner.HasBuff(EET_Burning) && owner.HasBuff(EET_Bleeding) && (owner.HasBuff(EET_Poison) || owner.HasBuff(EET_PoisonCritical)) )
		{
			theGame.GetGamerProfile().IncStat(ES_BleedingBurnedPoisoned);
			npcOwner.SetBleedBurnPoison();
		}
	}
	
	
	if(owner == thePlayer && IsBuffShrine(effectType))
	{
		doneBuffs = CountShrineBuffs();
		if (doneBuffs >= 5) 
		{
			theGame.GetGamerProfile().AddAchievement(EA_PowerOverwhelming);
		}
		else
		{
			theGame.GetGamerProfile().NoticeAchievementProgress(EA_PowerOverwhelming, doneBuffs);
		}
	}
}

@wrapMethod( W3EffectManager ) function InternalAddEffect(effectType : EEffectType, creat : CGameplayEntity, srcName : string, optional inDuration : float, optional customVal : SAbilityAttributeValue, optional customAbilityName : name, optional customFXName : name, optional signEffect : bool, optional powerStatValue : SAbilityAttributeValue, optional customParams : W3BuffCustomParams, optional vibratePadLowFreq : float, optional vibratePadHighFreq : float) : EEffectInteract
{
	var effect : CBaseGameplayEffect;
	var overridenEffectsIdxs : array<int>;
	var cumulateIdx, i : int;
	var npc : CNewNPC;
	var actorCreator : CActor;
	var action : W3DamageAction;
	var hasQuen, hasAltQuen : bool;
	var damages : array<SRawDamage>;
	var forceOnNpc : bool;
	var npcStorage : CBaseAICombatStorage;
	var quen : W3QuenEntity;
	var j, focus : int;
	var woundsAll : array<EEffectType>;
	var woundsToAdd : array<EEffectType>;
	
	if(false) 
	{
		wrappedMethod(effectType, creat, srcName, inDuration, customVal, customAbilityName, customFXName, signEffect, powerStatValue, customParams, vibratePadLowFreq, vibratePadHighFreq);
	}
	
	
	if(effectType == EET_Undefined)
	{
		LogAssert(false, "EffectManager.AddEffectByType: trying to add effect of undefined type!");
		return EI_Undefined;
	}
	
	
	if(effectType == EET_Burning)
	{
		if( ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).GetSubmergeDepth() <= -1)
		{
			LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get burning effect since it's underwater!");
			return EI_Deny;
		}
	}		
	
	else if( effectType == EET_Frozen )
	{
		npc = (CNewNPC)owner;
		if ( npc )
		{
			npcStorage = (CBaseAICombatStorage)npc.GetScriptStorageObject('CombatData');
			if ( npc.IsFlying() )
			{
				LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get frozen effect since it's currently flying!");
				return EI_Deny;
			}
			else if ( npcStorage.GetIsInImportantAnim() )
			{
				LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> will not get frozen effect since it's in an uninterruptable animation!");
				return EI_Deny;
			}
		}
	}
	
	
	if( owner == thePlayer && thePlayer.HasBuff( EET_Mutagen08 ) )
	{
		if( effectType == EET_Knockdown || effectType == EET_HeavyKnockdown )
		{
			LogEffects( "EffectManager.InternalAddEffect: changing EET_Knockdown to EET_Stagger due to Mutagen 8 in effect" );
			effectType = EET_Stagger;
		}
		else if( effectType == EET_LongStagger || effectType == EET_Stagger )
		{
			LogEffects( "EffectManager.InternalAddEffect: denying " + effectType + " due to Mutagen 8 in effect" );
			return EI_Deny;
		}
	}
	
	if( owner != thePlayer && owner.HasAlternateQuen() )
	{
		if(effectType == EET_Knockdown || effectType == EET_HeavyKnockdown)
		{
			owner.FinishQuen(false);
			return EI_Deny;
		}
		else if(effectType == EET_Stagger || effectType == EET_LongStagger)
		{
			return EI_Deny;
		}
	}

	if( ((W3PlayerWitcher)owner) && ((W3PlayerWitcher)owner).IsAnyQuenActive() )
	{
		hasQuen = true;
		hasAltQuen = owner.HasAlternateQuen();
		quen = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
								   
								   
		
		if(hasAltQuen)
		{
			if(effectType == EET_Knockdown || effectType == EET_HeavyKnockdown)
			{
				quen.ShowHitFX();
				owner.FinishQuen(false);
				LogEffects("EffectManager.InternalAddEffect: Geralt has active alt quen so it breaks and we don't knockdown.");
				return EI_Deny;
			}
			else if(effectType == EET_Stagger || effectType == EET_LongStagger || effectType == EET_CounterStrikeHit)
			{
				quen.ShowHitFX();
				LogEffects("EffectManager.InternalAddEffect: Geralt has active alt quen so we don't stagger.");
				return EI_Deny;
			}
		}
		else if(effectType == EET_Stagger || effectType == EET_LongStagger || effectType == EET_CounterStrikeHit)
		{
			quen.ShowHitFX();
			owner.FinishQuen(false);
			LogEffects("EffectManager.InternalAddEffect: Geralt has active quen so it breaks and we don't stagger.");
			return EI_Deny;
		}
	}

	if( owner == thePlayer && effectType == EET_HeavyKnockdown )
	{
		effectType = EET_Knockdown;
	}
	

	if(srcName == "" && creat)
		srcName = creat.GetName();
	
	
	
	if( effectType == EET_Bleeding && (CNewNPC)owner && GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ) )
	{
		focus = (int) thePlayer.GetStat(BCS_Focus);
		
		woundsAll.PushBack( EET_Bleeding1 );
		woundsAll.PushBack( EET_Bleeding2 );
		woundsAll.PushBack( EET_Bleeding3 );
		
		if( !owner.HasBuff( EET_Bleeding ) )
		{
			
		}
		else
		{
			woundsToAdd = woundsAll;
			woundsAll.PushBack( EET_Bleeding );
			
			if( owner.HasBuff( EET_Bleeding1 ) ) { woundsToAdd.Remove( EET_Bleeding1 ); j += 1; }
			if( owner.HasBuff( EET_Bleeding2 ) ) { woundsToAdd.Remove( EET_Bleeding2 ); j += 1; }
			if( owner.HasBuff( EET_Bleeding3 ) ) { woundsToAdd.Remove( EET_Bleeding3 ); j += 1; }
			
			
			if( focus > j )
			{
				effectType = woundsToAdd[ RandRange( woundsToAdd.Size() ) ];
			}
			

			else
			{
				effectType = woundsAll[ RandRange( focus, 0 ) ];
			}
			
		}
	}
	
	if(!owner.IsAlive() && !effect.CanBeAppliedOnDeadTarget())
		return EI_Deny;
		
	actorCreator = (CActor)creat;
	
	
	if ( actorCreator.HasAbility('ForceCriticalEffectsAnim') )
	{
		forceOnNpc = true;
	}
	else if ( actorCreator.HasAbility('ForceCriticalEffectsAnimNPCOnly') && owner != thePlayer )
	{
		forceOnNpc = true;
	}
	
	if ( owner.HasTag('vampire') && effectType == EET_SilverDust )
	{
		forceOnNpc = true;
	}
	
	
	
	if(owner.IsImmuneToBuff(effectType) && !forceOnNpc && (!actorCreator.HasAbility('ForceCriticalEffects') || IsCriticalEffectType(effectType)) )
	{
		LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">> is immune to effect of this type (" + effectType + ")");
		return EI_Deny;
	}		
	
	
	if( actorCreator && GetAttitudeBetween( actorCreator, owner ) == AIA_Friendly && creat != owner && IsNegativeEffectType( effectType ) && effectType != EET_Confusion && effectType != EET_AxiiGuardMe )
	{
		LogAssert(false, "EffectManager.InternalAddEffect: unit <<" + owner + ">> is friendly to buff creator: <<" + creat + ">> negative buff cannot be added");
		return EI_Deny;
	}
	
	
	effect = theGame.effectMgr.MakeNewEffect(effectType, creat, owner, this, inDuration, srcName, powerStatValue, customVal, customAbilityName, customFXName, signEffect, vibratePadLowFreq, vibratePadHighFreq);
	
	if(effect)
	{
		if((actorCreator && 
			(((W3PlayerWitcher)owner) && 
			(effectType == EET_Stagger || effectType == EET_LongStagger)) &&
			(StrBeginsWith(actorCreator.GetName(), "q701_giant") || 
				StrBeginsWith(actorCreator.GetName(), "scolopendromorph"))) ||
			(srcName == "debuff_projectile"))
		{
			if(effectType == EET_Stagger)
			{
				theSound.TimedSoundEvent(1.5f, "start_stagger", "stop_stagger");
			}
			else if(effectType == EET_LongStagger)
			{
				theSound.TimedSoundEvent(2.f, "start_stagger", "stop_stagger");
			}
		}
		else if(((W3PlayerWitcher)owner) && actorCreator && (effectType == EET_Stagger || effectType == EET_LongStagger)) 
		{
			theSound.TimedSoundEvent(1.f, "start_small_stagger", "stop_small_stagger");
		}
		
		if( hasQuen && IsDoTEffect(effect) )
		{
			
			if(((W3PlayerWitcher)owner).IsAnyQuenActive())
			{
				quen.ShowHitFX();
				if(!hasAltQuen)
					owner.FinishQuen(false);
			}
			
			return EI_Deny;
		}
		
		if(effect.GetDurationLeft() == 0)
		{
			LogEffects("EffectManager.InternalAddEffect: unit <<" + owner + ">>: effect <<" + effectType + ">> cannot be added as its final duration is 0.");
			LogEffects("EffectManager.InternalAddEffect: this can be due to high unit's resist, which is " + NoTrailZeros(effect.GetBuffResist()*100) + "%.");
			return EI_Deny;
		}
		
		if( theGame.effectMgr.CheckInteractionWith(this, effect, effects, overridenEffectsIdxs, cumulateIdx) )
			return ApplyEffect(effect, overridenEffectsIdxs, cumulateIdx, customParams);
		else
			return EI_Deny;
	}
	
	return EI_Undefined;
}

@replaceMethod( W3EffectManager ) function AddEffectsFromAction( action : W3DamageAction ) : bool
{
	var i, size : int;
	var effectInfos : array< SEffectInfo >;
	var ret : EEffectInteract;
	var signProjectile : W3SignProjectile;
	var attackerPowerStatValue : SAbilityAttributeValue;
	var retB, applyBuff : bool;
	var signEntity : W3SignEntity;
	var canLog : bool;
	
	canLog = theGame.CanLog();
	size = action.GetEffects( effectInfos );
	signProjectile = (W3SignProjectile)action.causer;
	attackerPowerStatValue = action.GetPowerStatValue();
	retB = true;
	
	
	signEntity = (W3SignEntity)action.causer;
	if(!signEntity && signProjectile)
		signEntity = signProjectile.GetSignEntity();
		
	for( i = 0; i < size; i += 1 )
	{		
		if ( canLog )
		{
			LogDMHits("Trying to add buff <<" + effectInfos[i].effectType + ">> on target...", action);
		}
		
		
		if(signEntity)
		{
			applyBuff = GetSignApplyBuffTest(signEntity.GetSignType(), effectInfos[i].effectType, attackerPowerStatValue, signEntity.IsAlternateCast(), (CActor)action.attacker);
		}
		else
		{
			applyBuff = GetNonSignApplyBuffTest(effectInfos[i].applyChance, effectInfos[i].effectType, (CActor)action.attacker);
		}
		
		if(applyBuff)
		{
			
			ret = InternalAddEffect(effectInfos[i].effectType, action.attacker, action.GetBuffSourceName(), effectInfos[i].effectDuration, effectInfos[i].effectCustomValue, effectInfos[i].effectAbilityName, effectInfos[i].customFXName, signEntity, attackerPowerStatValue, effectInfos[i].effectCustomParam );
		}
		
		if ( theGame.CanLog() )
		{
			if(ret == EI_Undefined)
			{
				retB = false;
				LogDMHits("... not valid effect!", action);
			}
			else if(!applyBuff)
				LogDMHits("... failed randomization test.", action);
			else if(ret == EI_Deny)
				LogDMHits("... denied.", action);
			else if(ret == EI_Override)
				LogDMHits("... overriden by other effect already on target.", action);
			else if(ret == EI_Pass)
				LogDMHits("... added.", action);
			else if(ret == EI_Cumulate)
				LogDMHits("... cumulated with existing effect on target.", action);			
		}
		else
		{
			if ( ret == EI_Undefined )
			{
				retB = false;
			}
		}
		
	}
	
	return retB;
}

@replaceMethod( W3EffectManager ) function GetNonSignApplyBuffTest(applyChance : float, effectType : EEffectType, actorAttacker : CActor) : bool
{
	var resPt, resPrc, chance : float;
	var witcher : W3PlayerWitcher;
	
	if(!IsNegativeEffectType( effectType ))
		return RandF() < applyChance;
	
	owner.GetResistValue(theGame.effectMgr.GetBuffResistStat(effectType), resPt, resPrc);
	chance = MaxF(0, applyChance * (1 - resPrc));
		   
	witcher = (W3PlayerWitcher)actorAttacker;
	if(witcher && witcher.IsMutationActive(EPMT_Mutation12))
		chance *= MaxF(1.0f, 1.0f + witcher.Mutation12GetBonus());
	
	return RandF() < chance;
}

@replaceMethod( W3EffectManager ) function GetSignApplyBuffTest(signType : ESignType, effectType : EEffectType, powerStatValue : SAbilityAttributeValue, isAlternate : bool, caster : CActor) : bool
{
	var resPt, res, chance, tempF, rawChance, bonusChance : float;
	var chanceBonus : SAbilityAttributeValue;
	var witcher : W3PlayerWitcher;
	
	if(signType != ST_Igni || isAlternate)
	{
		return true;
	}
	
	owner.GetResistValue(theGame.effectMgr.GetBuffResistStat(effectType), resPt, res);

	rawChance = 0.5;
	bonusChance = 0;
	witcher = (W3PlayerWitcher)caster;
	
	if(witcher)
	{
		rawChance = CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Magic_2, 'initial_burn_chance', false, true));
		if(witcher.CanUseSkill(S_Magic_s09))
			bonusChance = CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, true)) * witcher.GetSkillLevel(S_Magic_s09);
		if(witcher.HasGlyphwordActive('Glyphword 7 _Stats'))
			bonusChance += CalculateAttributeValue(witcher.GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_burnchance_debuff'));
	}
	
	chance = MaxF(0, (rawChance + bonusChance) * (1 - res));

	if(witcher && witcher.IsMutationActive(EPMT_Mutation12))
		chance *= MaxF(1.0f, 1.0f + witcher.Mutation12GetBonus());
	
	LogEffects("Buff <<" + effectType + ">> is from sign, chance = " + NoTrailZeros(100*chance) + "%, spell_power = " + NoTrailZeros(powerStatValue.valueMultiplicative) + ", resist=" + NoTrailZeros(res));

	if(RandF() < chance)
	{
		LogEffects("Sign buff chance succeeded!");
		return true;
	}
	LogEffects("Sign buff chance failed - no effect applied");
	return false;
}

@addMethod(W3EffectManager) function PauseAllDoTEffects(sourceName : name, optional singleLock : bool, optional duration : float, optional useMaxDuration : bool)
{
	var i : int;
	var dotEffect : W3DamageOverTimeEffect;

	for(i=0; i<effects.Size(); i+=1)
	{
		dotEffect = (W3DamageOverTimeEffect)effects[i];
		if(dotEffect)
			PauseEffects(dotEffect.GetEffectType(), sourceName, singleLock, duration, useMaxDuration);
	}
}

@addMethod(W3EffectManager) function ResumeAllDoTEffects(sourceName : name)
{
	var i : int;
	var dotEffect : W3DamageOverTimeEffect;

	for(i=0; i<effects.Size(); i+=1)
	{
		dotEffect = (W3DamageOverTimeEffect)effects[i];
		if(dotEffect)
			ResumeEffects(dotEffect.GetEffectType(), sourceName);
	}
}