@addField(W3ItemSelectionPopupData)
var menuCallBack : CR4AlchemyMenu;

@addField(W3ItemSelectionPopupData)
var frame : W3PopupData; 

@addField(W3ItemSelectionPopupData)
var category : name;

@wrapMethod(CR4ItemSelectionPopup) function OnConfigUI()
{
    if(false) 
	{
		wrappedMethod();
	}

    super.OnConfigUI();
    
    theInput.StoreContext( 'EMPTY_CONTEXT' );
    m_DataObject = (W3ItemSelectionPopupData)GetPopupInitData();		
    
    if (!m_DataObject)
    {
        ClosePopup();
    }
    
    if (theInput.LastUsedPCInput())
    {
        theGame.MoveMouseTo(0.34, 0.36);
    }
    
    
    m_fxSetItemDescription = GetPopupFlash().GetMemberFlashFunction( "setItemDescription" );
    m_fxSetCategory = GetPopupFlash().GetMemberFlashFunction( "setCategory" );
    m_fxShowCategoryButtons = GetPopupFlash().GetMemberFlashFunction( "showCategoryButtons" );
    m_fxDeselectItem = GetPopupFlash().GetMemberFlashFunction( "deselectItem" );
    
    if( m_DataObject.selectionMode == EISPM_RadialMenuSlot1 
        || m_DataObject.selectionMode == EISPM_RadialMenuSlot2 
        || m_DataObject.selectionMode == EISPM_RadialMenuSlot3 
        || m_DataObject.selectionMode == EISPM_RadialMenuSlot4 )
    {	
        tagsP.PushBack('Potion');
        tagsM.PushBack('Mutagen');
        tagsE.PushBack('Edibles');
    
        forbiddenTags.PushBack('NoEquip');
        forbiddenTagsPotion.PushBack('NoEquip');
        forbiddenTagsPotion.PushBack('Mutagen');
        forbiddenTagsPotion.PushBack('Edibles');
        
        m_potionInv = new W3GuiSelectItemComponent in this;
        m_potionInv.Initialize( thePlayer.GetInventory() );
        m_potionInv.filterTagList = tagsP;
        m_potionInv.filterForbiddenTagList = forbiddenTagsPotion;
        m_potionInv.ignorePosition = true;
        m_potionInv.SetFilterType( IFT_None );
        
        m_potionInv.maxItemLimit = 80;
        
        m_mutagenInv = new W3GuiSelectItemComponent in this;
        m_mutagenInv.Initialize( thePlayer.GetInventory() );
        m_mutagenInv.filterTagList = tagsM;
        m_mutagenInv.filterForbiddenTagList = forbiddenTags;
        m_mutagenInv.ignorePosition = true;
        m_mutagenInv.checkTagsOR = true;
        m_mutagenInv.SetFilterType( IFT_None );
        
        m_mutagenInv.maxItemLimit = 80;
        
        m_edibleInv = new W3GuiSelectItemComponent in this;
        m_edibleInv.Initialize( thePlayer.GetInventory() );
        m_edibleInv.filterTagList = tagsE;
        m_edibleInv.filterForbiddenTagList = forbiddenTags;
        m_edibleInv.ignorePosition = true;
        m_edibleInv.checkTagsOR = true;
        m_edibleInv.SetFilterType( IFT_None );
        
        m_edibleInv.maxItemLimit = 80;
        
        m_playerInv = m_potionInv;
        m_fxSetCategory.InvokeSelfOneArg( FlashArgString( GetLocStringByKeyExt( "panel_alchemy_tab_potions" ) ) );
        m_fxShowCategoryButtons.InvokeSelfOneArg( FlashArgBool(true) );
    }
    else
    {
        m_fxShowCategoryButtons.InvokeSelfOneArg( FlashArgBool(false) );		
        
        m_playerInv = new W3GuiSelectItemComponent in this;
        m_playerInv.Initialize( thePlayer.GetInventory() );
        m_playerInv.filterTagList = m_DataObject.filterTagsList;
        m_playerInv.filterForbiddenTagList = m_DataObject.filterForbiddenTagsList;
        m_playerInv.ignorePosition = true; 
        m_playerInv.checkTagsOR = m_DataObject.checkTagsOR; 
    }
    
    switch( m_DataObject.selectionMode )
    {
        case EISPM_Default :
        {
            
            m_playerInv.SetFilterType( IFT_QuestItems );
        }
        break;
        
        case EISPM_ArmorStand :
        {
            
            m_playerInv.SetFilterType( IFT_Armors );
            
            if( m_DataObject.categoryFilterList.Size() > 0 )
            {
                m_playerInv.SetItemCategoryType( m_DataObject.categoryFilterList[m_selectedItemCategory] );	
            }
            else
            {
                m_playerInv.SetItemCategoryType( 'armor' );
            }
            
            
            m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );
        }
        break;
        
        case EISPM_SwordStand :
        {
            
            m_playerInv.SetFilterType( IFT_Weapons );
            m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
        }
        break;	
        
        case EISPM_Painting :
        {
            
            m_playerInv.SetFilterType( IFT_None );
            m_playerInv.SetOverrideQuestItemFilters( m_DataObject.overrideQuestItemRestrictions );			
        }
        break;
        
        
        case EISPM_RadialMenuSlot1 :
        case EISPM_RadialMenuSlot2 :
        case EISPM_RadialMenuSlot3 :
        case EISPM_RadialMenuSlot4 :
        case EISPM_RadialMenuSteelOil :
        case EISPM_RadialMenuSilverOil :
        {
            m_playerInv.SetFilterType( IFT_None );	
        }
        break;
        
    }
    
    
    m_containerOwner = (CGameplayEntity)theGame.GetEntityByTag( m_DataObject.collectorTag );
    
    
    
    UpdateData();
    
    
    m_guiManager.RequestMouseCursor(true);
    theGame.ForceUIAnalog(true);
    
    theGame.Pause("ItemSelectionPopup");
}

