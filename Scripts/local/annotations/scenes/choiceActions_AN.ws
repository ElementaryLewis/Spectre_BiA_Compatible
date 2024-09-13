@wrapMethod(CPayFactBasedStorySceneChoiceAction) function PerformAction()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	thePlayer.RemoveMoney( FactsQuerySum( valueFact ) );
	GetWitcherPlayer().AddPoints( EExperiencePoint, 5, true );
	theSound.SoundEvent("gui_bribe");
}


@wrapMethod(CPayStorySceneChoiceAction) function PerformAction()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	thePlayer.RemoveMoney( money );
	
	if( !dontGrantExp )
	{
		GetWitcherPlayer().AddPoints( EExperiencePoint, 5, true );
	}
	
	theSound.SoundEvent("gui_bribe");
}

@wrapMethod(CAxiiStorySceneChoiceAction) function PerformAction()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	GetWitcherPlayer().AddPoints( EExperiencePoint, GetWitcherPlayer().GetAxiiLevel() * 5, true );
}