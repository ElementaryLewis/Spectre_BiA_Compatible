@addField(CR4HudModuleWolfHead)
private var m_StaminaBar 				: CScriptedFlashSprite;
@addField(CR4HudModuleWolfHead)
private var m_IconLoader 				: CScriptedFlashSprite;
@addField(CR4HudModuleWolfHead)
private var m_SignReady 				: CScriptedFlashSprite;
@addField(CR4HudModuleWolfHead)
private var m_IconLoaderDimmed 			: bool;

@wrapMethod(CR4HudModuleWolfHead) function OnConfigUI()
{
	var flashModule : CScriptedFlashSprite;
	var hud : CR4ScriptedHud;

	if(false) 
	{
		wrappedMethod();
	}
	
	m_anchorName = "mcAnchorWolfHead";
	
	super.OnConfigUI();
	
	flashModule = GetModuleFlash();	
	
	m_StaminaBar 						= flashModule.GetChildFlashSprite( "mcStaminaBar" );
	m_IconLoader 						= flashModule.GetChildFlashSprite( "mcSignSlot" ).GetChildFlashSprite( "mcIconLoader" );
	m_SignReady 						= flashModule.GetChildFlashSprite( "mSignReady" );
	
	m_fxSetVitality						= flashModule.GetMemberFlashFunction( "setVitality" );
	m_fxSetStamina						= flashModule.GetMemberFlashFunction( "setStamina" );
	m_fxSetToxicity						= flashModule.GetMemberFlashFunction( "setToxicity" );
	m_fxSetExperience					= flashModule.GetMemberFlashFunction( "setExperience" );
	m_fxSetLockedToxicity				= flashModule.GetMemberFlashFunction( "setLockedToxicity" );
	m_fxSetDeadlyToxicity				= flashModule.GetMemberFlashFunction( "setDeadlyToxicity" );
	m_fxShowStaminaNeeded				= flashModule.GetMemberFlashFunction( "showStaminaNeeded" );
	m_fxSwitchWolfActivation			= flashModule.GetMemberFlashFunction( "switchWolfActivation" );
	m_fxSetSignIconSFF 					= flashModule.GetMemberFlashFunction( "setSignIcon" );
	m_fxSetSignTextSFF 					= flashModule.GetMemberFlashFunction( "setSignText" );
	m_fxSetFocusPointsSFF				= flashModule.GetMemberFlashFunction( "setFocusPoints" );
	m_fxSetFocusProgressSFF				= flashModule.GetMemberFlashFunction( "UpdateFocusPointsBar" );
	m_fxLockFocusPointsSFF				= flashModule.GetMemberFlashFunction( "lockFocusPoints" );
	m_fxSetCiriAsMainCharacter			= flashModule.GetMemberFlashFunction( "setCiriAsMainCharacter" );
	m_fxSetCoatOfArms					= flashModule.GetMemberFlashFunction( "setCoatOfArms" );
	m_fxSetShowNewLevelIndicator		= flashModule.GetMemberFlashFunction( "setShowNewLevelIndicator" );
	m_fxSetAlwaysDisplayed				= flashModule.GetMemberFlashFunction( "setAlwaysDisplayed" );
	m_fxshowMutationFeedback			= flashModule.GetMemberFlashFunction( "showMutationFeedback" );
	
	m_CurrentSelectedSign = thePlayer.GetEquippedSign();
	m_fxSetSignIconSFF.InvokeSelfOneArg(FlashArgString(GetSignIcon()));
	
	SetTickInterval( 0.5 );
	hud = (CR4ScriptedHud)theGame.GetHud();
	if (hud)
	{
		hud.UpdateHudConfig('WolfMedalion', true);
	}
	DisplayNewLevelIndicator();
	
	UpdateCoatOfArms();
}