@wrapMethod(CR4ItemSelectionPopup) function OnCloseSelectionPopup()
{	
    if(false) 
	{
		wrappedMethod();
	}

    if (m_DataObject.menuCallBack)
    {	m_DataObject.menuCallBack.OnIngredientChanged(''); 
        m_DataObject.frame.ClosePopupOverlay();
        delete m_DataObject.frame;
        delete m_DataObject;
    }

    ClosePopup();
}

@wrapMethod(CR4ItemSelectionPopup) function OnCallSelectItem(itemId : SItemUniqueId)
{
    var len, i : int;

    if(false) 
	{
		wrappedMethod(itemId);
	}
    
    switch( m_DataObject.selectionMode )
    {
        
        case EISPM_Default :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                len = m_DataObject.targetItems.Size();
                for (i = 0; i < len; i=i+1 )
                {
                    
                    if (m_DataObject.targetItems[i] == m_playerInv.GetItemName(itemId))
                    {
                        thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
                        break;
                    }
                }
                ClosePopup();
            }
        }
        break;
        
        
        case EISPM_ArmorStand :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
                
                while( m_selectedItemCategory <= m_DataObject.categoryFilterList.Size() )
                {
                    if(TryToOpenNextCategory())
                    {
                        return true;
                    }
                }
                
                ClosePopup();
            }
        }
        break;
        
        
        case EISPM_SwordStand :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
                ClosePopup();
            }
        }
        break;
        
        
        case EISPM_Painting :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
                ClosePopup();
            }
        }
        break;		
        
        
        case EISPM_RadialMenuSlot1 :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.EquipItem(itemId, EES_Potion1);
                GetWitcherPlayer().EnableRadialInput();
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_RadialMenuSlot2 :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.EquipItem(itemId, EES_Potion2);
                GetWitcherPlayer().EnableRadialInput();
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_RadialMenuSlot3 :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.EquipItem(itemId, EES_Potion3);
                GetWitcherPlayer().EnableRadialInput();
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_RadialMenuSlot4 :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.EquipItem(itemId, EES_Potion4);
                GetWitcherPlayer().EnableRadialInput();
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_RadialMenuSteelOil :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.ApplyOil(itemId, GetWitcherPlayer().GetEquippedSword( true ));
                GetWitcherPlayer().EnableRadialInput();
                theSound.SoundEvent( "gui_preparation_potion" );
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_RadialMenuSilverOil :
        {
            if (thePlayer.GetInventory().IsIdValid(itemId))
            {
                thePlayer.ApplyOil(itemId, GetWitcherPlayer().GetEquippedSword( false ));
                GetWitcherPlayer().EnableRadialInput();
                theSound.SoundEvent( "gui_preparation_potion" );
                ClosePopup();		
            }
        }
        break;
        
        case EISPM_Ingredients:
            ClosePopup();
            m_DataObject.menuCallBack.OnIngredientChanged(thePlayer.GetInventory().GetItemName(itemId) );
            m_DataObject.frame.ClosePopupOverlay();
            delete m_DataObject.frame;
            delete m_DataObject;
        break ;
    }
}

@wrapMethod(CR4ItemSelectionPopup) function UpdateData():void
{
    var l_flashObject			: CScriptedFlashObject;
    var l_flashArray			: CScriptedFlashArray;

    if(false) 
	{
		wrappedMethod();
	}
    
    l_flashObject = m_flashValueStorage.CreateTempFlashObject();
    l_flashArray = m_flashValueStorage.CreateTempFlashArray();		

    if (m_DataObject.menuCallBack)
        theGame.alchexts.ing_mngr.PopulateIngredientMenu(l_flashArray, l_flashObject, m_DataObject, (W3GuiPlayerInventoryComponent)m_playerInv);
    else m_playerInv.GetInventoryFlashArray(l_flashArray, l_flashObject);
    m_flashValueStorage.SetFlashArray( "repair.grid.player", l_flashArray );
}