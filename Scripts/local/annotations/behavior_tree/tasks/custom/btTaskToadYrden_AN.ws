@wrapMethod(CBTTaskToadYrden) function Main(): EBTNodeStatus
{
	if(false) 
	{
		wrappedMethod();
	}
	
	while( true )
	{
		if ( leftYrden )
			break;

		else if ( theGame.GetEngineTimeAsSeconds() > enterTimestamp + leaveAfter )
		{
			break;
		}
		
		SleepOneFrame();
	}
	
	return BTNS_Completed;
	
}