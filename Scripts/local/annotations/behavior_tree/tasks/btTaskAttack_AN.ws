@wrapMethod(CBTTaskAttack) function IsAvailable() : bool
{
	var target : CActor = GetCombatTarget();
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( unavailableWhenInvisibleTarget && target && !target.GetGameplayVisibility() )
	{
		return false;
	}
	
	return super.IsAvailable();
}

@wrapMethod(CBTTaskAttack) function OnActivate() : EBTNodeStatus
{
	if( !IsAvailable() ) //modEHGM
	{
		Complete(false);
		return BTNS_Failed;
	}
		
	wrappedMethod();
	
	return super.OnActivate();
}

@addMethod(CBTTaskAttack) function GetStats()
{
	super.GetStats();
	if((GetActor().HasAbility('mon_ghoul_base') || GetActor().HasAbility('mon_bear_base')) && (xmlStaminaCostName == 'light_action_stamina_cost' || xmlStaminaCostName == 'counter_stamina_cost'))
		drainStaminaOnUse = false;
	else
		drainStaminaOnUse = true;
}

@wrapMethod(CBTTaskAttackDef) function OnSpawn( task : IBehTreeTask )
{
	var thisTask : CBTTaskAttack; 
	
	wrappedMethod(task);
	
	thisTask = (CBTTaskAttack)task;
	
	thisTask.drainStaminaOnUse = true;

	if( attackType == EAT_Attack20 )
	{
		thisTask.xmlStaminaCostName = 'counter_stamina_cost';
		thisTask.checkStats = true;
	}
	else
	{
		thisTask.xmlStaminaCostName = 'light_action_stamina_cost';
	}
}