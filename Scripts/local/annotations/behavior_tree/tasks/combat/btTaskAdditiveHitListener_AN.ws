@addField(BTTaskAdditiveHitListener)
var parryStaminaCost 				: float; //modEHGM

@wrapMethod(BTTaskAdditiveHitListener) function CheckGuardOrCounter() : bool
{
	var npc : CNewNPC = GetNPC();
	var hitCounter : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats();
	hitCounter = npc.GetHitCounter();
	if ( hitCounter >= hitsToRaiseGuard && npc.CanGuard() )
	{
		
		if( Roll( raiseGuardChance ) && npc.GetStat( BCS_Stamina ) >= parryStaminaCost ) //modEHGM: parry stamina check
		{		
			if ( npc.RaiseGuard() )
			{
				npc.SignalGameplayEvent('HitReactionTaskCompleted');
				return true;
			}
		}
	}
	if ( !npc.IsHuman() && GetActor().GetMovingAgentComponent().GetName() != "wild_hunt_base" && hitCounter >= hitsToCounter  )
	{
		if( Roll( counterChance ) && npc.GetStat( BCS_Stamina ) >= counterStaminaCost )
		{
			npc.SignalGameplayEvent('LaunchCounterAttack');
			return true;
		}
	}
	
	return false;
}

@wrapMethod(BTTaskAdditiveHitListener) function GetStats()
{
	var raiseGuardMultiplier 	: int;
	var counterMultiplier 		: int;
	var actor 					: CActor = GetActor();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	hitsToRaiseGuard = (int)CalculateAttributeValue(actor.GetAttributeValue('hits_to_raise_guard'));
	raiseGuardChance = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('raise_guard_chance')));
	raiseGuardMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('raise_guard_chance_mult_per_hit')));
	parryStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'parry_stamina_cost' )); //modEHGM
	
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