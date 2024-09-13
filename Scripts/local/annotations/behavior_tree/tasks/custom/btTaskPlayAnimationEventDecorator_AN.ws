@addField(CBTTaskPlayAnimationEventDecorator)
protected var staminaDelay				: float;

@wrapMethod(CBTTaskPlayAnimationEventDecorator) function OnActivate() : EBTNodeStatus
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetStats();
	InitializeCombatDataStorage();
	if ( setIsImportantAnim )
	{
		combatDataStorage.SetIsInImportantAnim( true );
	}
	
	if ( drainStaminaOnUse && staminaCost )
		npc.DrainStamina(ESAT_FixedValue, staminaCost, staminaDelay);
	if ( disableHitOnActivation )
		npc.SetCanPlayHitAnim( false );
	if ( disableLookatOnActivation )
	{
		npc.SignalGameplayEvent('LookatOff');
		lookAt = true;
	}
	if ( interruptOverlayAnim )
	{
		npc.RaiseEvent('InterruptOverlay');
	}

	if(GetActor().IsInCombat())
		GetActor().PauseStaminaRegen('spectre_combat_action', 10.f);
	return BTNS_Active;
}

@wrapMethod(CBTTaskPlayAnimationEventDecorator) function OnDeactivate()
{
	var npc : CNewNPC = GetNPC();
	
	if(false) 
	{
		wrappedMethod();
	}
	
	GetActor().ResumeStaminaRegen('spectre_combat_action');
	if ( setIsImportantAnim )
	{
		combatDataStorage.SetIsInImportantAnim( false );
	}
	if ( hitAnim || disableHitOnActivation )
	{
		npc.SetCanPlayHitAnim( true );
		hitAnim = false;
	}
	if ( unstoppable )
	{
		npc.SetUnstoppable( false );
		unstoppable = false;
	}
	if ( lookAt )
	{
		lookAt = false;
		npc.SignalGameplayEvent('LookatOn');
	}
	if ( additiveHits )
	{
		npc.SetUseAdditiveHit( false );
	}
	if ( slowMo )
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_SlowMoTask) );
		slowMo = false;
	}
	if ( guardOpen )
	{
		npc.SetGuarded(true);
	}
	if( waitingForEndOfDisableHit )
	{
		npc.SetCanPlayHitAnim( true );
		waitingForEndOfDisableHit = false;
	}
}

@wrapMethod(CBTTaskPlayAnimationEventDecorator) function GetStats()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	if ( xmlStaminaCostName )
	{
		staminaCost = CalculateAttributeValue(GetNPC().GetAttributeValue( xmlStaminaCostName ));
		switch(xmlStaminaCostName)
		{
			case theGame.params.STAMINA_COST_LIGHT_ACTION_ATTRIBUTE:
			case theGame.params.STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE:
			case theGame.params.STAMINA_COST_PARRY_ATTRIBUTE:
			case theGame.params.STAMINA_COST_COUNTERATTACK_ATTRIBUTE:
			case theGame.params.STAMINA_COST_DODGE_ATTRIBUTE:
				staminaDelay = theGame.params.STAMINA_DELAY_LIGHT_NPC;
				break;
			case theGame.params.STAMINA_COST_HEAVY_ACTION_ATTRIBUTE:
			case theGame.params.STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE:
				staminaDelay = theGame.params.STAMINA_DELAY_HEAVY_NPC;
				break;
			case theGame.params.STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE:
				staminaDelay = theGame.params.STAMINA_DELAY_SUPER_HEAVY_NPC;
				break;
			default:
				staminaDelay = theGame.params.STAMINA_DELAY_DEFAULT_NPC;
				break;
		}
	}
	if ( xmlMoraleCheckName )
	{
		moraleThreshold = CalculateAttributeValue(GetNPC().GetAttributeValue( xmlMoraleCheckName ));
	}
}