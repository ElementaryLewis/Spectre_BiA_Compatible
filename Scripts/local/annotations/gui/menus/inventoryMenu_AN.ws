@wrapMethod(CR4InventoryMenu) function OnConfigUI()
{
	var l_flashPaperdoll		: CScriptedFlashSprite;
	var l_flashInventory		: CScriptedFlashSprite;
	var l_flashObject			: CScriptedFlashObject;
	var l_flashArray			: CScriptedFlashArray;
	var l_obj		 			: IScriptable;
	var l_containerNpc			: CNewNPC;
	var l_horse 				: CActor;
	var l_initData				: W3InventoryInitData;
	var l_craftIngredientsList	: array<name>;
	var merchantComponent : W3MerchantComponent;
	var pinTypeName 	  : name;
	var defaultTab        : int;
	var hasNewItems 	  : array<bool>;
	var tempItem, tempItem2 : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	m_initialSelectionsToIgnore = 2;
	drawHorse = false;
	m_menuInited = false;
	
	super.OnConfigUI();
	
	l_obj = GetMenuInitData();
	_container = (W3Container)l_obj;
	l_containerNpc = (CNewNPC)l_obj;
	
	l_initData = (W3InventoryInitData) l_obj;
	if (l_initData)
	{
		_container = (W3Container)l_initData.containerNPC;
		if (!_container)
		{
			l_containerNpc = (CNewNPC)l_initData.containerNPC;
		}
		m_tagsFilter = l_initData.filterTagsList;
		m_ignoreSaveData = true;			
	}
	if (l_containerNpc)
	{
		if (l_containerNpc.HasTag('Merchant'))
		{
			m_initialSelectionsToIgnore = 3;
			_shopNpc = l_containerNpc;
			m_ignoreSaveData = true;
		}
	}
	
	m_flashModule = GetMenuFlash();
	m_fxSetSortingMode = m_flashModule.GetMemberFlashFunction("setSortingMode");
	m_fxSetFilteringMode = m_flashModule.GetMemberFlashFunction( "setFilteringMode" );
	m_fxPaperdollRemoveItem = m_flashModule.GetMemberFlashFunction( "paperdollRemoveItem" );
	m_fxInventoryRemoveItem = m_flashModule.GetMemberFlashFunction( "inventoryRemoveItem" );
	m_fxInventoryUpdateFilter = m_flashModule.GetMemberFlashFunction( "forceSelectTab" );
	m_fxForceSelectItem = m_flashModule.GetMemberFlashFunction( "forceSelectItem" );		
	m_fxForceSelectPaperdollSlot = m_flashModule.GetMemberFlashFunction( "forceSelectPaperdollSlot" );
	m_fxRemoveContainerItem = m_flashModule.GetMemberFlashFunction( "shopRemoveItem" );
	m_fxSetInventoryMode = m_flashModule.GetMemberFlashFunction( "setInventoryMode" );
	m_fxHideSelectionMode = m_flashModule.GetMemberFlashFunction( "hideSelectionMode" );
	m_fxSetNewFlagsForTabs = m_flashModule.GetMemberFlashFunction( "setNewFlagsForTabs" );
	m_fxSetVitality = m_flashModule.GetMemberFlashFunction( "setVitality" );
	m_fxSetToxicity = m_flashModule.GetMemberFlashFunction( "setToxicity" );
	m_fxSetPreviewMode = m_flashModule.GetMemberFlashFunction( "setPreviewMode" );
	m_fxSetDefaultTab = m_flashModule.GetMemberFlashFunction( "setDefaultTab" );
	m_fxSetPaperdollPreviewIcon = m_flashModule.GetMemberFlashFunction( "setPaperdollPreviewIcon" );
	
	m_fxSetSortingMode.InvokeSelfSixArgs(FlashArgInt(theGame.GetGuiManager().GetInventorySortingMode()),
										 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_item_type")),
										 FlashArgString(GetLocStringByKeyExt("attribute_name_price")),
										 FlashArgString(GetLocStringByKeyExt("attribute_name_weight")),
										 FlashArgString(GetLocStringByKeyExt("attribute_name_durability")),
										 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_item_rarity")));
	
	_inv = thePlayer.GetInventory();
			
	
	GetWitcherPlayer().UnequipItemFromSlot(EES_Petard2,true);		
	_inv.GetItemEquippedOnSlot( EES_Quickslot2, tempItem );
	if(_inv.IsIdValid(tempItem) && _inv.GetItemCategory(tempItem) != 'mask')
	{			
		GetWitcherPlayer().UnequipItemFromSlot(EES_Quickslot2,true);
	}	
	
	
	_inv.GetItemEquippedOnSlot( EES_Quickslot1, tempItem );
	_inv.GetItemEquippedOnSlot( EES_Quickslot2, tempItem2 );
	if(!_inv.IsIdValid(tempItem2) && _inv.IsIdValid(tempItem) && _inv.GetItemCategory(tempItem) == 'mask')
	{
		GetWitcherPlayer().EquipItemInGivenSlot(tempItem, EES_Quickslot2, true, false);
	}
	
		
	_playerInv = new W3GuiPlayerInventoryComponent in this;
	_playerInv.Initialize( _inv );
	_playerInv.filterTagList = m_tagsFilter;
	_playerInv.autoCleanNewMark = true;
	
	if (m_tagsFilter.Size() > 0)
	{
		_playerInv.SetFilterType(IFT_None);
	}
	
	_currentInv = _playerInv;
	
	_paperdollInv = new W3GuiPaperdollInventoryComponent in this;
	_paperdollInv.Initialize( _inv );
	
	_horseInv = new  W3GuiContainerInventoryComponent in this;
	_horseInv.Initialize(GetWitcherPlayer().GetHorseManager().GetInventoryComponent());
	_horsePaperdollInv = new  W3GuiHorseInventoryComponent in this;
	_horsePaperdollInv.Initialize(GetWitcherPlayer().GetHorseManager().GetInventoryComponent());
	
	_tooltipDataProvider = new W3TooltipComponent in this;
	_tooltipDataProvider.initialize(_inv, m_flashValueStorage);
	
	theGame.GetGuiManager().SetBackgroundTexture( LoadResource( "inventory_background" ) );
	
	m_flashValueStorage.SetFlashString("inventory.grid.paperdoll.pockets",GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_quickitems"));
	m_flashValueStorage.SetFlashString("inventory.grid.paperdoll.potions",GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_potions"));
	m_flashValueStorage.SetFlashString("inventory.grid.paperdoll.petards",GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_petards"));
	m_flashValueStorage.SetFlashString("inventory.grid.paperdoll.masks",GetLocStringByKeyExt("item_category_mask")); 
	m_flashValueStorage.SetFlashString("playerstats.stats.name", GetLocStringByKeyExt("panel_common_statistics_name") );
	
	if( _container )
	{
		_containerInv = new W3GuiContainerInventoryComponent in this;
		_containerInv.Initialize( _container.GetInventory() );
		if( m_tagsFilter.Size() > 0 )
		{
			if( m_tagsFilter.FindFirst('HideOwnerInventory') != -1 )
			{
				_containerInv.HideAllItems();
			}
		}
		
		_playerInv.currentDefaultItemAction = IAT_Transfer;
		_paperdollInv.currentDefaultItemAction = IAT_Transfer;
		m_flashValueStorage.SetFlashString("inventory.grid.container.name",_container.GetDisplayName(false));
		_defaultInventoryState = IMS_Container;
	}
	else if( _shopNpc )
	{
		_shopInv = new W3GuiShopInventoryComponent in this;
		_shopNpc.GetInventory().UpdateLoot();
		_shopNpc.GetInventory().ClearGwintCards();
		_shopNpc.GetInventory().ClearTHmaps();
		_shopNpc.GetInventory().ClearKnownRecipes();
		_shopInv.Initialize( _shopNpc.GetInventory() );
		
		merchantComponent = (W3MerchantComponent)_shopNpc.GetComponentByClassName( 'W3MerchantComponent' );
		if( merchantComponent )
		{
			pinTypeName = merchantComponent.GetMapPinType();
			
			switch( pinTypeName )
			{
				case 'Alchemic':
				case 'Herbalist':
					defaultTab = 0;
					break;
				case 'Innkeeper':
					defaultTab = 2;
					break;
				default:
					defaultTab = -1;
			}
			
			m_fxSetDefaultTab.InvokeSelfOneArg( FlashArgInt( defaultTab ) );
		}
		
		
		
		_tooltipDataProvider.setShopInventory(_shopNpc.GetInventory());
		
		_playerInv.SetShopInvCmp( _shopInv );
		_playerInv.currentDefaultItemAction = IAT_Sell;
		m_flashValueStorage.SetFlashString("inventory.grid.container.name",_shopNpc.GetDisplayName(false));
		_defaultInventoryState = IMS_Shop;
		UpdateMerchantData();
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu('ShopMenu');
		}
		
		l_craftIngredientsList = UpdatePinnedCraftingItemInfo();
		_shopInv.highlightItems(l_craftIngredientsList);			
	}
	else if( l_containerNpc )
	{
		_containerInv = new W3GuiContainerInventoryComponent in this;
		_containerInv.Initialize( l_containerNpc.GetInventory() );
		
		_playerInv.currentDefaultItemAction = IAT_Transfer;
		_paperdollInv.currentDefaultItemAction = IAT_Transfer;
		
		m_flashValueStorage.SetFlashString("inventory.grid.container.name",l_containerNpc.GetDisplayName(false));
		_defaultInventoryState = IMS_Container;
	}
	else if ( theGame.GameplayFactsQuerySum("stashMode") == 1 )
	{
		_defaultInventoryState = IMS_Stash;
	}
	else
	{
		_defaultInventoryState = IMS_Player;
		spectreFixQuestItems_internal();				  
	}
	
	defaultTab = SetInitialTabNewFlags( hasNewItems );
	if( _defaultInventoryState == IMS_Container )
	{
		
		m_fxSetDefaultTab.InvokeSelfOneArg( FlashArgInt( defaultTab ) );
	}
	
	PaperdollUpdateAll();
	UpdatePlayerStatisticsData();
	
	m_menuInited = true;
	if (m_menuState == '') m_menuState = 'CharacterInventory';
	ApplyMenuState(m_menuState);
	
	_currentEqippedQuickSlot = GetCurrentEquippedQuickSlot();
	SelectCurrentModule();	
	
	m_fxSetNewFlagsForTabs.InvokeSelfSixArgs( FlashArgBool(hasNewItems[0]), FlashArgBool(hasNewItems[1]), FlashArgBool(hasNewItems[2]), FlashArgBool(hasNewItems[3]), FlashArgBool(hasNewItems[4]), FlashArgBool(hasNewItems[5] ) );
	m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
	
	m_dyePreviewSlots.Resize( EnumGetMax( 'EEquipmentSlots' ) + 1 );
	m_previewSlots.Resize( EnumGetMax( 'EEquipmentSlots' ) + 1 );		
}

@addMethod(CR4InventoryMenu) function spectreUpdateFace()
{
	PlayPaperdollAnimation( 'armor' );
	UpdateGuiSceneEntityItems();
}

@addMethod(CR4InventoryMenu) function PlayerDismantleItem(currentItemId : SItemUniqueId)
{
	var isAlchemy, isCrafting : bool;
	var invComp : CInventoryComponent;
	
	invComp = _playerInv.GetInventoryComponent();

	if(!invComp.ItemHasRecyclingParts(currentItemId))
		return;
		
	isAlchemy = invComp.IsItemAlchemyIngredient(currentItemId);
	isCrafting = invComp.IsItemCraftingIngredient(currentItemId) || invComp.IsItemJunk(currentItemId);
	
	if(!isAlchemy && !isCrafting)
		return;
	
	if(isAlchemy && invComp.GetItemQuantityByName('alchemy_dismantle_kit_1') < 1)
		return;

	if(isCrafting && invComp.GetItemQuantityByName('gear_dismantle_kit_1') < 1)
		return;
	
	invComp.RecycleItem(currentItemId, ECL_Arch_Master);

	if(isAlchemy)
		invComp.RemoveItemByName('alchemy_dismantle_kit_1', 1);
	else if(isCrafting)
		invComp.RemoveItemByName('gear_dismantle_kit_1', 1);

	UpdateItemsCounter();
	UpdatePlayerStatisticsData();
	UpdateEncumbranceInfo();
	PopulateTabData(InventoryMenuTab_Weapons);
	PopulateTabData(InventoryMenuTab_Potions);
	PopulateTabData(InventoryMenuTab_Ingredients);
	PopulateTabData(InventoryMenuTab_QuestItems);
	PopulateTabData(InventoryMenuTab_Default);
	PopulateTabData(InventoryMenuTab_Books);
}

@replaceMethod(CR4InventoryMenu) function UnequipItem( item : SItemUniqueId, moveToIndex : int, optional forceUnequip : bool ) : bool
{
	var forceInvAllUpdate : bool;
	var isSetBonusActive  : bool;
	var filterType 	   : EInventoryFilterType;
	var itemOnSlot 	   : SItemUniqueId;
	var crossbowOnSlot : SItemUniqueId;
	var horseItem 	   : SItemUniqueId;
	var slot 		   : EEquipmentSlots;
	var itemsList      : array<SItemUniqueId>;
	var gridUpdateList : array<SItemUniqueId>;
	var abls	       : array<name>;
	var i, targetSlot  : int;
	
	forceInvAllUpdate = false;
	
	if (thePlayer.IsInCombat() && !forceUnequip)
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		OnPlaySoundEvent("gui_global_denied");
		return false;
	}
	
	if ( _horsePaperdollInv.GetInventoryComponent().IsIdValid(item) && _horsePaperdollInv.isHorseItem(item))
	{
		slot = _horsePaperdollInv.GetInventoryComponent().GetSlotForItemId(item);
		horseItem = GetWitcherPlayer().GetHorseManager().UnequipItem(slot);
		
		PlayItemUnequipSound( _inv.GetItemCategory(horseItem) );
		
		m_fxInventoryUpdateFilter.InvokeSelfOneArg( FlashArgUInt( GetTabIndexForSlot(slot) ));
		
		InventoryUpdateItem(horseItem);
		
		PaperdollUpdateAll(); 
		
		UpdateEncumbranceInfo();
		
		
		
		
		PlayItemUnequipSound( _horsePaperdollInv.GetInventoryComponent().GetItemCategory(item) );
		
		return true; 
	}
	
	if( _containerInv )
	{
		GiveItem(item, 1);
		UpdateContainer();
		
		InventoryUpdateItem(item);
		PaperdollRemoveItem(item);
		UpdatePlayerStatisticsData();
	}
	else if (_inv.IsIdValid(item))
	{
		if (_inv.IsItemBolt(item) && _inv.ItemHasTag(item,theGame.params.TAG_INFINITE_AMMO))
		{
			return false;
		}
		
		LogChannel('ITEMDRAG'," OnUnequipItem "+_playerInv.GetItemName(item)+" moveToIndex "+moveToIndex);
		if( moveToIndex > -1 )
		{
			_playerInv.MoveItem( item , moveToIndex );
		}
		
		PlayItemUnequipSound( _inv.GetItemCategory(item) );
		
		if (_inv.IsItemCrossbow(item) && GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt,itemOnSlot))
		{
			_playerInv.UnequipItem( itemOnSlot );
			PaperdollRemoveItem(itemOnSlot);
			
			if (!_inv.ItemHasTag(itemOnSlot,theGame.params.TAG_INFINITE_AMMO))
			{
				forceInvAllUpdate = true;
			}
		}
		
		isSetBonusActive = GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_2 );
		
		targetSlot = _inv.GetSlotForItemId( item );
		ResetDisplayPreviewCache( item, slot, gridUpdateList );
		
		_playerInv.UnequipItem( item );
		filterType = _playerInv.GetFilterTypeByItem(item);
		_playerInv.SetFilterType( filterType );
		UpdateInventoryFilter(filterType);
		
		if (_inv.IsItemSetItem(item) && isSetBonusActive)
		{
			PushIfItemEquipped(itemsList, EES_Petard1);
			PushIfItemEquipped(itemsList, EES_Petard2);
			PushIfItemEquipped(itemsList, EES_Quickslot1);
			PushIfItemEquipped(itemsList, EES_Quickslot2);
			PushIfItemEquipped(itemsList, EES_Potion1);
			PushIfItemEquipped(itemsList, EES_Potion2);
			PushIfItemEquipped(itemsList, EES_Potion3);
			PushIfItemEquipped(itemsList, EES_Potion4);
			
			PopulateTabData(InventoryMenuTab_Potions);
		}
		
		if (forceInvAllUpdate)
		{
			PopulateTabData(getTabFromItem(item));
		}
		else
		{
			gridUpdateList.PushBack( item );
		}
		
		if (_inv.GetEnchantment(item) == 'Runeword 6')
		{
			AddEquippedPotionsToList(itemsList);
		}
		
		PaperdollRemoveItem(item);
		
		if(_inv.IsItemBolt(item) && GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, itemOnSlot))
		{
			itemsList.PushBack(itemOnSlot);
		}
		
		PaperdollUpdateItemsList(itemsList);
		
		UpdatePlayerStatisticsData();
	}
	
	if( gridUpdateList.Size() > 0 )
	{
		InventoryUpdateItems( gridUpdateList );
	}
	
	UpdateEncumbranceInfo();
	UpdateGuiSceneEntityItems();
	
		
	switch (_inv.GetItemCategory( item ))
		{
		case 'steelsword':
			m_player.RaiseEvent('RemoveSteelSword_Inv');
			break;
		case 'silversword':
			m_player.RaiseEvent('RemoveSilverSword_Inv');
			break;
		case 'crossbow':
			m_player.RaiseEvent('RemoveCrossbow_Inv');
			break;
		default:
			break;
		}
	
	return true;
}

