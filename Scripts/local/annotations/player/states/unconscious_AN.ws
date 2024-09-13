@wrapMethod(Unconscious) function OnLeaveState( nextStateName : name )
{
	wrappedMethod(nextStateName);
	
	if( (W3PlayerWitcher)parent )
		((W3PlayerWitcher)parent).UpdateEncumbrance();										 
}

@wrapMethod(Unconscious) function TakeMoneyFromPlayer()
{
	var amount : float = thePlayer.GetMoney() * 0.25; 
	
	if(false) 
	{
		wrappedMethod();
	}
}