@wrapMethod(CR4HudModuleWolfHead) function UpdateStamina() : void
{
	var l_curStamina 				: float;
	var l_curMaxStamina 			: float;
	var l_tooLowStaminaIndication 	: float = thePlayer.GetShowToLowStaminaIndication();
	var m_EnoughStaminaForSign 		: bool;

	if(false) 
	{
		wrappedMethod();
	}
	
	thePlayer.GetStats( BCS_Stamina, l_curStamina, l_curMaxStamina );
	
	if ( m_LastStamina != l_curStamina || m_LastMaxStamina != l_curMaxStamina )
	{			
		m_StaminaBar.SetMemberFlashNumber( "value", l_curStamina / l_curMaxStamina * 100 );
		m_EnoughStaminaForSign = thePlayer.HasStaminaToUseSkill( SignEnumToSkillEnum( m_CurrentSelectedSign ), false );
		if(  m_EnoughStaminaForSign &&  m_IconLoaderDimmed )
		{
			m_IconLoader.SetAlpha(100);
			m_SignReady.GotoAndPlayFrameLabel("show");
			m_IconLoaderDimmed = false;
		}
		else if( !m_EnoughStaminaForSign && !m_IconLoaderDimmed )
		{
			m_IconLoader.SetAlpha(50);
			m_IconLoaderDimmed = true;
		}
		
		m_LastStamina 	 = l_curStamina;
		m_LastMaxStamina = l_curMaxStamina;
		
		if ( l_curStamina <= l_curMaxStamina*0.60 ) 
			playStaminaSoundCue = true;
			
		if ( l_curStamina <= 0 )
		{
			thePlayer.SoundEvent("gui_no_stamina");
			theGame.VibrateControllerVeryLight(); 
		}
		else if ( l_curStamina >= l_curMaxStamina && playStaminaSoundCue )
		{
			thePlayer.SoundEvent("gui_stamina_recharged");
			theGame.VibrateControllerVeryLight(); 
			playStaminaSoundCue = false;
		}
	}
	
	if( l_tooLowStaminaIndication > 0 )
	{
		m_fxShowStaminaNeeded.InvokeSelfOneArg( FlashArgNumber ( l_tooLowStaminaIndication / l_curMaxStamina ) );
		thePlayer.SetShowToLowStaminaIndication( 0 );
	}
}

@wrapMethod(CR4HudModuleWolfHead) function UpdateToxicity() : void
{
	var curToxicity 	: float;	
	var curMaxToxicity 	: float;
	var curLockedToxicity: float;
	var damageThreshold	: float;
	var curDeadlyToxicity : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	curToxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false);
	curMaxToxicity = GetWitcherPlayer().GetStatMax(BCS_Toxicity);
	curLockedToxicity = curToxicity - GetWitcherPlayer().GetStat(BCS_Toxicity, true);
	
	m_curToxicity = curToxicity;
	m_lockedToxicity = curLockedToxicity;
	
	if ( m_LastToxicity != curToxicity || m_LastMaxToxicity != curMaxToxicity || m_LastLockedToxicity != curLockedToxicity )
	{
		if( m_LastLockedToxicity != curLockedToxicity || m_LastMaxToxicity != curMaxToxicity)
		{
			m_fxSetLockedToxicity.InvokeSelfOneArg( FlashArgNumber( ( curLockedToxicity )/ curMaxToxicity ) );
			m_LastLockedToxicity = curLockedToxicity;
		}
		
		m_fxSetToxicity.InvokeSelfOneArg( FlashArgNumber( curToxicity / curMaxToxicity ) );
		m_LastToxicity 	= curToxicity;
		m_LastMaxToxicity = curMaxToxicity;
		
		damageThreshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		curDeadlyToxicity = ( curToxicity >= damageThreshold * curMaxToxicity );
		if( m_bLastDeadlyToxicity != curDeadlyToxicity ) 
		{
			m_fxSetDeadlyToxicity.InvokeSelfOneArg( FlashArgBool( curDeadlyToxicity ) );
			m_bLastDeadlyToxicity = curDeadlyToxicity;
		}
	}
}