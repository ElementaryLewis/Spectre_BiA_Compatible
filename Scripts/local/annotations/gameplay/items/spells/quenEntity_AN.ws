@addField(W3QuenEntity)
protected var dmgAbsorptionPrc	: float;
@addField(W3QuenEntity)
protected var impulseLevel		: int;
@addField(W3QuenEntity)
protected var quenPower			: SAbilityAttributeValue;
@addField(W3QuenEntity)
protected var healingFactor		: float;
@addField(W3QuenEntity)
public var freeCast	: bool;
@addField(W3QuenEntity)
public var glyphword17Cast : bool;

@addMethod(W3QuenEntity) function ShowHitFX(optional damageData : W3DamageAction)
{

}

@wrapMethod(W3QuenEntity) function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
{
	var oldQuen : W3QuenEntity;
	
	if(false) 
	{
		wrappedMethod(inOwner, prevInstance, skipCastingAnimation, notPlayerCast );
	}
	
	ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'pelvis' );
	if(ownerBoneIndex == -1)
		ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'k_pelvis_g' );
		
	oldQuen = (W3QuenEntity)prevInstance;
	if(oldQuen)
		oldQuen.OnSignAborted(true);
	
	hitEntityTimestamps.Clear();
	
	return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast );
}

@replaceMethod(W3QuenEntity) function GetSignStats()
{
	var skillBonus : float;
	var min, max : SAbilityAttributeValue;
	
	super.GetSignStats();
	
	quenPower = owner.GetActor().GetTotalSignSpellPower(S_Magic_4);
	
	if(owner.GetActor() == GetWitcherPlayer() && owner.GetActor().HasBuff(EET_Mutagen19))
		quenPower += ((W3Mutagen19_Effect)owner.GetActor().GetBuff(EET_Mutagen19)).GetQuenPowerBonus();
	
	if(glyphword17Cast)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 17 _Stats', 'glyphword17_quen_buff', min, max);
		quenPower.valueMultiplicative += CalculateAttributeValue(min);
		glyphword17Cast = false;
	}

	if( owner.CanUseSkill(S_Magic_s13) )
		impulseLevel = owner.GetSkillLevel(S_Magic_s13);
	else
		impulseLevel = 0;
	
	dmgAbsorptionPrc = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'max_dmg_absorption', false, false));
	
	shieldDuration = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
	if(owner.GetPlayer() && owner.GetPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
	{
		shieldDuration *= 1.34;
	}
	shieldHealth = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_health', false, true));

	if( owner.CanUseSkill(S_Magic_s14) )
	{			
		dischargePercent = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s14, 'discharge_percent', false, true)) * owner.GetSkillLevel(S_Magic_s14);
		if( owner.GetPlayer().HasGlyphwordActive( 'Glyphword 5 _Stats' ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Glyphword 5 _Stats', 'glyphword5_dmg_boost', min, max );
			dischargePercent *= 1 + min.valueMultiplicative;
		}
	}
	else
	{
		dischargePercent = 0;
	}

	if( owner.CanUseSkill(S_Magic_s15) )
		skillBonus = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s15, 'shield_health_bonus', false, true)) * owner.GetSkillLevel(S_Magic_s15);
	else
		skillBonus = 0;
	
	shieldHealth += skillBonus;
	shieldHealth *= 1 + SignPowerStatToPowerBonus(quenPower.valueMultiplicative);

	initialShieldHealth = shieldHealth;
	
	if( owner.CanUseSkill(S_Magic_s04) )
		healingFactor = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s04, 'shield_healing_factor', false, true)) * owner.GetSkillLevel(S_Magic_s04);
	else
		healingFactor = 0;
}

@wrapMethod(W3QuenEntity) function AddBuffImmunities()
{
	if(false) 
	{
		wrappedMethod();
	}
}

@wrapMethod(W3QuenEntity) function OnStarted() 
{
	var isAlternate		: bool;
	var witcherOwner	: W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	owner.ChangeAspect( this, S_Magic_s04 );
	isAlternate = IsAlternateCast();
	witcherOwner = owner.GetPlayer();
	
	if(isAlternate)
	{
		
		CreateAttachment( owner.GetActor(), 'quen_sphere' );
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
	}
	else
	{
		super.OnStarted();
	}
	
	
	if(owner.GetActor() == thePlayer && ShouldProcessTutorial('TutorialSelectQuen'))
	{
		FactsAdd("tutorial_quen_cast");
	}
	
	if((CPlayer)owner.GetActor())
		GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			
	if( isAlternate || !owner.IsPlayer() )
	{
		if( owner.IsPlayer() && GetWitcherPlayer().HasBuff( EET_Mutation11Immortal ) )
		{
			PlayEffect( 'quen_second_life' );
		}
		else
		{
			PlayEffect( effects[1].castEffect );
		}
		
		if( witcherOwner && dischargePercent > 0 )
			PlayEffect( 'default_fx_bear_abl2' );
		
		CacheActionBuffsFromSkill();
		GotoState( 'QuenChanneled' );
	}
	else
	{
		PlayEffect( effects[0].castEffect );
		GotoState( 'QuenShield' );
	}
}

