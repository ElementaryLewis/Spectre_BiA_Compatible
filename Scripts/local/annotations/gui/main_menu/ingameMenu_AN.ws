@addField(CR4IngameMenu)
protected var spectreHasChangedScalingOption : bool;
@addField(CR4IngameMenu)
protected var spectreHasChangedQuestLevelsOption : bool;
@addField(CR4IngameMenu)
protected var spectreHasChangedGameplayOption : bool;
@addField(CR4IngameMenu)
protected var spectreHasChangedQoLOption : bool;	

@wrapMethod(CR4IngameMenu) function OnPresetApplied(groupId:name, targetPresetIndex:int)
{
	if(false) 
	{
		wrappedMethod(groupId, targetPresetIndex);
	}

	hasChangedOption = true;
	IngameMenu_ChangePresetValue(groupId, targetPresetIndex, this);
	
	if (groupId == 'spectreScalingOptions')
		spectreHasChangedScalingOption = true;
	if (groupId == 'spectreExpOptions')
		spectreHasChangedQuestLevelsOption = true;
	if (groupId == 'spectreGameplayOptions')
		spectreHasChangedGameplayOption = true;
	if (groupId == 'spectreQOLOptions')
		spectreHasChangedQoLOption = true;
		
	if (groupId == 'Rendering' && !isMainMenu)
	{
		m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
	}
	
	
	if(groupId == 'PostProcess')
	{
		UpdateAO2CorrespondRT(theGame.GetRTEnabled(), true);
		UpdateOptions('PostProcess', false);
	}

	updateOptionsDisableState();
}

