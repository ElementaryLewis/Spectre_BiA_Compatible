@wrapMethod(CR4ScriptedHud) function OnQuestUpdate( journalQuest : CJournalQuest, isQuestUpdate : bool )
{
	var hudJournalUpdateModule : CR4HudModuleJournalUpdate;
	var manager : CWitcherJournalManager;
	var status : int;
	var id : int;
	var itemIds : array<SItemUniqueId>;
	
	if(false) 
	{
		wrappedMethod(journalQuest, isQuestUpdate);
	}

	hudJournalUpdateModule = (CR4HudModuleJournalUpdate)GetHudModule( "JournalUpdateModule" );
	if ( hudJournalUpdateModule )
	{
		hudJournalUpdateModule.AddQuestUpdate( journalQuest, isQuestUpdate );
		spectreFamilyIssuesAutosave( journalQuest );								   
	}

	manager = theGame.GetJournalManager();

	status = manager.GetEntryStatus( journalQuest );
	
	if ( status == JS_Success )
	{
		thePlayer.inv.GetAllItems( itemIds );

		theTelemetry.LogWithLabel( TE_INV_QUEST_COMPLETED, "QUEST COMPLETED - ECONOMY REPORT" );
		theTelemetry.LogWithLabelAndValue( TE_INV_QUEST_COMPLETED, "Crowns", thePlayer.GetMoney() );

		for ( id = itemIds.Size() - 1; id >= 0; id -= 1 )
		{
			theTelemetry.LogWithLabelAndValue( TE_INV_QUEST_COMPLETED, thePlayer.inv.GetItemName(itemIds[ id ] ), thePlayer.inv.GetItemQuantity( itemIds[ id ] ) );
		}
	}
}