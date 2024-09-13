@wrapMethod(CBTTaskTaunt) function IsAvailable() : bool
{
	if(false) 
	{
		wrappedMethod();
	}
	
	InitializeCombatDataStorage();
	timeStamp = combatDataStorage.GetTauntTimeStamp();
	if ( tauntDelay > 0 && timeStamp > 0 && ( timeStamp + tauntDelay > GetLocalTime() ) )
	{
		return false;
	}
	
	chance = (int)(100*CalculateAttributeValue(GetActor().GetAttributeValue('taunt_chance')));
	
	if ( !Roll(chance) )
		return false;
	
	return true;
}