@wrapMethod(W3QuenEntity) function SetDataFromRestore(health : float, duration : float)
{
	if(false) 
	{
		wrappedMethod(health, duration);
	}
	
	shieldHealth = health;
	shieldDuration = duration;
	if( shieldHealth > initialShieldHealth )
		initialShieldHealth = shieldHealth;
	shieldStartTime = theGame.GetEngineTime();
	AddTimer('Expire', shieldDuration, false, , , true, true);
}

@wrapMethod(W3QuenEntity) function ForceFinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
{
	var min, max : SAbilityAttributeValue;
	var player : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod(skipVisuals, forceNoBearSetBonus);
	}
	
	player = owner.GetPlayer();
	
	if(IsAlternateCast())
	{
		OnEnded();
		
		if(!skipVisuals)
			owner.GetActor().PlayEffect('hit_electric_quen');
	}
	else
	{
		showForceFinishedFX = !skipVisuals;
		GotoState('Expired');
	}
}

@wrapMethod(ShieldActive) function GetLastingFxName() : name
{
	var sp : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	sp = parent.quenPower.valueMultiplicative - 1;
	if(sp >= 1.5)
		return parent.effects[0].lastingEffectUpg3;
	if(sp >= 1.0)
		return parent.effects[0].lastingEffectUpg2;
	else if(sp >= 0.5)
		return parent.effects[0].lastingEffectUpg1;
	else
		return parent.effects[0].lastingEffectUpgNone;
}

@wrapMethod(ShieldActive) function OnEnterState( prevStateName : name )
{
	var witcher			: W3PlayerWitcher;
	var params 			: SCustomEffectParams;
	
	if(false) 
	{
		wrappedMethod(prevStateName);
	}
	
	super.OnEnterState( prevStateName );
	
	witcher = (W3PlayerWitcher)caster.GetActor();
	
	if(witcher)
	{
		witcher.SetUsedQuenInCombat();

		params.effectType = EET_BasicQuen;
		params.creator = witcher;
		params.sourceName = "sign cast";
		params.duration = parent.shieldDuration;
		
		witcher.AddEffectCustom( params );
	}
	
	caster.GetActor().PlayEffect(GetLastingFxName());
	
	parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
	
	parent.AddBuffImmunities();
	
	if( ( !witcher.HasBuff( EET_HeavyKnockdown ) && !witcher.HasBuff( EET_Knockdown ) ) )
	{
		witcher.CriticalEffectAnimationInterrupted("basic quen cast");
	}
	
	
	witcher.AddTimer('HACK_QuenSaveStatus', 0, true);
	parent.shieldStartTime = theGame.GetEngineTime();
}

@addMethod(ShieldActive) function ShowHitFX(optional damageData : W3DamageAction)
{
	parent.owner.GetActor().PlayEffect('quen_lasting_shield_hit');
	GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
	theGame.VibrateControllerHard();
}

