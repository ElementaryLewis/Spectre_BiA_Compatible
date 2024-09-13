@wrapMethod(W3ActorRemains) function OnItemTaken(itemId : SItemUniqueId, quantity : int)
{
	var itemName : name;
	
	if (false)
	{
		wrappedMethod( itemId, quantity );
	}
	
	super.OnItemTaken(itemId, quantity);
	
	if(!HasQuestItem())
		StopEffect('quest_highlight_fx');
}

@wrapMethod(W3ActorRemains) function FinalizeLooting()
{
	var commonMapManager : CCommonMapManager;
	
	if (false)
	{
		wrappedMethod();
	}
	
	if(IsEmpty())
	{
		commonMapManager = theGame.GetCommonMapManager();
		commonMapManager.DeleteQuestLootContainer( this );
		UnhighlightEntity();
		Enable(false);
		Destroy();
	}
}