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
		maxMult = 1;		   
		maxHaggleValue = FloorF( rewardValue * (1.f + maxMult) );
		currentReward = minimalHagglingReward;
		
		if ( alwaysSuccessful )
		{
			NPCsPrettyClose = 1.f + maxMult;
			NPCsTooMuch = NPCsPrettyClose;
		}
		else
		{
			NPCsPrettyClose = 1.f + RandRangeF(0.7, 0.2f) * maxMult;		
			NPCsTooMuch = NPCsPrettyClose + 0.3 * maxMult;				
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