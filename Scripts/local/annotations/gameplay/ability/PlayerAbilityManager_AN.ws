@addField(W3PlayerAbilityManager)
var spectreActiveSkills : array<ESkill>;		

@wrapMethod(W3PlayerAbilityManager) function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
{
	var skillDefs : array<name>;
	var i : int;
	
	if(false) 
	{
		wrappedMethod(ownr, cStats, isFromLoad, diff);
	}
	
	isInitialized = false;	
	
	if(!ownr)
	{
		LogAssert(false, "W3PlayerAbilityManager.Init: owner is NULL!!!!");
		return false;
	}
	else if(!( (CPlayer)ownr ))
	{
		LogAssert(false, "W3PlayerAbilityManager.Init: trying to create for non-player object!! Aborting!!");
		return false;
	}
	
	
	resistStatsItems.Resize(EnumGetMax('EEquipmentSlots')+1);
	pathPointsSpent.Resize(EnumGetMax('ESkillPath')+1);		
	
	
	ownr.AddAbility(theGame.params.GLOBAL_PLAYER_ABILITY);
	
	if(!super.Init(ownr,cStats, isFromLoad, diff))
		return false;
		
	LogChannel('CHR', "Init W3PlayerAbilityManager "+isFromLoad);

	if(!isMutationSystemEnabled)
	{
		MutationSystemEnable(true);
	}		
	
	InitSkillSlots( isFromLoad );
	
	if(!isFromLoad)
	{	
		
		charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
		LogAssert(skillDefs.Size()>0, "W3PlayerAbilityManager.Init: actor <<" + owner + ">> has no skills!!");
		
		for(i=0; i<skillDefs.Size(); i+=1)
			CacheSkills(skillDefs[i], skills);
			
		LoadMutagenSlotsDataFromXML();
		
		
		mutagenBonuses.Resize( GetSkillGroupsCount() + 1 );
		
		
		InitSkills();
		
		PrecacheModifierSkills();			
		alchemy19OptimizationDone = true;
	}
	else
	{
		tempSkills.Clear();
		temporaryTutorialSkills.Clear();
		
		if ( !ep1SkillsInitialized && theGame.GetDLCManager().IsEP1Available() )
		{				
			ep1SkillsInitialized = FixMissingSkills();
		}
		if ( !ep2SkillsInitialized && theGame.GetDLCManager().IsEP2Available() )
		{
			ep2SkillsInitialized = FixMissingSkills();
		}
		if ( !baseGamePerksGUIPosUpdated )
		{
			baseGamePerksGUIPosUpdated = FixBaseGamePerksGUIPos();
		}
		if( !alchemy19OptimizationDone )
		{
			Alchemy19OptimizationRetro();
			alchemy19OptimizationDone = true;
		}
	}
	
	
	LoadMutationData();		
	
	isInitialized = true;

	UpdateMutationSkillSlotsLocks();
	
	return true;	
}

@wrapMethod(W3PlayerAbilityManager) function PostInit()
{		
	var i, playerLevel : int;

	if(false) 
	{
		wrappedMethod();
	}

	if(CanUseSkill(S_Sword_5))
		AddPassiveSkillBuff(S_Sword_5);
		
	
	if( (W3PlayerWitcher)owner )
	{
		playerLevel = ((W3PlayerWitcher)owner).GetLevel();
		for(i=0; i<skillSlots.Size(); i+=1)
		{
			if( skillSlots[ i ].groupID != MUTATION_SKILL_GROUP_ID )
			{
				skillSlots[i].unlocked = ( playerLevel >= skillSlots[i].unlockedOnLevel);
			}
		}
	}
	
	
	if( FactsQuerySum( "154531" ) <= 0 )
	{
		mutationUnlockedSlotsIndexes.Clear();
		FactsAdd( "154531" );
	}
	if( FactsQuerySum( "154975" ) <= 0 )
	{
		mutationUnlockedSlotsIndexes.Clear();
		FactsAdd( "154975" );
	}
	
	
	if( mutationUnlockedSlotsIndexes.Size() == 0 )
	{
		for( i=0; i<skillSlots.Size(); i+=1 )
		{
			if( skillSlots[ i ].groupID == MUTATION_SKILL_GROUP_ID )
			{
				mutationUnlockedSlotsIndexes.PushBack( i );
			}
		}
	}
	
	
	if( !mutationSkillSlotsInitialized && theGame.GetDLCManager().IsEP2Enabled() && theGame.GetDLCManager().IsEP2Available() )
	{
		UpdateMutationSkillSlots();
		mutationSkillSlotsInitialized = true;
	}

	spectreActiveSkills.Clear();
	//spectreActiveSkills.PushBack(S_Sword_s21); // Fast Attack - Muscle Memory
	//spectreActiveSkills.PushBack(S_Sword_s17); // Fast Attack - Precise Blows
	spectreActiveSkills.PushBack(S_Sword_s01); // Fast Attack - Whirl
	//spectreActiveSkills.PushBack(S_Sword_s05); // Fast Attack - Crippling Strikes
	//spectreActiveSkills.PushBack(S_Sword_s04); // Strong Attack - Strength Training
	//spectreActiveSkills.PushBack(S_Sword_s08); // Strong Attack - Crushing Blows
	spectreActiveSkills.PushBack(S_Sword_s02); // Strong Attack - Rend
	//spectreActiveSkills.PushBack(S_Sword_s06); // Strong Attack - Sunder Armor
	spectreActiveSkills.PushBack(S_Sword_s10); // Defense - Arrow Deflection
	//spectreActiveSkills.PushBack(S_Sword_s09); // Defense - Fleet Footed
	//spectreActiveSkills.PushBack(S_Sword_s11); // Defense - Counterattack
	//spectreActiveSkills.PushBack(S_Sword_s03); // Defense - Deadly Precision
	//spectreActiveSkills.PushBack(S_Sword_s13); // Marksmanship - Lightning Reflexes
	spectreActiveSkills.PushBack(S_Sword_s15); // Marksmanship - Cold Blood
	//spectreActiveSkills.PushBack(S_Sword_s07); // Marksmanship - Anatomical Knowledge
	//spectreActiveSkills.PushBack(S_Sword_s12); // Marksmanship - Crippling Shot
	//spectreActiveSkills.PushBack(S_Sword_s16); // Battle Trance - Resolve
	//spectreActiveSkills.PushBack(S_Sword_s18); // Battle Trance - Undying
	spectreActiveSkills.PushBack(S_Sword_s20); // Battle Trance - Razor Focus
	//spectreActiveSkills.PushBack(S_Sword_s19); // Battle Trance - Flood of Anger
	//spectreActiveSkills.PushBack(S_Magic_s20); // Aard Sign - Far-Reaching Aard
	spectreActiveSkills.PushBack(S_Magic_s01); // Aard Sign - Aard Sweep
	spectreActiveSkills.PushBack(S_Magic_s12); // Aard Sign - Aard Intensity
	//spectreActiveSkills.PushBack(S_Magic_s06); // Aard Sign - Shock Wave
	//spectreActiveSkills.PushBack(S_Magic_s08); // Igni Sign - Melt Armor
	spectreActiveSkills.PushBack(S_Magic_s02); // Igni Sign - Firestream
	spectreActiveSkills.PushBack(S_Magic_s07); // Igni Sign - Igni Intensity
	//spectreActiveSkills.PushBack(S_Magic_s09); // Igni Sign - Pyromaniac
	//spectreActiveSkills.PushBack(S_Magic_s10); // Yrden Sign - Sustained Glyphs
	spectreActiveSkills.PushBack(S_Magic_s03); // Yrden Sign - Magic Trap
	spectreActiveSkills.PushBack(S_Magic_s16); // Yrden Sign - Yrden Intensity
	//spectreActiveSkills.PushBack(S_Magic_s11); // Yrden Sign - Supercharged Glyphs
	//spectreActiveSkills.PushBack(S_Magic_s13); // Quen Sign - Exploding Shield
	spectreActiveSkills.PushBack(S_Magic_s04); // Quen Sign - Active Shield
	spectreActiveSkills.PushBack(S_Magic_s15); // Quen Sign - Quen Intensity
	//spectreActiveSkills.PushBack(S_Magic_s14); // Quen Sign - Quen Discharge
	spectreActiveSkills.PushBack(S_Magic_s17); // Axii Sign - Delusion
	spectreActiveSkills.PushBack(S_Magic_s05); // Axii Sign - Puppet
	spectreActiveSkills.PushBack(S_Magic_s18); // Axii Sign - Axii Intensity
	//spectreActiveSkills.PushBack(S_Magic_s19); // Axii Sign - Domination
	//spectreActiveSkills.PushBack(S_Alchemy_s01); // Brewing - Heightened Tolerance
	//spectreActiveSkills.PushBack(S_Alchemy_s02); // Brewing - Refreshment
	//spectreActiveSkills.PushBack(S_Alchemy_s03); // Brewing - Delayed Recovery
	//spectreActiveSkills.PushBack(S_Alchemy_s04); // Brewing - Side Effects
	//spectreActiveSkills.PushBack(S_Alchemy_s12); // Oil Preparation - Poisoned Blades
	//spectreActiveSkills.PushBack(S_Alchemy_s05); // Oil Preparation - Protective Coating
	//spectreActiveSkills.PushBack(S_Alchemy_s06); // Oil Preparation - Fixative
	//spectreActiveSkills.PushBack(S_Alchemy_s07); // Oil Preparation - Hunter Instinct
	//spectreActiveSkills.PushBack(S_Alchemy_s09); // Bomb Creation - Steady Aim
	//spectreActiveSkills.PushBack(S_Alchemy_s10); // Bomb Creation - Pyrotechnics
	//spectreActiveSkills.PushBack(S_Alchemy_s08); // Bomb Creation - Efficiency
	//spectreActiveSkills.PushBack(S_Alchemy_s11); // Bomb Creation - Cluster Bombs
	//spectreActiveSkills.PushBack(S_Alchemy_s18); // Mutation - Acquired Tolerance
	//spectreActiveSkills.PushBack(S_Alchemy_s13); // Mutation - Tissue Transmutation
	//spectreActiveSkills.PushBack(S_Alchemy_s19); // Mutation - Synergy
	//spectreActiveSkills.PushBack(S_Alchemy_s14); // Mutation - Adaptation
	//spectreActiveSkills.PushBack(S_Alchemy_s16); // Trial of the Grasses - Frenzy
	//spectreActiveSkills.PushBack(S_Alchemy_s20); // Trial of the Grasses - Endure Pain
	//spectreActiveSkills.PushBack(S_Alchemy_s15); // Trial of the Grasses - Fast Metabolism
	//spectreActiveSkills.PushBack(S_Alchemy_s17); // Trial of the Grasses - Killing Spree
	spectreActiveSkills.PushBack(S_Perk_01); // General - Sun and Stars
	spectreActiveSkills.PushBack(S_Perk_02); // General - Steady Shot
	spectreActiveSkills.PushBack(S_Perk_13); // General - Metabolism Boosts
	spectreActiveSkills.PushBack(S_Perk_14); // General - Gorged on Power
	spectreActiveSkills.PushBack(S_Perk_04); // General - Survival Instinct
	spectreActiveSkills.PushBack(S_Perk_09); // General - Rage Management
	spectreActiveSkills.PushBack(S_Perk_17); // General - Trick Shot
	spectreActiveSkills.PushBack(S_Perk_15); // General - Gourmet
	spectreActiveSkills.PushBack(S_Perk_05); // General - Cat School Techniques
	spectreActiveSkills.PushBack(S_Perk_11); // General - Focus
	spectreActiveSkills.PushBack(S_Perk_18); // General - Advanced Pyrotechnics
	spectreActiveSkills.PushBack(S_Perk_16); // General - In Combat's Fires
	spectreActiveSkills.PushBack(S_Perk_06); // General - Griffin School Techniques
	spectreActiveSkills.PushBack(S_Perk_10); // General - Adrenaline Burst
	spectreActiveSkills.PushBack(S_Perk_19); // General - Battle Frenzy
	spectreActiveSkills.PushBack(S_Perk_20); // General - Heavy Artillery
	spectreActiveSkills.PushBack(S_Perk_07); // General - Bear School Techniques
	spectreActiveSkills.PushBack(S_Perk_12); // General - Metabolic Control
	spectreActiveSkills.PushBack(S_Perk_22); // General - Strong Back
	spectreActiveSkills.PushBack(S_Perk_21); // General - Attack is the Best Defense
}
	
