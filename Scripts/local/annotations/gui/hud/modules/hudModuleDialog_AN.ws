@wrapMethod(CR4HudModuleDialog) function OpenMonsterHuntNegotiationPopup( rewardName : name, minimalGold : int, alwaysSuccessful : bool, optional isItemReward : bool  )
{
	var popupData   : DialogueMonsterBarganingSliderData;
	var rewrd	    : SReward;
	var maxMult     : float;
	var rewardValue : int;
	
	if(false) 
	{
		wrappedMethod(rewardName, minimalGold, alwaysSuccessful, isItemReward);
	}
	
	if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
	{
		theGame.GetTutorialSystem().uiHandler.OnOpeningMenu('MonsterHuntNegotiationMenu');
	}
	
	popupData = new DialogueMonsterBarganingSliderData in this;
	popupData.ScreenPosX = 0.05;
	popupData.ScreenPosY = 0.5;
	
	theGame.GetReward( rewardName, rewrd );
	currentRewardName = rewardName;
	isBet = false;
	isReverseHaggling = false;
	isPopupOpened = true;
	m_fxSetBarValueSFF.InvokeSelfOneArg(FlashArgNumber(0));
	
	popupData.SetMessageTitle( GetLocStringByKeyExt("panel_hud_dialogue_title_negotiation"));
	popupData.dialogueRef = this;
	popupData.BlurBackground = false; 
	popupData.m_DisplayGreyBackground = false;
	popupData.alternativeRewardType = isItemReward;
	
	if( isItemReward && rewrd.items.Size() > 0 )
	{
		
		rewardValue = rewrd.items[0].amount;
	}
	else
	{
		rewardValue = minimalGold;
	}
	
	if( anger == 0 ) 
	{	
		currentRewardMultiply = 1.f;
		minimalHagglingReward = FloorF(rewardValue);					
		maxMult =  (thePlayer.GetSkillLevel(S_Magic_s17) * thePlayer.GetSkillLevel(S_Magic_s17) / 10) + RandRangeF(0.5, 0.35);
		maxHaggleValue = FloorF( rewardValue * (1.f + maxMult) );
		currentReward = minimalHagglingReward;
		
		if ( alwaysSuccessful || thePlayer.GetSkillLevel(S_Magic_s17) >= 5)
		{
			spectrePlayAxiiEffectOnNpcsAroundDialog(true, true);	

			NPCsPrettyClose = 1.f + maxMult;
			NPCsTooMuch = NPCsPrettyClose;
		}
		else
		{
			if (thePlayer.GetSkillLevel(S_Magic_s17) >= 1)
			{
				spectrePlayAxiiEffectOnNpcsAroundDialog(true, false);

				NPCsPrettyClose = thePlayer.GetSkillLevel(S_Magic_s17) + 1.f + RandRangeF(0.8f, 0.1f) * maxMult;	
				NPCsTooMuch = NPCsPrettyClose + 0.3f * RandRangeF(0.5, 0.35);		
			}
			else
			{
				NPCsPrettyClose = 1.f + RandRangeF(0.7f, 0.2f) * RandRangeF(0.5, 0.35);		
				NPCsTooMuch = NPCsPrettyClose + 0.3f * RandRangeF(0.5, 0.35);	
			}
		}
		
		LogHaggle("");
		LogHaggle("Haggling for " + rewardName);
		LogHaggle("min/base gold: " + rewardValue);
		LogHaggle("max bar value: " + maxHaggleValue);
		LogHaggle("default bar value (1.0): " + NoTrailZeros(currentReward));
		LogHaggle("deal/pretty close border (" + NoTrailZeros(NPCsPrettyClose) + "): " + NoTrailZeros(NPCsPrettyClose * rewardValue));
		LogHaggle("pretty close/too much border (" + NoTrailZeros(NPCsTooMuch) + "): " + NoTrailZeros(NPCsTooMuch * rewardValue));
		LogHaggle("");
		
		popupData.currentValue = minimalHagglingReward;
	}
	else
	{
		popupData.currentValue = currentReward;
	}
	
	popupData.minValue = rewardValue;
	popupData.baseValue = rewardValue;
	popupData.anger = anger;
	popupData.maxValue = maxHaggleValue;
	
	theGame.RequestMenu('PopupMenu', popupData);		
}

@wrapMethod(CR4HudModuleDialog) function OnDialogChoiceTimeoutSet(timeOutPercent : float)
{
	wrappedMethod(timeOutPercent);
	spectrePlayAxiiEffectOnNpcsAroundDialog(false, false);
}

@wrapMethod(CR4HudModuleDialog) function OnDialogChoiceTimeoutHide()
{
	wrappedMethod();
	spectrePlayAxiiEffectOnNpcsAroundDialog(false, false);
}

@wrapMethod(CR4HudModuleDialog) function OnDialogSkipConfirmShow()
{
	wrappedMethod();
	spectrePlayAxiiEffectOnNpcsAroundDialog(false, false);
}

@wrapMethod(CR4HudModuleDialog) function OnDialogSkipConfirmHide()
{
	wrappedMethod();
	spectrePlayAxiiEffectOnNpcsAroundDialog(false, false);
}

function spectrePlayAxiiEffectOnNpcsAroundDialog(effect_add, max_effect : bool)
{
	var actor							: CActor; 
	var actors		    				: array<CActor>;
	var i								: int;
	var npc								: CNewNPC;

	actors.Clear();

	actors = thePlayer.GetNPCsAndPlayersInRange( 10, 5, , FLAG_OnlyAliveActors + FLAG_ExcludePlayer);

	if( actors.Size() > 0 )
	{
		for( i = 0; i < actors.Size(); i += 1 )
		{
			npc = (CNewNPC)actors[i];

			actor = actors[i];

			if (effect_add)
			{
				if (!npc.HasTag('ACS_Dialog_Axiied')
				)
				{
					//thePlayer.GetRootAnimatedComponent().PlaySlotAnimationAsync( 'high_standing_determined_gesture_axii_covert', 'PLAYER_SLOT', SAnimatedComponentSlotAnimationSettings(0.25f, 0.25f) );

					//npc.PlayEffectSingle('demonic_possession');

					npc.PlayEffectSingle('axii_confusion');

					if(max_effect)
					{
						npc.PlayEffectSingle('axii_guardian');
					}
	
					npc.AddTag('ACS_Dialog_Axiied');
				}
			}
			else
			{
				if (npc.HasTag('ACS_Dialog_Axiied'))
				{
					//npc.StopEffect('demonic_possession');

					npc.StopEffect('axii_confusion');

					npc.StopEffect('axii_guardian');

					npc.RemoveTag('ACS_Dialog_Axiied');
				}
			}
		}
	}
}