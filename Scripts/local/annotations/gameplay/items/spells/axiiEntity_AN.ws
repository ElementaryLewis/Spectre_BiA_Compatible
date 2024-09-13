@wrapMethod(W3AxiiEntity) function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
{	
	var ownerActor : CActor;
	var prevSign : W3SignEntity;
	
	if(false) 
	{
		wrappedMethod( inOwner, prevInstance, skipCastingAnimation, notPlayerCast );
	}
	
	ownerActor = inOwner.GetActor();
	
	if( (CPlayer)ownerActor )
	{
		prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
		if(prevSign)
			prevSign.OnSignAborted(true);
	}
	
	ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
	
	ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
	
	return super.Init( inOwner, prevInstance, skipCastingAnimation );
}

@wrapMethod(W3AxiiEntity) function OnStarted()
{
	var player : CR4Player;
	var i : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	SelectTargets();
	
	SloMo();
	
	Attach(true);
	
	player = (CR4Player)owner.GetActor();
	if(player)
	{
		GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		player.AddTimer('ResetPadBacklightColorTimer', 2);
	}
		
	PlayEffect( effects[fireMode].castEffect );
	
	if ( owner.ChangeAspect( this, S_Magic_s05 ) )
	{
		CacheActionBuffsFromSkill();
		GotoState( 'AxiiChanneled' );
	}
	else
	{
		GotoState( 'AxiiCast' );
	}		
}

@wrapMethod(W3AxiiEntity) function OnEnded(optional isEnd : bool)
{
	var buff : EEffectInteract;
	var i : int;
	var duration, durationAnimal, axiiPower: SAbilityAttributeValue;
	var casterActor : CActor;
	var dur, durAnimals : float;
	var params, staggerParams : SCustomEffectParams;
	var npcTarget : CNewNPC;
	var jobTreeType : EJobTreeType;
	var pts, prc, chance, currentDuration : float;				

	if(false) 
	{
		wrappedMethod(isEnd);
	}	
	
	casterActor = owner.GetActor();		
	ProcessThrow();
	StopEffect(effects[fireMode].throwEffect);
			
	if(IsAlternateCast())
	{
		thePlayer.LockToTarget( false );
		thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
	}
	
	if (targets.Size() > 0 )
	{
		durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);

								   
		durationAnimal.valueMultiplicative = 1.0f;
		durAnimals = CalculateAttributeValue(durationAnimal);

		duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
		if(IsAlternateCast())
			duration += thePlayer.GetSkillAttributeValue(S_Magic_s05, 'duration_bonus_after1', false, true) * (thePlayer.GetSkillLevel(S_Magic_s05) - 1);
		
		duration.valueMultiplicative = 1.0f;

		if(owner.CanUseSkill(S_Magic_s19) && targets.Size() > 1)

			duration -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
																															  
		
		dur = CalculateAttributeValue(duration);

		if(owner.CanUseSkill(S_Magic_s18))
			dur *= 1 + CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s18, 'axii_duration_bonus', false, false)) * owner.GetSkillLevel(S_Magic_s18);
		
		axiiPower = casterActor.GetTotalSignSpellPower(skillEnum);
		
		params.creator = casterActor;
		params.sourceName = "axii_" + skillEnum;			
		params.customPowerStatValue = casterActor.GetTotalSignSpellPower(skillEnum);
		params.isSignEffect = true;
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			npcTarget = (CNewNPC)targets[i];

			if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				currentDuration = durAnimals;
			else
				currentDuration = dur;

			if( owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Hostile )
			{
				targets[i].GetResistValue(CDS_WillRes, pts, prc);
				chance = ClampF(1 - prc, 0.0, 1.0);
			}
			else
			{
				pts = 0;
				chance = 1;
			}

			params.duration = currentDuration * (1 + SignPowerStatToPowerBonus(MaxF(0, axiiPower.valueMultiplicative - pts/100)));
			
			jobTreeType = npcTarget.GetCurrentJTType();	
				
			if( jobTreeType == EJTT_InfantInHand )
			{
				params.effectType = EET_AxiiGuardMe;
				chance = 1;
			}

			else if( IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly )
			{
				params.effectType = EET_Confusion;
				chance = 1;
			}
			else
			{
				params.effectType = actionBuffs[0].effectType;
			}
			
			if( params.duration > 0 && chance > 0 && RandF() < chance )
				buff = targets[i].AddEffectCustom(params);
			else
				buff = EI_Deny;
				
			if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
			{
				targets[i].OnAxiied( casterActor );
			}
			else
			{
 
				params.duration = 0.5;
				staggerParams = params;
				staggerParams.effectType = EET_Stagger;
					   
				buff = targets[i].AddEffectCustom(staggerParams);
				if( buff == EI_Deny || buff == EI_Undefined )
	 
  
  
					owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
			}
		}
	}

	
	casterActor.OnSignCastPerformed(ST_Axii, fireMode);
	
	RemoveSloMo();
	
	super.OnEnded();
}