@wrapMethod(W3PlayerAbilityManager) function AddTempNonAlchemySkills() : array<SSimpleSkill>
{
	var i, cnt, j : int;
	var ret : array<SSimpleSkill>;
	var temp : SSimpleSkill;
	
	if(false) 
	{
		wrappedMethod();
	}

	tempSkills.Clear();

	for(i=0; i<skills.Size(); i+=1)
	{
		if(skills[i].skillPath == ESP_Signs && (skills[i].level < skills[i].maxLevel || !IsSkillEquipped(skills[i].skillType)))
		{
			temp.skillType = skills[i].skillType;
			temp.level = skills[i].level;
			ret.PushBack(temp);
			
			tempSkills.PushBack(skills[i].skillType);
			
			cnt = skills[i].maxLevel - skills[i].level;
			for(j=0; j<cnt; j+=1)
				AddSkill(skills[i].skillType, true);
		}
	}
	
	return ret;
}

@wrapMethod(W3PlayerAbilityManager) function OnFocusChanged()
{
	var points : float;
	var buff : W3Effect_Toxicity;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	points = GetStat(BCS_Focus);
	
	if(points < owner.GetStatMax(BCS_Focus))
	{
		owner.RemoveBuff(EET_Runeword11);
	}
	
	if(points < 1 && owner.HasBuff(EET_BattleTrance))
	{
		owner.RemoveBuff(EET_BattleTrance);
	}
	else if(points >= 1 && !owner.HasBuff(EET_BattleTrance))
	{
		if(CanUseSkill(S_Sword_5))
			owner.AddEffectDefault(EET_BattleTrance, owner, "BattleTranceSkill");
	}
	
	if ( (W3PlayerWitcher)owner && points >= owner.GetStatMax(BCS_Focus) && ((W3PlayerWitcher)owner).HasRunewordActive('Runeword 8 _Stats') && !owner.HasBuff(EET_Runeword8) )
	{
		owner.AddEffectDefault(EET_Runeword8, owner, "max focus");
	}
}

@wrapMethod(W3PlayerAbilityManager) function OnVitalityChanged()
{
	var vitPerc : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	vitPerc = GetStatPercents(BCS_Vitality);		
	
	if(vitPerc < theGame.params.LOW_HEALTH_EFFECT_SHOW && !owner.HasBuff(EET_LowHealth))
		owner.AddEffectDefault(EET_LowHealth, owner, 'vitality_change');
	else if(vitPerc >= theGame.params.LOW_HEALTH_EFFECT_SHOW && owner.HasBuff(EET_LowHealth))
		owner.RemoveBuff(EET_LowHealth);
		
	if(vitPerc < 1.f)
	{
		owner.RemoveBuff(EET_Runeword4);
	}

	if(owner.HasBuff(EET_Mutagen24))
		((W3Mutagen24_Effect)owner.GetBuff(EET_Mutagen24)).ManageMutagen24Bonus();

	theTelemetry.SetCommonStatFlt(CS_VITALITY, GetStat(BCS_Vitality));
}

@addMethod(W3PlayerAbilityManager) function OnStaminaChanged()
{
	if(owner.HasBuff(EET_Mutagen12))
		((W3Mutagen12_Effect)owner.GetBuff(EET_Mutagen12)).ManageAdditionalBonus();
}

@wrapMethod(W3PlayerAbilityManager) function OnToxicityChanged()
{
	var tox : float;
	var enemies : array< CActor >;
	
	if(false) 
	{
		wrappedMethod();
	}

	if( !((W3PlayerWitcher)owner) )
		return;
		
	tox = GetStat(BCS_Toxicity);

	
	if( tox == 0.f && owner.HasBuff( EET_Toxicity ) )
	{
		owner.RemoveBuff( EET_Toxicity );			
	}
	else if(tox > 0.f && !owner.HasBuff(EET_Toxicity))
	{
		owner.AddEffectDefault(EET_Toxicity,owner,'toxicity_change');
	}	

	theTelemetry.SetCommonStatFlt(CS_TOXICITY, GetStat(BCS_Toxicity));
}

@wrapMethod(W3PlayerAbilityManager) function OnSkillMutagenEquipped(item : SItemUniqueId, slot : EEquipmentSlots, prevColor : ESkillColor)
{
	var i : int;
	var newColor : ESkillColor;
	var tutState : W3TutorialManagerUIHandlerStateCharDevMutagens;
	
	if(false) 
	{
		wrappedMethod(item, slot, prevColor);
	}
	
	i = GetMutagenSlotIndex(slot);
	if(i<0)
		return;
	
	mutagenSlots[i].item = item;
	
	
	newColor = GetSkillGroupColor(mutagenSlots[i].skillGroupID);
	LinkUpdate(newColor, prevColor );
	
	
	if(CanUseSkill(S_Alchemy_s19))
	{
		MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, GetSkillLevel( S_Alchemy_s19) );
	}
	
	
	if(ShouldProcessTutorial('TutorialCharDevMutagens'))
	{
		tutState = (W3TutorialManagerUIHandlerStateCharDevMutagens)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if(tutState)
		{
			tutState.EquippedMutagen();
		}
	}
	
	theTelemetry.LogWithValueStr(TE_HERO_MUTAGEN_USED, owner.GetInventory().GetItemName( item ) );
	
	
	theGame.GetGamerProfile().CheckTrialOfGrasses();
	
	thePlayer.inv.SetItemStackable( item, false );
	
	if(thePlayer.HasBuff(EET_Mutagen09))
		((W3Mutagen09_Effect)thePlayer.GetBuff(EET_Mutagen09)).RecalcM09Bonus();
	
	if(thePlayer.HasBuff(EET_Mutagen23))
		((W3Mutagen23_Effect)thePlayer.GetBuff(EET_Mutagen23)).AddM23Abilities();
	
	if(thePlayer.HasBuff(EET_Mutagen25))
		((W3Mutagen25_Effect)thePlayer.GetBuff(EET_Mutagen25)).RecalcM25Bonus();
}

