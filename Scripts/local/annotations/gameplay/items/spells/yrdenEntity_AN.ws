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
	
	skillLevel = caster.GetSkillLevel(parent.skillEnum);
	
	if(skillLevel == 1)
		usedShockAreaName = 'Shock_lvl_1';
	else if(skillLevel == 2)
		usedShockAreaName = 'Shock_lvl_2';
	else if(skillLevel >= 3)
		usedShockAreaName = 'Shock_lvl_3';
		
	parent.GetComponent(usedShockAreaName).SetEnabled( true );
	
	ActivateShock();
	parent.NotifyGameplayEntitiesInArea( usedShockAreaName );
}