@wrapMethod(W3WitchBoilingWaterObstacle) function Appear( _Delta : float, optional id : int)
{
	var i						: int;
	var l_entitiesInRange		: array <CGameplayEntity>;
	var l_damage				: W3DamageAction;
	var l_action 				: W3Action_Attack; 
	var l_actor					: CActor;
	var none					: SAbilityAttributeValue;
	var l_tempBool				: bool;
	
	if(false) 
	{
		wrappedMethod(_Delta, id);
	}
	
	if ( !l_tempBool )
	{
		if ( !SetParams() ) return;
		l_tempBool = true;
	}
	
	if ( IsNameValid(attackEffectName) && !playAttackEffectOnlyWhenHit )
	{
		if ( useSeperateAttackEffectEntity )
		{
			fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, this.GetWorldPosition(), this.GetWorldRotation() );
			fxEntity.PlayEffect(attackEffectName);
			fxEntity.DestroyAfter( 5.0 );
		}
		else
		{
			PlayEffect(attackEffectName);
		}
		
		if ( onAttackEffectCameraShakeStrength > 0 )
		{
			GCameraShake( onAttackEffectCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
		}
	}
	
	FindGameplayEntitiesInRange( l_entitiesInRange, this, attackRadius, 1000);
	
	for	( i = 0; i < l_entitiesInRange.Size(); i += 1 )
	{
		l_actor = (CActor) l_entitiesInRange[i];
		if ( !l_actor ) continue;
		
		if ( l_actor == summoner ) continue;
		
		if ( IsNameValid( ignoreVictimWithTag ) && l_actor.HasTag( ignoreVictimWithTag ) ) continue;
		
		if ( !l_actor.IsCurrentlyDodging() )
		{
			
			if( damageValue < 101 && !summoner.HasTag( 'q111_witch' ) )
			{
				if ( simpleDamageAction )
				{
					l_action = new W3Action_Attack in theGame.damageMgr;
					
					l_action.Init( (CGameplayEntity)summoner, l_actor, NULL, ((CGameplayEntity)summoner).GetInventory().GetItemFromSlot( 'r_weapon' ), 'attack_heavy', ((CGameplayEntity)summoner).GetName(), EHRT_Heavy, false, true, 'attack_heavy', AST_Jab, ASD_DownUp, false, false, false, true );
					l_action.GetDamageValueTotal();
					theGame.damageMgr.ProcessAction( l_action );
					
					if ( onHitCameraShakeStrength > 0 )
						GCameraShake( onHitCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
					
					delete l_action;
				}
				if ( applyDebuffType != EET_Undefined )
				{
					l_actor.AddEffectCustom(params);
				}
				
				if ( IsNameValid(attackEffectName) && playAttackEffectOnlyWhenHit )
				{
					if ( useSeperateAttackEffectEntity )
					{
						fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, l_actor.GetWorldPosition(), l_actor.GetWorldRotation() );
						fxEntity.PlayEffect(attackEffectName);
						fxEntity.DestroyAfter( 5.0 );
					}
					else
					{
						PlayEffect(attackEffectName);
					}
				}
				
			} 
			else if ( damageValue > 0 )
			{
				if ( simpleDamageAction )
				{
					l_damage = new W3DamageAction in this;
					l_damage.Initialize( summoner, l_actor, summoner, summoner.GetName(), hitReactionType, CPS_AttackPower, false, false, false, true );
					l_damage.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
					theGame.damageMgr.ProcessAction( l_damage );
					delete l_damage;
					
					if ( onHitCameraShakeStrength > 0 )
						GCameraShake( onHitCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
				}
				if ( applyDebuffType != EET_Undefined )
				{
					l_actor.AddEffectCustom(params);
				}
				
				if ( IsNameValid(attackEffectName) && playAttackEffectOnlyWhenHit )
				{
					if ( useSeperateAttackEffectEntity )
					{
						fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, l_actor.GetWorldPosition(), l_actor.GetWorldRotation() );
						fxEntity.PlayEffect(attackEffectName);
						fxEntity.DestroyAfter( 5.0 );
					}
					else
					{
						PlayEffect(attackEffectName);
					}
				}
			}
		}
	}
}