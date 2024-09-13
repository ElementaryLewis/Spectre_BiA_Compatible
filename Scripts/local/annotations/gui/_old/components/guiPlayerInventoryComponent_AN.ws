@wrapMethod(W3GuiPlayerInventoryComponent) function GetCraftedItemInfo(craftedItemName:name, targetObject:CScriptedFlashObject) : void
{
	var playerInv			: CInventoryComponent;
	var wplayer		        : W3PlayerWitcher;
	var dm 					: CDefinitionsManagerAccessor;
	var htmlNewline			: string;
	var minQuality 			: int;
	var maxQuality 			: int;
	var color				: string;
	var itemType 			: EInventoryFilterType;
	var minWeightAttribute 	: SAbilityAttributeValue;
	var maxWeightAttribute 	: SAbilityAttributeValue;
	var i					: int;
	var attributes			: array<SAttributeTooltip>;
	var itemName			: string;
	var itemDesc			: string;
	var rarity				: string;
	var rarityId			: int;
	var type				: string;
	var weightValue			: float;
	var weight				: string;
	var enhancementSlots 	: int;
	var attributesStr		: string;
	var tmpStr				: string;
	var requiredLevel		: string;
	var primaryStatDiff     : string;
	var primaryStatLabel    : string;
	var primaryStatValue    : float;
	var primaryStatDiffValue: float;
	var primaryStatDiffStr  : string;
	var eqPrimaryStatLabel  : string;
	var eqPrimaryStatValue  : float;
	var primaryStatName	    : name;
	var itemCategory		: name;
	var dontCompare			: bool;
	var itemSlot 			: EEquipmentSlots;
	var equipedItemId		: SItemUniqueId;
	var equipedItemStats	: array<SAttributeTooltip>;
	var attributesList      : CScriptedFlashArray;
	var addDescription		: string;
	var itemLevel			: int;
	var isSetBonus1Active	 : bool;
	var isSetBonus2Active	 : bool;
	var setBonusDescription1 : string;
	var setBonusDescription2 : string;
	var setBonusText	     : string;
	var setBonusText2		 : string;
	var paramString			 : array<string>;
	var setAttribute 	  : CScriptedFlashObject;
	var setAttributesList : CScriptedFlashArray;
	
	if(false) 
	{
		wrappedMethod(craftedItemName, targetObject);
	}
	
	htmlNewline = "&#10;";
	
	wplayer = GetWitcherPlayer();
	dm = theGame.GetDefinitionsManager();
	_inv.GetItemStatsFromName(craftedItemName, attributes);
	_inv.GetPotionAttributesByName(craftedItemName, attributes);
	_inv.GetBombAttributesForTooltipByName(craftedItemName, attributes);
	_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
	itemType = dm.GetFilterTypeByItem(craftedItemName);
	
	itemCategory = dm.GetItemCategory(craftedItemName);
	
	dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);
	weightValue = minWeightAttribute.valueBase;
	
	tmpStr = FloatToStringPrec( weightValue, 2 );
	weight = GetLocStringByKeyExt("attribute_name_weight") + "  " + tmpStr;
	
	itemName = GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(craftedItemName));

	if(dm.ItemHasTag(craftedItemName, 'Mutagen'))
		_inv.FillInMutagenDescriptionByName(craftedItemName, itemDesc);
	else
		itemDesc = GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName));
	
	rarityId = minQuality;
	rarity = GetItemRarityDescriptionFromInt(minQuality);
	type = GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
	
	setBonusText = "";
	setBonusText2 = "";
	
	if ( dm.IsItemSetItem( craftedItemName ) && dm.ItemHasTag( craftedItemName, 'SetBonusPiece' ) || _inv.IsSetArmorTypeByName( craftedItemName ) )
	{
		GetWitcherPlayer().GetSetBonusStatusByName( craftedItemName, setBonusDescription1, setBonusDescription2, isSetBonus1Active, isSetBonus2Active );
		
		if( setBonusDescription1!="" )
		{				
			
			setBonusText = setBonusText + "<font color='#b7ae8c'>" + StrUpperUTF( GetLocStringByKeyExt( "crafting_bonus_title" ) ) + "</font><br/><br/>";
			
			paramString.PushBack( (string)( theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS ) );
			setBonusText = setBonusText + "<font color='#9f977a'>" + GetLocStringByKeyExtWithParams( "crafting_bonus_set_title",,, paramString ) + ":</font><br/>";
			setBonusText = setBonusText + "<font color='#818181'>" + setBonusDescription1 + "</font>";
			
			if( setBonusDescription2 != "" )
			{
				paramString.Clear();
				paramString.PushBack( (string)( theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS ) );
				setBonusText2 ="<font color='#9f977a'>" + GetLocStringByKeyExtWithParams( "crafting_bonus_set_title",,, paramString ) + ":</font><br/>";
				setBonusText2 = setBonusText2 + "<font color='#818181'>" + setBonusDescription2 + "</font>";
			}
			
			targetObject.SetMemberFlashString( "SetBonusDescription", setBonusText );
			targetObject.SetMemberFlashString( "SetBonusDescription2", setBonusText2 );
		}
		else
		{
			_inv.GetSetArmorItemDescriptionByName(craftedItemName, setBonusText);
			paramString.Clear();
			paramString.PushBack("4");
			setBonusText = "<font color='#b7ae8c'>" + StrUpperUTF( GetLocStringByKeyExt( "spectre_crafting_bonus_title" ) ) + "</font><br/><br/>"
				+ "<font color='#9f977a'>" + GetLocStringByKeyExtWithParams( "crafting_bonus_set_title",,, paramString ) + ":</font><br/>"
				+ "<font color='#818181'>" + setBonusText + "</font>";
			setBonusText2 = "";
			targetObject.SetMemberFlashString( "SetBonusDescription", setBonusText );
			targetObject.SetMemberFlashString( "SetBonusDescription2", setBonusText2 );
		}
	}
	
	enhancementSlots = dm.GetItemEnhancementSlotCount( craftedItemName );
	itemSlot = GetSlotForItemByCategory(itemCategory);
	wplayer.GetItemEquippedOnSlot(itemSlot, equipedItemId);
	playerInv = thePlayer.GetInventory();
	
	eqPrimaryStatValue = 0;
	if (playerInv.IsIdValid(equipedItemId))
	{
		playerInv.GetItemStats(equipedItemId, equipedItemStats);
		playerInv.GetItemPrimaryStat(equipedItemId, eqPrimaryStatLabel, eqPrimaryStatValue);
	}
	
	dontCompare = itemCategory == 'potion' || itemCategory == 'petard' || itemCategory == 'oil';
	playerInv.GetItemPrimaryStatFromName(craftedItemName, primaryStatLabel, primaryStatValue, primaryStatName);
	
	if ( FactsQuerySum("NewGamePlus") > 0 )
	{
		if ( theGame.params.NewGamePlusLevelDifference() > 0 )
		{
			primaryStatValue += IncreaseNGPPrimaryStatValue(itemCategory);
		}
	}
	
	primaryStatDiff = "none";
	primaryStatDiffValue = 0;
	primaryStatDiffStr = "";
	
	if ( !dontCompare )
	{
		primaryStatDiff = GetStatDiff(primaryStatValue, eqPrimaryStatValue);
		primaryStatDiffValue = RoundMath(primaryStatValue) - RoundMath(eqPrimaryStatValue);
		if (primaryStatDiffValue > 0)
		{
			primaryStatDiffStr = "<font color=\"#19D900\"> +" + NoTrailZeros(primaryStatDiffValue) + "</font>";
		}
		else if (primaryStatDiffValue < 0)
		{
			primaryStatDiffStr = "<font color=\"#E00000\"> " + NoTrailZeros(primaryStatDiffValue) + "</font>";
		}
		
		if (dm.IsItemWeapon(craftedItemName))
		{
			targetObject.SetMemberFlashNumber("PrimaryStatDelta", .1);
		}
		else
		{
			targetObject.SetMemberFlashNumber("PrimaryStatDelta", 0);
		}
	}
	
	if ( dm.IsItemAnyArmor(craftedItemName) || dm.IsItemBolt(craftedItemName) || dm.IsItemWeapon(craftedItemName) )
	{
		itemLevel = theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName );
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( theGame.params.NewGamePlusLevelDifference() > 0 )
			{
				itemLevel += theGame.params.NewGamePlusLevelDifference();
				if ( itemLevel > GetWitcherPlayer().GetMaxLevel() ) 
				{
					itemLevel = GetWitcherPlayer().GetMaxLevel();
				}
			}
		}
		requiredLevel = _inv.GetItemLevelColor( itemLevel ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + " " + itemLevel + "</font>";
		targetObject.SetMemberFlashString("requiredLevel", requiredLevel);
	}
	
	attributesList = targetObject.CreateFlashArray();		
	CalculateStatsComparance(attributes, equipedItemStats, targetObject, attributesList, true,  dontCompare);
	
	attributesStr = "";
	for (i = 0; i < attributes.Size(); i += 1)
	{
		color = attributes[i].attributeColor;
		attributesStr += "<font color=\"#" + color + "\">";
		attributesStr += attributes[i].attributeName + ": ";
		if( attributes[i].percentageValue )
		{
			attributesStr += RoundMath( attributes[i].value * 100 ) + " %";
		}
		else
		{
			attributesStr += RoundMath( attributes[i].value );
		}
		attributesStr += "</font>" + htmlNewline;
	}

	addDescription = "";
	
	if ( theGame.GetGuiManager().GetShowItemNames() )
	{
		itemDesc = "<font color=\"#FFDB00\">Item Name: '" + craftedItemName + "'</font><br><br>" + itemDesc;
	}
	
	targetObject.SetMemberFlashString("additionalDescription", addDescription);
	targetObject.SetMemberFlashString("itemName", itemName);
	targetObject.SetMemberFlashString("itemDescription", itemDesc);
	targetObject.SetMemberFlashString("rarity", rarity);
	targetObject.SetMemberFlashInt("rarityId", rarityId);
	targetObject.SetMemberFlashString("type", type);
	targetObject.SetMemberFlashInt("enhancementSlots", enhancementSlots );
	targetObject.SetMemberFlashString("weight", weight);
	targetObject.SetMemberFlashString("attributes", attributesStr);
	targetObject.SetMemberFlashArray("attributesList", attributesList);
	targetObject.SetMemberFlashString("PrimaryStatLabel", primaryStatLabel);
	targetObject.SetMemberFlashNumber("PrimaryStatValue", primaryStatValue);
	targetObject.SetMemberFlashString("PrimaryStatDiff", primaryStatDiff);
	targetObject.SetMemberFlashString("PrimaryStatDiffStr", primaryStatDiffStr);
}