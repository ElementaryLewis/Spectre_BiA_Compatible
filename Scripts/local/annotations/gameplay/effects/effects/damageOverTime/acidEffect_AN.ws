@wrapMethod(W3Effect_Acid) function OnEffectAddedPost()
{
	wrappedMethod();
	
	if(target != thePlayer)
		target.AddAbility('Mutation4BloodDebuff');
}