@wrapMethod(BTTaskManageDjinnRage) function Main() : EBTNodeStatus
{
	var l_owner		: CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	while ( true )
	{
		if(l_owner.HasBuff(EET_DimeritiumEffect))
		{
			if(m_inRageState)
				RemoveRageState();
			if(!m_inWeakenedState)
				EnterWeakenedState();
		}
		else
		{
			if ( m_inRageState && GetLocalTime() >= m_enterRageTimeStamp + calmDownCooldown )
			{
				RemoveRageState();
			}
			
			if ( !m_inWeakenedState && l_owner.HasBuff( EET_Confusion ) || l_owner.HasBuff( EET_AxiiGuardMe ) )
			{
				RemoveRageState();
				EnterWeakenedState();
			}
			
			if ( m_inWeakenedState && !m_isInYrden && GetLocalTime() >= m_enterWeakendTimeStamp + calmDownCooldown )
				RemoveWeakenedState();
		}
		
		SleepOneFrame();
	}
	
	return BTNS_Active;
}

@wrapMethod(BTTaskManageDjinnRage) function OnListenedGameplayEvent( eventName : name ) : bool
{
	var l_owner			: CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	if ( eventName == 'EntersYrden' )
	{
		m_isInYrden = true;
		EnterWeakenedState();
		return true;
	}
	else if ( eventName == 'LeavesYrden' )
	{
		m_isInYrden = false;
		
		return true;
	}
	else if ( removeWeakenedStateOnCounter && ( eventName == 'LaunchCounterAttack' || eventName == 'HitReactionTaskCompleted' ) )
	{
		if ( !m_isInYrden && !l_owner.HasBuff(EET_DimeritiumEffect) )
			RemoveWeakenedState();
		return true;
	}
	else if ( eventName == 'IgniHitReceived' )
	{
		if ( !m_isInYrden && !l_owner.HasBuff( EET_Confusion ) && !l_owner.HasBuff( EET_AxiiGuardMe ) && !l_owner.HasBuff(EET_DimeritiumEffect) )
		{
			EnterRageState();
			l_owner.PlayEffectSingle( playFXOnIgniHit );
			l_owner.PlayEffectSingle( playFXOnAardHit );
		}
		return true;
	}
	else if ( eventName == 'AardHitReceived' )
	{
		if ( !m_isInYrden && !l_owner.HasBuff( EET_Confusion ) && !l_owner.HasBuff( EET_AxiiGuardMe ) && !l_owner.HasBuff(EET_DimeritiumEffect) )
		{
			EnterRageState();
			l_owner.PlayEffectSingle( playFXOnAardHit );
		}
		return true;
	}
	else if ( eventName == 'Death' )
	{
		l_owner.StopAllEffects();
		return true;
	}
	
	return false;
}