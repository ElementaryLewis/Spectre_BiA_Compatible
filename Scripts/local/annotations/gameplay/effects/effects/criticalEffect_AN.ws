@wrapMethod(W3CriticalEffect) function OnTimeUpdated(deltaTime : float)
{
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