@wrapMethod(CR4IngameMenu) function OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
{
	var groupName			: name;
	var hud 				: CR4ScriptedHud;
	var isValid 			: bool;
	var isBuffered 			: bool;
	var dialogModule : CR4HudModuleDialog;
	var subtitleModule : CR4HudModuleSubtitles;
	var onelinerModule : CR4HudModuleOneliners;
	var minimapModule : CR4HudModuleMinimap2;
	var objectiveModule : CR4HudModuleQuests;
	
	if(false) 
	{
		wrappedMethod(groupId, optionName, optionValue);
	}
	
	hasChangedOption = true;
	
	OnPlaySoundEvent( "gui_global_switch" );
	
	if (groupId == NameToFlashUInt('SpecialSettingsGroupId'))
	{
		HandleSpecialValueChanged(optionName, optionValue);
		return true;
	}		
	
	if (optionName == 'InvertLockOption')
	{
		if ( optionValue == "true" )
			thePlayer.SetInvertedLockOption(true);
		else
			thePlayer.SetInvertedLockOption(false);
	}
	
	if (optionName == 'InvertCameraX')
	{
		if ( optionValue == "true" )
			thePlayer.SetInvertedCameraX(true);
		else
			thePlayer.SetInvertedCameraX(false);
	}
	
	if (optionName == 'InvertCameraY')
	{
		if ( optionValue == "true" )
			thePlayer.SetInvertedCameraY(true);
		else
			thePlayer.SetInvertedCameraY(false);
	}
	
	if (optionName == 'InvertCameraXOnMouse')
	{
		if ( optionValue == "true" )
			thePlayer.SetInvertedMouseCameraX(true);
		else
			thePlayer.SetInvertedMouseCameraX(false);
	}
	
	if (optionName == 'InvertCameraYOnMouse')
	{
		if ( optionValue == "true" )
			thePlayer.SetInvertedMouseCameraY(true);
		else
			thePlayer.SetInvertedMouseCameraY(false);
	}
	
	if (optionName == 'EnableAlternateSignCasting')
	{
		if ( optionValue == "1" )
		{
			thePlayer.GetInputHandler().SetIsAltSignCasting(true);
			FactsSet( "nge_alt_sign_casting_chosen", 1 );
		}
		else
		{
			thePlayer.GetInputHandler().SetIsAltSignCasting(false);
			FactsSet( "nge_alt_sign_casting_chosen", 0 );
		}
		thePlayer.ApplyCastSettings();
	}
	
	
	if (optionName == 'EnableAlternateExplorationCamera')
	{
		if ( optionValue == "1" )
			thePlayer.SetExplCamera(true);
		else
			thePlayer.SetExplCamera(false);
	}
	
	if (optionName == 'EnableAlternateCombatCamera')
	{
		if ( optionValue == "1" )
			thePlayer.SetCmbtCamera(true);
		else
			thePlayer.SetCmbtCamera(false);
	}
	
	if (optionName == 'EnableAlternateHorseCamera')
	{
		if ( optionValue == "1" )
			thePlayer.SetHorseCamera(true);
		else
			thePlayer.SetHorseCamera(false);
	}
	
	if (optionName == 'SoftLockCameraAssist')
	{
		if ( optionValue == "true" )
			thePlayer.SetSoftLockCameraAssist(true);
		else
			thePlayer.SetSoftLockCameraAssist(false);
	}
	
	if (optionName == 'SubtitleScale')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(hud)
		{
			dialogModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
			if(dialogModule)
				dialogModule.SetSubtitleScale( StringToInt(optionValue) );
			
			subtitleModule = (CR4HudModuleSubtitles)hud.GetHudModule("SubtitlesModule");
			if(subtitleModule)
				subtitleModule.SetSubtitleScale( StringToInt(optionValue) );
		}
	}
	
	if (optionName == 'DialogChoiceScale')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(hud)
		{
			dialogModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
			if(dialogModule)
				dialogModule.SetDialogChoiceScale( StringToInt(optionValue) );
		}
	}
	
	if (optionName == 'OnelinerScale')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(hud)
		{
			onelinerModule = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
			if(onelinerModule)
				onelinerModule.SetOnelinerScale( StringToInt(optionValue) );
		}
	}
	
	
	if (optionName == 'WidescreenCutscene' && optionValue == "true")
	{
		theGame.GetGuiManager().ShowUserDialog(0, "", "message_widescreen_cutscene_use_cachets_disclaimer", UDB_Ok);
	}
	
	
	if (optionName == 'MinimapDuringFocusCombat')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(hud)
		{
			minimapModule = (CR4HudModuleMinimap2)hud.GetHudModule("Minimap2Module");
			if(minimapModule)
			{
				if ( optionValue == "true" )
				{
					minimapModule.SetMinimapDuringFocusCombat( true );
				}
				else
				{
					minimapModule.SetMinimapDuringFocusCombat( false );
				}
			}					
		}
	}
	
	if (optionName == 'ObjectiveDuringFocusCombat')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(hud)
		{
			objectiveModule = (CR4HudModuleQuests)hud.GetHudModule("QuestsModule");
			if(objectiveModule)
			{
				if ( optionValue == "true" )
				{
					objectiveModule.SetObjectiveDuringFocusCombat( true );
				}
				else
				{
					objectiveModule.SetObjectiveDuringFocusCombat( false );
				}
			}					
		}
	}
	
	if (optionName == 'LeftStickSprint')
	{
		if ( optionValue == "true" )
			thePlayer.SetLeftStickSprint(true);
		else
			thePlayer.SetLeftStickSprint(false);
	}
	
	
	
	if (optionName == 'AutoApplyBladeOils')
	{
		if ( optionValue == "true" )
			thePlayer.SetAutoApplyOils(true);
		else
			thePlayer.SetAutoApplyOils(false);
	}

	if (optionName == 'HardwareCursor')
	{
		isValid = optionValue;
		m_fxSetHardwareCursorOn.InvokeSelfOneArg(FlashArgBool(isValid));
	}
	
	if (groupId == NameToFlashUInt('spectreScalingOptions'))
		spectreHasChangedScalingOption = true;
	if (spectreIsScalingOption(optionName))
		spectreHasChangedScalingOption = true;
	if (optionName == 'spectreNoQuestLevels')
		spectreHasChangedQuestLevelsOption = true;
	if (spectreIsGameplayOption(optionName))
		spectreHasChangedGameplayOption = true;
	if (spectreIsQoLOption(optionName))
		spectreHasChangedQoLOption = true;		
		
	if( optionName == 'ConsentTelemetry' )
	{
		if ( optionValue =="true" )
		{
			OnTelemetryConsentChanged(true);
		}
		else
		{
			OnTelemetryConsentChanged(false);
		}
	}
	
	if (optionName == 'SwapAcceptCancel')
	{
		swapAcceptCancelChanged = true;
	}
	
	if (optionName == 'AlternativeRadialMenuInputMode')
	{
		alternativeRadialInputChanged = true;
	}
	
	if (optionName == 'EnableUberMovement')
	{
		if ( optionValue == "1" )
			theGame.EnableUberMovement( true );
		else
			theGame.EnableUberMovement( false );
	}
	
	if (optionName == 'GwentDifficulty')
	{
		if ( optionValue == "0" )
			FactsSet( 'gwent_difficulty' , 1 );
		else if ( optionValue == "1" )
			FactsSet( 'gwent_difficulty' , 2 );
		else if ( optionValue == "2" )
			FactsSet( 'gwent_difficulty' , 3 );
		
		return true;
	}
	
	if (optionName == 'HardwareCursor')
	{
		updateInputDeviceRequired = true;
	}
	
	groupName = mInGameConfigWrapper.GetGroupName( groupId );
	
	
	isBuffered = 
		( mInGameConfigWrapper.DoGroupHasTag( groupName, 'buffered' ) || mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'buffered' ) )
		&& !mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'dropDown' )
		&& !mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'nonbuffered' );
	
	if ( groupName == 'Localization' &&
		 optionName == 'Virtual_Localization_speech' && 
		 theGame.GetVoiceLangDownloadStatus( mInGameConfigWrapper.GetVarOption( groupName, optionName, StringToInt( optionValue ) ) ) != STREAMABLE_LOADED 
		)
	{
		return true;
	}
	
	if( isBuffered == true )
	{
		inGameConfigBufferedWrapper.SetVarValue(groupName, optionName, optionValue);
	}
	else
	{
		mInGameConfigWrapper.SetVarValue(groupName, optionName, optionValue);
	}
		
	theGame.OnConfigValueChanged(optionName, optionValue);
	
	if (groupName == 'Hud' || optionName == 'Subtitles')
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if (hud)
		{
			hud.UpdateHudConfig(optionName, true);
		}
	}
	
	if (groupName == 'Localization')
	{
		if (optionName == 'Virtual_Localization_text')
		{
			currentLangValue = optionValue;
		}
		else if (optionName == 'Virtual_Localization_speech')
		{
			currentSpeechLang = optionValue;
		}
	}
	
	if (groupName == 'Rendering' && !isMainMenu)
	{
		m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
	}
	
	if (groupName == 'Rendering' && optionName == 'PreserveSystemGamma')
	{
		theGame.GetGuiManager().DisplayRestartGameToApplyAllChanges();
	}
	
	if(optionName == 'EnableRT')
	{
		
		if( optionValue == "true" )
		{
			if(StringToInt(mInGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) != IGMOPT_AO_NRDRTAO)
			{
				mInGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_NRDRTAO));
			}
		}
		if( optionValue == "false" )
		{
			if(StringToInt(mInGameConfigWrapper.GetVarValue('PostProcess', 'Virtual_SSAOSolution')) >= IGMOPT_AO_RTAO)
			{
				mInGameConfigWrapper.SetVarValue('PostProcess', 'Virtual_SSAOSolution', IntToString(IGMOPT_AO_SSAO));
			}
		}
		UpdateAO2CorrespondRT(optionValue == "true", false);
		UpdateOptions('PostProcess', false);

		
		updateRTOptionEnabled(optionValue == "true");
		updateRTAOOptionChanged();
		updateRTROptionChanged();
	}
	
	if (optionName == 'AllowMotionBlur')
	{
		updateMotionBlurOptionChanged(optionValue == "true");
	}

	
	
	
	
	
	

	
	
	
	
	
	

	if ( optionName == 'Virtual_HairWorksLevel' )
	{
		updateHairWorksOptionChanged();
	}
	
	if( optionName == 'AAMode' )
	{
		UpdateOptions('PostProcess', true);
		updateAAOptionChanged();
	}

	if (optionName == 'RTAOEnabled')
	{
		updateRTAOOptionChanged();
	}

	if (optionName == 'EnableRtRadiance')
	{
		updateRTROptionChanged();
	}
	
	if( optionName == 'DeveloperMode' )
	{
		ShowDeveloperOptions( optionValue == "true" );
	}

	if (optionName == 'GraphicsPreset')
	{
		setLocksOnPresetChanged();
	}

	if (optionName == 'Virtual_DLSSG')
	{
		updateDLSSGOptionChanged();
	}

	if (optionName == 'Virtual_Reflex')
	{
		updateReflexOptionChanged();
	}

	IngameMenu_AdditionalOptionValueChangeHandling( groupName, optionName, optionValue, m_flashValueStorage );

	
	
	
	
	
	
	if ( optionName == 'CrossProgression' )
	{
		theGame.UpdateCrossProgressionValue( optionValue );
	}
}

@addMethod(CR4IngameMenu) function gmUserSettings()
{
	if(spectreHasChangedScalingOption)
	{
		spectreHasChangedScalingOption = false;
		theGame.gmUserSettingsScaling();
	}
	if(spectreHasChangedQuestLevelsOption)
	{
		spectreHasChangedQuestLevelsOption = false;
		theGame.gmUserSettingsQuestLevels();
	}
	if(spectreHasChangedGameplayOption)
	{
		spectreHasChangedGameplayOption = false;
		theGame.gmUserSettingsGameplay();
	}
	if(spectreHasChangedQoLOption)
	{
		spectreHasChangedQoLOption = false;
		theGame.gmUserSettingsQoL();
	}
}

@wrapMethod(CR4IngameMenu) function SaveChangedSettings()
{
	wrappedMethod();

	if (hasChangedOption)
	{
		gmUserSettings();	  
	}
}