@wrapMethod(W3PlayerAbilityManager) function OnSkillMutagenUnequipped( out item : SItemUniqueId, slot : EEquipmentSlots, prevColor : ESkillColor, optional dontMerge : bool )
{
	var i : int;
	var newColor : ESkillColor;
	var ids : array< SItemUniqueId >;
	var itemName : name;
	
	if(false) 
	{
		wrappedMethod(item, slot, prevColor, dontMerge);
	}
	
	i = GetMutagenSlotIndex(slot);
	if(i<0)
		return;
	
	
	if(CanUseSkill(S_Alchemy_s19))
	{
		MutagensSyngergyBonusUpdate( mutagenSlots[i].skillGroupID, GetSkillLevel( S_Alchemy_s19) );
	}
	
	mutagenSlots[i].item = GetInvalidUniqueId();
	
	newColor = GetSkillGroupColor(mutagenSlots[i].skillGroupID);
	LinkUpdate(newColor, prevColor);

	theGame.GetGuiManager().IgnoreNewItemNotifications( true );
	
	
	
	if (!dontMerge)
	{
		itemName = thePlayer.inv.GetItemName( item );
		thePlayer.inv.RemoveItem( item );
		ids = thePlayer.inv.AddAnItem( itemName, 1, true, true );
		item = ids[0];
	}
	
	theGame.GetGuiManager().IgnoreNewItemNotifications( false );
	
	if(thePlayer.HasBuff(EET_Mutagen09))
		((W3Mutagen09_Effect)thePlayer.GetBuff(EET_Mutagen09)).RecalcM09Bonus();
	
	if(thePlayer.HasBuff(EET_Mutagen23))
		((W3Mutagen23_Effect)thePlayer.GetBuff(EET_Mutagen23)).AddM23Abilities();
	
	if(thePlayer.HasBuff(EET_Mutagen25))
		((W3Mutagen25_Effect)thePlayer.GetBuff(EET_Mutagen25)).RecalcM25Bonus();
}

@wrapMethod(W3PlayerAbilityManager) function OnSwappedMutagensPost(a : SItemUniqueId, b : SItemUniqueId)
{
	var oldSlotIndexA, oldSlotIndexB : int;
	var oldColorA, oldColorB, newColorA, newColorB : ESkillColor;
	
	if(false) 
	{
		wrappedMethod(a, b);
	}

	oldSlotIndexA = GetMutagenSlotIndexFromItemId(a);
	oldSlotIndexB = GetMutagenSlotIndexFromItemId(b);
	
	oldColorA = GetSkillGroupColor(mutagenSlots[oldSlotIndexA].skillGroupID);
	oldColorB = GetSkillGroupColor(mutagenSlots[oldSlotIndexB].skillGroupID);
	
	mutagenSlots[oldSlotIndexA].item = b;
	mutagenSlots[oldSlotIndexB].item = a;
	
	newColorA = GetSkillGroupColor(mutagenSlots[oldSlotIndexA].skillGroupID);
	newColorB = GetSkillGroupColor(mutagenSlots[oldSlotIndexB].skillGroupID);
	
	LinkUpdate(newColorA, oldColorA);
	LinkUpdate(newColorB, oldColorB);
	
	if(thePlayer.HasBuff(EET_Mutagen09))
		((W3Mutagen09_Effect)thePlayer.GetBuff(EET_Mutagen09)).RecalcM09Bonus();
	
	if(thePlayer.HasBuff(EET_Mutagen23))
		((W3Mutagen23_Effect)thePlayer.GetBuff(EET_Mutagen23)).AddM23Abilities();
	
	if(thePlayer.HasBuff(EET_Mutagen25))
		((W3Mutagen25_Effect)thePlayer.GetBuff(EET_Mutagen25)).RecalcM25Bonus();
}

@wrapMethod(W3PlayerAbilityManager) function MutagensSyngergyBonusUpdateSingle( skillGroupID : int, skillLevel : int )
{
	var current : SMutagenBonusAlchemy19;
	var color : ESkillColor;
	var mutagenItemID : SItemUniqueId;
	var delta : int;
	
	if(false) 
	{
		wrappedMethod(skillGroupID, skillLevel);
	}
	
	if( skillGroupID < 0 )
	{
		return;
	}
	
	
	mutagenItemID = GetMutagenItemIDFromGroupID( skillGroupID );
	
	if( owner.GetInventory().IsIdValid( mutagenItemID ) )
	{			
		current.abilityName = GetMutagenBonusAbilityName( mutagenItemID );
		
		if( skillLevel > 0 )
		{
			color = owner.GetInventory().GetSkillMutagenColor( mutagenItemID );
			current.count = skillLevel * (1 + GetSkillGroupColorCount(color, skillGroupID));
		}
	}
	
	
	if( current.abilityName != mutagenBonuses[skillGroupID].abilityName )
	{
		
		if( IsNameValid( mutagenBonuses[skillGroupID].abilityName ) && mutagenBonuses[skillGroupID].count > 0 )
		{
			owner.RemoveAbilityMultiple( mutagenBonuses[skillGroupID].abilityName, mutagenBonuses[skillGroupID].count );
		}
		
		
		if( IsNameValid( current.abilityName ) && current.count > 0 )
		{
			owner.AddAbilityMultiple( current.abilityName, current.count );
		}
	}
	
	else if( IsNameValid( current.abilityName ) )
	{
		
		delta = current.count - mutagenBonuses[skillGroupID].count;
		
		if( delta > 0 )
		{
			owner.AddAbilityMultiple( current.abilityName, delta );
		}
		else if( delta < 0 )
		{
			owner.RemoveAbilityMultiple( current.abilityName, -delta );
		}
	}
	
	
	mutagenBonuses[skillGroupID] = current;
}

@wrapMethod(W3PlayerAbilityManager) function GetSkillStaminaUseCost(skill : ESkill, optional isPerSec : bool) : float
{
	var reductionCounter : int;
	var ability, attributeName : name;
	var ret, costReduction : SAbilityAttributeValue;
	var cost : float;
	
	if(false) 
	{
		wrappedMethod(skill, isPerSec);
	}

	ability = '';
	
	
	if(CanUseSkill(skill))
		ability = GetSkillAbilityName(skill);
	
	if(isPerSec)
		attributeName = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
	else 
		attributeName = theGame.params.STAMINA_COST_DEFAULT;
	
	ret = GetSkillAttributeValue(ability, attributeName, true, true);
	
	
	reductionCounter = GetSkillLevel(skill) - 1;
	if(reductionCounter > 0)
	{
		costReduction = GetSkillAttributeValue(ability, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
		ret -= costReduction;
	}
	
	cost = CalculateAttributeValue(ret);

	if((W3PlayerWitcher)owner && IsSkillSign(skill))
	{
		spectreModSignStaminaCost(cost);
		cost *= 1 + CalcSignCastingArmorPenalty();
		if(CanUseSkill(S_Perk_06))
			cost *= 1 - ((W3PlayerWitcher)owner).GetPerk6StaminaCostReduction();
		if(owner.HasBuff(EET_GryphonSetBonus))
			cost *= 1 - ((W3PlayerWitcher)owner).GetGryphonSetTier1Bonus();
		cost *= 1 + GetGlyphword234Mod(ESAT_Ability, true);
	}
	
	cost = ClampF(cost, 0, 100);
	
	return cost;
}

@wrapMethod(W3PlayerAbilityManager) function GetStaminaActionCostInternal(action : EStaminaActionType, isPerSec : bool, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, optional abilityName : name)
{
	var attributeName : name;
	var skill : ESkill;
	
	if(false) 
	{
		wrappedMethod(action, isPerSec, cost, delay, abilityName);
	}

	super.GetStaminaActionCostInternal(action, isPerSec, cost, delay, abilityName);
	
	if(isPerSec)
	{
		attributeName = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
	}
	else
	{
		attributeName = theGame.params.STAMINA_COST_DEFAULT;
	}
	
	if(action == ESAT_LightAttack && CanUseSkill(S_Sword_1) )
		cost += GetSkillAttributeValue(SkillEnumToName(S_Sword_1), attributeName, false, true);
	else if(action == ESAT_HeavyAttack && CanUseSkill(S_Sword_2) )
		cost += GetSkillAttributeValue(SkillEnumToName(S_Sword_2), attributeName, false, true);
}

@addMethod(W3PlayerAbilityManager) function GetStaminaActionCost(action : EStaminaActionType, out cost : float, out delay : float, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float)
{
	var blizzard : W3Potion_Blizzard;
	var bonus, penalty : float;
	
	if( thePlayer.HasBuff( EET_Blizzard ) && owner == GetWitcherPlayer() && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && thePlayer.GetStat(BCS_Focus) >= 3 )
	{
		blizzard = ( W3Potion_Blizzard )thePlayer.GetBuff( EET_Blizzard );
		if( blizzard.IsSlowMoActive() )
		{
			cost = 0;
			return;
		}
	}
	
	super.GetStaminaActionCost(action, cost, delay, fixedCost, fixedDelay, abilityName, dt, costMult);

	if((W3PlayerWitcher)owner)
	{
		if(action == ESAT_Ability && IsSkillSign(SkillNameToEnum(abilityName)))
		{
			spectreModSignStaminaCost(cost);
			cost *= 1 + CalcSignCastingArmorPenalty();
			if(CanUseSkill(S_Perk_06))
				cost *= 1 - GetWitcherPlayer().GetPerk6StaminaCostReduction();
			if(owner.HasBuff(EET_GryphonSetBonus))
				cost *= 1 - ((W3PlayerWitcher)owner).GetGryphonSetTier1Bonus();
			cost *= 1 + GetGlyphword234Mod(ESAT_Ability, true);
		}
		else if(IsActionMelee(action))
		{
			if(action == ESAT_Sprint || action == ESAT_Jump)
				spectreModAgilityStaminaCost(cost);
			else
				spectreModMeleeStaminaCost(cost);
			bonus = GetPerk10Bonus();
			if(action != ESAT_UsableItem)
				penalty = CalcStaminaArmorPenalty(action) + CalcStaminaOverEncumbrancePenalty(action);
			cost *= (1 - bonus);
			cost *= (1 + penalty);
			if(owner.HasBuff(EET_GryphonSetBonus))
				cost *= 1 - ((W3PlayerWitcher)owner).GetGryphonSetTier1Bonus();
			if(owner.HasBuff(EET_Mutagen25))
				cost *= 1 - ((W3Mutagen25_Effect)owner.GetBuff(EET_Mutagen25)).GetM25Bonus();
			if(owner.HasBuff(EET_Mutagen04))
				cost *= 1 + CalcMutagen04Penalty(action);
			cost *= 1 + GetGlyphword234Mod(action);
			if(action == ESAT_Parry)
				cost *= 1 - GetDeflectionBonus();
		}
	}
	
	cost = ClampF(cost, 0, 100);
}

@addMethod(W3PlayerAbilityManager) function GetGlyphword234Mod(action : EStaminaActionType, optional isSign : bool) : float
{
	var min, max : SAbilityAttributeValue;
	var modifier : float;

	if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 2 _Stats'))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 2 _Stats', 'glyphword2_mod', min, max);
		modifier = CalculateAttributeValue(min);
		if(action == ESAT_Ability && isSign)
			return modifier;
		else if(IsActionMelee(action))
			return -modifier;
	}
	else if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 3 _Stats'))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 3 _Stats', 'glyphword3_mod', min, max);
		modifier = CalculateAttributeValue(min);
		if(action == ESAT_Ability && isSign)
			return -modifier;
		else if(IsActionMelee(action))
			return modifier;
	}
	else if(GetWitcherPlayer().HasGlyphwordActive('Glyphword 4 _Stats')) 
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 4 _Stats', 'glyphword4_mod', min, max);
		modifier = CalculateAttributeValue(min);
		if(action == ESAT_LightAttack || action == ESAT_HeavyAttack || action == ESAT_Counterattack)
			return modifier;
	}
	
	return 0.f;
}

