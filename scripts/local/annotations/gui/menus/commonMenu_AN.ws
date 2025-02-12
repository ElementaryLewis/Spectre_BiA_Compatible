@wrapMethod(CR4CommonMenu) function OnHotkeyTriggered(keyCode:EInputKey)
{	
	spectreResettingIndividualSkillsKey(keyCode);

	wrappedMethod(keyCode);
}

function spectreResettingIndividualSkillsKey(keyCode:EInputKey)
{
	var RSKeys  : EInputKey;
	var outRSKeys   : array< EInputKey >;
	
	outRSKeys.Clear();

	if ( theInput.LastUsedPCInput() )
	{
		theInput.GetPCKeysForAction('Sprint', outRSKeys);
	}
	else if ( !theInput.LastUsedPCInput() )
	{
		theInput.GetPadKeysForAction('Sprint', outRSKeys);
	}

	if (outRSKeys.Size() > 0)
	{
		RSKeys = outRSKeys[0];

		if (keyCode == RSKeys && ((CR4CharacterMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild()))
		{
			if(!(((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill))
			{
				((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill(true);

				theSound.SoundEvent( "gui_inventory_potion_attach" );
			}
			else
			{
				((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager ).spectreResetSkill(false);

				theSound.SoundEvent( "gui_inventory_boots_back" );
			}
		}
	}
}