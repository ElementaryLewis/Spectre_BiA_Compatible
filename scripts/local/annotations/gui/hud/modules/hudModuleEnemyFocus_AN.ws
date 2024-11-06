@wrapMethod( CR4HudModuleEnemyFocus ) function OnTick( timeDelta : float )
{
	var l_targetNonActor			: CGameplayEntity;
	
	l_targetNonActor = (CGameplayEntity)theGame.GetInteractionsManager().GetActiveInteraction().GetEntity();

	if( !l_targetNonActor )
	{
		wrappedMethod(timeDelta);
	}
}