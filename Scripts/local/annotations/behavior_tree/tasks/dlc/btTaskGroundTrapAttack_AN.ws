@wrapMethod(CBTTaskGroundTrapAttack) function Main() : EBTNodeStatus
{
	var npc						: CNewNPC = GetNPC();
	var params 					: SCustomEffectParams;
	var action 					: W3DamageAction;
	var reactToHitEntity		: W3ReactToBeingHitEntity;
	var spawnPos 				: Vector;
	var attributeName 			: name;
	var victims 				: array<CGameplayEntity>;
	var damage 					: float;
	var timeStamp 				: float;
	var res1, res2, res3		: bool;
	var i 						: int;
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( !m_trapEntity )
	{
		m_trapEntity = (CEntityTemplate)LoadResourceAsync( trapResourceName );
	}
	
	if ( !m_trapEntity )
	{
		return BTNS_Failed;
	}
	
	damageTypeName = 'DirectDamage';
	
	action = new W3DamageAction in this;

	if ( IsNameValid( activateOnAnimEvent ) )
	{
		while( !m_activated )
		{
			SleepOneFrame();
		}
	}
	else
	{
		m_activated = true;
	}
	
	while ( m_activated )
	{
		if ( timeStamp == 0 )
			timeStamp = GetLocalTime();
		
		SleepOneFrame();
		
		if ( !res3 )
		{
			if ( randomizePosition )
			{
				spawnPos = FindPosition();
				while( !IsPositionValid( spawnPos, guaranteedHit ) )
				{
					SleepOneFrame();
					spawnPos = FindPosition();
				}
				guaranteedHit = false;
			}
			else
			{
				spawnPos = GetCombatTarget().GetWorldPosition();
			}
			m_trap = (CGameplayEntity)theGame.CreateEntity( m_trapEntity, spawnPos, npc.GetWorldRotation() );
			if ( IsNameValid( playFxOnTrapSpawn ) && m_trap )
				m_trap.PlayEffect( playFxOnTrapSpawn );
			
			res3 = true;
		}
		
		if ( ( timeStamp + delayDamageFx ) < GetLocalTime() && !res1 )
		{
			res1 = true;
			
			if ( IsNameValid( playFxDamage ) )
				m_trap.PlayEffect( playFxDamage );
		}
		
		if ( ( timeStamp + delayDamage ) < GetLocalTime() && !res2 )
		{
			victims.Clear();
			FindGameplayEntitiesInRange( victims, m_trap, affectEnemiesInRange, 99 );
			
			if ( camShakeStrength > 0 )
				GCameraShake(camShakeStrength, true, m_trap.GetWorldPosition(), 30.0f);
			
			if ( victims.Size() > 0 )
			{
				for ( i = 0 ; i < victims.Size() ; i += 1 )
				{
					reactToHitEntity = (W3ReactToBeingHitEntity)victims[i];
					if ( reactToHitEntity )
					{
						reactToHitEntity.ActivateEntity();
					}
					if ( ( allowDamageSelf || victims[i] != npc ) && !((CActor)victims[i]).IsCurrentlyDodging() && !((CActor)victims[i]).IsInvulnerable()
						&& ((CActor)victims[i]).GetGameplayVisibility() && ((CActor)victims[i]).IsAlive() )
					{
						if ( debuffType != EET_Undefined )
						{
							params.effectType = debuffType;
							params.creator = m_trap;
							params.sourceName = m_trap.GetName();
							if ( debuffDuration > 0 )
								params.duration = debuffDuration;
							
							((CActor)victims[i]).AddEffectCustom(params);
						}
						
						action.attacker = m_trap;
						action.Initialize( m_trap, victims[i], NULL, m_trap.GetName(), EHRT_Light, CPS_Undefined, false, false, false, true);
						damage = MaxF(500, 0.2 * ((CActor)victims[i]).GetMaxHealth());

						action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, damage );
						theGame.damageMgr.ProcessAction( action );
						if ( IsNameValid( playFxOnDamageVictim ) )
						{
							victims[i].PlayEffect( playFxOnDamageVictim );
						}
						if ( IsNameValid( raiseEventOnDamageNPC ) && victims[i] != thePlayer )
						{
							victims[i].RaiseEvent( raiseEventOnDamageNPC );
							((CActor)victims[i]).SignalGameplayEvent( 'CustomHit' );
						}
					}
				}
			}
			
			res2 = true;
			m_activated = false;
		}
	}
	
	victims.Clear();
	delete action;
	if ( completeAfterMain )
	{
		return BTNS_Completed;
	}
	else
	{
		return BTNS_Active;
	}
}