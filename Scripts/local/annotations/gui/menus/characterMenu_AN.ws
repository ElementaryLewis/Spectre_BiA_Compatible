@wrapMethod(CR4CharacterMenu) function setMutationBonusMode( value : bool ) : void
{
	var updated : bool;
	updated = false;
	
	if(false) 
	{
		wrappedMethod(value);
	}

	if( m_mutationBonusMode != value )
	{
		m_mutationBonusMode = value;
		m_fxSetMutationBonusMode.InvokeSelfOneArg( FlashArgBool( value ) );
		
		if( m_mutationBonusMode )
		{
			
		}
		else
		{
			thePlayer.UnequipSkill( BSS_SkillSlot1 );
			thePlayer.UnequipSkill( BSS_SkillSlot2 );
			thePlayer.UnequipSkill( BSS_SkillSlot3 );
			thePlayer.UnequipSkill( BSS_SkillSlot4 );
			
			UpdatePlayerStatisticsData();
			UpdateGroupsData();
			updated = true;
		}
	}
	if( !updated )
		CheckAdditionalSlots();
}

@addMethod(CR4CharacterMenu) function CheckAdditionalSlots()
{
	var skillSlots : array<SSkillSlot>;
	var curSlot : SSkillSlot;
	var i, slotsCount : int;
	var updateNeeded : bool;
	
	updateNeeded = false;
	
	skillSlots = thePlayer.GetSkillSlots();
	slotsCount = skillSlots.Size();
	
	for( i=0; i < slotsCount; i += 1 )
	{
		curSlot = skillSlots[i];
		if( !curSlot.unlocked && curSlot.socketedSkill != S_SUndefined )
		{
			thePlayer.UnequipSkill( curSlot.id );
			updateNeeded = true;
		}
	}
	if ( updateNeeded )
	{
		UpdatePlayerStatisticsData();
		UpdateGroupsData();
	}
}

@wrapMethod(CR4CharacterMenu) function OnSwapSkill(skill1 : ESkill, slotID1 : int, skill2 : ESkill, slotID2 : int)
{
	var equippedMutationId : EPlayerMutationType;
	var equippedMutation   : SMutation;
	
	if(false) 
	{
		wrappedMethod(skill1, slotID1, skill2, slotID2);
	}
	
	if (thePlayer.IsInCombat())
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		OnPlaySoundEvent("gui_global_denied");
	}
	else
	{
		equippedMutationId = GetWitcherPlayer().GetEquippedMutationType();
		if( equippedMutationId != EPMT_None )
		{
			equippedMutation = GetWitcherPlayer().GetMutation( equippedMutationId );
		}
		if( slotID1 >= BSS_SkillSlot1 && !equippedMutation.colors.Contains( thePlayer.GetSkillColor( skill1 ) ) ||
			slotID2 >= BSS_SkillSlot1 && !equippedMutation.colors.Contains( thePlayer.GetSkillColor( skill2 ) ) )
		{
			OnPlaySoundEvent("gui_global_denied");
		}
		else
		{
			thePlayer.UnequipSkill(slotID1);
			thePlayer.UnequipSkill(slotID2);
			
			thePlayer.EquipSkill(skill1, slotID1);
			thePlayer.EquipSkill(skill2, slotID2);
		
			UpdateAppliedSkills();
			UpdateSkillPoints();			
			UpdatePlayerStatisticsData();						
			UpdateGroupsData();
			UpdateMutagens();
			UpdateMasterMutation();
			
			OnPlaySoundEvent("gui_character_add_skill");
		}
	}
}

