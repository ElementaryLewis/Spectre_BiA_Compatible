@wrapMethod(W3Effect_Ragdoll) function OnTimeUpdated(deltaTime : float)
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