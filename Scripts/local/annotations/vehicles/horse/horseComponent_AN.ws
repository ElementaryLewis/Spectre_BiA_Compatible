@wrapMethod(W3HorseComponent) function ShouldUpdatePanic() : bool
{
	var horseActor : CActor;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	horseActor 	= (CActor)GetEntity();

	return !horseActor.HasAbility( 'HorseAxiiBuff' ) && !horseActor.HasBuff( EET_Confusion ) && !horseActor.HasBuff( EET_AxiiGuardMe ) && !horseActor.HasAbility( 'DisableHorsePanic' );
}