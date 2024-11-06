@wrapMethod(W3GuiSelectItemComponent) function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
{
	if(false) 
	{
		wrappedMethod(item, flashObject);
	}

	super.SetInventoryFlashObjectForItem( item, flashObject );
		
	flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByUniqueID(item) ) + ". " + theGame.alchexts.ing_mngr.GetIngredientDescription(_inv.GetItemName(item), true) );
	flashObject.SetMemberFlashBool( "isNew", false );
	flashObject.SetMemberFlashInt("quality", theGame.alchexts.ing_mngr.GetIngredientQuality(_inv.GetItemName(item) ) );
	flashObject.SetMemberFlashInt("gridPosition", -1);
}