@addMethod(W3PlayerAbilityManager) function IsActionMelee(action : EStaminaActionType) : bool
{
	if( action == ESAT_LightAttack || action == ESAT_HeavyAttack ||
		action == ESAT_UsableItem ||
		action == ESAT_Parry || action == ESAT_Counterattack ||
		action == ESAT_Dodge || action == ESAT_Roll || action == ESAT_Evade ||
		action == ESAT_Sprint || action == ESAT_Jump )
	{
		return true;
	}
	
	return false;
}

@addMethod(W3PlayerAbilityManager) function CalcSignCastingArmorPenalty() : float
{
	var armorPieces : array<int>;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	if(owner != witcher)
		return 0;
	
	witcher.inv.CountArmorPieces(armorPieces);
	return armorPieces[2] * 0.125;
}

@addMethod(W3PlayerAbilityManager) function GetPerk10Bonus() : float
{
	var focus : float;
	var ability : SAbilityAttributeValue;
	
	if(!((W3PlayerWitcher)owner))
		return 0;

	if(thePlayer.CanUseSkill(S_Perk_10))
	{
		focus = FloorF(owner.GetStat(BCS_Focus));
		if(focus > 0)
		{
			ability = ((W3PlayerWitcher)owner).GetSkillAttributeValue(S_Perk_10, 'stamina_cost_reduction', false, true);
			return focus * ability.valueAdditive;
		}
	}
	
	return 0.0f;
}

@addMethod(W3PlayerAbilityManager) function GetDeflectionBonus() : float
{
	if(thePlayer.CanUseSkill(S_Sword_s10) && thePlayer.GetSkillLevel(S_Sword_s10) >= 3)
	{
		if(((W3PlayerWitcher)owner).GetNumHostilesInRange() > 1)
			return CalculateAttributeValue(((W3PlayerWitcher)owner).GetSkillAttributeValue(S_Sword_s10, 'parry_cost_decrease', false, false));
	}
	return 0.0f;
}

@addMethod(W3PlayerAbilityManager) function CalcStaminaArmorPenalty(action : EStaminaActionType) : float
{
	var armorPieces : array<int>;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	if(owner != witcher)
		return 0;
	
	witcher.inv.CountArmorPieces(armorPieces);

	return -armorPieces[0] * 0.075 + armorPieces[2] * 0.125 - (4 - armorPieces[0] - armorPieces[1] - armorPieces[2]) * 0.125;
}

@addMethod(W3PlayerAbilityManager) function CalcStaminaOverEncumbrancePenalty(action : EStaminaActionType) : float
{
	var tmpBool : bool;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	if(owner != witcher)
		return 0;
	
	if(witcher.HasBuff(EET_OverEncumbered))
	{
		return ClampF(witcher.GetEncumbrance()/witcher.GetMaxRunEncumbrance(tmpBool) - 1, 0, 1);
	}
	
	return 0;
}

@addMethod(W3PlayerAbilityManager) function CalcMutagen04Penalty(action : EStaminaActionType) : float
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	if(owner != witcher || !witcher.HasBuff(EET_Mutagen04))
		return 0;
	
	if(action == ESAT_LightAttack || action == ESAT_HeavyAttack || action == ESAT_Counterattack)
		return ((W3Mutagen04_Effect)witcher.GetBuff(EET_Mutagen04)).GetAttackCostIncrease();
	
	return 0;
}

@addMethod(W3PlayerAbilityManager) function ResetAlchemy05SkillMaxLevel()
{
	skills[S_Alchemy_s05].maxLevel = 5;
}

@replaceMethod(W3PlayerAbilityManager) function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float) : float
{	
	var cost : float;
	var mutagen : W3Mutagen21_Effect;
	var min, max : SAbilityAttributeValue;
	var signEntity : W3SignEntity;
	
	if(FactsDoesExist("debug_fact_stamina_boy"))
		return 0;
		
	cost = super.DrainStamina(action, fixedCost, fixedDelay, abilityName, dt, costMult);
	
	if(cost > 0 && dt > 0)
	{
		
		owner.AddTimer('AbilityManager_FloorStaminaSegment', 0.1, , , , true);
	}
	
	if(cost > 0 && owner == thePlayer && thePlayer.HasBuff(EET_Mutagen21))
	{
		mutagen = (W3Mutagen21_Effect)thePlayer.GetBuff(EET_Mutagen21);
		mutagen.Heal(cost);
	}
	
	if(owner == GetWitcherPlayer())
	{
		signEntity = GetWitcherPlayer().GetCurrentSignEntity();

		if(signEntity)
		{
			signEntity.ManageFocusGain(cost, dt);
		}
	}
	
	return cost;
}

@wrapMethod(W3PlayerAbilityManager) function GainStat( stat : EBaseCharacterStats, amount : float )
{
	if (false)
	{
		wrappedMethod(stat, amount);
	}
	
	if(stat == BCS_Focus)
	{
		if(owner.IsFocusGainPaused())
			return;
		if(owner.HasBuff(EET_Runeword8))
			return;
		if(owner.HasBuff(EET_UndyingSkillImmortal))
			return;
	}
		
	super.GainStat(stat, amount);
}

@wrapMethod(W3PlayerAbilityManager) function AddToxicityOffset(val : float)
{
	if (false)
	{
		wrappedMethod(val);
	}
	
	if(val > 0)
	{
		toxicityOffset += val;
		OnToxicityChanged();
	}
}

@wrapMethod(W3PlayerAbilityManager) function SetToxicityOffset( val : float)
{
	if (false)
	{
		wrappedMethod(val);
	}
	
	if(val >= 0)
	{
		toxicityOffset = val;
		OnToxicityChanged();
	}
}
	
@wrapMethod(W3PlayerAbilityManager) function RemoveToxicityOffset(val : float)
{
	if (false)
	{
		wrappedMethod(val);
	}
	
	if(val > 0)
	{
		toxicityOffset -= val;
		OnToxicityChanged();
	}
	
	if (toxicityOffset < 0)
	{
		toxicityOffset = 0;
		OnToxicityChanged();
	}
}

@wrapMethod(W3PlayerAbilityManager) function IsSkillEquipped(skill : ESkill) : bool
{
	var i, idx : int;

	if (false)
	{
		wrappedMethod(skill);
	}
			
	if(spectreActiveSkills.Contains(skill) && skills[skill].level > 0)
		return true;
	
	if(IsCoreSkill(skill))
		return true;
	
	
	for(i=0; i<skillSlots.Size(); i+=1)
		if(skillSlots[i].socketedSkill == skill)
			return true;
	
	
	if(tempSkills.Contains(skill))
		return true;
	
	return false;
}

@wrapMethod(W3PlayerAbilityManager)  function EquipSkill(skill : ESkill, slotID : int) : bool
{
	var idx : int;
	var prevColor : ESkillColor;

	if (false)
	{
		wrappedMethod(skill, slotID);
	}
	
	if(!HasLearnedSkill(skill) || IsCoreSkill(skill))
		return false;
		
	idx = GetSkillSlotIndex(slotID, true);		
	
	if(idx < 0)
		return false;
	
	prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
	
	UnequipSkill(slotID);

	skillSlots[idx].socketedSkill = skill;
	
	LinkUpdate(GetSkillGroupColor(skillSlots[idx].groupID), prevColor);

	if(!spectreActiveSkills.Contains(skill))
	{
		OnSkillEquip(skill);
	}
	
	return true;
}

