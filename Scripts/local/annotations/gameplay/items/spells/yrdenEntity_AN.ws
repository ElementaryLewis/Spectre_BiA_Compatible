@addField(W3YrdenEntity)
protected var maxCount		: int;
@addField(W3YrdenEntity)
protected var hasSupercharged	: bool;
@addField(W3YrdenEntity)
protected var yrdenPower	: SAbilityAttributeValue; 
@addField(W3YrdenEntity)
protected var turretLevel	: int;
@addField(W3YrdenEntity)
protected var turretDamageBonus	: float;
@addField(W3YrdenEntity)
protected var superchargedDmg	: float;
@addField(W3YrdenEntity)
protected var isEntanglement	: bool;

@addMethod(W3YrdenEntity) function GetCachedYrdenPower() : SAbilityAttributeValue
{
	return yrdenPower;
}

@replaceMethod(W3YrdenEntity) function GetSignStats()
{
	var chargesAtt, trapDurationAtt : SAbilityAttributeValue;
	var min, max : SAbilityAttributeValue;
	var rangeMult : float;
	
	super.GetSignStats();

	isEntanglement = (notFromPlayerCast && (W3PlayerWitcher)owner.GetActor() && ((W3PlayerWitcher)owner.GetActor()).HasGlyphwordActive('Glyphword 15 _Stats'));
	
	chargesAtt = owner.GetSkillAttributeValue(skillEnum, 'charge_count', false, true);
																					  
	if(IsAlternateCast())
		trapDurationAtt = owner.GetSkillAttributeValue(skillEnum, 'trap_duration', false, false);
	else
		trapDurationAtt = owner.GetSkillAttributeValue(skillEnum, 'trap_duration', false, false);
	
	baseModeRange = CalculateAttributeValue( owner.GetSkillAttributeValue(skillEnum, 'range', false, false) );
	rangeMult = 1;
	if(!IsAlternateCast() && owner.CanUseSkill(S_Magic_s10) && owner.GetSkillLevel(S_Magic_s10) >= 2)
		rangeMult += CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s10, 'range_bonus', false, false));
	if(!IsAlternateCast() && owner.GetPlayer() && GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
		rangeMult += min.valueAdditive - 1;
	}
	baseModeRange *= rangeMult;
	
	maxCount = 1;
	if(!IsAlternateCast() && owner.CanUseSkill(S_Magic_s10) && owner.GetSkillLevel(S_Magic_s10) >= 3)
	{
		maxCount += 1;
	}
	yrdenPower = owner.GetActor().GetTotalSignSpellPower(skillEnum);
	hasSupercharged = owner.CanUseSkill(S_Magic_s11);
	if( hasSupercharged && owner.GetPlayer() )
	{
		superchargedDmg = CalculateAttributeValue(owner.GetPlayer().GetSkillAttributeValue(S_Magic_s11, 's11_dmg_bonus', false, true));
		superchargedDmg *= (float)owner.GetPlayer().GetSkillLevel(S_Magic_s11);
	}
	if( owner.CanUseSkill(S_Magic_s03) )
	{
		turretLevel = owner.GetSkillLevel(S_Magic_s03);
		turretDamageBonus = CalculateAttributeValue( owner.GetPlayer().GetSkillAttributeValue( S_Magic_s03, 'damage_bonus_flat_after_1', false, false ) ) * ( turretLevel - 1 );
		trapDurationAtt.valueAdditive += CalculateAttributeValue( owner.GetPlayer().GetSkillAttributeValue( S_Magic_s03, 'duration_bonus_flat_after_1', false, false ) ) * ( turretLevel - 1 );
		chargesAtt.valueAdditive += CalculateAttributeValue( owner.GetPlayer().GetSkillAttributeValue( S_Magic_s03, 'charge_bonus_flat_after_1', false, false ) ) * ( turretLevel - 1 );
		if( owner.CanUseSkill(S_Magic_s16) )
			turretDamageBonus += CalculateAttributeValue( owner.GetPlayer().GetSkillAttributeValue( S_Magic_s16, 'turret_bonus_damage', false, true ) ) * owner.GetSkillLevel(S_Magic_s16);
	}
	else
	{
		turretLevel = 0;
		turretDamageBonus = 0;
	}
	
	charges = (int)CalculateAttributeValue(chargesAtt);
	
	trapDuration = CalculateAttributeValue(trapDurationAtt);
	
	if(!IsAlternateCast() && owner.CanUseSkill(S_Magic_s10))
		trapDuration *= 1 + CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s10, 'trap_duration_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s10);

	if(isEntanglement)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_duration', min, max);
		trapDuration = min.valueAdditive;
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_range', min, max);
		baseModeRange = min.valueAdditive;
	}

	if(owner.GetPlayer() && owner.GetPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
	{
		trapDuration *= 1.34;
	}
}

