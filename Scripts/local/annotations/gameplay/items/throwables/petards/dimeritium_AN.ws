@wrapMethod(W3Dimeritium) function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
{
	var i : int;
	var witcher : W3PlayerWitcher;
	var rift : CRiftEntity;
	
	if(false) 
	{
		wrappedMethod(targets, isImpact, dt);
	}

	super.ProcessMechanicalEffect(targets, isImpact, dt);

	witcher = GetWitcherPlayer();
	if(targets.Contains(witcher) && witcher.GetCurrentlyCastSign() == ST_Quen)
		witcher.CastSignAbort();

	for(i=0; i<targets.Size(); i+=1)
	{
		rift = (CRiftEntity)targets[i];
		if(rift)
		{	
			rift.PlayEffect( 'rift_dimeritium' );
			rift.DeactivateRiftIfPossible();
		}
	}
}

@wrapMethod(W3Dimeritium) function LoopFunction(dt : float)
{
	var skill : ESkill;
	var i, j : int;
	var blocked, isPlayer : bool;
	var actor : CActor;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	super.LoopFunction(dt);

	disabledFxDT -= dt;
	if( disabledFxDT > 0.f )
	{
		return;
	}
	disabledFxDT = DISABLED_FX_CHECK_DELAY;

	blocked = false;
	for(i = 0; i < targetsSinceLastCheck.Size(); i += 1)
	{
		actor = (CActor)targetsSinceLastCheck[i];
		if(actor && actor.HasBuff(EET_DimeritiumEffect))
		{
			blocked = true;
			break;
		}
	}		
	
	if(blocked)
	{
		if(isCluster && IsNameValid(affectedFXCluster))
			PlayEffectInternal(affectedFXCluster);
		else
			PlayEffectInternal(affectedFX);
			
		RemoveTimer('DisableAffectedFx');
		disableTimerCalled = false;
	}
	else if(!disableTimerCalled)
	{
		disableTimerCalled = true;
		AddTimer('DisableAffectedFx', 0.5);
	}
}

@wrapMethod(W3Dimeritium) function ProcessTargetOutOfArea(entity : CGameplayEntity)
{
	if(false) 
	{
		wrappedMethod(entity);
	}
	
	super.ProcessTargetOutOfArea(entity);
}