@wrapMethod(W3PlayerAbilityManager) function UnequipSkill(slotID : int) : bool
{
	var idx : int;
	var prevColor : ESkillColor;
	var skill : ESkill;

	if (false)
	{
		wrappedMethod(slotID);
	}
	
	idx = GetSkillSlotIndex(slotID, false);									 
	if(idx < 0)
		return false;
	
	
	skill = skillSlots[idx].socketedSkill;	
	if( skill == S_SUndefined )
	{
		return false;
	}
	
	
	skillSlots[idx].socketedSkill = S_SUndefined;
	prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
	LinkUpdate(GetSkillGroupColor(skillSlots[idx].groupID), prevColor);

	if(!spectreActiveSkills.Contains(skill))
	{
		OnSkillUnequip(skill);
	}
	
	return true;
}

@wrapMethod(W3PlayerAbilityManager) function OnSkillEquip(skill : ESkill)
{
	var abs : array<name>;
	var buff : W3Effect_Toxicity;
	var witcher : W3PlayerWitcher;
	var i, skillLevel : int;
	var isPassive, isNight : bool;
	var uiState : W3TutorialManagerUIHandlerStateCharacterDevelopment;
	var battleTrance : W3Effect_BattleTrance;
	var mutagens : array<CBaseGameplayEffect>;
	var trophy : SItemUniqueId;
	var horseManager : W3HorseManager;
	var weapon, armor : W3RepairObjectEnhancement;
	var foodBuff : W3Effect_WellFed;
	var commonMenu : CR4CommonMenu;
	var guiMan : CR4GuiManager;
	var shrineBuffs : array<CBaseGameplayEffect>;
	var shrineTimeLeft, highestShrineTime : float;
	var shrineEffectIndex : int;
	var hud : CR4ScriptedHud;
	
	if (false)
	{
		wrappedMethod(skill);
	}
	
	
	if(IsCoreSkill(skill))
		return;
	
	witcher = GetWitcherPlayer();

	
	AddPassiveSkillBuff(skill);
	
	
	isPassive = theGame.GetDefinitionsManager().AbilityHasTag(skills[skill].abilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG);
	
	for( i = 0; i < GetSkillLevel(skill); i += 1 )
	{
		if(isPassive)
			owner.AddAbility(skills[skill].abilityName, true);
		else
			skillAbilities.PushBack(skills[skill].abilityName);
	}

	if ( CanUseSkill(S_Alchemy_s19) )
	{
		MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), GetSkillLevel(S_Alchemy_s19) );
	}
	
	if(skill == S_Alchemy_s20)
	{
		if ( GetWitcherPlayer().GetStatPercents(BCS_Toxicity) >= GetWitcherPlayer().GetToxicityDamageThreshold() )
			owner.AddEffectDefault(EET_IgnorePain, owner, 'IgnorePain');
	}
	else if(skill == S_Alchemy_s16)
	{
		if ( GetWitcherPlayer().GetStatPercents(BCS_Toxicity) >= GetWitcherPlayer().GetToxicityDamageThreshold() )
			thePlayer.AddAbilityMultiple(SkillEnumToName(S_Alchemy_s16), thePlayer.GetSkillLevel(S_Alchemy_s16));
	}
	else if(skill == S_Alchemy_s18)
	{
		witcher.RecalcAlchemy18Abilities();
	}
	else if(skill == S_Alchemy_s15 && owner.HasBuff(EET_Toxicity))
	{
		buff = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
		buff.RecalcEffectValue();
	}
	else if(skill == S_Alchemy_s13)
	{
		GetWitcherPlayer().RecalcTransmutationAbilities();
	}		
	else if(skill == S_Alchemy_s06)
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.OnRelevantSkillChanged( skill, true );
		}
	}
	else if(skill == S_Alchemy_s10)
	{
		thePlayer.SkillReduceBombAmmoBonus();
	}
	else if(skill == S_Magic_s11)		
	{
		((W3YrdenEntity) (witcher.GetSignEntity(ST_Yrden))).SkillEquipped(skill);
	}
	else if(skill == S_Perk_08)
	{
		
		thePlayer.ChangeAlchemyItemsAbilities(true);
	}
	else if(skill == S_Alchemy_s19)
	{
		MutagensSyngergyBonusUpdate( -1, GetSkillLevel(S_Alchemy_s19) );
	}
	else if(skill == S_Perk_01)
	{
		isNight = theGame.envMgr.IsNight();
		SetPerk01Abilities(!isNight, isNight);
	}
	else if(skill == S_Perk_05)
	{
		SetPerkArmorBonus(S_Perk_05);
	}
	else if(skill == S_Perk_06)
	{
		SetPerkArmorBonus(S_Perk_06);
	}
	else if(skill == S_Perk_07)
	{
		SetPerkArmorBonus(S_Perk_07);
	}
	else if(skill == S_Perk_11)
	{
		battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
		if(battleTrance)
			battleTrance.OnPerk11Equipped();
	}
	else if( skill == S_Perk_14 )
	{
		highestShrineTime = 0.f;
		shrineBuffs = GetWitcherPlayer().GetShrineBuffs();
		for( i = 0; i<shrineBuffs.Size() ; i+=1 )
		{
			shrineTimeLeft = shrineBuffs[i].GetDurationLeft();
			if( shrineTimeLeft > highestShrineTime )
			{
				highestShrineTime = shrineTimeLeft;
				shrineEffectIndex = i;
			}
		}
		for( i = 0; i<shrineBuffs.Size() ; i+=1 )
		{
			if( i != shrineEffectIndex )
			{
				GetWitcherPlayer().RemoveEffect( shrineBuffs[i] );
			}
		}
	}
	else if(skill == S_Perk_19 && witcher.HasBuff(EET_BattleTrance))
	{
		skillLevel = FloorF(witcher.GetStat(BCS_Focus));
		witcher.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), skillLevel);
		witcher.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), skillLevel);
	}		
	else if(skill == S_Perk_20)
	{
		thePlayer.SkillReduceBombAmmoBonus();
	}
	else if(skill == S_Perk_22)
	{
		GetWitcherPlayer().UpdateEncumbrance();
		guiMan = theGame.GetGuiManager();
		if(guiMan)
		{
			commonMenu = theGame.GetGuiManager().GetCommonMenu();
			if(commonMenu)
			{
				commonMenu.UpdateItemsCounter();
			}
		}
	}
	
	if(GetSkillPathType(skill) == ESP_Alchemy)
		witcher.RecalcPotionsDurations();
	
	
	if(ShouldProcessTutorial('TutorialCharDevEquipSkill'))
	{
		uiState = (W3TutorialManagerUIHandlerStateCharacterDevelopment)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if(uiState)
			uiState.EquippedSkill();
	}
	
	
	theGame.GetGamerProfile().CheckTrialOfGrasses();
}

@wrapMethod(W3PlayerAbilityManager) function OnSkillUnequip(skill : ESkill)
{
	var i, skillLevel : int;
	var isPassive : bool;
	var petard : W3Petard;
	var ents : array<CGameplayEntity>;
	var mutagens : array<CBaseGameplayEffect>;
	var tox : W3Effect_Toxicity;
	var names, abs : array<name>;
	var skillName : name;
	var battleTrance : W3Effect_BattleTrance;
	var trophy : SItemUniqueId;
	var horseManager : W3HorseManager;
	var witcher : W3PlayerWitcher;
	var weapon, armor : W3RepairObjectEnhancement;
	var foodBuff : W3Effect_WellFed;
	var waterBuff : W3Effect_WellHydrated;
	var commonMenu : CR4CommonMenu;
	var guiMan : CR4GuiManager;
	var hud : CR4ScriptedHud;

	if (false)
	{
		wrappedMethod(skill);
	}
					  
	if(IsCoreSkill(skill))
		return;
		
	
	isPassive = theGame.GetDefinitionsManager().AbilityHasTag(skills[skill].abilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG);
	
	skillLevel = skills[skill].level;
		
	for( i = 0; i < skillLevel; i += 1 )
	{
		if(isPassive)
			owner.RemoveAbility(skills[skill].abilityName);
		else
			skillAbilities.Remove(skills[skill].abilityName);
	}

	
	if(skill == S_Magic_s11)		
	{
		((W3YrdenEntity) (GetWitcherPlayer().GetSignEntity(ST_Yrden))).SkillUnequipped(skill);
	}
	else if(skill == S_Alchemy_s13)
	{
		GetWitcherPlayer().RecalcTransmutationAbilities();
	}
	else if(skill == S_Alchemy_s06)
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.OnRelevantSkillChanged( skill, false );
		}
	}
	else if(skill == S_Alchemy_s20)
	{
		owner.RemoveBuff(EET_IgnorePain);
	}
	else if(skill == S_Alchemy_s16)
	{
		thePlayer.RemoveAbilityAll(SkillEnumToName(S_Alchemy_s16));
	}
	else if(skill == S_Alchemy_s15 && owner.HasBuff(EET_Toxicity))
	{
		tox = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
		tox.RecalcEffectValue();
	}
	else if(skill == S_Alchemy_s18)			
	{			
		skillName = SkillEnumToName(S_Alchemy_s18);		
		charStats.RemoveAbilityAll(skillName);
	}
	else if(skill == S_Sword_s13)			
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_ThrowingAim) );
	}
	else if(skill == S_Alchemy_s08)
	{
		skillLevel = GetSkillLevel(S_Alchemy_s08);
		for (i=0; i < skillLevel; i+=1)
			thePlayer.SkillReduceBombAmmoBonus();
	}
	else if(skill == S_Perk_08)
	{
		
		thePlayer.ChangeAlchemyItemsAbilities(false);
	}
	else if(skill == S_Alchemy_s19)
	{			
		MutagensSyngergyBonusUpdate( -1, 0 );
	}
	else if(skill == S_Perk_01)
	{
		SetPerk01Abilities(false, false);
	}
	else if(skill == S_Perk_05)
	{
		UpdatePerkArmorBonus(S_Perk_05, 0);	
	}
	else if(skill == S_Perk_06)
	{
		UpdatePerkArmorBonus(S_Perk_06, 0);	
	}
	else if(skill == S_Perk_07)
	{
		UpdatePerkArmorBonus(S_Perk_07, 0);	
	}
	else if(skill == S_Perk_11)
	{
		battleTrance = (W3Effect_BattleTrance)owner.GetBuff(EET_BattleTrance);
		if(battleTrance)
			battleTrance.OnPerk11Unequipped();
	}		
	else if( skill == S_Perk_15 )
	{
		foodBuff = (W3Effect_WellFed)owner.GetBuff( EET_WellFed );
		if( foodBuff )
		{
			foodBuff.OnPerk15Unequipped();
		}
		waterBuff = (W3Effect_WellHydrated)owner.GetBuff( EET_WellHydrated );
		if( waterBuff )
		{
			waterBuff.OnPerk15Unequipped();
		}
	}
	else if(skill == S_Perk_19 && owner.HasBuff(EET_BattleTrance))
	{
		skillLevel = FloorF(owner.GetStat(BCS_Focus));
		owner.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), skillLevel);
		owner.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), skillLevel);
	}
	else if(skill == S_Perk_22)
	{
		GetWitcherPlayer().UpdateEncumbrance();
		guiMan = theGame.GetGuiManager();
		if(guiMan)
		{
			commonMenu = theGame.GetGuiManager().GetCommonMenu();
			if(commonMenu)
			{
				commonMenu.UpdateItemsCounter();
			}
		}
	}
	
	if(GetSkillPathType(skill) == ESP_Alchemy)
		GetWitcherPlayer().RecalcPotionsDurations();
	
	
	if ( CanUseSkill(S_Alchemy_s19) )
	{
		MutagensSyngergyBonusUpdate( GetSkillGroupIdFromSkill( skill ), GetSkillLevel(S_Alchemy_s19) );
	}
}

