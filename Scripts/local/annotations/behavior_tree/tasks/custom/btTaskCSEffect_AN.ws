@wrapMethod(CBehTreeTaskCSEffect) function ShouldEnableFinisher() : bool
{
	var actor : CActor;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	actor = GetActor();

	
	if( (CSType == ECST_HeavyKnockdown || forceFinisherActivation) && GetWitcherPlayer() && GetAttitudeBetween( actor, thePlayer ) == AIA_Hostile && actor.IsVulnerable() && actor.GetComponent( "Finish" ) )
	{
		return true;
	}
	
	return false;
}

@wrapMethod(CBehTreeTaskCSEffect) function OnGameplayEvent( eventName : name ) : bool
{
	var effect 			: CBaseGameplayEffect;
	var data 			: CDamageData;
	var npc 			: CNewNPC;
	var syncAnimName 	: name;
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	npc = GetNPC();
	if ( eventName == 'RotateEventStart' )
	{
		effect = npc.GetBuff(getBuffType( CSType ));
		npc.SetRotationAdjustmentRotateTo( (CNode)(effect.GetCreator()) );
		return true;
	}
	else if ( eventName == 'StoppingEffect' && finisherEnabled && GetEventParamInt(-1) == CSType )
	{
		npc.EnableFinishComponent( false );
		thePlayer.AddToFinishableEnemyList( npc, false );
		finisherEnabled = false;
		return true;
	}
	else if ( eventName == 'Finisher' )
	{
		if ( CombatCheck() && finisherEnabled )
		{
			npc.EnableFinishComponent( false );
			thePlayer.AddToFinishableEnemyList( npc, false );
			npc.FinisherAnimStart();
			FinisherSyncAnim();
		}
		return true;
	}
	else if ( eventName == 'ParryStart' && ShouldCompleteOnParryStart() && npc.IsShielded(GetCombatTarget()) )
	{
		Complete(true);
		return true;
	}
	else if ( eventName == 'DisableFinisher' )
	{
		finisherDisabled = true;
		DisableFinisher();
		return true;
	}
	else if ( eventName == 'EnableFinisher' )
	{
		finisherDisabled = false;
		EnableFinisher();
		return true;
	}
	else if ( eventName == 'ForceStopCriticalEffect' && GetEventParamInt(-1) == CSType )
	{
		Complete(true);
		return true;
	}
	else if	( eventName == 'SpearDestruction' )
	{
		npc.ProcessSpearDestruction();
		waitForDropItem = false;
		return true;
	}
	else if ( eventName == 'OnRagdollPullingStart' )
	{
		ragdollPullingEventReceived = true;
		return true;
	}
	else if ( eventName == 'BeingHit' && ( npc.HasAbility( 'ablMagic' ) || npc.HasAbility( 'CounterCriticalEffects' ) ) )
	{
		data = (CDamageData) GetEventParamBaseDamage();
		if ( !data.isDoTDamage )
		{
			npc.IncHitCounter();
			if ( CheckGuardOrCounter() )
			{
				npc.RequestCriticalAnimStop();
				counterRequested = true;
				if ( CSType != ECST_HeavyKnockdown && CSType != ECST_Knockdown )
				{
					Complete(true);
				}
			}
			return true;
		}
	}
	else if ( eventName == 'AardHitReceived' && ( npc.HasAbility( 'ablMagic' ) || npc.HasAbility( 'CounterCriticalEffects' ) ) )
	{
		npc.IncHitCounter();
		if ( CheckGuardOrCounter() )
		{
			npc.RequestCriticalAnimStop();
			counterRequested = true;
			if ( CSType != ECST_HeavyKnockdown && CSType != ECST_Knockdown )
			{
				Complete(true);
			}
		}
		return true;
	}
	
	return false;
}