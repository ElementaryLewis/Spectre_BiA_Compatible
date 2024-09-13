function IsAlchemy18Recipe( type : EAlchemyCookedItemType ) : bool
{
	return ((type == EACIT_Potion) || (type == EACIT_Bomb) || (type == EACIT_Oil) || (type == EACIT_Substance) || (type == EACIT_MutagenPotion));
}

function GetAlchemy18RecipeLevel( recipe : SAlchemyRecipe ) : int
{
	if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_Bomb || recipe.cookedItemType == EACIT_Oil)
		return recipe.level;
	if(recipe.cookedItemType == EACIT_Substance)
		return 2;
	if(recipe.cookedItemType == EACIT_MutagenPotion)
		return 3;
	return 999;
}

@replaceMethod function AlchemyCookedItemTypeStringToEnum(nam : string) : EAlchemyCookedItemType
{
	switch(nam)
	{
		case "potion" 			: return EACIT_Potion;
		case "petard"   		: return EACIT_Bomb;
		case "oil"    			: return EACIT_Oil;
		case "Substance" 		: return EACIT_Substance;
		case "bolt"				: return EACIT_Bolt;
		case "mutagen_potion" 	: return EACIT_MutagenPotion;
		case "alcohol"			: return EACIT_Alcohol;
		case "quest"			: return EACIT_Quest;
		case "dye"				: return EACIT_Dye;
		case "edibles"			: return EACIT_Edibles;
		default	     			: return EACIT_Undefined;
	}
}

@replaceMethod function AlchemyCookedItemTypeEnumToName( type : EAlchemyCookedItemType) : name
{
	switch (type)
	{
		case EACIT_Potion			: return 'potion';
		case EACIT_Bomb				: return 'petard';
		case EACIT_Oil				: return 'oil';
		case EACIT_Substance		: return 'Substance';
		case EACIT_Bolt				: return 'bolt';
		case EACIT_MutagenPotion 	: return 'mutagen_potion';
		case EACIT_Alcohol 			: return 'alcohol';
		case EACIT_Quest			: return 'quest';
		case EACIT_Dye				: return 'dye';
		case EACIT_Edibles			: return 'edibles';
		default	     				: return '___'; 
	}
}

@replaceMethod function AlchemyCookedItemTypeToLocKey( type : EAlchemyCookedItemType ) : string
{
	switch (type)
	{
		case EACIT_Potion			: return "panel_alchemy_tab_potions";
		case EACIT_Bomb				: return "panel_alchemy_tab_bombs";
		case EACIT_Oil				: return "panel_alchemy_tab_oils";
		case EACIT_Substance		: return "item_category_Substance";
		case EACIT_Bolt				: return "item_category_bolt";
		case EACIT_MutagenPotion 	: return "panel_inventory_filter_type_decoctions";
		case EACIT_Alcohol 			: return "panel_inventory_filter_type_alcohols";
		case EACIT_Quest 			: return "panel_button_worldmap_showquests";
		case EACIT_Dye				: return "item_category_dye";
		case EACIT_Edibles			: return "item_category_edibles";
		default	     				: return "";
	}
}