@wrapMethod(CR4CharacterMenu) function GetSwordSkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
{
	var baseString	: string;
	var argsInt 	: array<int>;
	var argsFloat	: array<float>;
	var argsString	: array< string >;
	var arg, arg2, arg3	: float;
	var arg_focus	: float;
	var ability		: SAbilityAttributeValue;
	var min, max	: SAbilityAttributeValue;
	var dm 			: CDefinitionsManagerAccessor;
	
	if(false) 
	{
		wrappedMethod(targetSkill, skillLevel, locKey);
	}
	
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue('sword_adrenalinegain', 'focus_gain', min, max);
	ability =  GetAttributeRandomizedValue(min, max);
	arg_focus = ability.valueAdditive;
	
	switch (targetSkill.skillType)
	{
		case S_Alchemy_2:
			argsInt.PushBack(RoundMath((1 - theGame.params.OIL_DECAY_FACTOR)*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		
		case S_Magic_1:
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
			arg2 = SignPowerStatToPowerBonus(ability.valueMultiplicative);
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s12))
			{
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s12, 'heavy_knockdown_chance_bonus', false, false);
				arg3 = ability.valueMultiplicative * GetWitcherPlayer().GetSkillLevel(S_Magic_s12);
			}
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_1, 'starting_knockdown_chance', false, false)) * (1 + arg2);
			argsInt.PushBack(RoundMath(arg*100));
			arg2 = (0.15 + arg3) * arg;
			argsInt.PushBack(RoundMath(arg2*100));
			baseString = GetLocStringByKeyExtWithParams(targetSkill.localisationDescriptionKey, argsInt);
			break;
		case S_Magic_2:
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
			arg = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_2, theGame.params.DAMAGE_NAME_FIRE, false, true ) );
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s07))
				arg += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s07, 'fire_damage_bonus', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s07);
			if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 7 _Stats'))
				arg += CalculateAttributeValue(GetWitcherPlayer().GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_dmg_buff'));
			argsInt.PushBack(RoundMath(arg));
			arg2 = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_2, 'initial_burn_chance', false, true));
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s09))
				arg2 += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s09);
			if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 7 _Stats'))
				arg2 += CalculateAttributeValue(GetWitcherPlayer().GetAbilityAttributeValue('Glyphword 7 _Stats', 'glyphword7_burnchance_debuff'));
			arg2 = MaxF(0, arg2);
			argsInt.PushBack(RoundMath(arg2*100));
			arg *= ability.valueMultiplicative;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_3:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_starting_slowdown', false, false));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
			arg *= 1 + SignPowerStatToPowerBonus(ability.valueMultiplicative);
			argsString.PushBack(RoundMath(arg * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, false));
			argsString.PushBack(RoundMath(arg * 100));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'trap_duration', false, true);
			arg = CalculateAttributeValue(ability);
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s10))
				arg *= 1 + CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s10, 'trap_duration_bonus', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s10);
			argsString.PushBack(NoTrailZeros(RoundTo(arg,1)));
			baseString = GetLocStringByKeyExtWithParams(targetSkill.localisationDescriptionKey, , , argsString);
			break;
		case S_Magic_4:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'max_dmg_absorption', false, false));										 
			argsInt.PushBack(RoundMath(arg*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_health', false, false));
			if( GetWitcherPlayer().CanUseSkill(S_Magic_s15) )
				arg += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s15, 'shield_health_bonus', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s15);
			argsInt.PushBack(RoundMath(arg));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
			arg *= 1 + SignPowerStatToPowerBonus(ability.valueMultiplicative);
			argsInt.PushBack(RoundMath(arg));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_duration', false, false));
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_5:
			dm.GetAbilityAttributeValue('ConfusionEffect', 'critical_hit_chance', min, max);
			arg = CalculateAttributeValue(GetAttributeRandomizedValue(min, max)) * 100;
			if(thePlayer.CanUseSkill(S_Magic_s17))
				arg += CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Magic_s17, 'crit_chance_bonus', false, true)) * thePlayer.GetSkillLevel(S_Magic_s17) * 100;
			argsString.PushBack(FloatToStringPrec(arg, 1));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
			arg = 1 * (1 + SignPowerStatToPowerBonus(ability.valueMultiplicative));
			argsString.PushBack(FloatToStringPrec(arg, 1));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_5, 'duration', false, true);
			arg = ability.valueBase;
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s18))
				arg *= 1 + CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s18, 'axii_duration_bonus', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s18);
			arg *= 1 + SignPowerStatToPowerBonus(ability.valueMultiplicative);
			argsString.PushBack(FloatToStringPrec(arg, 1));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
			
		case S_Sword_2:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_2, 'heavy_attack_dmg_boost', false, false);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, false));
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
		case S_Sword_3:
			argsInt.PushBack(RoundMath(0.25 * 100));
			arg = theGame.params.PARRY_STAGGER_REDUCE_DAMAGE;
			arg = ClampF(arg, 0, 1);
			argsInt.PushBack(RoundMath((1 - arg) * 100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			
		case S_Sword_5:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_5, PowerStatEnumToName(CPS_AttackPower), false, true);
			argsInt.PushBack( RoundMath( ability.valueMultiplicative * 100) );
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
		case S_Sword_s01:				
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_per_sec', false, false))
				* (1 - CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'stamina_cost_reduction_after_1', false, false)) * (skillLevel - 1));
			argsString.PushBack( NoTrailZeros( arg ) );
			argsString.PushBack( NoTrailZeros( arg / GetWitcherPlayer().GetStatMax(BCS_Stamina) ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_bonus', false, false) * skillLevel;
			arg = ability.valueMultiplicative;
			argsString.PushBack( NoTrailZeros( arg * 100 ) );
			argsString.PushBack( NoTrailZeros( arg * 5 * 100 ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction', false, false);
			ability += GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'whirl_dmg_reduction_bonus_after_1', false, false) * (skillLevel - 1);
			arg = ability.valueMultiplicative;
			argsString.PushBack( NoTrailZeros( arg * 100 ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Sword_s02:
			argsString.PushBack( "3" );
			argsString.PushBack( "3" );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s02, 'attack_damage_bonus', false, false) * skillLevel;
			arg = ability.valueMultiplicative * 100;
			argsString.PushBack( NoTrailZeros( arg ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, false) * skillLevel;
			arg2 = ability.valueMultiplicative * 100;
			argsString.PushBack( NoTrailZeros( arg2 ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, false) * skillLevel;
			arg3 = ability.valueMultiplicative * 100;
			argsString.PushBack( RoundMath( arg3 ) );
			argsString.PushBack( RoundMath( arg + arg2 * thePlayer.GetStatMax(BCS_Stamina) + arg3 * thePlayer.GetStatMax(BCS_Focus) ) );
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s02, theGame.params.CRITICAL_HIT_CHANCE, false, false)) * skillLevel;
			argsString.PushBack( RoundMath( arg * 100 ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Sword_s03:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			argsInt.PushBack(RoundMath(arg*100*GetWitcherPlayer().GetStatMax(BCS_Focus)));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, , argsString);
			break;
		case S_Sword_s04:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, false) * skillLevel;
			argsString.PushBack(RoundMath(ability.valueMultiplicative*100));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s04, 'heavy_focus_gain', false, false) * skillLevel;
			argsString.PushBack(RoundMath(ability.valueAdditive*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Sword_s05:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s05, 'sword_s5_chance', false, false)) * skillLevel;
			argsString.PushBack( NoTrailZeros( arg*100 ) );
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s05, 'sword_s5_dmg_boost', false, false)) * skillLevel;
			argsString.PushBack( NoTrailZeros( arg*100 ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Sword_s06:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s06, 'armor_reduction_perc', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s07:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s08:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s09:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s09, 's9_damage_reduction', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s10:

			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s10, 's10_damage_reduction', false, false))*skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			argsInt.PushBack(RoundMath((1-theGame.params.PARRY_STAGGER_REDUCE_DAMAGE-arg)*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, false)) * (skillLevel - 1);
			argsInt.PushBack(RoundMath(arg*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s10, 'parry_cost_decrease', false, false));
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s11:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s11, 'attack_power', false, false);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative * skillLevel * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s11, 'critical_hit_chance', false, false));
			argsInt.PushBack(RoundMath(arg*100*(skillLevel-1)));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s11, 's11_knockdown_chance', false, false));
			argsInt.PushBack(RoundMath(arg*100));
			argsInt.PushBack(RoundMath(arg*100*GetWitcherPlayer().GetStatMax(BCS_Focus)));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s12:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s12, 'duration', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s13:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s13, 'slowdown_mod', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s15:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s15, 'xbow_dmg_bonus', false, false)) * skillLevel;
			argsFloat.PushBack(arg);
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
		case S_Sword_s16:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s17:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s18:
			dm.GetAbilityAttributeValue('UndyingSkillImmortalEffect', 'duration', min, max);
			arg = min.valueAdditive;
			argsString.PushBack(RoundMath(arg));
			dm.GetAbilityAttributeValue('UndyingSkillImmortalEffect', 'vitalityCombatRegen', min, max);
			argsString.PushBack(RoundMath(min.valueMultiplicative*arg*100*skillLevel));
			argsString.PushBack(RoundMath(min.valueMultiplicative*arg*100*3*skillLevel));
			min = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s18, 'trigger_delay', false, false);
			argsString.PushBack(RoundMath(min.valueAdditive));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Sword_s19:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s19, 'spell_power', false, false) * skillLevel;
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Sword_s20:
			argsString.PushBack(NoTrailZeros(CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s20, 'focus_add', false, false)) * skillLevel));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, false) * skillLevel;
			argsInt.PushBack(RoundMath(ability.valueAdditive*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, , argsString);
			break;
		case S_Sword_s21:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, false) * skillLevel;
			argsString.PushBack(RoundMath(ability.valueMultiplicative*100));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s21, 'light_focus_gain', false, false) * skillLevel;
			argsString.PushBack(RoundMath(ability.valueAdditive*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		default:
			if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
			else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
			else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
	}
	
	return baseString;
}

