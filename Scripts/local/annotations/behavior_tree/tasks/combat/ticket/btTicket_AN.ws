@addMethod(CTicketAttackAlgorithm) function ShouldAskForTicket() : bool
{
	var owner : CActor = GetActor();
	
	if(owner.shouldWaitForStaminaRegen)
	{
		return false;
	}
	return super.ShouldAskForTicket();
}

@wrapMethod(CTicketAlgorithmMelee) function CalculateTicketImportance() : float
{
	var importance 			: float = 100.f;
	var owner 				: CActor = GetActor();
	
	if ( owner.shouldWaitForStaminaRegen )
		return 0;
			
	wrappedMethod();
	
	return importance;
}