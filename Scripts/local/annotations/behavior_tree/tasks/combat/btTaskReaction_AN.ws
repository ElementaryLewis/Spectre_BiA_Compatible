@wrapMethod(CBTTaskReaction) function Main() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if ( (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy ) && counterChance > 0)
	{
		if (RandRange(100) < counterChance)
		{
			if( npc.RaiseForceEvent( 'CounterAttack' ) )
			{
				npc.WaitForBehaviorNodeDeactivation( 'CounterAttackEnd', 10.0f );
				Time2Dodge = false;
				return BTNS_Completed;
			}
		}
	}
	else
	{
		if( ChooseAndCheckDodge() )
		{
			if( npc.RaiseForceEvent( 'Dodge' ) )
			{
				npc.WaitForBehaviorNodeDeactivation( 'DodgeEnd', 10.0f );
				Time2Dodge = false;
				return BTNS_Completed;
			}
		}
	}
	return BTNS_Failed;
}

@wrapMethod(CBTTaskReaction) function ChooseAndCheckDodge() : bool
{
	var npc : CNewNPC = GetNPC();
	var dodgeChance : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if ( npc.HasBuff(EET_CounterStrikeHit) )
		return false;
	
	if( !Time2Dodge )
	{
		return false;
	}
	
	switch (dodgeType)
	{
		case EDT_Attack_Light	: dodgeChance = dodgeChanceAttacks; break;
		case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttacks; break;
		case EDT_Aard			: dodgeChance = dodgeChanceAard; break;
		case EDT_Igni			: dodgeChance = dodgeChanceIgni; break;
		case EDT_Bomb			: dodgeChance = dodgeChanceBomb; break;
		case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; break;
		default : return false;
	}
	
	if (RandRange(100) < dodgeChance)
	{
		if ( dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy )
		{
			npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Back);
		}
		else
		{
			npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Left);
		}
		return true;
	}
	
	return false;
}

@wrapMethod(CBTTaskReaction) function OnGameplayEvent( eventName : name ) : bool
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	if ( eventName == 'Time2Dodge' && (nextReactionTime < GetLocalTime()) && !npc.HasBuff(EET_CounterStrikeHit) )
	{
		Time2Dodge = true;
		dodgeType = this.GetEventParamInt(-1);
		return true;
	}
	return false;
}