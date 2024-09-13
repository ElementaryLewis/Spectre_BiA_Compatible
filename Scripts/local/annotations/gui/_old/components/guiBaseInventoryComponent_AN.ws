@wrapMethod(W3GuiBaseInventoryComponent) function GetAlchemyBookText(item : SItemUniqueId):string
{
	var dm 					: CDefinitionsManagerAccessor;
	var finalString			: string;
	var tempString			: string;
	var recipe				: SAlchemyRecipe;
	var currentIngredient	: SItemParts;
	var htmlNewline			: string;
	var itemType 			: EInventoryFilterType;
	var i					: int;
	var craftedItemName		: name;
	var color				: string;
	var attributes			: array<SAttributeTooltip>;
	var minWeightAttribute 	: SAbilityAttributeValue;
	var maxWeightAttribute 	: SAbilityAttributeValue;
	var minQuality 			: int;
	var maxQuality 			: int;
	var itemDesc			: string;
	var itemQuantity		: int;
	var fontColor	 		: string;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	htmlNewline = "&#10;";
	finalString = "";
	
	recipe = getAlchemyRecipeFromName(_inv.GetItemName(item));
	dm = theGame.GetDefinitionsManager();
	craftedItemName = recipe.cookedItemName;
	_inv.GetItemStatsFromName(craftedItemName, attributes);
	_inv.GetPotionAttributesByName(craftedItemName, attributes);
	_inv.GetBombAttributesForTooltipByName(craftedItemName, attributes);
	_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
	dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);
	itemType = dm.GetFilterTypeByItem(craftedItemName);

	
	tempString = GetLocStringByKeyExt(GetFilterTypeName( itemType )) + " / " + GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
	finalString += "<font color=\"#FF8832\">" + tempString + "</font>";

	finalString += htmlNewline + GetItemRarityDescriptionFromInt(minQuality);

	if (attributes.Size() > 0)
	{
		finalString += htmlNewline;
		for (i = 0; i < attributes.Size(); i += 1)
		{
			
			color = attributes[i].attributeColor;
			tempString = htmlNewline + "<font color=\"#" + color + "\">";
			if( attributes[i].percentageValue )
			{
				tempString += NoTrailZeros(attributes[i].value * 100 ) +" %";
			}
			else
			{
				tempString += NoTrailZeros(attributes[i].value);
			}
			tempString += " " + attributes[i].attributeName;
			tempString += "</font>";
			finalString += tempString;
		}

	}
	
	if(dm.ItemHasTag(craftedItemName, 'Mutagen'))
		_inv.FillInMutagenDescriptionByName(craftedItemName, itemDesc);
	else
		itemDesc = GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName));
	
	finalString += htmlNewline; 
	finalString += htmlNewline + "<font color=\"#C49560\">" + itemDesc + "</font>";
	
	finalString += htmlNewline;
	finalString += htmlNewline + GetLocStringByKeyExt("panel_crafting_ingredients_start") + ":";
	
	for (i = 0; i < recipe.requiredIngredients.Size(); i += 1)
	{
		currentIngredient = recipe.requiredIngredients[i];
		itemQuantity = thePlayer.inv.GetItemQuantityByName(currentIngredient.itemName);
		if(currentIngredient.quantity > itemQuantity)
		{
			fontColor = "<font color=\"#FF0000\">";
		}
		else
		{
			fontColor = "<font color=\"#00FF00\">";
		}
		finalString += htmlNewline + fontColor + itemQuantity + " / " + currentIngredient.quantity + " " + GetLocStringByKeyExt( _inv.GetItemLocalizedNameByName(currentIngredient.itemName ) ) + "</font>";
	}
	
	return finalString;
}

