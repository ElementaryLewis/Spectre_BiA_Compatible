@addField(CR4LootPopup)
private var spectreAreaLoot				: spectreAoELoot;

@wrapMethod(CR4LootPopup) function OnConfigUI()
{
    var lootPopupData : W3LootPopupData;
    var targetSize : float;

    if(false) 
	{
		wrappedMethod();
	}
    
    super.OnConfigUI();
    
    setupFunctions();
    
    lootPopupData = (W3LootPopupData)GetPopupInitData();
    
    theGame.ForceUIAnalog(true);
    theGame.GetGuiManager().RequestMouseCursor(true);
    
    
    if (lootPopupData && lootPopupData.targetContainer && !theGame.IsDialogOrCutscenePlaying() && !theGame.GetGuiManager().IsAnyMenu())
    {
        theInput.StoreContext( 'EMPTY_CONTEXT' );
        inputContextSet = true;
        
        thePlayer.GetUsedHorseComponent().OnHorseStop();
        
        theSound.SoundEvent("gui_loot_popup_open");
        spectreAreaLoot = new spectreAoELoot in this;		
        _container = lootPopupData.targetContainer;
        spectreAreaLoot.initialize(_container);
        PopulateData();
        
        spectreAreaLoot.signalReactionEvent('LootingAction');
        
        if (StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('Hud', 'HudSize'), 0) == 0)
        {
            targetSize = 0.85;
            if (theInput.LastUsedPCInput())
            {
                theGame.MoveMouseTo(0.4, 0.63);
            }
        }
        else
        {
            targetSize = 1;
            if (theInput.LastUsedPCInput())
            {
                theGame.MoveMouseTo(0.4, 0.58);
            }
        }
        
        thePlayer.RaiseEvent('LootHerb');

        m_fxSetWindowScale.InvokeSelfOneArg(FlashArgNumber(targetSize));
    }
    else
    {
        ClosePopup();
    }
}

@wrapMethod(CR4LootPopup) function OnClosingPopup()
{
    if(false) 
	{
		wrappedMethod();
	}

    theSound.SoundEvent("gui_loot_popup_close");
    super.OnClosingPopup();
    if (theInput.GetContext() == 'EMPTY_CONTEXT' && inputContextSet)
    {
        theInput.RestoreContext( 'EMPTY_CONTEXT', false );
    }
    
    theGame.GetGuiManager().RequestMouseCursor(false);
    theGame.ForceUIAnalog(false);

    spectreAreaLoot.signalReactionEvent('ContainerClosed');
    
    
    if(ShouldProcessTutorial('TutorialLootWindow'))
    {
        FactsAdd("tutorial_container_close", 1, 1 );	
    }
    if( _container )
    {
        _container.OnContainerClosed();
    }
}

