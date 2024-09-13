@replaceMethod(W3CraftsmanComponent) function CalculateCostOfCrafting( schem : SCraftingSchematic ) : int
{
	var i, size, craftingCost : int;		
	var invItem : SInventoryItem;
	var owner : W3MerchantNPC;
	var items : array<SItemUniqueId>;
	

	if ( craftsmanData.Size() > 0 )
	{
		if ( true == craftsmanData[0].noCraftingCost )
		{
			return 0;
		}
	}

	owner = (W3MerchantNPC) this.GetEntity();
	
	if ( owner )
	{
		if ( owner.invComp )
		{
			items = owner.invComp.AddAnItem( schem.craftedItemName, 1 );
			if ( items.Size() > 0 )
			{
				craftingCost = owner.invComp.GetItemPriceCrafting( owner.invComp.GetItem( items[ 0 ] ) );
				owner.invComp.RemoveItem( items[ 0 ], 1 );
				return craftingCost;
			}
		}
	}

	return -1;
}