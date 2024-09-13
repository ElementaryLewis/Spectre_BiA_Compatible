@wrapMethod(W3IceSpike) function DealDamage( optional _Delta : float, optional id : int)
{
	var i						: int;
	var l_actorsRange			: array <CActor>;
	var l_range					: float;
	var l_actor					: CActor;
	var none					: SAbilityAttributeValue;
	var l_damageAction			: W3DamageAction;
	var l_summonedEntityComp 	: W3SummonedEntityComponent;
	var	l_summoner				: CActor;	
	var l_damageAttr 			: SAbilityAttributeValue;
	var l_inv					: CInventoryComponent;
	var l_weaponId 				: SItemUniqueId;
	var l_damageValue			: float;
	var l_damageNames			: array < CName >;
	var l_attribute				: name;
	
	if(false) 
	{
		wrappedMethod(_Delta, id);
	}
	
	l_summonedEntityComp = (W3SummonedEntityComponent) GetComponentByClassName('W3SummonedEntityComponent');
	
	if( !l_summonedEntityComp )
	{
		return;
	}
	
	l_summoner = l_summonedEntityComp.GetSummoner();
	
	l_range = 0.3f;
	l_actorsRange = GetActorsInRange( this, l_range, -1, , true );
	
	for	( i = 0; i < l_actorsRange.Size(); i += 1 )
	{
		l_actor = (CActor) l_actorsRange[i];
		
		if ( l_actor == l_summoner ) continue;
		
		l_damageAction = new W3DamageAction in this;
		l_damageAction.Initialize( l_summoner, l_actor, l_summoner, l_summoner.GetName(), EHRT_Heavy, CPS_AttackPower, false, false, false, true );
		
		l_summoner.GetVisualDebug().AddSphere('DetectionRange', l_range, GetWorldPosition(), true);
		l_summoner.GetVisualDebug().AddText('DetectionRangeText', "Ice", GetWorldPosition(), true);
		
		if ( damageValue < 1 )
		{
			damageValue = 100;
		}
		
		if( l_summoner && IsNameValid( weaponSlot ) )
		{
			l_inv 		= l_summoner.GetInventory();		
			l_weaponId 	= l_inv.GetItemFromSlot( weaponSlot );
			l_inv.GetWeaponDTNames( l_weaponId, l_damageNames );
			l_damageAttr.valueAdditive = 0;
			l_damageAttr.valueMultiplicative = 1;
			l_damageAttr.valueBase  = l_summoner.GetTotalWeaponDamage( l_weaponId, l_damageNames[0], GetInvalidUniqueId() );
			l_damageValue = CalculateAttributeValue(l_damageAttr);

		}
		
		l_damageAction.AddDamage( theGame.params.DAMAGE_NAME_FROST, damageValue );
		
		theGame.damageMgr.ProcessAction( l_damageAction );
		delete l_damageAction;
	}
}