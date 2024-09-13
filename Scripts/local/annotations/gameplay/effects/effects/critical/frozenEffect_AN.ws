@wrapMethod(W3Effect_Frozen) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	wrappedMethod(customParams);

	effectManager.PauseAllDoTEffects('FrozenEffect');
}

@wrapMethod(W3Effect_Frozen) function OnEffectAddedPost()
{
	wrappedMethod();

	effectManager.ResumeAllDoTEffects('FrozenEffect');
}