@wrapMethod(CR4CharacterMenu) function GetSignSkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
{
	var baseString	: string;
	var argsInt 	: array<int>;
	var argsFloat	: array<float>;
	var arg, arg2, penaltyReduction : float;
	var arg_stamina : float;
	var ability, penalty : SAbilityAttributeValue;
	var min, max	: SAbilityAttributeValue;
	var dm 			: CDefinitionsManagerAccessor;
	var argsString	: array<string>;
	
	if(false) 
	{
		wrappedMethod(targetSkill, skillLevel, locKey);
	}

	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue('magic_staminaregen', 'staminaRegen', min, max);
	ability =  GetAttributeRandomizedValue(min, max);
	arg_stamina = ability.valueMultiplicative;
	
	switch (targetSkill.skillType)
	{
		case S_Magic_s01:
			penalty = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s01, PowerStatEnumToName(CPS_SpellPower), false, false);
			penaltyReduction = (skillLevel - 1) * CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', false, false));
			arg = AbsF(penalty.valueMultiplicative) - penaltyReduction;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s02:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s02, 'channeling_damage', false, false);
			ability += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s02, 'channeling_damage_after_1', false, false) * (skillLevel - 1);
			arg = ability.valueAdditive;
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s07))
				arg += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s07, 'channeling_damage_bonus', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s07);
			argsInt.PushBack(RoundMath(arg));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
			argsInt.PushBack(RoundMath(arg*ability.valueMultiplicative));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s02, 'stamina_cost_reduction_after_1', false, false) * (skillLevel-1);
			argsInt.PushBack(RoundMath(CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s02, 'stamina_cost_per_sec', false, false)) * (1 - ability.valueMultiplicative)));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s03:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'ShockDamage', false, false) + GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'damage_bonus_flat_after_1', false, false) * (skillLevel-1);
			arg = CalculateAttributeValue(ability);
			if( GetWitcherPlayer().CanUseSkill(S_Magic_s16) )
				arg += CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s16, 'turret_bonus_damage', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s16);
			argsInt.PushBack(RoundMath(arg));
			argsInt.PushBack(10 + 2*(skillLevel-1));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
			arg *= ability.valueMultiplicative;
			argsInt.PushBack(RoundMath(arg));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'trap_duration', false, false)) + CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'duration_bonus_flat_after_1', false, false))*(skillLevel - 1);
			argsInt.PushBack(RoundMath(arg));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'charge_count', false, false)) + CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s03, 'charge_bonus_flat_after_1', false, false))*(skillLevel - 1);
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s04:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s04, 'shield_health_factor', false, false)) - 1;
			argsInt.PushBack(RoundMath(arg*100));
			if( skillLevel < 3 )
			{
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s04, 'stamina_cost_reduction_after_1', false, false) * (skillLevel - 1);
				argsInt.PushBack(RoundMath(CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s04, 'stamina_cost_per_sec', false, false)) * (1 - ability.valueMultiplicative)));
			}
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s04, 'shield_healing_factor', false, false)) * (float)skillLevel;
			argsInt.PushBack(RoundMath(arg * 100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s05:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s05, 'duration', false, false);
			ability += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s05, 'duration_bonus_after1', false, false) * (skillLevel - 1);
			arg = ability.valueBase;
			argsInt.PushBack(RoundMath(arg));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s05, PowerStatEnumToName(CPS_AttackPower), false, false) * skillLevel;
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s18))
				arg *= 1 + CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s18, 'axii_duration_bonus', false, false)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s18);
			arg *= 1 + SignPowerStatToPowerBonus(ability.valueMultiplicative);
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
		case S_Magic_s06:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
			arg *= ability.valueMultiplicative;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;	
		case S_Magic_s07:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s07, 'fire_damage_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s07, 'channeling_damage_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s08:
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
			arg2 = RoundMath(1 + 7.0*SignPowerStatToPowerBonus(ability.valueMultiplicative));
			dm.GetAbilityAttributeValue('MeltArmorDebuff', 'armor', min, max);
			arg = CalculateAttributeValue(min);
			argsString.PushBack(FloatToStringPrec(-arg * arg2 * skillLevel, 1));
			dm.GetAbilityAttributeValue('MeltArmorDebuff', 'physical_resistance_perc', min, max);
			arg = CalculateAttributeValue(min);
			argsString.PushBack(FloatToStringPrec(-arg * arg2 * skillLevel * 100, 1));
			dm.GetAbilityAttributeValue('MeltArmorDebuff', 'duration', min, max);
			arg = CalculateAttributeValue(min);
			argsString.PushBack(FloatToStringPrec(arg, 0));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;	
		case S_Magic_s09:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, false) * skillLevel ;
			argsInt.PushBack(RoundMath(ability.valueAdditive*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s10:				
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s10, 'trap_duration_bonus', false, false));
			arg *= skillLevel;
			argsInt.PushBack(RoundMath(arg * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s10, 'range_bonus', false, false));					  
			argsInt.PushBack(RoundMath(arg * 100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s11:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s11, 's11_dmg_bonus', false, false);
			arg = ability.valueAdditive * skillLevel;
			argsString.PushBack(NoTrailZeros(arg * 100));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;	
		case S_Magic_s12:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s12, 'heavy_knockdown_chance_bonus', false, false);
			ability.valueMultiplicative *= skillLevel;
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s13:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s13, 'ShockDamage', false, false)) * (skillLevel - 1);
			argsInt.PushBack(RoundMath(arg));
			ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
			arg *= ability.valueMultiplicative;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s14:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s14, 'discharge_percent', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s15:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s15, 'shield_health_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s16:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s16, 'turret_bonus_damage', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s17:
			argsInt.PushBack(RoundMath(CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s17, 'slowdown_mod', false, false)) * 100 * skillLevel));
			argsInt.PushBack(RoundMath(CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s17, 'crit_chance_bonus', false, false)) * 100 * skillLevel));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s18:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s18, 'axii_duration_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s19:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s19, 'duration', false, false) * (3 - skillLevel);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Magic_s20:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s20, 'range', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;					
	}
	
	return baseString;
}

