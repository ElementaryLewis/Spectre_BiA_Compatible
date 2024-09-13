@addField(CBTTaskPerformParry)
var parryStaminaCost : float;

@addField(CBTTaskPerformParry)
var counterStaminaCost : float;

@wrapMethod(CBTTaskPerformParry)  function IsAvailable() : bool
{
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats();
		
	InitializeCombatDataStorage();
	
	if ( GetNPC().HasBuff(EET_CounterStrikeHit) )
		return false;
	
	if ( ((CHumanAICombatStorage)combatDataStorage).IsProtectedByQuen() )
	{
		GetNPC().SetParryEnabled(true);
		return false;
	}
	else if ( activationTimeLimit > 0.0 && ( isActive || !combatDataStorage.GetIsAttacking() ) )
	{
		if ( GetLocalTime() < activationTimeLimit )
		{
			return GetNPC().GetStat( BCS_Stamina ) >= parryStaminaCost;
		}
		activationTimeLimit = 0.0;
		return false;
	}
	else if ( GetNPC().HasShieldedAbility() && activationTimeLimit > 0.0 )
	{
		GetNPC().SetParryEnabled(true);
		return false;
	}
	else
		GetNPC().SetParryEnabled(false);
		
	return false;
}

@wrapMethod(CBTTaskPerformParry) function OnActivate() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats(); 
		
	if ( swingDir != -1 )
	{
		npc.SetBehaviorVariable( 'HitSwingDirection', swingDir );
	}
	if ( swingType != -1 )
	{
		npc.SetBehaviorVariable( 'HitSwingType', swingType );
	}
	
	InitializeCombatDataStorage();
	npc.SetParryEnabled(true);
	LogChannel( 'HitReaction', "TaskActivated. ParryEnabled" );
	
	if ( action == 'ParryPerform' )
	{
		if ( TryToParry() )
		{
			runMain = true;
			RunMain();
		}
		action = '';
	}
	
	if ( CheckCounter() && interruptTaskToExecuteCounter )
	{
		npc.DisableHitAnimFor(0.1);
		activationTimeLimit = 0.0;
		return BTNS_Completed;
	}
	
	return BTNS_Active;
}

@wrapMethod(CBTTaskPerformParry) function CheckCounter() : bool
{
	var npc : CNewNPC = GetNPC();
	var defendCounter : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats();
		
	defendCounter = npc.GetDefendCounter();
	if ( defendCounter >= hitsToCounter )
	{
		if( Roll( counterChance ) && GetNPC().GetStat( BCS_Stamina ) >= counterStaminaCost )
		{
			npc.SignalGameplayEvent('CounterFromDefence');
			return true;
		}
	}
	
	return false;
}

@wrapMethod(CBTTaskPerformParry) function GetStats()
{
	var actor : CActor = GetActor();
	var multiplier : float;
	
	if(false) 
	{
		wrappedMethod();
	}

	if( FactsQuerySum("NewGamePlus") > 0 )
		multiplier = 1.15;
	else
		multiplier = 1.0;
	
	drainStaminaOnUse = false;
	parryStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'parry_stamina_cost' ));																								 
	counterChance = MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance')));
	counterMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance_per_hit')));
	hitsToCounter = (int)MaxF(0, CalculateAttributeValue(actor.GetAttributeValue('hits_to_roll_counter')));
	counterChance += Max( 0, actor.GetDefendCounter() ) * counterMultiplier;
	counterStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'counter_stamina_cost' ));																									 
	
	if ( hitsToCounter < 0 )
	{
		hitsToCounter = 65536;
	}
}

@wrapMethod(CBTTaskPerformParry) function TryToParry(optional counter : bool) : bool
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(counter);
	}

	GetStats();
		
	if ( isActive && npc.CanParryAttack() && allowParryOverlap && (!counter && npc.GetStat( BCS_Stamina ) >= parryStaminaCost || counter && npc.GetStat( BCS_Stamina ) >= counterStaminaCost) )
	{
		LogChannel( 'HitReaction', "Parried" );
		
		npc.SignalGameplayEvent('SendBattleCry');
		

		if ( npc.RaiseEvent('ParryPerform') )
		{
			if( counter )
			{
				npc.SignalGameplayEvent('Counter');
			}
			else
			{
				npc.DrainStamina(ESAT_FixedValue, parryStaminaCost, staminaDelay);
			}
			
			((CHumanAICombatStorage)combatDataStorage).IncParryCount();
			npc.IncDefendCounter();
			activationTimeLimit = GetLocalTime() + 0.5;
		}
		else
		{
			Complete(false);
		}
		
		return true;
		
	}
	else if ( isActive )
	{
		Complete(false);
		activationTimeLimit = 0.0;
	}
	
	
	return false;
}

