@wrapMethod(W3MerchantComponent) function GetMapPinType() : name
{
	var merchantNPC : W3MerchantNPC;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	merchantNPC = (W3MerchantNPC)GetEntity();

	if( merchantNPC.HasTag('druid_yolar') && mapPinType != EMMPT_Herbalist ) mapPinType = EMMPT_Herbalist;
	
	switch( mapPinType )
	{
		case EMMPT_Shopkeeper:
			return 'Shopkeeper';
		case EMMPT_Blacksmith:
			return 'Blacksmith';
		case EMMPT_Armorer:
			return 'Armorer';
		case EMMPT_BoatBuilder:
			return 'BoatBuilder';
		case EMMPT_Hairdresser:
			return 'Hairdresser';
		case EMMPT_Alchemist:
			return 'Alchemic';
		case EMMPT_Herbalist:
			return 'Herbalist';
		case EMMPT_Innkeeper:
			return 'Innkeeper';
		case EMMPT_Enchanter:
			return 'Enchanter';
		case EMMPT_DyeTrader:
			return 'DyeMerchant';
		case EMMPT_WineTrader:
			return 'WineMerchant';
		case EMMPT_Cammerlengo:
			return 'Cammerlengo';
	}
	return '';
}