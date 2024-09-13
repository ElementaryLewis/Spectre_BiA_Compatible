@wrapMethod(W3Effect_Hypnotized) function OnUpdate(deltaTime : float)
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	if(false) 
	{
		wrappedMethod(deltaTime);
	}
	
	if(isOnPlayer && GetCreator() && !GetCreator().IsAlive())
		timeLeft = 0;
	
	
	if(isOnPlayer && witcher.HasBuff( EET_Cat ) && witcher.GetPotionBuffLevel( EET_Cat ) == 3 )
		timeLeft = 0;
	
	super.OnUpdate(deltaTime);
}