@wrapMethod(CR4InventoryMenu) function ApplyRepairKit(itemId : SItemUniqueId,  targetSlot : int) : void
{
	var curItemInSlot : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod(itemId, targetSlot);
	}
	
	OnPlaySoundEvent("gui_inventory_repair");
	
	if (_inv.GetItemEquippedOnSlot(targetSlot, curItemInSlot))
	{
		if ( !( _inv.GetItemName(itemId) == 'weapon_repair_kit_4' || _inv.GetItemName(itemId) == 'armor_repair_kit_4' ) && _inv.GetItemDurability( curItemInSlot ) == 100 )
		{
			OnPlaySoundEvent( "gui_global_denied" );
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
			return;
		}

		GetWitcherPlayer().RepairItem (itemId, curItemInSlot);
		if (_inv.IsIdValid(itemId) && _inv.GetItemQuantity( itemId ) > 0)
		{
			InventoryUpdateItem(itemId);
		}
		else
		{
			InventoryRemoveItem(itemId);
		}
		if( !thePlayer.HasRequiredLevelToEquipItem( curItemInSlot ) )
		{
			UnequipItem( curItemInSlot, -1, true );
		}
		else
		{
			PaperdollUpdateItem(curItemInSlot);
		}
	}
	else
	{
		return;
	}
}