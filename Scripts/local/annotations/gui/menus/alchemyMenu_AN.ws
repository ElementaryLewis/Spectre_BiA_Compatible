@addField(CR4AlchemyMenu)
private var bHerbalist			: bool;

@wrapMethod(CR4AlchemyMenu) function OnConfigUI()
{	
	var commonMenu 			: CR4CommonMenu;
	var l_craftingFilters	: SCraftingFilters;
	var pinnedTag			: int;
	var l_obj	 			: IScriptable;
	var l_initData			: W3InventoryInitData;
	var l_merchantComponent	: W3MerchantComponent;
	
	if(false) 
	{
		wrappedMethod();
	}

	super.OnConfigUI();
	
	m_initialSelectionsToIgnore = 2;
	
	_inv = thePlayer.GetInventory();
	m_definitionsManager = theGame.GetDefinitionsManager();
	
	_playerInv = new W3GuiPlayerInventoryComponent in this;
	_playerInv.Initialize( _inv );

	bHerbalist = false;
	l_obj = GetMenuInitData();
	l_initData = (W3InventoryInitData)l_obj;
	if( l_initData )
	{
		m_npc = (CNewNPC)l_initData.containerNPC;
	}
	else
	{
		m_npc = (CNewNPC)l_obj;
	}
	if( m_npc )
	{
		l_merchantComponent = (W3MerchantComponent)m_npc.GetComponentByClassName('W3MerchantComponent');
		bHerbalist = ((l_merchantComponent.GetMapPinType() == 'Herbalist') || (l_merchantComponent.GetMapPinType() == 'Alchemic'));
		if( bHerbalist )
		{
			m_npcInventory = m_npc.GetInventory();
			UpdateMerchantData(m_npc);
			m_shopInvComponent = new W3GuiShopInventoryComponent in this;
			m_shopInvComponent.Initialize( m_npcInventory );
		}
	}

	m_alchemyManager = new W3AlchemyManager in this;
	m_alchemyManager.Init();		
	m_recipeList     = m_alchemyManager.GetRecipes(false);
	
	m_fxSetCraftedItem = m_flashModule.GetMemberFlashFunction("setCraftedItem");
	m_fxSetCraftingEnabled = m_flashModule.GetMemberFlashFunction("setCraftingEnabled");
	m_fxHideContent = m_flashModule.GetMemberFlashFunction("hideContent");
	m_fxSetFilters = m_flashModule.GetMemberFlashFunction("SetFiltersValue");
	m_fxSetPinnedRecipe = m_flashModule.GetMemberFlashFunction("setPinnedRecipe");
	
	l_craftingFilters = GetWitcherPlayer().GetAlchemyFilters();
	m_fxSetFilters.InvokeSelfSixArgs(FlashArgString(GetLocStringByKeyExt("gui_panel_filter_has_ingredients")), FlashArgBool(l_craftingFilters.showCraftable), 
									 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_elements_missing")), FlashArgBool(l_craftingFilters.showMissingIngre), 
									 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_already_crafted")), FlashArgBool(l_craftingFilters.showAlreadyCrafted));
	
	commonMenu = (CR4CommonMenu)m_parentMenu;
	bCouldCraft = true;
	m_fxSetCraftingEnabled.InvokeSelfOneArg(FlashArgBool(bCouldCraft));
	pinnedTag = NameToFlashUInt(theGame.GetGuiManager().PinnedCraftingRecipe);
	m_fxSetPinnedRecipe.InvokeSelfOneArg(FlashArgUInt(pinnedTag));
	
	PopulateData();
	
	
	SelectFirstModule();
	
	m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
}

@wrapMethod(CR4AlchemyMenu) function BuyIngredient( itemId : SItemUniqueId, quantity : int, isLastItem : bool ) : void
{
	var newItemID   : SItemUniqueId;
	var result 		: bool;
	var itemName	: name;
	var notifText	: string;
	var itemLocName : string;
	
	if(false) 
	{
		wrappedMethod( itemId, quantity, isLastItem );
	}
	
	itemLocName = GetLocStringByKeyExt( m_npcInventory.GetItemLocalizedNameByUniqueID( itemId ) );
	itemName = m_npcInventory.GetItemName( itemId );
	theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_BOUGHT, itemName, quantity );
	result = m_shopInvComponent.GiveItem( itemId, _playerInv, quantity, newItemID );
	
	if( result )
	{
		notifText = GetLocStringByKeyExt("panel_blacksmith_items_added") + ":" + quantity + " x " + itemLocName;
		
		if (isLastItem)
		{
			PopulateData();
		}
	}
	else
	{
		notifText = GetLocStringByKeyExt( "panel_shop_notification_not_enough_money" );
	}
	
	showNotification( notifText );
	
	UpdateMerchantData(m_npc);
	UpdateItemsCounter();
	
	if (m_lastSelectedTag != '')
	{
		UpdateItems(m_lastSelectedTag);
	}
}
	
@addMethod(CR4AlchemyMenu) function UpdateMerchantData( targetNpc : CNewNPC ) : void
{
	var l_merchantData	: CScriptedFlashObject;
	
	l_merchantData = m_flashValueStorage.CreateTempFlashObject();
	GetNpcInfo((CGameplayEntity)targetNpc, l_merchantData);
	m_flashValueStorage.SetFlashObject("crafting.merchant.info", l_merchantData);
}