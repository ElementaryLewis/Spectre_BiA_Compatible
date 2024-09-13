@wrapMethod(TaskTeleportAction) function IsAvailable() : bool
{
	var currTime : float = GetLocalTime();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(GetNPC().HasAbility('Specter') && GetNPC().HasBuff(EET_SilverDust))
	{
		return false;
	}
	
	if ( useCombatTarget && !GetCombatTarget() )
	{
		return false;
	}
	return true;
}

@wrapMethod(CBTTaskTeleport) function IsAvailable() : bool
{
	var currTime : float = GetLocalTime();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(GetNPC().HasAbility('Specter') && GetNPC().HasBuff(EET_SilverDust))
	{
		return false;
	}
	
	super.IsAvailable();
	
	if ( isActive )
	{
		return true;
	}
	
	if (  nextTeleTime > 0 && nextTeleTime > currTime )
	{
		return false;
	}
	
	if ( disallowInPlayerFOV )
	{
		if ( !ActorInPlayerFOV() )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return true;
	}
}