@wrapMethod(CR4HudModuleWolfHead) function UpdateToxicity() : void
{
	var curToxicity 	: float;	
	var curMaxToxicity 	: float;
	var curLockedToxicity: float;
	var damageThreshold	: float;
	var curDeadlyToxicity : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	curToxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false);
	curMaxToxicity = GetWitcherPlayer().GetStatMax(BCS_Toxicity);
	curLockedToxicity = curToxicity - GetWitcherPlayer().GetStat(BCS_Toxicity, true);
	
	m_curToxicity = curToxicity;
	m_lockedToxicity = curLockedToxicity;
	
	if ( m_LastToxicity != curToxicity || m_LastMaxToxicity != curMaxToxicity || m_LastLockedToxicity != curLockedToxicity )
	{
		if( m_LastLockedToxicity != curLockedToxicity || m_LastMaxToxicity != curMaxToxicity)
		{
			m_fxSetLockedToxicity.InvokeSelfOneArg( FlashArgNumber( ( curLockedToxicity )/ curMaxToxicity ) );
			m_LastLockedToxicity = curLockedToxicity;
		}
		
		m_fxSetToxicity.InvokeSelfOneArg( FlashArgNumber( curToxicity / curMaxToxicity ) );
		m_LastToxicity 	= curToxicity;
		m_LastMaxToxicity = curMaxToxicity;
		
		damageThreshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		curDeadlyToxicity = ( curToxicity >= damageThreshold * curMaxToxicity );
		if( m_bLastDeadlyToxicity != curDeadlyToxicity ) 
		{
			m_fxSetDeadlyToxicity.InvokeSelfOneArg( FlashArgBool( curDeadlyToxicity ) );
			m_bLastDeadlyToxicity = curDeadlyToxicity;
		}
	}
}