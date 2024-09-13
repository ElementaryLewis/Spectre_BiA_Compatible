@addMethod(W3AbilityManager) function GetAttributeValueUnsafe(attributeName : name, optional tags : array<name>) : SAbilityAttributeValue
{
	return GetAttributeValueInternal(attributeName, tags);
}

@replaceMethod(W3AbilityManager) function GetResistValue(stat : ECharacterDefenseStats, out points : float, out percents : float)
{
	var pts, prc, charPts, charPerc : SAbilityAttributeValue;
	var buff : W3Mutagen20_Effect;
	var resistStat : SResistanceValue; 
	
	if ( GetResistStat( stat, resistStat ) )
	{
		charPts = resistStat.points;
		charPerc = resistStat.percents;		
	}

	points = CalculateAttributeValue(charPts);
	percents = MinF(1, CalculateAttributeValue(charPerc));		
	return;
}

@wrapMethod(W3AbilityManager) function ForceSetStat( stat : EBaseCharacterStats, val : float )
{
	var prev : float;
	
	if(false) 
	{
		wrappedMethod(stat, val);
	}
		
	prev = GetStat(stat);
	SetStatPointCurrent(stat, MinF(GetStatMax(stat), MaxF(0, val)) );
	
	if(prev != GetStat(stat))
	{
		if( stat == BCS_Vitality )
		{
			OnVitalityChanged();				
		}
		else if( stat == BCS_Stamina )
		{
			OnStaminaChanged();
		}
		else if( stat == BCS_Toxicity )
		{
			OnToxicityChanged();
		}
		else if( stat == BCS_Focus )
		{
			OnFocusChanged();
		}
		else if( stat == BCS_Air )
		{
			OnAirChanged();
		}
		else if( stat == BCS_Essence )
		{
			OnEssenceChanged();
		}
	}
}

@wrapMethod(W3AbilityManager) function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float) : float
{
	var cost, delay : float;
	var signEnt : W3SignEntity;
	
	if(false) 
	{
		wrappedMethod(action, fixedCost, fixedDelay, abilityName, dt, costMult);
	}

	GetStaminaActionCost(action, cost, delay, fixedCost, fixedDelay, abilityName, dt, costMult);
	
	
	if(cost > 0)
	{
		InternalReduceStat(BCS_Stamina, cost);
		owner.StartStaminaRegen();
	}
	
	if(owner == GetWitcherPlayer())
	{
		spectreModStaminaDelay(delay);
	}
	
	
	if(delay > 0) 
	{
		if(IsNameValid(abilityName))
			owner.PauseStaminaRegen( abilityName, delay );
		else
			owner.PauseStaminaRegen( StaminaActionTypeToName(action), delay );
	}

	if(owner == thePlayer)
		thePlayer.CheckForLowStamina();
	else
		owner.CheckShouldWaitForStaminaRegen();
	
	if(cost > 0)
		OnStaminaChanged();
	
	return cost;
}