@addMethod(W3PlayerAbilityManager) function ManageSetArmorTypeBonus()
{
	var toxicity : W3Effect_Toxicity;
	var hadAbl : bool;
	
	hadAbl = charStats.HasAbility('ArmorTypeMediumSetBonusAbility');
	
	charStats.RemoveAbility('ArmorTypeHeavySetBonusAbility');
	charStats.RemoveAbility('ArmorTypeMediumSetBonusAbility');
	charStats.RemoveAbility('ArmorTypeLightSetBonusAbility');
	switch( owner.GetInventory().GetSetArmorType() )
	{
		case EAT_Heavy:
			charStats.AddAbility('ArmorTypeHeavySetBonusAbility' , false);
			break;
		case EAT_Medium:
			charStats.AddAbility('ArmorTypeMediumSetBonusAbility' , false);
			break;
		case EAT_Light:
			charStats.AddAbility('ArmorTypeLightSetBonusAbility' , false);
			break;
	}
	if(hadAbl || charStats.HasAbility('ArmorTypeMediumSetBonusAbility'))
	{
		toxicity = (W3Effect_Toxicity)owner.GetBuff(EET_Toxicity);
		if(toxicity)
			toxicity.RecalcEffectValue();
	}
}

@wrapMethod(W3PlayerAbilityManager) function OnSkillEquippedLevelChange(skill : ESkill, prevLevel : int, currLevel : int)
{
	var cnt, i : int;
	var names : array<name>;
	var skillAbilityName : name;
	var mutagens : array<CBaseGameplayEffect>;
	var recipe : SAlchemyRecipe;
	var m_alchemyManager : W3AlchemyManager;
	var ignorePain : W3Effect_IgnorePain;
	
	if (false)
	{
		wrappedMethod(skill, prevLevel, currLevel);
	}
					   
	if(IsCoreSkill(skill))
		return;

	skillAbilityName = SkillEnumToName(skill);
	if( theGame.GetDefinitionsManager().AbilityHasTag(skillAbilityName, theGame.params.SKILL_GLOBAL_PASSIVE_TAG) )
	{
		cnt = owner.GetAbilityCount(skillAbilityName);
		if(cnt < currLevel)
		{
			owner.AddAbilityMultiple(skillAbilityName, currLevel - cnt);
		}
		else
		{
			owner.RemoveAbilityMultiple(skillAbilityName, cnt - currLevel);
		}
	}

	if(skill == S_Alchemy_s08)
	{
		if(currLevel < prevLevel)
			thePlayer.SkillReduceBombAmmoBonus();
	}
	else if(skill == S_Alchemy_s18)
	{
		GetWitcherPlayer().RecalcAlchemy18Abilities();
	}
	else if(skill == S_Alchemy_s13)
	{
		GetWitcherPlayer().RecalcTransmutationAbilities();
	}
	else if(skill == S_Alchemy_s19)
	{
		
		if ( CanUseSkill(S_Alchemy_s19) )
		{
			MutagensSyngergyBonusUpdate( -1, currLevel );
		}
	}
	else if(skill == S_Alchemy_s20)
	{
		if(owner.HasBuff(EET_IgnorePain))
		{
			ignorePain = (W3Effect_IgnorePain)owner.GetBuff(EET_IgnorePain);
			ignorePain.OnSkillLevelChanged(currLevel - prevLevel);
		}
	}
	else if(skill == S_Alchemy_s16)
	{
		thePlayer.RemoveAbilityAll(SkillEnumToName(S_Alchemy_s16));
		if ( GetWitcherPlayer().GetStatPercents(BCS_Toxicity) >= GetWitcherPlayer().GetToxicityDamageThreshold() )
			thePlayer.AddAbilityMultiple(SkillEnumToName(S_Alchemy_s16), thePlayer.GetSkillLevel(S_Alchemy_s16));
	}
	else if(skill == S_Perk_08)
	{
		if(currLevel == 3)
			thePlayer.ChangeAlchemyItemsAbilities(true);
		else if(currLevel == 2 && prevLevel == 3)
			thePlayer.ChangeAlchemyItemsAbilities(false);
	}
	
	if(GetSkillPathType(skill) == ESP_Alchemy)
		GetWitcherPlayer().RecalcPotionsDurations();
}

@wrapMethod(W3PlayerAbilityManager) function NGEFixSkillPoints()
{
	var i, j : int;
	var skillType : ESkill;
	var equippedSkills : array<STempSkill>;
	var tempSkill : STempSkill;
	var skillPointsToAdd : int;
	var skillDefs : array<name>;
	var canContinue : bool;
	var used, free : int;
	
	if (false)
	{
		wrappedMethod();
	}
	
	used = GetWitcherPlayer().levelManager.GetPointsUsed(ESkillPoint);
	free = GetWitcherPlayer().levelManager.GetPointsFree(ESkillPoint);	

	skillPointsToAdd += free;

	for(i=0; i<skills.Size(); i+=1)
	{			
		skillType = skills[i].skillType;
		
		if(IsCoreSkill(skillType))
			continue;
			
		if(skillType == S_SUndefined)
			continue;
		
		
		if(IsSkillEquipped(skillType))
		{
			tempSkill.skillType = skillType;				
			tempSkill.skillSlot = GetSkillSlotID(skillType);
			tempSkill.equipped = true;	
			tempSkill.temporary = skills[i].isTemporary;
				
			if(skillType == S_Sword_s10)
			{
				if(skills[i].level >= 2)
					tempSkill.skillLevel = 2;
				else
					tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Sword_s09)
			{
				tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Sword_s13)
			{
				tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Alchemy_s09)
			{			
				tempSkill.skillLevel = 1;
			}				
			else if(skills[i].level >= 3)
				tempSkill.skillLevel = 3;
			else
				tempSkill.skillLevel = skills[i].level;
			
			equippedSkills.PushBack(tempSkill);
			
			
			UnequipSkill(GetSkillSlotID(skillType));
		}
		else if(HasLearnedSkill(skillType))
		{
			tempSkill.skillType = skillType;				
			tempSkill.skillSlot = GetSkillSlotID(skillType);
			tempSkill.equipped = false;		
			tempSkill.temporary = skills[i].isTemporary;
				
			if(skillType == S_Sword_s10)
			{
				if(skills[i].level >= 2)
					tempSkill.skillLevel = 2;
				else
					tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Sword_s09)
			{
				tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Sword_s13)
			{
				tempSkill.skillLevel = 1;
			}
			else if(skillType == S_Alchemy_s09)
			{			
				tempSkill.skillLevel = 1;
			}				
			else if(skills[i].level >= 3)
				tempSkill.skillLevel = 3;
			else
				tempSkill.skillLevel = skills[i].level;
							
			equippedSkills.PushBack(tempSkill);
		}

		if(skillType == S_Sword_s10) 
		{
			if(skills[i].level >= 3)
			{
				skillPointsToAdd += 1;
				skills[i].level = 2;	
			}
		}
		else if(skillType == S_Sword_s09) 
		{
			if(skills[i].level >= 5)
			{
				skillPointsToAdd += 4;
				skills[i].level = 1;		
			}
			else if(skills[i].level == 4)
			{
				skillPointsToAdd += 3;
				skills[i].level = 1;		
			}
			else if(skills[i].level == 3)
			{
				skillPointsToAdd += 2;
				skills[i].level = 1;	
			}
			else if(skills[i].level == 2)
			{
				skillPointsToAdd += 1;
				skills[i].level = 1;	
			}
		}
		else if(skillType == S_Sword_s13) 
		{
			if(skills[i].level >= 3)
			{
				skillPointsToAdd += 2;
				skills[i].level = 1;	
			}
			else if(skills[i].level == 2)
			{
				skillPointsToAdd += 1;
				skills[i].level = 1;	
			}
		}
		else if(skillType == S_Alchemy_s09) 
		{
			if(skills[i].level >= 3)
			{
				skillPointsToAdd += 2;
				skills[i].level = 1;	
			}
			else if(skills[i].level == 2)
			{
				skillPointsToAdd += 1;
				skills[i].level = 1;	
			}				
		}
		else if(skills[i].level == 5)
		{
			skills[i].level = 3;
			skillPointsToAdd += 2;
		}
		else if(skills[i].level == 4)
		{
			skills[i].level = 3;
			skillPointsToAdd += 1;
		}
	}
	
	
	for(i=0; i<pathPointsSpent.Size(); i+=1)
	{
		pathPointsSpent[i] = 0;
	}

	
	owner.RemoveAbilityAll('sword_adrenalinegain');
	owner.RemoveAbilityAll('magic_staminaregen');
	owner.RemoveAbilityAll('alchemy_potionduration');
	
	if( FactsQuerySum( "modSpectre_S_Alchemy_s05_Fix_2" ) < 1 )
	{
		ResetAlchemy05SkillMaxLevel();
		FactsAdd( "modSpectre_S_Alchemy_s05_Fix_2" );			 
	}
	
	charStats.GetAbilitiesWithTag('SkillDefinitionName', skillDefs);
	for(i=0; i<skillDefs.Size(); i+=1)
		CacheSkills(skillDefs[i], skills);
	InitSkills();	
	PrecacheModifierSkills();	
	
	
	for(i=0; i<equippedSkills.Size(); i+=1)
	{
		skillType = equippedSkills[i].skillType;
		if(skillType == S_SUndefined)
			continue;
		
		for(j=0; j<equippedSkills[i].skillLevel;j+=1)
		{
			AddSkill(skillType,equippedSkills[i].temporary);				
		}			
		
		if(equippedSkills[i].equipped)
			EquipSkill(skillType, equippedSkills[i].skillSlot);
	}

	
	GetWitcherPlayer().AddPoints(ESkillPoint, skillPointsToAdd, true);
	
	GetWitcherPlayer().levelManager.NGE_SetUsedPoints( used - Abs(skillPointsToAdd - free) );
	GetWitcherPlayer().levelManager.NGE_SetFreePoints( skillPointsToAdd );
	
	
	SetToxicityOffset(0.f);
}

