@replaceMethod function SetItemNameToType( nam : name ) : EItemSetType
{
	switch( nam )
	{
		case theGame.params.ITEM_SET_TAG_LYNX : 			return EIST_Lynx ;
		case theGame.params.ITEM_SET_TAG_GRYPHON : 			return EIST_Gryphon ;
		case theGame.params.ITEM_SET_TAG_BEAR : 			return EIST_Bear ;
		case theGame.params.ITEM_SET_TAG_WOLF : 			return EIST_Wolf ;
		case theGame.params.ITEM_SET_TAG_RED_WOLF : 		return EIST_RedWolf ;
		case theGame.params.ITEM_SET_TAG_VAMPIRE :			return EIST_Vampire ;
		case theGame.params.ITEM_SET_TAG_VIPER : 			return EIST_Viper;								
		case theGame.params.ITEM_SET_TAG_NETFLIX : 			return EIST_Netflix;
		case theGame.params.ITEM_SET_TAG_KAER_MORHEN :		return EIST_KaerMorhen;
		case theGame.params.ITEM_SET_TAG_LYNX_MINOR :		return EIST_Lynx_Minor;
		case theGame.params.ITEM_SET_TAG_GRYPHON_MINOR :	return EIST_Gryphon_Minor;
		case theGame.params.ITEM_SET_TAG_BEAR_MINOR :		return EIST_Bear_Minor;
		case theGame.params.ITEM_SET_TAG_WOLF_MINOR :		return EIST_Wolf_Minor;
		case theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR :	return EIST_RedWolf_Minor;
		default: 											return EIST_Undefined;
	}
}

@replaceMethod function GetSetBonusAbility( setBonus : EItemSetBonus ) : name
{
	switch( setBonus )
	{
		case EISB_Lynx_2:				return 'setBonusAbilityLynx_2';
		case EISB_Bear_1:				return 'setBonusAbilityBear_1';
		case EISB_Bear_2:				return 'setBonusAbilityBear_2';
		case EISB_RedWolf_1:			return 'setBonusAbilityRedWolf_1';	
		case EISB_RedWolf_2:			return 'setBonusAbilityRedWolf_2';
		case EISB_Wolf_1:				return 'SetBonusAbilityWolf_1';
		case EISB_Netflix_1:			return 'SetBonusAbilityNetflix_1';
		case EISB_Wolf_2:				return 'SetBonusAbilityWolf_2';
		case EISB_Gryphon_1:			return 'SetBonusAbilityGryphon_1';
		default: 						return '';
	}
}

function GetNumItemsRequiredForSetActivation( setType : EItemSetType ) : int
{
	return theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
}

function GetNumItemsRequiredForFullSet( setType : EItemSetType ) : int
{
	switch( setType )
	{
		case EIST_KaerMorhen:
			return 4;
		default:
			return theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
	}
}