@replaceMethod(W3AbilityManager) function GainStat( stat : EBaseCharacterStats, amount : float )
{
	var statWithoutLock, statWithLock, lock, max : float;

	statWithoutLock = GetStat(stat, true);
	statWithLock = GetStat(stat, false);
	lock = statWithLock - statWithoutLock;
	max = GetStatMax(stat);
	
	SetStatPointCurrent(stat, MinF( max - lock, statWithoutLock + MaxF(0, amount) ) );
	
	if( stat == BCS_Vitality )
	{
		OnVitalityChanged();
		if ( (W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats') && GetWitcherPlayer().IsInCombat() && (statWithoutLock + amount) > max )
		{
			if(!thePlayer.HasBuff(EET_Runeword4))
				thePlayer.AddEffectDefault(EET_Runeword4, NULL, "");
			((W3Effect_Runeword4)thePlayer.GetBuff(EET_Runeword4)).IncOverhealBonus((statWithoutLock + amount) - GetStatMax(stat));
		}
	}
	else if( stat == BCS_Toxicity )
		OnToxicityChanged();
	else if( stat == BCS_Stamina )
		OnStaminaChanged();
	else if( stat == BCS_Focus )
	{
		OnFocusChanged();
		if((W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && GetWitcherPlayer().IsInCombat() && (statWithoutLock + amount) > max)
		{
			if(GetWitcherPlayer().HasRunewordActive('Runeword 11 _Stats'))
			{
				if(!thePlayer.HasBuff(EET_Runeword11))
					thePlayer.AddEffectDefault(EET_Runeword11, NULL, "");
				((W3Effect_Runeword11)thePlayer.GetBuff(EET_Runeword11)).IncBonusAdrenaline((statWithoutLock + amount) - GetStatMax(stat));
			}
		}
	}
	else if( stat == BCS_Essence )
		OnEssenceChanged();
}

@addMethod(W3AbilityManager) function OnStaminaChanged();

@wrapMethod(W3AbilityManager) function OnAbilityRemoved( abilityName : name )
{
	if(false) 
	{
		wrappedMethod(abilityName);
	}
	
	if( abilityName == 'Runeword 4 _Stats' )
	{
		thePlayer.RemoveBuff(EET_Runeword4);
	}
	if( abilityName == 'Runeword 1 _Stats' )
		thePlayer.RemoveBuff(EET_Runeword11);
	
	OnAbilityChanged( abilityName );
}

@wrapMethod(W3AbilityManager) function OnAbilityChanged( abilityName : name )
{
	var atts, tags : array<name>;
	var attribute : name;
	var i,size,stat, j : int;
	var oldMax, maxVit, maxEss : float;
	var resistStatChanged, tmpBool : bool;
	var dm : CDefinitionsManagerAccessor;
	var val : SAbilityAttributeValue;
	var buffs : array<CBaseGameplayEffect>;
	var regenBuff : W3RegenEffect;
	
	if(false) 
	{
		wrappedMethod(abilityName);
	}
	
	if(!owner)
		return;		
			
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributes(abilityName, atts);		
	resistStatChanged = false;
	size = atts.Size();
	
	
	if(dm.AbilityHasTag(abilityName, theGame.params.DIFFICULTY_TAG_IGNORE))
	{
		ignoresDifficultySettings = true;
		difficultyAbilities.Clear();
		usedDifficultyMode = EDM_NotSet;
	}
	
	for(i=0; i<size; i+=1)
	{					
		attribute = atts[ i ];
		if ( ( attribute == 'vitality' && UsesEssence() )
			|| ( attribute == 'essence' && UsesVitality() ) )
		{
			continue;
		}
	
		stat = StatNameToEnum( attribute );
		if(stat != BCS_Undefined)
		{
			if(!HasStat(stat))
			{
				
				StatAddNew(stat);
			}
			else
			{
				
				if(abilityName == theGame.params.GLOBAL_ENEMY_ABILITY || abilityName == theGame.params.GLOBAL_PLAYER_ABILITY || abilityName == theGame.params.ENEMY_BONUS_PER_LEVEL)
				{
					
					UpdateStatMax(stat);
					RestoreStat(stat);
				}
				else
				{
					
					oldMax = GetStatMax(stat);
					UpdateStatMax(stat);
					MutliplyStatBy(stat, GetStatMax(stat) / oldMax);
				}
			}
			continue;
		}
		
		
		stat = ResistStatNameToEnum(attribute, tmpBool);
		if(stat != CDS_None)
		{
			if ( HasResistStat( stat ) )
			{
				RecalcResistStat(stat);
				resistStatChanged = true;
			}								
			else
			{
				
				ResistStatAddNew(stat);
			}
			
			continue;
		}
		
		
		stat = RegenStatNameToEnum(attribute);
		if(stat != CRS_Undefined && stat != CRS_UNUSED)
		{
			buffs = owner.GetBuffs();
			
			for(j=0; j<buffs.Size(); j+=1)
			{
				regenBuff = (W3RegenEffect)buffs[j];
				if(regenBuff)
				{
					if(regenBuff.GetRegenStat() == stat && IsBuffAutoBuff(regenBuff.GetEffectType()))
					{
						regenBuff.UpdateEffectValue();
						break;
					}
				}
			}
			if( stat == CRS_Essence )
			{
				owner.StartEssenceRegen();
			}

			else if( stat == CRS_Vitality )
				owner.StartVitalityRegen();
			else if( stat == CRS_Stamina )
				owner.StartStaminaRegen();
		}
		
		
		if(!ignoresDifficultySettings && attribute == theGame.params.DIFFICULTY_HP_MULTIPLIER)
		{		
			

			maxVit = GetStatMax( BCS_Vitality );
			maxEss = GetStatMax( BCS_Essence );
			if(maxVit > 0)
			{
				oldMax = maxVit;
				UpdateStatMax(BCS_Vitality);					
				MutliplyStatBy(BCS_Vitality, GetStatMax(BCS_Vitality) / oldMax);
			}
			
			if(maxEss > 0)
			{
				oldMax = maxEss;
				UpdateStatMax(BCS_Essence);					
				MutliplyStatBy(BCS_Essence, GetStatMax(BCS_Essence) / oldMax);
			}
			
			continue;
		}		
	}
	
	if(resistStatChanged)
	{
		owner.RecalcEffectDurations();
	}
}