@addMethod(W3PlayerAbilityManager) function spectreGetMutationsUsedMutagens() : array<int>
{
	var total : array<int>;
	var i : int;
	
	total.Resize(3);
	for(i = 0; i < mutations.Size(); i += 1)
	{
		total[0] += mutations[i].progress.redUsed;
		total[1] += mutations[i].progress.blueUsed;
		total[2] += mutations[i].progress.greenUsed;
	}
	
	return total;
}

@wrapMethod(W3PlayerAbilityManager) function OnMutationUnequippedPre( mutationType : EPlayerMutationType )
{
	var bank			: string;
	var i 				: int;
	var buffs			: array< CBaseGameplayEffect >;
	
	if (false)
	{
		wrappedMethod(mutationType);
	}
	
	bank = GetMutationSoundBank( mutationType );
	if( bank != "" && theSound.SoundIsBankLoaded( bank ) )
	{
		theSound.SoundUnloadBank( bank );
	}
	
	if( mutationType == EPMT_Mutation10 )
	{
		owner.RemoveBuff( EET_Mutation10 );
		owner.StopEffect( 'mutation_10' );
	}
	else if( mutationType == EPMT_Mutation12 )
	{
		buffs = GetWitcherPlayer().GetDrunkMutagens( "Mutation12" );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			owner.RemoveEffect( buffs[i] );
		}
	}
	else if( mutationType == EPMT_Mutation3 )
	{
		owner.RemoveBuff( EET_Mutation3 );
	}
	
	theGame.MutationHUDFeedback( MFT_PlayHide );
}

@wrapMethod(W3PlayerAbilityManager) function OnMutationEquippedPost( mutationType : EPlayerMutationType )
{
	var tutEquipping : W3TutorialManagerUIHandlerStateMutationsEquipping;
	var tutEquipped : W3TutorialManagerUIHandlerStateMutationsEquippedAfter;
	var bank : string;
	
	if (false)
	{
		wrappedMethod(mutationType);
	}
	
	bank = GetMutationSoundBank( mutationType );
	if( bank != "" )
	{
		theSound.SoundLoadBank( bank, true );
	}
	
	//UpdateMutationSkillSlots();
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation10 ) && GetWitcherPlayer().GetStatPercents(BCS_Toxicity) >= GetWitcherPlayer().GetToxicityDamageThreshold() && GetWitcherPlayer().IsInCombat() )
	{
		owner.AddEffectDefault( EET_Mutation10, NULL, "Mutation 10" );
	}
	
	
	if( ShouldProcessTutorial( 'TutorialMutationsEquippingOnlyOne' ) )
	{
		tutEquipping = ( W3TutorialManagerUIHandlerStateMutationsEquipping ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if( tutEquipping )
		{
			tutEquipping.OnMutationEquippedPost();
		}
		
		tutEquipped = ( W3TutorialManagerUIHandlerStateMutationsEquippedAfter ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if( tutEquipped )
		{
			tutEquipped.OnMutationEquippedPost();
		}
		
		GameplayFactsAdd( "tutorial_mutations_equipped_mutation" );
	}
}

@replaceMethod(W3PlayerAbilityManager) function OnMutationFullyResearched( mutationType : EPlayerMutationType )
{
	var idx, firstLockedSlotIdx, i : int;
	var attributeName : name;
	var min, max : SAbilityAttributeValue;
	var tutEquip : W3TutorialManagerUIHandlerStateMutationsEquipping;
	
	idx = GetMutationIndex( EPMT_MutationMaster );
	if( idx < 0 )
	{
		return;
	}
	
	
	GetMutationResearchProgress( EPMT_MutationMaster );
	
	//UpdateMutationSkillSlots();
	
	if( mutationType == EPMT_Mutation11 )
	{
		GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutation Trigger', false, true);
	}
	
	
	theGame.GetGamerProfile().AddAchievement( EA_SchoolOfTheMutant );
	
	
	if( GetResearchedMutationsCount() == 1 && !theGame.GetTutorialSystem().AreMessagesEnabled() )
	{
		SetEquippedMutation( mutationType, false );
	}
	
	
	if( ShouldProcessTutorial( 'TutorialMutationsEquipping' ) )
	{
		tutEquip = ( W3TutorialManagerUIHandlerStateMutationsEquipping ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if( tutEquip )
		{
			tutEquip.OnMutationFullyResearched();
		}
	}
}

@wrapMethod(W3PlayerAbilityManager) function AddSkillInternal(skill : ESkill, spendPoints : bool, isTemporary : bool, optional skipTutorialMessages : bool) : bool
{
	if (false)
	{
		wrappedMethod(skill, spendPoints, isTemporary, skipTutorialMessages);
	}

	if(skill == S_SUndefined )
	{
		LogAssert(false,"W3AbilityManager.AddSkill: trying to add undefined skill, aborting!");
		return false;
	}	
	if(HasLearnedSkill(skill) && skills[skill].level >= skills[skill].maxLevel)
	{
		LogAssert(false,"W3AbilityManager.AddSkill: trying to add skill already known <<" + SkillEnumToName(skill) + ">>, aborting!");
		return false;
	}
	
	
	skills[skill].level += 1;
	skills[skill].isTemporary = isTemporary;
	
	
	if(!skills[skill].isCoreSkill)
		pathPointsSpent[skills[skill].skillPath] = pathPointsSpent[skills[skill].skillPath] + 1;
	
	if(!isTemporary)
	{
		LogSkills("Skill <<" + skills[skill].abilityName + ">> learned");
		
		if(spendPoints)
			((W3PlayerWitcher)owner).levelManager.SpendPoints(ESkillPoint, skills[skill].cost);
		if ( this.IsSkillEquipped(skill) )
			OnSkillEquippedLevelChange(skill, GetSkillLevel(skill) - 1, GetSkillLevel(skill));
		theTelemetry.LogWithValueStr(TE_HERO_SKILL_UP, SkillEnumToName(skill));
	}

	if(spectreActiveSkills.Contains(skill))
	{
		if(skills[skill].level >= 1) OnSkillUnequip(skill);
		OnSkillEquip(skill);
	}
	
	return true;
}

@wrapMethod(W3PlayerAbilityManager) function ResetCharacterDev()
{
	var i : int;
	var skillType : ESkill;

	if (false)
	{
		wrappedMethod();
	}
	
	for(i=0; i<spectreActiveSkills.Size(); i+=1)
	{
		if(skills[spectreActiveSkills[i]].level != 0) OnSkillUnequip(spectreActiveSkills[i]);
	}
	
	for(i=0; i<skills.Size(); i+=1)
	{			
		skillType = skills[i].skillType;
		
		if(IsCoreSkill(skillType))
			continue;
		
		if(IsSkillEquipped(skillType))
			UnequipSkill(GetSkillSlotID(skillType));
			
		skills[i].level = 0;
	}
	
	for(i=0; i<pathPointsSpent.Size(); i+=1)
	{
		pathPointsSpent[i] = 0;
	}
	
	owner.RemoveAbilityAll('sword_adrenalinegain');
	owner.RemoveAbilityAll('magic_staminaregen');
	owner.RemoveAbilityAll('alchemy_potionduration');
}

@wrapMethod(W3PlayerAbilityManager) function GetResearchedMutationsCount() : int
{
	var researchedMutations, i : int;

	if (false)
	{
		wrappedMethod();
	}
	
	researchedMutations = 12;

	for( i=0; i<mutations.Size(); i+=1 )
	{
		if( mutations[ i ].type != EPMT_MutationMaster && GetMutationResearchProgress( mutations[ i ].type ) == 100 )
		{
			researchedMutations += 1;
		}
	}
	
	return researchedMutations;
}

@wrapMethod(W3PlayerAbilityManager) function GetStat(stat : EBaseCharacterStats, optional skipLock : bool) : float	
{
	if (false)
	{
		wrappedMethod(stat, skipLock);
	}

	return (super.GetStat(stat) );
}

@replaceMethod(W3PlayerAbilityManager) function ResetMutationsDev()
{
	var i : int;
	
	for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
	{
		UnequipSkill( mutationUnlockedSlotsIndexes[ i ] );
	}

	RemoveAllEquippedMutations();
	
	for( i=0; i<mutations.Size(); i+=1 )
	{
		mutations[i].progress.redUsed = 0;
		mutations[i].progress.blueUsed = 0;
		mutations[i].progress.greenUsed = 0;
		mutations[i].progress.skillpointsUsed = 0;
		mutations[i].progress.overallProgress = -1;	
	}
}

@wrapMethod(W3PlayerAbilityManager) function LoadMutationDataFromXML( out xmlMutations : array< SMutation > )
{
	var dm : CDefinitionsManagerAccessor;
	var main, subNode : SCustomNode;
	var xmlMutation : SMutation;
	var i, tmpInt, j : int;
	var tmpName : name;
	var tmpStr : string;
	var skillColor : ESkillColor;

	if (false)
	{
		wrappedMethod(xmlMutations);
	}
	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition( 'mutations' );
	
	xmlMutation.progress.redUsed = 0;
	xmlMutation.progress.blueUsed = 0;
	xmlMutation.progress.greenUsed = 0;
	xmlMutation.progress.skillpointsUsed = 0;
	xmlMutation.progress.overallProgress = -1;
		
	
	for( i=0; i<main.subNodes.Size(); i+=1 )
	{
		dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'type_name', tmpName );
		xmlMutation.type = MutationNameToType( tmpName );
		
		dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'redMutagenPoints', tmpInt );
		xmlMutation.progress.redRequired = tmpInt;
		
		dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'blueMutagenPoints', tmpInt );
		xmlMutation.progress.blueRequired = tmpInt;
		
		dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'greenMutagenPoints', tmpInt );
		xmlMutation.progress.greenRequired = tmpInt;
		
		dm.GetCustomNodeAttributeValueInt( main.subNodes[ i ], 'skillPoints', tmpInt );
		xmlMutation.progress.skillpointsRequired = tmpInt;
		
		dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'localizationNameKey_name', tmpName );
		xmlMutation.localizationNameKey = tmpName;
		
		dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'localizationDescriptionKey_name', tmpName );
		xmlMutation.localizationDescriptionKey = tmpName;
		
		dm.GetCustomNodeAttributeValueName( main.subNodes[ i ], 'iconPath_name', tmpName );
		xmlMutation.iconPath = tmpName;
		
		dm.GetCustomNodeAttributeValueString( main.subNodes[ i ], 'soundbank', tmpStr );
		xmlMutation.soundbank = tmpStr;
		
		
		subNode = dm.GetCustomDefinitionSubNode( main.subNodes[ i ], 'colors' );
		for( j=0; j<subNode.values.Size(); j+=1 )
		{
			skillColor = SkillColorStringToType( subNode.values[ j ] );
			xmlMutation.colors.PushBack( skillColor );
		}
		
		
		subNode = dm.GetCustomDefinitionSubNode( main.subNodes[ i ], 'required_mutations' );
		for( j=0; j<subNode.values.Size(); j+=1 )
		{
			xmlMutation.requiredMutations.PushBack( MutationNameToType( subNode.values[ j ] ) );
		}
		
		xmlMutations.PushBack( xmlMutation );
		
		xmlMutation.colors.Clear();
		xmlMutation.requiredMutations.Clear();
	}
}