@wrapMethod(CR4CharacterMenu) function GetAlchemySkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
{
	var baseString		: string;
	var argsInt 		: array<int>;
	var argsFloat		: array<float>;
	var argsString		: array<string>;
	var arg				: float;
	var arg_duration	: float;
	var toxThreshold	: float;
	var ability			: SAbilityAttributeValue;
	var min, max		: SAbilityAttributeValue;
	var dm 				: CDefinitionsManagerAccessor;
	
	if(false) 
	{
		wrappedMethod(targetSkill, skillLevel, locKey);
	}
	
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue('alchemy_potionduration', 'potion_duration', min, max);
	ability =  GetAttributeRandomizedValue(min, max);
	arg_duration = CalculateAttributeValue(ability);
			
	switch (targetSkill.skillType)
	{
		case S_Alchemy_s01:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s01, 'stamina_gain_perc', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s02:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s02, 'vitality_gain_perc', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s03:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s03, 'toxicityReduction', false, false)) * skillLevel;
			argsString.PushBack(NoTrailZeros(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s04:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s04, 'potion_duration', false, false)) * skillLevel;
			argsString.PushBack( RoundMath(arg*100) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s05:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s05, 'defence_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s05, 'oil_level_defence', false, false));
			argsInt.PushBack(RoundMath(arg * 100));
			argsInt.PushBack(RoundMath(arg * 2 * 100));
			argsInt.PushBack(RoundMath((1 - theGame.params.OIL_DECAY_FACTOR)*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s06:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s06, 'ammo_bonus', false, false)) * skillLevel;
			argsInt.PushBack(Min(100, RoundMath(arg*100)));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s07:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false)) * skillLevel;				
			argsString.PushBack(FloatToStringPrec(arg*100,1));
			argsString.PushBack(RoundF(arg*100*3));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s08:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s08, 'item_count', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s09:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s09, 'slowdown_mod', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s10:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s10, 'PhysicalDamage', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s11:
			arg = 1 + skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s12:			
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg * 100));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, false));
			argsInt.PushBack(RoundMath(arg * 100));
			argsInt.PushBack(RoundMath(arg * 2 * 100));
			argsInt.PushBack(RoundMath((1 - theGame.params.OIL_DECAY_FACTOR)*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s13:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s13, 'vitality', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s14:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s14, 'tox_off_bonus', false, false);
			arg = skillLevel * ability.valueMultiplicative;
			argsString.PushBack(FloatToStringPrec(arg * 100, 0));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s15:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s15, 'toxicityRegen', false, false)) * skillLevel;
			argsString.PushBack(NoTrailZeros(-arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s16:
			arg = skillLevel * CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s16, 'slowdown_ratio', false, false));
			argsString.PushBack(FloatToStringPrec(arg * 100, 0));
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s16, 'slowdown_duration', false, false));
			argsString.PushBack(FloatToStringPrec(arg, 2));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s16, 'attack_power', false, false);
			arg = skillLevel * ability.valueMultiplicative;
			argsString.PushBack(FloatToStringPrec(arg * 100, 0));
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Alchemy_s17:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s17, 'critical_hit_chance', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s18:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s18, 'max_abs_per_lvl_s18', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg));
			arg = GetWitcherPlayer().CountAlchemy18Abilities(skillLevel);
			argsInt.PushBack(RoundMath(arg));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s19:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s19, 'synergy_bonus', false, false)) * skillLevel;
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Alchemy_s20:
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(EffectTypeToName(EET_IgnorePain), StatEnumToName(BCS_Vitality), min, max);
			ability = GetAttributeRandomizedValue(min, max);
			arg = ability.valueMultiplicative * skillLevel;				
			argsInt.PushBack(RoundMath(arg*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		default:
			if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
			else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
			else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
	}
	
	return baseString;
}