@wrapMethod(W3GuiBaseInventoryComponent) function GetSchematicBookText(item : SItemUniqueId):string
{
	var dm 					: CDefinitionsManagerAccessor;
	var finalString			: string;
	var tempString			: string;
	var htmlNewline			: string;
	var craftingSchematic	: SCraftingSchematic;
	var craftedItemName		: name;
	var currentIngredient	: SItemParts;
	var i					: int;
	var color				: string;
	var attributes			: array<SAttributeTooltip>;
	var minWeightAttribute 	: SAbilityAttributeValue;
	var maxWeightAttribute 	: SAbilityAttributeValue;
	var minQuality 			: int;
	var maxQuality 			: int;
	var itemType 			: EInventoryFilterType;
	var itemQuantity		: int;
	var fontColor	 		: string;
	
	var delimiter			: string;
	var prefix				: string;
	var language 	  		: string;
	var audioLanguage 		: string;
	
	if(false) 
	{
		wrappedMethod(item);
	}
	
	theGame.GetGameLanguageName(audioLanguage,language);
	if (language == "AR")
	{
		delimiter = "";
		prefix = "&nbsp;";
	}
	else
	{
		delimiter = ": ";
		prefix = "";
	}
	
	htmlNewline = "&#10;";
	finalString = "";
	
	dm = theGame.GetDefinitionsManager();
	craftingSchematic = getCraftingSchematicFromName(_inv.GetItemName(item));
	craftedItemName = craftingSchematic.craftedItemName;
	_inv.GetItemStatsFromName(craftedItemName, attributes);
	_inv.GetItemQualityFromName(craftedItemName, minQuality, maxQuality);
	itemType = dm.GetFilterTypeByItem(craftedItemName);
	dm.GetItemAttributeValueNoRandom(craftedItemName, true, 'weight', minWeightAttribute, maxWeightAttribute);

	tempString = GetLocStringByKeyExt(GetFilterTypeName( itemType )) + " / " + GetLocStringByKeyExt("item_category_" + dm.GetItemCategory(craftedItemName));
	finalString += "<font color=\"#FF8832\">" + tempString + "</font>";
	finalString += htmlNewline + GetItemRarityDescriptionFromInt(minQuality);
	
	if (attributes.Size() > 0)
	{
		finalString += htmlNewline;
		for (i = 0; i < attributes.Size(); i += 1)
		{
			
			color = attributes[i].attributeColor;
			tempString = htmlNewline + "<font color=\"#" + color + "\">";
			if( attributes[i].percentageValue )
			{
				tempString += (NoTrailZeros(attributes[i].value * 100 ) +"%" + prefix);
			}
			else
			{
				tempString += (NoTrailZeros(attributes[i].value) + prefix);
			}
			tempString += " " + attributes[i].attributeName;
			tempString += "</font>";
			finalString += tempString;
		}
	}
	
	finalString += htmlNewline;
	finalString += htmlNewline + "<font color=\"#C49560\">" + GetLocStringByKeyExt(_inv.GetItemLocalizedDescriptionByName(craftedItemName)) + "</font>";
	
	finalString += htmlNewline;
	finalString += htmlNewline + _inv.GetItemLevelColor( theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) ) + GetLocStringByKeyExt( 'panel_inventory_item_requires_level' ) + ": " + theGame.GetDefinitionsManager().GetItemLevelFromName( craftedItemName ) + "</font>"; 

	finalString += htmlNewline;
	finalString += htmlNewline + GetLocStringByKeyExt("panel_crafting_ingredients_start") + ":";
	
	for (i = 0; i < craftingSchematic.ingredients.Size(); i += 1)
	{
		currentIngredient = craftingSchematic.ingredients[i];
		itemQuantity = thePlayer.inv.GetItemQuantityByName(currentIngredient.itemName);
		if(currentIngredient.quantity > itemQuantity)
		{
			fontColor = "<font color=\"#FF0000\">";
		}
		else
		{
			fontColor = "<font color=\"#00FF00\">";
		}
		finalString += htmlNewline + fontColor + itemQuantity + " / " + currentIngredient.quantity + " " + GetLocStringByKeyExt( _inv.GetItemLocalizedNameByName(currentIngredient.itemName ) ) + "</font>";
	}
	
	return finalString;
}