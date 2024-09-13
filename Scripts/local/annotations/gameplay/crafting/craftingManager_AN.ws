@replaceMethod( W3CraftingManager ) function GetCraftingCost(schematic : name) : int
{
	var schem : SCraftingSchematic;

	if ( GetSchematic(schematic, schem) )
	{
		return craftMasterComp.CalculateCostOfCrafting( schem );
	}

	return -1;
}