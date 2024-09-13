@wrapMethod(CR4GlossaryBestiaryMenu) function UpdateImage( entryName : name )
{
	var creature : CJournalCreature;
	var templatepath : string;
	
	if(false) 
	{
		wrappedMethod(entryName);
	}
	
	if(entryName == 'KillCount')
	{
		ShowRenderToTexture("");
		m_fxSetImage.InvokeSelfOneArg(FlashArgString("bestiary_leshen_locked.png"));
		return;
	}
	
	creature = (CJournalCreature)m_journalManager.GetEntryByTag( entryName );
	
	if(creature)
	{
		templatepath = creature.GetEntityTemplateFilename();
		
		
			ShowRenderToTexture("");
			templatepath = thePlayer.ProcessGlossaryImageOverride( creature.GetImage(), entryName );
			m_fxSetImage.InvokeSelfOneArg(FlashArgString(templatepath));
		
		
		
		
		
	}
	else
	{
		ShowRenderToTexture("");
		m_fxSetImage.InvokeSelfOneArg(FlashArgString(""));
	}
}

@wrapMethod(CR4GlossaryBestiaryMenu) function PopulateData()
{
	var l_DataFlashArray		: CScriptedFlashArray;
	var l_DataFlashObject 		: CScriptedFlashObject;
	var i, length				: int;
	var l_creature 				: CJournalCreature;
	var l_creatureGroup			: CJournalCreatureGroup;
	var l_Title					: string;
	var l_Tag					: name;
	var l_CategoryTag			: name;
	var l_IconPath				: string;
	var l_GroupTitle			: string;
	var l_IsNew					: bool;
	var expandedBestiaryCategories : array< name >;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	expandedBestiaryCategories = GetWitcherPlayer().GetExpandedBestiaryCategories();
	
	l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
	length = allCreatures.Size();
	
	for( i = 0; i < length; i+= 1 )
	{	
		l_creature = allCreatures[i];
		
		l_creatureGroup = (CJournalCreatureGroup)m_journalManager.GetEntryByGuid( l_creature.GetLinkedParentGUID() );
		l_GroupTitle = GetLocStringById( l_creatureGroup.GetNameStringId() );	
		l_CategoryTag = l_creatureGroup.GetUniqueScriptTag();
		
		l_Title = GetLocStringById( l_creature.GetNameStringId() );
		l_Tag = l_creature.GetUniqueScriptTag();
		l_IconPath = thePlayer.ProcessGlossaryImageOverride( l_creature.GetImage(), l_Tag );
		l_IsNew	= m_journalManager.IsEntryUnread( l_creature );
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
		l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
		l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_CategoryTag) );
		l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", expandedBestiaryCategories.Contains( l_CategoryTag ) );
		l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
		
		l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
		l_DataFlashObject.SetMemberFlashBool( "selected", ( l_Tag == currentTag ) );			
		l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
		l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/monsters/"+l_IconPath );
		
		l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
	}

	l_GroupTitle = "* " + GetLocStringByKey("spectre_kills_kill_count");
	l_CategoryTag = 'KillCountCat';
	l_Title = GetLocStringByKey("spectre_kills_kill_count");
	l_Tag = 'KillCount';
	l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
	l_DataFlashObject.SetMemberFlashUInt( "tag", NameToFlashUInt(l_Tag) );
	l_DataFlashObject.SetMemberFlashString( "dropDownLabel", l_GroupTitle );
	l_DataFlashObject.SetMemberFlashUInt( "dropDownTag",  NameToFlashUInt(l_CategoryTag) );
	l_DataFlashObject.SetMemberFlashBool( "dropDownOpened", expandedBestiaryCategories.Contains( l_CategoryTag ) );
	l_DataFlashObject.SetMemberFlashString( "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
	l_DataFlashObject.SetMemberFlashBool( "isNew", false );
	l_DataFlashObject.SetMemberFlashBool( "selected", ( l_Tag == currentTag ) );
	l_DataFlashObject.SetMemberFlashString( "label", l_Title );
	l_DataFlashObject.SetMemberFlashString( "iconPath", "icons/monsters/bestiary_leshen_locked.png" );
	l_DataFlashArray.PushBackFlashObject( l_DataFlashObject );
	if( l_DataFlashArray.GetLength() > 0 )
	{
		m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME, l_DataFlashArray );
		m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
	}
	else
	{
		m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
	}
}

