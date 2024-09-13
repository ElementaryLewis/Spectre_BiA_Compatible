@addField(CBTTaskHitReactionDecorator)
var parryStaminaCost 		: float;

@wrapMethod(CBTTaskHitReactionDecorator) function OnActivate() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats();
	
	npc.SetIsInHitAnim(true);
	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( npc, 'ActorInHitReaction', -1, 30.0f, -1.f, -1, true ); 
	
	InitializeReactionDataStorage();
	reactionDataStorage.ChangeAttitudeIfNeeded( npc, (CActor)lastAttacker );
	
	if (  ( !increaseHitCounterOnlyOnMeleeDmg || damageIsMelee ) && CheckGuardOrCounter() )
	{
		npc.DisableHitAnimFor(0.1);
		npc.SetIsInHitAnim(false);
		return BTNS_Completed;
	}
	
	return BTNS_Active;
}

@wrapMethod(CBTTaskHitReactionDecorator) function GetStats()
{
	var raiseGuardMultiplier : int;
	var counterMultiplier : int;
	var actor : CActor = GetActor();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	hitsToRaiseGuard = (int)CalculateAttributeValue(actor.GetAttributeValue('hits_to_raise_guard'));
	raiseGuardChance = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('raise_guard_chance')));
	raiseGuardMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('raise_guard_chance_mult_per_hit')));
	parryStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'parry_stamina_cost' ));
	
	hitsToCounter = (int)CalculateAttributeValue(actor.GetAttributeValue('hits_to_roll_counter'));
	counterChance = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance')));
	counterMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance_per_hit')));
	
	counterStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'counter_stamina_cost' ));
	
	raiseGuardChance += Max( 0, actor.GetHitCounter() - 1 ) * raiseGuardMultiplier;
	counterChance += Max( 0, actor.GetHitCounter() - 1 ) * counterMultiplier;
	
	if ( hitsToRaiseGuard < 0 )
	{
		hitsToRaiseGuard = 65536;
	}
}

@wrapMethod(CBTTaskHitReactionDecorator) function CheckGuardOrCounter() : bool
{
	var npc : CNewNPC = GetNPC();
	var hitCounter : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( npc.HasTag( 'olgierd_gpl' ) )
	{
		if( AbsF( NodeToNodeAngleDistance( thePlayer, npc ) ) > 90 )
		{
			return false;
		}
	}
	
	GetStats();
	hitCounter = npc.GetHitCounter();
	if ( hitCounter >= hitsToRaiseGuard && npc.CanGuard() )
	{
		if( Roll( raiseGuardChance ) && npc.GetStat( BCS_Stamina ) >= parryStaminaCost )
		{		
			if ( npc.RaiseGuard() )
			{
				npc.SignalGameplayEvent('HitReactionTaskCompleted');
				return true;
			}
		}
	}
	if ( !npc.IsHuman() && hitCounter >= hitsToCounter && npc.GetMovingAgentComponent().GetName() != "wild_hunt_base" && !npc.HasTag( 'dettlaff_vampire' )  )
	{
		if( Roll( counterChance ) && npc.GetStat( BCS_Stamina ) >= counterStaminaCost )
		{
			npc.SignalGameplayEvent('LaunchCounterAttack');
			return true;
		}
	}
	
	return false;
}

@wrapMethod(CBTTaskHitReactionDecorator) function OnListenedGameplayEvent( eventName : name ) : bool
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	if ( eventName == 'BeingHit' )
	{			
		damageData 		= (CDamageData) GetEventParamBaseDamage();
		damageIsMelee 	= damageData.isActionMelee;
		
		lastAttacker = damageData.attacker;
		
		if ( !npc.IsInFistFightMiniGame() && (CActor)lastAttacker )
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( lastAttacker, 'CombatNearbyAction', 5.f, 10.f, 999.0f, -1, true); 
		
		rotateNode = GetRotateNode();
		
		if ( !increaseHitCounterOnlyOnMeleeDmg || (increaseHitCounterOnlyOnMeleeDmg && damageIsMelee) )
			npc.IncHitCounter();			
		
		
		if ( isActive && CheckGuardOrCounter() )
		{
			npc.DisableHitAnimFor(0.1);
			Complete(true);
			return false;
		}
		
		if ( damageData.hitReactionAnimRequested  )
			return true;
		else
			return false;
	}
	else if ( eventName == 'CriticalState' )
	{
		if ( isActive )
		{
			Complete(true);
		}
		else
			npc.DisableHitAnimFor(0.1);
	}
	else if ( eventName == 'CounterExecuted' )
	{
		npc.ResetHitCounter( 0, 0 );
	}
	
	return false;
}