@wrapMethod(ShieldActive) function OnTargetHit( out damageData : W3DamageAction )
{
	var inAttackAction : W3Action_Attack;
	var casterActor : CActor;
	var damageTypes : array<SRawDamage>;
	var reducedDamage, totalDamage : float;
	var i, size : int;
	var dmgVal : float;
	var dmgType : name;
	var returnedDmgAction : W3DamageAction;
	
	if(false) 
	{
		wrappedMethod(damageData);
	}
	
	if(damageData.GetBuffSourceName() == "FallingDamage")
		return true;

	if(damageData.IsDoTDamage() && (CBaseGameplayEffect)damageData.causer)
		return true;

	if(damageData.WasDodged())
		return true;

	inAttackAction = (W3Action_Attack)damageData;
	if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()))
		return true;
	
	size = damageData.GetDTs(damageTypes);
	casterActor = caster.GetActor();
	reducedDamage = 0;
	totalDamage = 0;

	for(i = 0; i < size; i += 1)
	{
		dmgType = damageTypes[i].dmgType;

		if(casterActor.UsesVitality() && !DamageHitsVitality(dmgType))
			continue;
		
		if(casterActor.UsesEssence() && !DamageHitsEssence(dmgType))
			continue;
		
		dmgVal = damageTypes[i].dmgVal;
		
		totalDamage += dmgVal;

		if(dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			continue;
		
		if(parent.shieldHealth <= 0)
			continue;
		
		dmgVal *= parent.dmgAbsorptionPrc;
		
		if(dmgVal > parent.shieldHealth)
		{
			dmgVal = parent.shieldHealth;
		}

		damageTypes[i].dmgVal -= dmgVal;
		
		reducedDamage += dmgVal;
		parent.shieldHealth -= dmgVal;

		if(theGame.CanLog())
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageTypes[i].dmgVal + " to " + (damageTypes[i].dmgVal - dmgVal), damageData);
		}
	}
	
	for(i = size - 1; i >= 0; i -= 1)
	{
		if(damageTypes[i].dmgVal <= 0)
			damageTypes.EraseFast(i);
	}

	if(damageTypes.Size() > 0)
		damageData.SetDTs(damageTypes);
	else
		damageData.ClearDamage();
	
	if(reducedDamage > 0)
	{
		ShowHitFX();

		if(!damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) //~3.5^2
		{
			returnedDmgAction = new W3DamageAction in theGame.damageMgr;
			returnedDmgAction.Initialize(casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock');
			parent.InitSignDataForDamageAction(returnedDmgAction);
			returnedDmgAction.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reducedDamage);
			returnedDmgAction.SetCanPlayHitParticle(true);
			returnedDmgAction.SetHitEffectAllTypes('hit_electric_quen');
			
			theGame.damageMgr.ProcessAction(returnedDmgAction);
			delete returnedDmgAction;
			
			casterActor.PlayEffect('quen_force_discharge');
		}
	}
	
	if(totalDamage <= reducedDamage)
	{
		parent.SetBlockedAllDamage(true);
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		damageData.SetCanPlayHitParticle(false);
	}
	else
	{
		parent.SetBlockedAllDamage(false);
	}
	
	if(totalDamage - reducedDamage >= 20)
		casterActor.RaiseForceEvent('StrongHitTest');

	if(parent.shieldHealth <= 0)
	{
		if(parent.impulseLevel > 0)
		{				
			casterActor.PlayEffect('lasting_shield_impulse');
			caster.GetPlayer().QuenImpulse(false, parent, "quen_impulse", parent.impulseLevel, parent.quenPower);
		}
		damageData.SetEndsQuen(true);
	}
}

