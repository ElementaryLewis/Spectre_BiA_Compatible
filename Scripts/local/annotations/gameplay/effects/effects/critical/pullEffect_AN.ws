@wrapMethod(W3Effect_Tangled) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{	
	var torsoBoneIndex : int;
	var boneMatrix	: Matrix;
	var effectEntityTemplate : CEntityTemplate;
	var pos : Vector;
	var rot  : EulerAngles;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}

	super.OnEffectAdded(customParams);
	
	if ( ((CR4Player)target).IsUsingHorse() )
		target.PlayEffectSingle('black_spider_web_break');
	else
		target.PlayEffectSingle('black_spider_web');
	
	spectreForceDeactivateCastSignHold();
	
	if(isOnPlayer)
		thePlayer.AbortSign();
}