@wrapMethod(CBTTaskPerformParry) function OnListenedGameplayEvent( eventName : name ) : bool
{
	var res : bool;
	var isHeavy : bool;
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	InitializeCombatDataStorage();
	
	if ( eventName == 'swingType' )
	{
		swingType = this.GetEventParamInt(-1);
	}
	if ( eventName == 'swingDir' )
	{
		swingDir = this.GetEventParamInt(-1);
	}
	
	
	if ( eventName == 'ParryStart' )
	{
		GetStats();
		
		if ( interruptTaskToExecuteCounter && CheckCounter() && !npc.IsCountering() )
		{
			npc.DisableHitAnimFor(0.1);
			activationTimeLimit = 0.0;
			Complete(true);
			return false;
		}
		
		if( npc.GetStat( BCS_Stamina ) >= parryStaminaCost )
		{
			isHeavy = GetEventParamInt(-1);
			
			if ( isHeavy )
				activationTimeLimit = GetLocalTime() + activationTimeLimitBonusHeavy;
			else
				activationTimeLimit = GetLocalTime() + activationTimeLimitBonusLight;
			
			if ( npc.HasShieldedAbility() )
			{
				npc.SetParryEnabled(true);
			}
		}
		return true;
	}
	
	else if ( eventName == 'ParryPerform' )
	{
		GetStats();
		
		if( AdditiveParry() )
			return true;
		
		if( !isActive )
			return false;
		
		isHeavy = GetEventParamInt(-1);
		if( ShouldCounter(isHeavy) )
			res = TryToParry(true);
		else
			res = TryToParry(false);
		
		if( res )
		{
			runMain = true;
			RunMain();
		}		
		return true;
	}
	
	else if ( eventName == 'CounterParryPerform' )
	{
		GetStats();
		
		if ( TryToParry(true) )
		{
			runMain = true;
			RunMain();
		}
		return true;
	}
	
	else if( eventName == 'ParryStagger' )
	{
		GetStats();
		
		if( !isActive )
			return false;
			
		if( npc.HasShieldedAbility() )
		{
			npc.AddEffectDefault( EET_Stagger, GetCombatTarget(), "ParryStagger" );
			runMain = false;
			activationTimeLimit = 0.0;
		}
		else if ( TryToParry() )
		{
			npc.LowerGuard();
			runMain = false;
		}
		return true;
	}
	
	else if ( eventName == 'ParryEnd' )
	{
		activationTimeLimit = 0.0;
		return true;
	}
	else if ( eventName == 'PerformAdditiveParry' )
	{
		AdditiveParry(true);
		return true;
	}
	else if ( eventName == 'WantsToPerformDodgeAgainstHeavyAttack' && GetActor().HasAbility('ablPrioritizeAvoidingHeavyAttacks') )
	{
		activationTimeLimit = 0.0;
		if ( isActive )
			Complete(true);
		return true;
	}
	
	return super.OnGameplayEvent ( eventName );
}

@wrapMethod(CBTTaskPerformParry) function ShouldCounter(isHeavy : bool) : bool
{
	var playerTarget : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod(isHeavy);
	}

	if ( GetActor().HasAbility('DisableCounterAttack') )
		return false;
	
	playerTarget = (W3PlayerWitcher)GetCombatTarget();
	
	if ( playerTarget && playerTarget.IsInCombatAction_SpecialAttack() )
		return false;
	
	if ( isHeavy && !GetActor().HasAbility('ablCounterHeavyAttacks') )
		return false;
		
	return ((CHumanAICombatStorage)combatDataStorage).GetParryCount() >= hitsToCounter && Roll(counterChance) && GetNPC().GetStat( BCS_Stamina ) >= counterStaminaCost;
}