@wrapMethod(QuenShield) function OnThrowing()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	if( super.OnThrowing() )
	{
		if( (W3PlayerWitcher)caster.GetActor() )
		{
			if( !parent.freeCast )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
				thePlayer.AddEffectDefault(EET_QuenCooldown, NULL, "normal_cast");
				if(thePlayer.HasBuff(EET_Mutagen10))
					((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
				if(thePlayer.HasBuff(EET_Mutagen17))
					((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
				if(thePlayer.HasBuff(EET_Mutagen22))
					((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
			}
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		
		parent.freeCast = false;
		parent.CleanUp();	
		parent.GotoState( 'ShieldActive' );
	}
}

@wrapMethod(QuenChanneled) function OnEnterState( prevStateName : name )
{
	var casterActor : CActor;
	var witcher : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod(prevStateName);
	}
	
	super.OnEnterState( prevStateName );

	casterActor = caster.GetActor();
	witcher = (W3PlayerWitcher)casterActor;
	
	if(witcher)
		witcher.SetUsedQuenInCombat();
						
	caster.OnDelayOrientationChange();
	
	casterActor.GetMovingAgentComponent().SetVirtualRadius( 'QuenBubble' );
		
	parent.AddBuffImmunities();	
	
	
	witcher.CriticalEffectAnimationInterrupted("quen channeled");
}

@wrapMethod(QuenChanneled) function OnLeaveState( nextStateName : name )
{
	var casterActor : CActor;
	
	if(false) 
	{
		wrappedMethod(nextStateName);
	}

	casterActor = caster.GetActor();
	casterActor.GetMovingAgentComponent().ResetVirtualRadius();
	casterActor.StopEffect('quen_shield');		
	parent.RemoveBuffImmunities();		
	parent.StopAllEffects();
	parent.RemoveHitDoTEntities();
	if(parent.usedFocus && casterActor.GetStat(BCS_Focus) > 0 || !parent.usedFocus && casterActor.GetStat(BCS_Stamina) > 0)
	{
		if(parent.impulseLevel > 0)
		{
			parent.PlayHitEffect('quen_rebound_sphere_impulse', parent.GetWorldRotation());
			caster.GetPlayer().QuenImpulse(true, parent, "quen_impulse", parent.impulseLevel, parent.quenPower);
		}
	}

	if(caster.IsPlayer() && !caster.GetPlayer().HasBuff(EET_Mutation11Buff) && !caster.GetPlayer().HasBuff(EET_Mutation11Debuff))
	{
		thePlayer.AddEffectDefault(EET_QuenCooldown, NULL, "alt_cast");
		if(thePlayer.HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
		if(thePlayer.HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(thePlayer.HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
	}
	caster.GetActor().OnSignCastPerformed(ST_Quen, true); 
	
	super.OnLeaveState(nextStateName);
}

@wrapMethod(QuenChanneled) function OnEnded(optional isEnd : bool)
{
	if(false) 
	{
		wrappedMethod(isEnd);
	}
	
	super.OnEnded();
}

@replaceMethod(QuenChanneled) function ChannelQuen()
{
	while( Update(theTimer.timeDelta) )
	{
		ProcessQuenCollisionForRiders();
		Sleep(theTimer.timeDelta);
	}
}

@replaceMethod(QuenChanneled) function ShowHitFX(optional damageData : W3DamageAction)
{
	var movingAgent : CMovingPhysicalAgentComponent;
	var inWater, hasFireDamage, hasElectricDamage, hasPoisonDamage, isBirds : bool;
	var witcher	: W3PlayerWitcher;
	var rot : EulerAngles;
	
	GCameraShake(parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f);
	theGame.VibrateControllerHard();
	
	if(!damageData || (CBaseGameplayEffect)damageData.causer)
	{
		parent.PlayHitEffect('quen_rebound_sphere', parent.GetWorldRotation());
		return;
	}
	
	if(damageData.attacker)
	{
		rot = VecToRotation(damageData.attacker.GetWorldPosition() - caster.GetActor().GetWorldPosition());
		rot.Pitch = 0;
		rot.Roll = 0;
	}
	else
		rot = parent.GetWorldRotation();
	
	witcher = parent.owner.GetPlayer();
	
	if(damageData.IsDoTDamage())
	{
		parent.PlayHitEffect('quen_rebound_sphere_constant', rot, true);
		parent.AddTimer('RemoveDoTFX', 0.3, false, , , , true);
	}
	else
	{
		hasFireDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_FIRE) > 0;
		hasPoisonDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_POISON) > 0;		
		hasElectricDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_SHOCK) > 0;
	
		if (witcher && parent.dischargePercent > 0)
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_bear_abl2', rot );
		}
		else if (hasFireDamage)
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_fire', rot );
		}
		else if (hasPoisonDamage)
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_poison', rot );
		}
		else if (hasElectricDamage)
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_electricity', rot );
		}
		else
		{
			parent.PlayHitEffect( 'quen_rebound_sphere', rot );
		}
	}

	movingAgent = (CMovingPhysicalAgentComponent)caster.GetActor().GetMovingAgentComponent();
	inWater = movingAgent.GetSubmergeDepth() < 0;
	if(!inWater)
	{
		parent.PlayHitEffect( 'quen_rebound_ground', rot );
	}
}

