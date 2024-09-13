@wrapMethod(W3Effect_AdrenalineDrain) function OnUpdate(dt : float)
{
	var drainVal : float;
	var buff : W3Effect_Toxicity;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
		
	
	if(target.IsInCombat() || target.HasBuff(EET_Runeword8))
		isActive = false;
		
	drainVal = dt * (effectValue.valueAdditive + (target.GetStatMax(BCS_Focus) + effectValue.valueBase) * effectValue.valueMultiplicative);
	((CR4Player)target).DrainFocus(drainVal);
	
	
	if(target.GetStat(BCS_Focus) <= 0)
	{
		isActive = false;			
	}
}