@wrapMethod(CR4GlossaryBestiaryMenu) function UpdateDescription( entryName : name )
{
	var l_creature : CJournalCreature;
	var description : string;
	var title : string;
	
	if(false) 
	{
		wrappedMethod(entryName);
	}

	if(entryName == 'KillCount')
	{
		UpdateKillCountEntry();
		return;
	}
	
	l_creature = (CJournalCreature)m_journalManager.GetEntryByTag( entryName );
	description = GetDescription( l_creature );
	title = GetLocStringById( l_creature.GetNameStringId());	
	
	m_fxSetTitle.InvokeSelfOneArg(FlashArgString(title));
	m_fxSetText.InvokeSelfOneArg(FlashArgString(description));
}	

@addMethod(CR4GlossaryBestiaryMenu) function UpdateKillCountEntry()
{
	var description, finalDescription : string;
	var i, kills, total, humans, animals, monsters, bosses : int;
	var locStr : string;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	for(i = EENT_HUMAN; i < EENT_MAX_TYPES; i += 1)
	{
		kills = witcher.GetKills(i);
		if(kills > 0)
		{
			locStr = spectreGetLocStringByEnemyType(i);
			if(locStr != "")
				description += locStr + ": " + kills + "<br>";
		}
		total += kills;
	}
	
	humans = witcher.GetKills(EENT_HUMAN) + witcher.GetKills(EENT_WILD_HUNT_WARRIOR);
	animals = witcher.GetKills(EENT_DOG) + witcher.GetKills(EENT_WOLF) + witcher.GetKills(EENT_BEAR) +
			  witcher.GetKills(EENT_BOAR) + witcher.GetKills(EENT_PANTHER);
	monsters = total - humans - animals;
	
	bosses = witcher.GetKills(EENT_BOSS);
	total += bosses;
	
	finalDescription = GetLocStringByKey("spectre_kills_total") + ": " + total + "<br>" +
					   GetLocStringByKey("spectre_kills_humans_total") + ": " + humans + "<br>" +
					   GetLocStringByKey("spectre_kills_animals_total") + ": " + animals + "<br>" +
					   GetLocStringByKey("spectre_kills_monsters_total") + ": " + monsters + "<br>" +
					   GetLocStringByKey("spectre_kills_bosses_total") + ": " + bosses;
	if(description != "")
		finalDescription += "<br><br>" + GetLocStringByKey("spectre_kills_by_type") + ":<br>" + description;
	
	m_fxSetTitle.InvokeSelfOneArg(FlashArgString(GetLocStringByKey("spectre_kills_kill_count")));
	m_fxSetText.InvokeSelfOneArg(FlashArgString(finalDescription));
}

@wrapMethod(CR4GlossaryBestiaryMenu) function UpdateItems( tag : name )
{
	var itemsFlashArray			: CScriptedFlashArray;
	var l_creature : CJournalCreature;
	var l_creatureParams : SJournalCreatureParams;
	var l_creatureEntityTemplateFilename : string;
	
	if(false) 
	{
		wrappedMethod(tag);
	}
	
	if(tag == 'KillCount')
	{
		m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
		return;
	}
	
	l_creature = (CJournalCreature)m_journalManager.GetEntryByTag( tag );
	
	itemsNames = l_creature.GetItemsUsedAgainstCreature();
	itemsFlashArray = CreateItems(itemsNames);

	if( itemsFlashArray && itemsFlashArray.GetLength() > 0 )
	{
		m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible",true);
		m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, itemsFlashArray );
	}
	else
	{
		m_flashValueStorage.SetFlashBool("journal.rewards.panel.visible", false);
	}
}