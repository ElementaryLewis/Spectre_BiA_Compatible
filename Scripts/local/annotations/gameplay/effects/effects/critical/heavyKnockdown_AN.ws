@wrapMethod(W3Effect_HeavyKnockdown) function OnEffectRemoved()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	target.SetIsRecoveringFromKnockdown();
	
	super.OnEffectRemoved();

	if(this == target.GetCurrentlyAnimatedCS())
		target.RequestCriticalAnimStop(target.IsInAir());
}

@wrapMethod(W3Effect_HeavyKnockdown) function OnTimeUpdated(deltaTime : float)
{
	var mac : CMovingPhysicalAgentComponent;
	var isInAir : bool;
	
	if(false) 
	{
		wrappedMethod(deltaTime);
	}
	
	if ( isActive )
	{
		timeActive += deltaTime;
	}
	
	if(pauseCounters.Size() == 0)
	{							
		if( duration != -1 )
			timeLeft -= deltaTime;				
		OnUpdate(deltaTime);	
	}

	if(duration != -1 && timeLeft <= 0 && isActive)
	{
		isActive = false;
	}
}

@wrapMethod(W3Effect_HeavyKnockdown) function CalculateDuration(optional setInitialDuration : bool)
{
	if(false) 
	{
		wrappedMethod(setInitialDuration);
	}
	
	super.CalculateDuration(setInitialDuration);
	
	duration = MaxF(1.f,duration);
}