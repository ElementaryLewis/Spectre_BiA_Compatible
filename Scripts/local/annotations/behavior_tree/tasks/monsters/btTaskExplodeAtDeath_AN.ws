@wrapMethod(BTTaskExplodeAtDeath) function Explode()
{
	var l_actor 				: CActor;	
	var l_dismembermentComp 	: CDismembermentComponent;
	var l_wounds				: array< name >;
	var l_actors				: array< CActor >;
	var l_usedWound				: name;
	var i						: int;
	var l_damageAction			: W3DamageAction;
	
	var l_damageAttr 			: SAbilityAttributeValue;
	var l_inv					: CInventoryComponent;
	var l_weaponId 				: SItemUniqueId;
	var l_damageNames			: array < CName >;
	var l_attribute				: name;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	l_actor = GetNPC();
	
	l_dismembermentComp = (CDismembermentComponent)(l_actor.GetComponentByClassName( 'CDismembermentComponent' ));
	if(!l_dismembermentComp) return;
	
	l_dismembermentComp.GetWoundsNames( l_wounds, WTF_Explosion );
	
	if ( l_wounds.Size() > 0 )
					l_usedWound = l_wounds[ RandRange( l_wounds.Size() ) ];
					
	l_actor.SetDismembermentInfo( l_usedWound, Vector( 0, 0, 10 ), false );
	l_actor.AddTimer( 'DelayedDismemberTimer', 0.05f );
	
	m_hasExploded = true;
	
	l_actor.GetVisualDebug().AddSphere( 'ExplosionRange', damageRadius, Vector(0,0,0),,,5 );
	
	if( damageRadius > 0 && !l_actor.HasTag('ExplodeNoDamage') )
	{
		l_actors = GetActorsInRange(  GetNPC(), damageRadius, -1,, true );
		
		if( l_actors.Size() > 0 )
		{
			l_damageAction = new W3DamageAction in this;
			
			if( IsNameValid( weaponSlot ) )
			{
				l_inv 		= l_actor.GetInventory();		
				l_weaponId 	= l_inv.GetItemFromSlot( weaponSlot );
				l_inv.GetWeaponDTNames( l_weaponId, l_damageNames );
				l_damageAttr.valueAdditive = 0;
				l_damageAttr.valueMultiplicative = 1;
				l_damageAttr.valueBase = l_actor.GetTotalWeaponDamage( l_weaponId, l_damageNames[0], GetInvalidUniqueId() );
				damageValue = CalculateAttributeValue(l_damageAttr);
			}
			if ( damageValue < 1 )
			{
				damageValue = 300;
			}
			
			for	( i = 0; i < l_actors.Size(); i += 1 )
			{
				if( l_actors[i] == GetNPC() ) 
					continue;
					
				l_damageAction.Initialize( l_actor, l_actors[i], NULL, "Explosion", EHRT_Heavy, CPS_AttackPower, false, true, false, false );
				l_damageAction.SetCannotReturnDamage( true );
				
				l_damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
				l_damageAction.AddDamage(  theGame.params.DAMAGE_NAME_SILVER, damageValue );
				l_damageAction.AddEffectInfo( EET_Stagger, 1.0f );
				theGame.damageMgr.ProcessAction( l_damageAction );
				
			}
			
			delete( l_damageAction );
		}
	}		
}