@addField(W3AxiiEntity)
var speedMultCasuserId	: int;

@addMethod(W3AxiiEntity) function SloMo()
{
	var speed : float;
	
	theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_ThrowingAim));
	owner.GetActor().ResetAnimationSpeedMultiplier(speedMultCasuserId);
	
	if(!owner.GetPlayer())
		return;
	
	speed = 0.6;
	if(owner.CanUseSkill(S_Magic_s17))
		speed -= CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s17, 'slowdown_mod', false, true)) * owner.GetSkillLevel(S_Magic_s17);

	theGame.SetTimeScale(speed, theGame.GetTimescaleSource(ETS_ThrowingAim), theGame.GetTimescalePriority(ETS_ThrowingAim), false);
	speedMultCasuserId = owner.GetActor().SetAnimationSpeedMultiplier(1/speed * 0.5);
	theSound.SoundEvent("gui_slowmo_start");
}

@addMethod(W3AxiiEntity) function RemoveSloMo()
{
	theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_ThrowingAim));
	owner.GetActor().ResetAnimationSpeedMultiplier(speedMultCasuserId);
	theSound.SoundEvent("gui_slowmo_end");
}

@wrapMethod(W3AxiiEntity) function HAXX_AXII_ABORTED()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	RemoveSloMo();
}

@wrapMethod(W3AxiiEntity) function OnDisplayTargetChange(newTarget : CActor)
{
	if(false) 
	{
		wrappedMethod(newTarget);
	}
	
	if(newTarget == orientationTarget)
		return;
		
	orientationTarget = newTarget;	
}

@wrapMethod(AxiiCast) function OnEnded(optional isEnd : bool)
{
	var player			: CR4Player;
	
	if(false) 
	{
		wrappedMethod(isEnd);
	}
		
	player = caster.GetPlayer();
	
	if( player )
	{
		parent.ManagePlayerStamina();
		parent.ManageGryphonSetBonusBuff();
		thePlayer.AddEffectDefault(EET_AxiiCooldown, NULL, "normal_cast");
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

	parent.OnEnded(isEnd);
	super.OnEnded(isEnd);
}

@wrapMethod(AxiiChanneled) function OnEnded(optional isEnd : bool)
{
	if(false) 
	{
		wrappedMethod(isEnd);
	}
	
	if(caster.IsPlayer())
	{
		thePlayer.AddEffectDefault(EET_AxiiCooldown, NULL, "alt_cast");
		if(thePlayer.HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
		if(thePlayer.HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(thePlayer.HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
	}
	
	parent.OnEnded(isEnd);
	super.OnEnded(isEnd);
}

@replaceMethod(AxiiChanneled) function ChannelAxii()
{	
	while( Update(theTimer.timeDelta) )
	{
		Sleep(theTimer.timeDelta);
	}
}