@addField(W3PlayerAbilityManager)
private saved var equippedMutations : array< EPlayerMutationType >;	

@addMethod(W3PlayerAbilityManager) function IsMutationEquipped(mutationType: EPlayerMutationType): bool
{
	return equippedMutations.Contains(mutationType);
}

@addMethod(W3PlayerAbilityManager) function RemoveAllEquippedMutations(): bool
{
	var i : int;

	for( i = 0; i < equippedMutations.Size(); i += 1 )
	{
		OnMutationUnequippedPre( equippedMutations[i] );
		equippedMutations.Remove(equippedMutations[i]);
	}

	MutationsDisable();
	return true;
}

@replaceMethod(W3PlayerAbilityManager) function SetEquippedMutation( mutationType : EPlayerMutationType, unequipp: bool ) : bool
{
	if( (unequipp || mutationType == EPMT_None) && !( ( CR4Player ) owner ).IsInCombat() )
	{
		if( equippedMutations.Size() > 0 )
		{
			OnMutationUnequippedPre( mutationType );			
		}

		equippedMutations.Remove(mutationType);
		
		return true;
	}
	else if( CanEquipMutation( mutationType ) )
	{
		equippedMutations.PushBack(mutationType);

		OnMutationEquippedPost( mutationType );
		return true;
	}
	
	return false;
}

@wrapMethod(W3PlayerAbilityManager) function DEBUG_SetEquippedMutation( mutationType : EPlayerMutationType )
{
	if(false) 
	{
		wrappedMethod(mutationType);
	}

	if( mutationType == EPMT_None )
	{	
		RemoveAllEquippedMutations();
	}
	else
	{	
		equippedMutations.PushBack(mutationType);
		MutationsEnable();
		OnMutationEquippedPost( mutationType );
	}
}

@wrapMethod(W3PlayerAbilityManager) function GetMutationColors( mutationType : EPlayerMutationType ) : array< ESkillColor >
{
	var idx : int;
	var colors : array< ESkillColor >;

	if(false) 
	{
		wrappedMethod(mutationType);
	}
	
	idx = GetMutationIndex( mutationType );

	if( idx == -1 )
	{
		return colors;
	}
	
	colors = mutations[idx].colors;
	
	return colors;
}

@replaceMethod(W3PlayerAbilityManager) function UpdateMutationSkillSlots()
{
	var i : int;
	var skillType : ESkill;
	var skillColor : ESkillColor;
	var mutationColors : array< ESkillColor >;
	var mutType : array<EPlayerMutationType>;
	
	UpdateMutationSkillSlotsLocks();
			
	mutType = GetEquippedMutationType();

	if( mutType.Size() > 0)
	{
		
		mutationColors = GetMutationColors( mutType[mutType.Size()-1] );
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			
			skillType = skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].socketedSkill;
			if( skillType != S_SUndefined )
			{
				
				skillColor = GetSkillColor( skillType );					
				if( !mutationColors.Contains( skillColor ) )
				{
					UnequipSkill( GetSkillSlotID( skillType ) );
				}
			}
		}
	}
	else
	{
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			skillType = skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].socketedSkill;
			UnequipSkill( GetSkillSlotID( skillType ) );
		}
	}
}

@replaceMethod(W3PlayerAbilityManager) function UpdateMutationSkillSlotsLocks()
{
	var i, researchedCount, masterStage, unlockedCount : int;
	var tutEquip : W3TutorialManagerUIHandlerStateMutationsUnlockedSkillSlot;
	var eqMut : array<EPlayerMutationType>;

	eqMut = GetEquippedMutationType();

	if( eqMut.Size() <= 0 )
	{
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = true;
		}
	}		
	else
	{
		researchedCount = GetResearchedMutationsCount();
		masterStage = GetMasterMutationStage();
		
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = true;
			/*
			if( masterStage >= i+1 && researchedCount >= GetMutationsRequiredForMasterStage( i+1 ) )
			{
				skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = true;
				
				if( ShouldProcessTutorial( 'TutorialMutationsMasterLevelUp' ) )
				{
					tutEquip = ( W3TutorialManagerUIHandlerStateMutationsUnlockedSkillSlot ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
					if( tutEquip )
					{
						tutEquip.OnMutationSkillSlotUnlocked();
					}
				}
			}
			else
			{
				skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked = false;
			}
			*/
		}
	}
	
	if( ShouldProcessTutorial( 'TutorialMutationsAdditionalSkillSlot' ) )
	{
		unlockedCount = 0;
		for( i=0; i<mutationUnlockedSlotsIndexes.Size(); i+=1 )
		{
			if( skillSlots[ mutationUnlockedSlotsIndexes[ i ] ].unlocked )
			{
				unlockedCount += 1;
			}
		}
		GameplayFactsSet( "tutorial_mutations_unlocked_skill_slots", unlockedCount );
	}
}

@replaceMethod(W3PlayerAbilityManager) function GetEquippedMutationType() : array<EPlayerMutationType>
{
	return equippedMutations;
}