@wrapMethod(W3YrdenEntity) function DisablePreviousYrdens()
{
	var i, size, currCount : int;
	var isAlternate : bool;
	var witcher : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod();
	}

	isAlternate = IsAlternateCast();
	witcher = GetWitcherPlayer();
	size = witcher.yrdenEntities.Size();
	
	currCount = 0;
	
	for(i=size-1; i>=0; i-=1)
	{
		
		if(!witcher.yrdenEntities[i])
		{
			witcher.yrdenEntities.Erase(i);		
			continue;
		}
		
		if(witcher.yrdenEntities[i].IsAlternateCast() == isAlternate)
		{
			currCount += 1;
			
			
			if(currCount > maxCount)
			{
				witcher.yrdenEntities[i].OnSignAborted(true);
			}
		}
	}
}

@wrapMethod(YrdenCast) function OnThrowing()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	if( super.OnThrowing() )
	{
		if(!parent.notFromPlayerCast)
		{
			if( caster.GetPlayer() )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
				thePlayer.AddEffectDefault(EET_YrdenCooldown, NULL, "normal_cast");
				if(thePlayer.HasBuff(EET_Mutagen10))
					((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
				if(thePlayer.HasBuff(EET_Mutagen17))
					((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
				if(thePlayer.HasBuff(EET_Mutagen22))
					((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
		}
		
		parent.CleanUp();	
		parent.StopEffect( 'yrden_cast' );			
		parent.GotoState( 'YrdenSlowdown' );

		thePlayer.ResumeStaminaRegen( 'SignCast' );
	}
}

@wrapMethod(YrdenChanneled) function OnEnterState( prevStateName : name )
{
	var actor : CActor;
	var player : CR4Player;
	var stamina : float;
	
	if(false) 
	{
		wrappedMethod(prevStateName);
	}
	
	super.OnEnterState( prevStateName );
	
	caster.OnDelayOrientationChange();

	actor = caster.GetActor();
	player = (CR4Player)actor;
		
	if(player)
	{
		if( parent.cachedCost <= 0.0f )
		{
			parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
		}
		stamina = player.GetStat(BCS_Stamina);
	}
		
	if( player && player.CanUseSkill(S_Perk_09) && player.GetStat(BCS_Focus) >= 1 )
	{
		if( parent.cachedCost > 0 )
		{
			player.DrainFocus( 1 * parent.foaMult );
		}
		parent.SetUsedFocus( true );
	}
	else
	{
		actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		actor.StartStaminaRegen();
		actor.PauseStaminaRegen( 'SignCast' );
		parent.SetUsedFocus( false );
		if(parent.GetUsedFoA())
			player.DrainFocus( 1 * parent.foaMult );
	}
	
	ChannelYrden();
}

@wrapMethod(YrdenChanneled) function OnThrowing()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	parent.CleanUp();	

	parent.StopEffect( 'yrden_cast' );

	caster.GetActor().ResumeStaminaRegen( 'SignCast' );
	
	parent.GotoState( 'YrdenShock' );
}

@replaceMethod(YrdenChanneled) function ChannelYrden()
{
	while( Update(theTimer.timeDelta) )
	{
		Sleep(theTimer.timeDelta);
	}

	OnSignAborted();
}


@wrapMethod(YrdenShock) function OnEnterState( prevStateName : name )
{
	var skillLevel : int;

	if(false) 
	{
		wrappedMethod(prevStateName);
	}
	
	super.OnEnterState( prevStateName );

	if(caster.IsPlayer())
	{
		thePlayer.AddEffectDefault(EET_YrdenCooldown, NULL, "alt_cast");
		if(thePlayer.HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
		if(thePlayer.HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(thePlayer.HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
	}
	
	skillLevel = parent.turretLevel;
	
	if(skillLevel == 1)
		usedShockAreaName = 'Shock_lvl_1';
	else if(skillLevel == 2)
		usedShockAreaName = 'Shock_lvl_2';
	else if(skillLevel >= 3)
		usedShockAreaName = 'Shock_lvl_3';
		
	parent.GetComponent(usedShockAreaName).SetEnabled( true );
	
	ActivateShock();

	thePlayer.ResumeStaminaRegen( 'SignCast' );
}

@wrapMethod(YrdenShock) function OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
{
	var target : CNewNPC;		
	var projectile : CProjectileTrajectory;		

	if(false) 
	{
		wrappedMethod(area, activator);
	}
	
	target = (CNewNPC)(activator.GetEntity());
	
	if( target && !parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.PushBack( target );
	}
	
	if ( parent.charges && parent.IsValidTarget( target ) && !parent.validTargetsInArea.Contains(target) )
	{
		if( parent.validTargetsInArea.Size() == 0 )
		{
			parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
		}
		
		parent.validTargetsInArea.PushBack( target );			
	}		
	else if(parent.projDestroyFxEntTemplate)
	{
		projectile = (CProjectileTrajectory)activator.GetEntity();
		
		if(projectile && !((W3SignProjectile)projectile) && IsRequiredAttitudeBetween(caster.GetActor(), projectile.caster, true, true, false))
		{
			if(projectile.IsStopped())
			{
				
				projectile.SetIsInYrdenAlternateRange(parent);
			}
			else
			{			
				ShootDownProjectile(projectile);
			}
		}
	}
}

@wrapMethod(YrdenShock) function OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
{
	var target : CNewNPC;
	var projectile : CProjectileTrajectory;

	if(false) 
	{
		wrappedMethod(area, activator);
	}
	
	target = (CNewNPC)(activator.GetEntity());
	
	if ( target && parent.charges && target.GetAttitude( thePlayer ) == AIA_Hostile )
	{
		parent.validTargetsInArea.Erase( parent.validTargetsInArea.FindFirst( target ) );
	}
	
	if ( parent.validTargetsInArea.Size() <= 0 )
	{
		parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
	}

	if( target && parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.Erase( parent.allActorsInArea.FindFirst( target ) );
	}
}

@wrapMethod(YrdenShock) function YrdenTrapHitEnemy(entity : CEntity, hitPosition : Vector)
{
	var component : CComponent;
	var targetActor, casterActor : CActor;
	var action : W3DamageAction;
	var player : W3PlayerWitcher;
	var skillType : ESkill;
	var skillLevel, i : int;
	var damageBonusFlat : float;		
	var damages : array<SRawDamage>;
	var glyphwordY : W3YrdenEntity;

	if(false) 
	{
		wrappedMethod(entity, hitPosition);
	}
	
	parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	parent.PlayEffect( parent.effects[parent.fireMode].shootEffect );
	parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
		
	targetActor = (CActor)entity;
	if(targetActor)
	{
		component = targetActor.GetComponent('torso3effect');		
		if ( component )
		{
			parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, component );
		}
	}
	
	if(!targetActor || !component)
	{
		parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, entity );
	}

	
	
		parent.charges -= 1;
	
	
	casterActor = caster.GetActor();
	if ( casterActor && (CGameplayEntity)entity)
	{
		
		action =  new W3DamageAction in theGame.damageMgr;
		player = caster.GetPlayer();
		skillType = virtual_parent.GetSkill();

		
		action.Initialize( casterActor, (CGameplayEntity)entity, this, casterActor.GetName()+"_sign_yrden_alt", EHRT_Light, CPS_SpellPower, false, false, true, false, 'yrden_shock', 'yrden_shock', 'yrden_shock', 'yrden_shock');
		virtual_parent.InitSignDataForDamageAction(action);
		action.hitLocation = hitPosition;
		action.SetCanPlayHitParticle(true);
		
		
		if(parent.turretDamageBonus > 0) 
		{
			action.GetDTs(damages);
			action.ClearDamage();
			
			for(i=0; i<damages.Size(); i+=1)
			{
				damages[i].dmgVal += parent.turretDamageBonus;
				action.AddDamage(damages[i].dmgType, damages[i].dmgVal);
			}
		}
		
		
		theGame.damageMgr.ProcessAction( action );
		
		((CGameplayEntity)entity).OnYrdenHit( casterActor );
	}
	else
	{
		entity.PlayEffect( 'yrden_shock' );
	}
	
	if((W3PlayerWitcher)casterActor && ((W3PlayerWitcher)casterActor).HasGlyphwordActive('Glyphword 15 _Stats'))
	{
		glyphwordY = (W3YrdenEntity)theGame.CreateEntity(GetWitcherPlayer().GetSignTemplate(ST_Yrden), entity.GetWorldPosition(), entity.GetWorldRotation() );
		glyphwordY.Init(caster, parent, true, true);
		glyphwordY.CacheActionBuffsFromSkill();
		glyphwordY.GotoState( 'YrdenSlowdown' );
	}
}

@wrapMethod( YrdenSlowdown ) function OnEnterState( prevStateName : name )
{
	if(false) 
	{
		wrappedMethod(prevStateName);
	}

	super.OnEnterState( prevStateName );
	
	parent.GetComponent( 'Slowdown' ).SetEnabled( true );
	parent.PlayEffect( 'yrden_slowdown_sound' );
	
	ActivateSlowdown();

	thePlayer.ResumeStaminaRegen( 'SignCast' );
}

@wrapMethod( YrdenSlowdown ) function CreateTrap()
{
	var i, size : int;
	var worldPos : Vector;
	var isSetBonus2Active : bool;
	var worldRot : EulerAngles;
	var polarAngle, yrdenRange, unitAngle : float;
	var runePositionLocal, runePositionGlobal : Vector;
	var entity : CEntity;
	
	if(false) 
	{
		wrappedMethod();
	}

	thePlayer.ResumeStaminaRegen( 'SignCast' );

	isSetBonus2Active = GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 );
	worldPos = virtual_parent.GetWorldPosition();
	worldRot = virtual_parent.GetWorldRotation();
	yrdenRange = virtual_parent.baseModeRange;
	size = virtual_parent.runeTemplates.Size();
	unitAngle = 2 * Pi() / size;
	
	if( isSetBonus2Active )
	{
		virtual_parent.PlayEffect( 'ability_gryphon_set' );
	}
	
	for( i=0; i<size; i+=1 )
	{
		polarAngle = unitAngle * i;
		
		runePositionLocal.X = yrdenRange * CosF( polarAngle );
		runePositionLocal.Y = yrdenRange * SinF( polarAngle );
		runePositionLocal.Z = 0.f;
		
		runePositionGlobal = worldPos + runePositionLocal;			
		runePositionGlobal = TraceFloor( runePositionGlobal );
		runePositionGlobal.Z += 0.05f;		
		
		entity = theGame.CreateEntity( virtual_parent.runeTemplates[i], runePositionGlobal, worldRot );
		virtual_parent.fxEntities.PushBack( entity );
	}
}

@wrapMethod( YrdenSlowdown ) function YrdenSlowdown_Loop()
{
	var i							: int;
	var casterActor, curTarget		: CActor;
	var casterPlayer				: CR4Player;
	var npc							: CNewNPC;
	var params, paramsDrain			: SCustomEffectParams;
	var min, max, pts, prc			: float;
	var startingMin					: float;
	var slowPower, drainNoRes		: float;
	var decayDelay, timePassed		: float;
	var inc, mult, slow				: float;
	var dt							: float = 0.1f;
	var ablMin, ablMax				: SAbilityAttributeValue;
	var superchargedBonus, bonus	: float;
	var currentlyAnimatedCS			: CBaseGameplayEffect;

	if(false) 
	{
		wrappedMethod();
	}
	
	casterActor = caster.GetActor();
	casterPlayer = caster.GetPlayer();

	params.effectType = EET_Slowdown; 
	params.creator = casterActor;
	params.sourceName = "yrden_mode0";
	params.isSignEffect = true;
	params.customAbilityName = '';
	params.duration = 0.2;
	
	min = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, false));
	max = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, false));
	startingMin = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_starting_slowdown', false, false));
	slowPower = parent.yrdenPower.valueMultiplicative;
	
	if(parent.isEntanglement)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 15 _Stats', 'glyphword15_slow_cap', ablMin, ablMax);
		max = CalculateAttributeValue(ablMin);
	}

	if(parent.hasSupercharged)
	{
		paramsDrain.effectType = EET_YrdenHealthDrain;
		paramsDrain.creator = casterActor;
		paramsDrain.sourceName = "yrden_mode0";
		paramsDrain.isSignEffect = true;
		paramsDrain.customAbilityName = '';
		paramsDrain.duration = 0.2;
		superchargedBonus = parent.superchargedDmg;
	}

	timePassed = 0;
	mult = 0;
	decayDelay = parent.trapDuration / 3.0;
	inc = dt / (parent.trapDuration - decayDelay);
	
	while(true)
	{
		for(i=parent.flyersInArea.Size()-1; i>=0; i-=1)
		{
			npc = parent.flyersInArea[i];
			if(!npc.IsFlying())
			{
				parent.validTargetsInArea.PushBack(npc);
				npc.BlockAbility('Flying', true);
				parent.flyersInArea.EraseFast(i);
			}
		}
		
		for(i=0; i<parent.validTargetsInArea.Size(); i+=1)
		{
			curTarget = parent.validTargetsInArea[i];

			curTarget.GetResistValue(CDS_ShockRes, pts, prc);
			if(prc < 1)
			{
				if(parent.isEntanglement)
					slow = max * (1 - prc);
				else
					slow = MaxF(0, startingMin * (1 + SignPowerStatToPowerBonus(slowPower - pts/100))) * (1 - prc);
				slow = ClampF(slow, min, max);
				bonus = MaxF(0, superchargedBonus * (1 - prc));
				if(timePassed >= decayDelay)
				{
					slow = min + (slow - min) * (1 - MinF(mult, 1));
					bonus *= 1 - MinF(mult, 1);
				}
				params.effectValue.valueAdditive = slow;
				currentlyAnimatedCS = curTarget.GetCurrentlyAnimatedCS();
				if(currentlyAnimatedCS && !((W3Effect_PoisonCritical)currentlyAnimatedCS) || curTarget.GetIsRecoveringFromKnockdown())
				{
					if(curTarget.HasBuff(EET_Slowdown))
						curTarget.RemoveBuff(EET_Slowdown);
				}
				else if(!curTarget.HasBuff(EET_Slowdown))
					curTarget.AddEffectCustom(params);
				else
					((W3Effect_Slowdown)curTarget.GetBuff(EET_Slowdown)).ResetSlowdownEffect(params.effectValue);
				if(parent.hasSupercharged)
				{
					if(!curTarget.HasBuff(EET_YrdenHealthDrain))
						curTarget.AddEffectCustom(paramsDrain);

					((W3Effect_YrdenHealthDrain)curTarget.GetBuff(EET_YrdenHealthDrain)).SetDmgBonus(bonus);
				}
			}
			
			curTarget.OnYrdenHit( casterActor );
		}
		
		timePassed += dt;
		if(timePassed >= decayDelay)
			mult += inc;
		Sleep(dt);
	}
}

@wrapMethod( YrdenSlowdown ) function OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
{
	var target : CNewNPC;
	var i : int;

	if(false) 
	{
		wrappedMethod(area, activator);
	}
	
	target = (CNewNPC)(activator.GetEntity());

	if( (W3PlayerWitcher)activator.GetEntity() )
	{
		parent.isPlayerInside = false;
	}
	if( target )
	{
		i = parent.validTargetsInArea.FindFirst( target );
		if( i >= 0 )
		{
			target.RemoveBuff( EET_YrdenHealthDrain );
			
			parent.validTargetsInArea.Erase( i );
		}
		target.SignalGameplayEventParamObject('LeavesYrden', parent );
		target.BlockAbility('Flying', false);
		parent.flyersInArea.Remove(target);
	}
	
	if ( parent.validTargetsInArea.Size() == 0 )
	{
		parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
	}
	if( !parent.isPlayerInside )
	{
		parent.UpdateGryphonSetBonusYrdenBuff();
	}
	
	if( target && parent.allActorsInArea.Contains( target ) )
	{
		parent.allActorsInArea.Erase( parent.allActorsInArea.FindFirst( target ) );
	}
}