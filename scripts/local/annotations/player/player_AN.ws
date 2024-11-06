@addField(CPlayer)
public saved var reusables : array<S_ReusableIngredient>;

@wrapMethod(CPlayer) function SetAbilityManager()
{
	if(false) 
	{
		wrappedMethod();
	}

	if (theGame.alchexts.abltymgr) 
	{
		abilityManager = theGame.alchexts.abltymgr; 
	}
	else 
	{
		abilityManager = new spectreAbilityManager in this;
	}
}