@wrapMethod(CR4LootPopup) function PopulateData()
{
    var	parsed, container_idx, item_count, itemid	: int;
    var l_lootItemsFlashArray			: CScriptedFlashArray;
    var l_lootItemsDataFlashObject		: CScriptedFlashObject;
    var l_containerInv 					: CInventoryComponent;
    var l_item							: SItemUniqueId;
    var l_itemName						: string;
    var l_itemIconPath					: string;
    var l_itemQuantity, l_itemStock		: int;
    var l_itemPrice						: float;
    var l_weight 						: float;
    var l_name							: name;
    var l_isBookRead					: bool;
    var ids								: array<SItemUniqueId>;
    var l_primaryStatLabel				: string;
    var l_primaryStatValue				: float;
    var l_typeStr						: string;
    var l_questTag						: string;

    if(false) 
	{
		wrappedMethod();
	}

    spectreAreaLoot.sorted_inventories.Clear();
    container_idx = spectreAreaLoot.inventories.Size();
    item_count = spectreAreaLoot.getContainersItemCount(spectreAreaLoot.inventories);
    l_lootItemsFlashArray = m_flashValueStorage.CreateTempFlashArray();
    l_lootItemsFlashArray.SetLength(item_count);
    m_fxResizeBackground.InvokeSelfOneArg(FlashArgBool(item_count > 4) );
    while (container_idx)
    {	container_idx -= 1;
        l_containerInv = spectreAreaLoot.inventories[container_idx];
        l_containerInv.GetAllItems(ids);
        item_count = ids.Size();
        for (itemid = 0; itemid < item_count; itemid += 1)
        {	l_item = ids[itemid];
            if (!l_containerInv.ItemHasTag(l_item, 'Lootable') && (l_containerInv.ItemHasTag(l_item, theGame.params.TAG_DONT_SHOW ) || l_containerInv.ItemHasTag(l_item,'NoDrop') ) )
                continue ;
            l_lootItemsDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
            l_name = l_containerInv.GetItemName(l_item);
            l_itemName = l_containerInv.GetItemLocalizedNameByUniqueID(l_item);
            l_itemPrice = l_containerInv.GetItemPriceModified( l_item );
			l_itemStock = thePlayer.GetInventory().GetItemQuantityByName(l_name) + GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemQuantityByName(l_name);
            l_itemName = GetLocStringByKeyExt(l_itemName);
            if (l_itemName == "")
                l_itemName = " ";
            l_lootItemsDataFlashObject.SetMemberFlashString	("label", l_itemName );
            if (l_containerInv.IsItemSingletonItem(l_item))
                l_itemQuantity = thePlayer.inv.SingletonItemGetAmmo(l_item);
            else
                l_itemQuantity = l_containerInv.GetItemQuantity( l_item );
            l_lootItemsDataFlashObject.SetMemberFlashInt("quantity", l_itemQuantity );
            l_lootItemsDataFlashObject.SetMemberFlashInt("quality", l_containerInv.GetItemQuality( l_item ) );
            l_itemIconPath = l_containerInv.GetItemIconPathByUniqueID(l_item);
            l_lootItemsDataFlashObject.SetMemberFlashString("iconPath", l_itemIconPath );

            if( l_containerInv.ItemHasTag(l_item, 'Quest') )
			{
				l_weight = 0;
			}
			else
			{
                if (!l_containerInv.ItemHasTag(l_item, 'Quest') && !l_containerInv.IsItemIngredient(l_item) && !l_containerInv.IsItemAlchemyItem(l_item) )
                {	
                    l_weight = l_containerInv.GetItemEncumbrance( l_item );
                    l_lootItemsDataFlashObject.SetMemberFlashString ( "WeightValue", NoTrailZeros( RoundTo( l_weight, 2 ) ) );
                }
            }
            l_questTag = "";
            if (l_containerInv.ItemHasTag(l_item, 'Quest'))
                l_questTag = "Quest";
            else if (l_containerInv.ItemHasTag(l_item, 'QuestEP1'))
                l_questTag = "QuestEP1";
            else if (l_containerInv.ItemHasTag(l_item, 'QuestEP2'))
                l_questTag = "QuestEP2";
            if (l_questTag != "")
            {	l_lootItemsDataFlashObject.SetMemberFlashBool("isQuestItem", true);
                l_lootItemsDataFlashObject.SetMemberFlashString("questTag", l_questTag );
            }
            if (l_isBookRead = l_containerInv.IsBookReadByName(l_name) )
                l_lootItemsDataFlashObject.SetMemberFlashBool("isRead", l_isBookRead );
            l_typeStr = GetItemRarityDescription(l_item, l_containerInv) + theGame.alchexts.GetIngredientPopupDescription(l_name, l_containerInv.IsItemAlchemyIngredient(l_item) );
            l_lootItemsDataFlashObject.SetMemberFlashString("itemType", l_typeStr );
            l_containerInv.GetItemPrimaryStat(l_item, l_primaryStatLabel, l_primaryStatValue);
            l_lootItemsDataFlashObject.SetMemberFlashString("PrimaryStatLabel", l_primaryStatLabel);
            l_lootItemsDataFlashObject.SetMemberFlashNumber("PrimaryStatValue", l_primaryStatValue);
            l_lootItemsDataFlashObject.SetMemberFlashString	( "PriceValue", NoTrailZeros( l_itemPrice ) );
            l_lootItemsDataFlashObject.SetMemberFlashString ( "StockValue", l_itemStock );
            l_lootItemsFlashArray.SetElementFlashObject(parsed, l_lootItemsDataFlashObject);
            spectreAreaLoot.sorted_inventories.PushBack(spectreAreaLoot.inventories[container_idx]);
            parsed += 1;
        }
    }
    m_flashValueStorage.SetFlashArray(KEY_LOOT_ITEM_LIST, l_lootItemsFlashArray );
    m_fxSetWindowTitle.InvokeSelfOneArg(FlashArgString( _container.GetDisplayName() ) );	
}

