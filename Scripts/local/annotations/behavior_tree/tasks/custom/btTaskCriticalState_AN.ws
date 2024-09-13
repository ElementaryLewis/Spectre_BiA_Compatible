@wrapMethod(CBehTreeTaskCriticalState) function OnDeactivate()
{	
	var currBuff : CBaseGameplayEffect;
	var nextBuff : CBaseGameplayEffect;
	var nextBuffType : ECriticalStateType;
	var owner : CNewNPC;
	var forceRemoveCurrentBuff : bool;
	var tempB : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	owner = GetNPC();
	
	if( owner.IsInFinisherAnim() )
	{
		activate = true;
		return;
	}		
	
	nextBuff = owner.ChooseNextCriticalBuffForAnim();
	nextBuffType = GetBuffCriticalType(nextBuff);
	if ( nextBuffType == ECST_BurnCritical && owner.HasAbility( 'BurnNoAnim' ) )
	{
		tempB = true;
	}
	
	
	
	if(!nextBuff || (currentCS == nextBuffType))
	{			
		forceRemoveCurrentBuff = true;
	}
	else
	{
		forceRemoveCurrentBuff = false;
	}
	
	owner.CriticalStateAnimStopped(forceRemoveCurrentBuff);
	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( owner, 'RecoveredFromCriticalEffect', -1, 30.0f, -1.f, -1, true ); 
	
	activate = false;
	
	if(!nextBuff)
	{
		
		currBuff = owner.GetCurrentlyAnimatedCS();
		CriticalBuffDisallowPlayAnimation(currBuff);
	}
	else if ( !tempB && !owner.HasAbility( 'ablIgnoreSigns' ) )
	{
		forceActivate = true;
	}
	
	currentCS = ECST_None;
	owner.EnableCollisions( true );
	owner.SetIsInHitAnim(false);
	owner.SetBehaviorVariable('bCriticalStopped',1.f);
}

@wrapMethod(CBehTreeTaskCriticalState) function OnListenedGameplayEvent( gameEventName : name ) : bool
{
	var npc : CNewNPC;
	
	var receivedBuffType 	: ECriticalStateType;
	var receivedBuff	: CBaseGameplayEffect;
	
	var currentBuffPriority		: int;
	var receivedBuffPriority	: int;
	
	if(false) 
	{
		wrappedMethod(gameEventName);
	}
	
	if ( gameEventName == 'ForceCS' )
	{
		forceActivate = true;
	}
	else if ( gameEventName == 'CriticalState' )
	{
		receivedBuffType = this.GetEventParamInt(-1);
		
		npc = GetNPC();
		
		
		
		if ( receivedBuffType == ECST_BurnCritical && ( npc.HasAbility( 'BurnNoAnim' ) ) )
		{
			npc.SignalGameplayEvent('CSBurningNoAnim');
			return false;
		}
		
		if ( npc.HasAbility( 'ablIgnoreSigns' ) )
			return false;
		
		if ( ShouldBeScaredOnOverlay() )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( GetNPC(), 'TauntAction', -1, 1.f, -1.f, 1, false ); 
			return false;
		}
		
		activate = true;
		activateTimeStamp = GetLocalTime();
		
		if( isActive ) 
		{
			if( IsStagger( receivedBuffType ) && IsStagger( currentCS ) )
			{
				Complete( true );
			}
			else
			{
				currentBuffPriority = CalculateCriticalStateTypePriority( currentCS );
				receivedBuffPriority = CalculateCriticalStateTypePriority( receivedBuffType );
				
				if ( receivedBuffPriority > currentBuffPriority )
				{
					Complete( true );
				}
			}
		}
	}
	else if ( gameEventName == 'RagdollFromHorse'  )
	{
		forceActivate = true;
	}
	
	currentCS = receivedBuffType;
	
	return IsAvailable();
}