@replaceMethod(QuenChanneled) function OnTargetHit( out damageData : W3DamageAction )
{
	var casterActor : CActor;
	var shieldHP, savedShieldHP, shieldFactor, staminaPrc, adrenalinePrc : float;
	var damageTypes : array<SRawDamage>;
	var reducedDamage, totalDamage : float;
	var i, size : int;
	var dmgVal : float;
	var dmgType : name;
	var returnedDmgAction : W3DamageAction;
	var attackerVictimEuler : EulerAngles;
	var reducedDamagePrc, drainedStamina, drainedAdrenaline : float;

	casterActor = caster.GetActor();

	if(damageData.GetBuffSourceName() == "FallingDamage")
		return true;
	
	if(damageData.IsDoTDamage() && (CBaseGameplayEffect)damageData.causer)
	{
		return true;
	}
	
	if(casterActor.HasBuff(EET_Mutation11Buff))
	{
		ShowHitFX(damageData);
		damageData.ClearDamage();
		parent.SetBlockedAllDamage(true);
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		damageData.SetCanPlayHitParticle(false);
		return true;
	}

	shieldFactor = CalculateAttributeValue(caster.GetSkillAttributeValue(S_Magic_s04, 'shield_health_factor', false, true));

	if((W3PlayerWitcher)casterActor && caster.CanUseSkill(S_Perk_09) && parent.usedFocus)
		adrenalinePrc = casterActor.GetStat(BCS_Focus);
	else
		staminaPrc = casterActor.GetStat(BCS_Stamina)/casterActor.GetStatMax(BCS_Stamina);
	shieldHP = parent.shieldHealth * shieldFactor * (staminaPrc + adrenalinePrc);
	savedShieldHP = shieldHP;
	
	size = damageData.GetDTs(damageTypes);
	
	reducedDamage = 0;
	totalDamage = 0;

	for(i = 0; i < size; i += 1)
	{
		dmgType = damageTypes[i].dmgType;
		
		if(casterActor.UsesVitality() && !DamageHitsVitality(dmgType))
			continue;
		
		if(casterActor.UsesEssence() && !DamageHitsEssence(dmgType))
			continue;
		
		dmgVal = damageTypes[i].dmgVal;
		
		totalDamage += dmgVal;
		
		if(dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			continue;
		
		if(shieldHP <= 0)
			continue;

		if(dmgVal > shieldHP)
		{
			dmgVal = shieldHP;
			damageTypes[i].dmgVal -= dmgVal;
		}
		else
			damageTypes[i].dmgVal = 0;

		reducedDamage += dmgVal;
		shieldHP -= dmgVal;
		
		if(theGame.CanLog())
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageTypes[i].dmgVal + " to " + (damageTypes[i].dmgVal - dmgVal), damageData);
		}
	}
	
	for(i = size - 1; i >= 0; i -= 1)
	{
		if(damageTypes[i].dmgVal <= 0)
			damageTypes.EraseFast(i);
	}

	if(damageTypes.Size() > 0)
		damageData.SetDTs(damageTypes);
	else
		damageData.ClearDamage();

	if(reducedDamage > 0)
	{
		ShowHitFX(damageData);

		caster.GetActor().Heal(reducedDamage * parent.healingFactor);
		if(!damageData.IsDoTDamage() && casterActor == thePlayer && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) //~3.5^2
		{
			returnedDmgAction = new W3DamageAction in theGame.damageMgr;
			returnedDmgAction.Initialize(casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock');
			parent.InitSignDataForDamageAction(returnedDmgAction);
			returnedDmgAction.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reducedDamage);
			returnedDmgAction.SetCanPlayHitParticle(true);
			returnedDmgAction.SetHitEffectAllTypes('hit_electric_quen');
			
			theGame.damageMgr.ProcessAction(returnedDmgAction);
			delete returnedDmgAction;
			
			parent.PlayHitEffect('discharge', attackerVictimEuler);
		}
	}

	if(totalDamage <= reducedDamage)
	{
		parent.SetBlockedAllDamage(true);
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		damageData.SetCanPlayHitParticle(false);
	}
	else
	{
		parent.SetBlockedAllDamage(false);
	}
	
	if(totalDamage - reducedDamage >= 20)
		casterActor.RaiseForceEvent( 'StrongHitTest' );

	if(reducedDamage > 0)
	{
		reducedDamagePrc = reducedDamage/(parent.shieldHealth * shieldFactor);
		if((W3PlayerWitcher)casterActor && caster.CanUseSkill(S_Perk_09) && parent.usedFocus)
		{
			drainedAdrenaline = MinF(reducedDamagePrc, casterActor.GetStat(BCS_Focus));
			if(drainedAdrenaline > 0)
				((W3PlayerWitcher)casterActor).DrainFocus( drainedAdrenaline * parent.foaMult );
		}
		else
		{
			drainedStamina = reducedDamagePrc * casterActor.GetStatMax(BCS_Stamina);
			casterActor.DrainStamina(ESAT_FixedValue, drainedStamina, casterActor.GetStaminaActionDelay(ESAT_Ability, caster.GetSkillAbilityName(S_Magic_s04)));
		}

		if(parent.usedFocus && casterActor.GetStat(BCS_Focus) <= 0 || !parent.usedFocus && casterActor.GetStat(BCS_Stamina) <= 0)
		{
			if(parent.impulseLevel > 0)
			{
				parent.PlayHitEffect('quen_rebound_sphere_impulse', attackerVictimEuler);
				caster.GetPlayer().QuenImpulse(true, parent, "quen_impulse", parent.impulseLevel, parent.quenPower);
			}
			damageData.SetEndsQuen(true);
		}
	}
}