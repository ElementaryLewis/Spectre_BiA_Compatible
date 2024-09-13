@wrapMethod(BTTaskCaretakerManager) function OnListenedGameplayEvent( eventName : name ) : bool
{
	var l_damage : float ;
	var l_player : CR4Player;
	
	if(false) 
	{
		wrappedMethod(eventName);
	}
	
	if( eventName == 'CausesDamage' )
	{
		CalculateHealingValues();
		
		l_damage = GetEventParamFloat( 0 );
		
		if( m_SummonerComponent.GetNumberOfSummonedEntities() > 0 )			
			RestoreHealth( m_Npc.GetMaxHealth() * l_damage * recoverPercPerHit * shadesModifier );
		else 
			RestoreHealth( m_Npc.GetMaxHealth() * l_damage * recoverPercPerHit );
	}
	if( eventName == 'Death' )
	{
		l_player.AddTimer('RemoveForceFinisher', 3, false, , , true );
		
		m_Npc.PlayEffectOnHeldWeapon( 'summon_shades', true );
	}
	
	return true;
}