@wrapMethod(CR4CharacterMenu) function GetPerkTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
{
	var baseString	: string;
	var argsInt 	: array<int>;
	var argsFloat	: array<float>;
	var argsString	: array<string>;
	var arg			: float;
	var ability		: SAbilityAttributeValue;
	var min, max	: SAbilityAttributeValue;
	var dm 			: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	
	if(false) 
	{
		wrappedMethod(targetSkill, skillLevel, locKey);
	}
	
	switch (targetSkill.skillType)
	{
		case S_Perk_01:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_01, 'vitalityRegen_tooltip', false, true);
			argsInt.PushBack(RoundMath(CalculateAttributeValue(ability)));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_01, 'staminaRegen_tooltip', false, true);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina)));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_02:
			baseString = GetLocStringByKeyExt(locKey);
			break;
		case S_Perk_04:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_04, 'vitality', false, true);
			argsInt.PushBack(RoundMath(ability.valueBase));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_05:
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Perk_05, 'critical_hit_chance', false, true));
			argsString.PushBack( NoTrailZeros( arg * 100 ) );
			arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Perk_05, 'critical_hit_damage_bonus', false, true));
			argsString.PushBack( NoTrailZeros( arg * 100 ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Perk_06:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_06, 'spell_power', false, true);
			argsString.PushBack( NoTrailZeros( ability.valueMultiplicative * 100 ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_06, 'perk_6_stamina_cost_reduction', false, true);
			argsString.PushBack( NoTrailZeros( ability.valueMultiplicative * 100 ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Perk_07:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_07, 'vitality', false, true);
			argsString.PushBack( NoTrailZeros( ability.valueMultiplicative * 100 ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_07, 'bonus_focus_gain', false, true);
			argsString.PushBack( NoTrailZeros( ability.valueAdditive ) );
			baseString = GetLocStringByKeyExtWithParams(locKey, , , argsString);
			break;
		case S_Perk_10:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_10, 'focus_gain', false, true);
			argsInt.PushBack(RoundMath(ability.valueAdditive*100));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_10, 'stamina_cost_reduction', false, true);
			argsInt.PushBack(RoundMath(ability.valueAdditive*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_11:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_11, 'spell_power', false, true);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_12:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_12, 'toxicity', false, true);
			argsInt.PushBack(RoundMath(ability.valueBase));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_13:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_13, 'cost_reduction', false, true);
			argsInt.PushBack(RoundMath(100 * ability.valueMultiplicative));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_15:
			ability = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration_bonus', false, false );
			argsString.PushBack( NoTrailZeros( ability.valueMultiplicative * 100 ) );
			baseString = GetLocStringByKeyExtWithParams( locKey, , , argsString );
			break;
		case S_Perk_18:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_18, 'focus_gain', false, true);
			argsFloat.PushBack(ability.valueAdditive);
			baseString = GetLocStringByKeyExtWithParams(locKey, , argsFloat);
			break;
		case S_Perk_19:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_19, 'critical_hit_chance', false, true);
			argsInt.PushBack(RoundMath(100 * ability.valueAdditive));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		case S_Perk_20:
			ability = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false );
			ability.valueMultiplicative *= 100;
			argsString.PushBack( FloatToString( ability.valueMultiplicative ) );
			ability = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'stack_multiplier', false, false );
			ability.valueMultiplicative *= 100;
			argsString.PushBack( FloatToString( ability.valueMultiplicative ) );
			baseString = GetLocStringByKeyExtWithParams( locKey, , , argsString );
			break;
		case S_Perk_21:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_21, 'stamina_kill', false, false);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_21, 'stamina_other', false, false);
			argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Perk21InternalCooldownEffect', 'duration', min, max);
			argsString.PushBack(FloatToString(min.valueAdditive));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, , argsString);
			break;
		case S_Perk_22:
			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_22, 'encumbrance', false, true);
			argsInt.PushBack(RoundMath(ability.valueBase));
			baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
		default:
			if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
			else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
			else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
	}
	
	return baseString;
}

@wrapMethod(CR4CharacterMenu) function UpdatePlayerStatisticsData()
{
	var l_flashObject			: CScriptedFlashObject;
	var l_flashArray			: CScriptedFlashArray;		
	var valueStr 				: string;
	var statsNr 				: int;
	var statName 				: name;
	var i 						: int;
	var lastSentStatString		: string;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	l_flashArray = m_flashValueStorage.CreateTempFlashArray();
	
	AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dph_spectre", "attack_silver", l_flashArray, m_flashValueStorage);
	AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dph_spectre", "attack_steel", l_flashArray, m_flashValueStorage);
	AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", l_flashArray, m_flashValueStorage); 
	AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", l_flashArray, m_flashValueStorage);
	AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", l_flashArray, m_flashValueStorage);
	
	m_flashValueStorage.SetFlashArray( "playerstats.stats", l_flashArray );
}