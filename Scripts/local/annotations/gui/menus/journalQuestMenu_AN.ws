@wrapMethod(CR4JournalQuestMenu) function UpdateObjectives( tag : name )
{	
	var l_objectivesTotal				: int;
	var l_questObjectivesFlashArray		: CScriptedFlashArray;
	var l_questObjectiveDataFlashObject	: CScriptedFlashObject;
	var l_objective						: CJournalQuestObjective;
	var questEntry 						: CJournalQuest;
	var l_questPhase 					: CJournalQuestPhase;
	var l_objectiveStatus				: EJournalStatus;
	var l_objectiveTitle				: string;
	var l_objectiveProgress				: string;
	var l_objectiveIsNew				: bool;
	var l_objectiveIsTracked			: bool;
	var l_objectiveTag					: name;
	var i, j							: int;
	var locID							: int;
	var l_objectiveOrder				: int;
	var highlightedObjective			: CJournalQuestObjective;
	
	if(false) 
	{
		wrappedMethod(tag);
	}
	
	if (m_initialSelectionsToIgnore == 0)
	{
		m_initialSelectionsToIgnore = 1;
	}
	
	l_questObjectivesFlashArray = m_flashValueStorage.CreateTempFlashArray();
	
	questEntry = (CJournalQuest)m_journalManager.GetEntryByTag(tag);
	
	if (!questEntry)
	{
		return;
	}
	
	highlightedObjective = m_journalManager.GetHighlightedObjective();

	for( i = 0; i < questEntry.GetNumChildren(); i += 1 )
	{
		l_questPhase = (CJournalQuestPhase) questEntry.GetChild(i);
		if(l_questPhase)
		{				
			for( j = 0; j < l_questPhase.GetNumChildren(); j += 1 )
			{
				l_objective =( CJournalQuestObjective ) l_questPhase.GetChild(j);
				l_objectiveStatus 	= ( m_journalManager.GetEntryStatus( l_objective ) );
				if( l_objectiveStatus != JS_Inactive )
				{						
					l_questObjectiveDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
					l_objectiveProgress = "";
					
					if( l_objective.GetCount() > 0 )
					{
						l_objectiveProgress =  " " + m_journalManager.GetQuestObjectiveCount( l_objective.guid ) + "/" + l_objective.GetCount();
					}
					l_objectiveTitle = GetLocStringById( l_objective.GetTitleStringId()  );
					l_objectiveIsNew = m_journalManager.IsEntryUnread( l_objective );
					l_objectiveIsTracked = ( highlightedObjective == l_objective );
					l_objectiveOrder = m_journalManager.GetEntryIndex( l_objective );
					
					l_objectiveTag = l_objective.GetUniqueScriptTag();
					
					if( NameToString(l_objectiveTag) == "Gather 5000 crowns for the enchanter 95C07E63-41549B12-5866D9AB-89B00199" ||
						NameToString(l_objectiveTag) == "Deliver 5000 crowns to the enchanter 7EFEF80B-483E7F6F-BB78AEB6-8AC302D1" )
					{
						l_objectiveTitle = StrReplace( l_objectiveTitle, "5000", "3000" );
					}
					
					l_questObjectiveDataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_objectiveTag) ); 
					l_questObjectiveDataFlashObject.SetMemberFlashBool( "isNew", l_objectiveIsNew );
					l_questObjectiveDataFlashObject.SetMemberFlashBool( "tracked", l_objectiveIsTracked );
					l_questObjectiveDataFlashObject.SetMemberFlashBool( "isLegend", false );
					l_questObjectiveDataFlashObject.SetMemberFlashInt( "status", l_objectiveStatus );
					
					l_questObjectiveDataFlashObject.SetMemberFlashString(  "label", l_objectiveTitle + l_objectiveProgress );
					l_questObjectiveDataFlashObject.SetMemberFlashInt( "phaseIndex", 1 );
					l_questObjectiveDataFlashObject.SetMemberFlashInt( "objectiveIndex", l_objectiveOrder );
					l_questObjectiveDataFlashObject.SetMemberFlashBool( "isMutuallyExclusive", l_objective.IsMutuallyExclusive() );
					
					l_questObjectivesFlashArray.PushBackFlashObject(l_questObjectiveDataFlashObject);
				}
			}
		}
	}
	
	locID = questEntry.GetTitleStringId();
	m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME_SUBLIST, l_questObjectivesFlashArray );
	m_flashValueStorage.SetFlashString( DATA_BINDING_NAME_SUBLIST+".questname", GetLocStringById(locID));
	
	m_fxUpdateExpansionIcon.InvokeSelfOneArg( FlashArgInt( questEntry.GetContentType() ) );
}