@wrapMethod(CR4LootPopup) function OnPopupTakeAllItems( ) : void
{
    if(false) 
	{
		wrappedMethod();
	}

    GetWitcherPlayer().StartInvUpdateTransaction();
    spectreAreaLoot.signalReactionEvent('StealingAction');
    TakeAllAction();
    GetWitcherPlayer().FinishInvUpdateTransaction();
    
    OnCloseLootWindow();
}

@wrapMethod(CR4LootPopup) function OnPopupTakeItem( Id : int ) : void
{
    var containerInv 		: CInventoryComponent;
    var playerInv 			: CInventoryComponent;
    var item 				: SItemUniqueId;
    var invalidatedItems 	: array< SItemUniqueId >;
    var itemName 			: name;
    var itemQuantity, i		: int;
    var category			: name;
    var l_allItems			: array<SItemUniqueId>;

    if(false) 
	{
		wrappedMethod(Id);
	}

    thePlayer.RaiseEvent('LootHerb');
    
    m_indexToSelect = Id;

    if (!spectreAreaLoot.takeItem(Id, _container) )
        OnCloseLootWindow();
    else
    {	m_fxSetSelectionIndex.InvokeSelfOneArg(FlashArgInt(m_indexToSelect ) );
        PopulateData();
    }
    return true;

    SignalStealingReactionEvent();
    
    m_indexToSelect = Id;
    
    containerInv 	= _container.GetInventory();
    playerInv 		= GetWitcherPlayer().inv;
    containerInv.GetAllItems( l_allItems );
    
    for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
    {
        if( ( containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
        {
            l_allItems.Erase(i);
        }
    }
    
    item 			= l_allItems[ Id ];
    itemName 		= containerInv.GetItemName(item);
    itemQuantity 	= containerInv.GetItemQuantity(item);
    if( containerInv.ItemHasTag(item, 'HerbGameplay') )
    {
        category	 	= 'herb';
    }
    else
    {
        category	 	= containerInv.GetItemCategory(item);
    }
    
    containerInv.NotifyItemLooted( item );
    containerInv.GiveItemTo( playerInv, item, itemQuantity, true, false, true );
    PlayItemEquipSound( category );
    
    containerInv.GetAllItems( l_allItems );
    for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
    {
        if( (containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
        {
            l_allItems.Erase(i);
        }
    }
    
    if( _container )
    {
        _container.InformClueStash();
    }
    
    if( l_allItems.Size() == 0)
    {
        OnCloseLootWindow();
        _container.Enable( false);
    }
    else
    {
        m_fxSetSelectionIndex.InvokeSelfOneArg( FlashArgInt( m_indexToSelect ) );
        PopulateData();
    }
}

@wrapMethod(CR4LootPopup) function TakeAllAction() : void
{
    if(false) 
	{
		wrappedMethod();
	}

    thePlayer.RaiseEvent('LootHerb');

    spectreAreaLoot.takeAllItems(_container);
}