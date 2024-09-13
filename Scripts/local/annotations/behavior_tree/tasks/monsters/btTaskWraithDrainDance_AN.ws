@wrapMethod(CBTTaskWraithDrainDance) function Main() : EBTNodeStatus
{
	var l_npc 						: CNewNPC 			= GetNPC();
	var l_target 					: CActor 			= l_npc.GetTarget();
	var l_npcPos, l_targetPos 		: Vector;
	var l_dist						: float;
	var l_summonerHealth			: float;
	
	var summonedEntityComponent 	: W3SummonedEntityComponent;
	
	var l_sourceNode				: CNode;
	var l_targetNode				: CNode;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	summonedEntityComponent = (W3SummonedEntityComponent) l_npc.GetComponentByClassName('W3SummonedEntityComponent');
	l_targetNode			= GetNPC().GetComponent("DrainEnergyTarget");
	if( !l_targetNode )
	{
		l_targetNode = GetNPC();
	}
	l_sourceNode			= GetCombatTarget().GetComponent("torso3effect");
	if( !l_sourceNode )
	{
		l_sourceNode = GetCombatTarget();
	}
	
	while ( !m_Disappeared )
	{			
		l_npcPos 		= l_npc.GetWorldPosition();
		l_targetPos 	= l_target.GetWorldPosition();
		
		l_dist 			= VecDistance( l_npcPos, l_targetPos );
		
		if( !summonedEntityComponent.GetSummoner() || !summonedEntityComponent.GetSummoner().IsAlive() )
		{
			l_npc.SignalGameplayEvent('Disappear');
			return BTNS_Active;
		}
		
		if( l_dist < 4 )
		{
			if( !l_target.HasBuff( EET_VitalityDrain ) )
			{
				AddDrainBuff();
			}				
			
			if( summonedEntityComponent )
			{
				
				l_summonerHealth = summonedEntityComponent.GetSummoner().GetCurrentHealth();
				if( summonedEntityComponent.GetSummoner().HasBuff(EET_SilverDust) )
				{
					summonedEntityComponent.GetSummoner().Heal( l_summonerHealth * 0.0005f );
				}
				else
				{
					summonedEntityComponent.GetSummoner().Heal( l_summonerHealth * 0.002f );
				}
			}
			
			if( !m_DrainEffectEntity )
			{
				m_DrainEffectEntity = theGame.CreateEntity( drainTemplate, GetNPC().GetWorldPosition(), GetNPC().GetWorldRotation() );
			}
			
			if( !m_DrainEffectEntity.IsEffectActive('drain_energy') )
			{
				m_DrainEffectEntity.PlayEffect( 'drain_energy', l_targetNode );
			}
		}
		else
		{
			m_DrainEffectEntity.StopEffect( 'drain_energy' );
		}
		
		if( m_DrainEffectEntity )
		{
			m_DrainEffectEntity.Teleport( l_sourceNode.GetWorldPosition() );
		}
		
		Sleep( 0.01f );
	}
	return BTNS_Active;
}