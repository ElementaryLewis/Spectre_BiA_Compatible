@wrapMethod(W3Mutagen_Effect) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var mutParams : W3MutagenBuffCustomParams;
	var witcher : W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}
	
	witcher = GetWitcherPlayer();
	if(target != witcher)
	{
		isActive = false;
		return false;
	}
	
	super.OnEffectAdded(customParams);
	
	mutParams = (W3MutagenBuffCustomParams)customParams;
	toxicityOffset = mutParams.toxicityOffset;
	
	if(toxicityOffset > 0)
	{
		witcher.AddToxicityOffset(toxicityOffset);
	
		witcher.RecalcTransmutationAbilities();
	}
	
	OverrideIcon( mutParams.potionItemName );		
}