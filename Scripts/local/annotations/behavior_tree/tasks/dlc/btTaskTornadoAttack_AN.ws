@wrapMethod(CBTTaskTornadoAttack) function Main() : EBTNodeStatus
{
	var npc						: CNewNPC = GetNPC();
	var targetNode 				: CNode;
	var targetPos 				: Vector;
	var params 					: SCustomEffectParams;
	var action 					: W3DamageAction;
	var movementAdjustor 		: CMovementAdjustor;
	var ticket 					: SMovementAdjustmentRequestTicket;
	var attributeName 			: name;
	var victims 				: array<CGameplayEntity>;
	var actorVictims 			: CActor;
	var damage 					: float;
	var lastShakeTime 			: float;
	var lastDebuffTime 			: float;
	var lastDamageTime 			: float;
	var timeStamp 				: float;
	var lastVictimsTestTime 	: float;
	var distToTarget 			: float;
	var camShakeStrength		: float;
	var res 					: bool;
	var i 						: int;
	
	
	if(false) 
	{
		wrappedMethod();
	}
	
	action = new W3DamageAction in this;
	timeStamp = GetLocalTime();
	
	npc.SetBehaviorVariable( setBehVarOnDeactivation, 0 );
	res = false;
	
	if ( IsNameValid( activateOnAnimEvent ) )
	{
		while( !m_activated )
		{
			if ( timeStamp + castingLoopTime < GetLocalTime() && !res )
			{
				npc.SetBehaviorVariable( setBehVarOnDeactivation, setBehVarValueOnDeactivation );
				res = true;
			}
			SleepOneFrame();
		}
	}
	else
	{
		m_activated = true;
	}
	
	while( m_activated )
	{
		SleepOneFrame();
		
		if ( lastShakeTime + cameraShakeInterval < GetLocalTime() )
		{
			lastShakeTime = GetLocalTime();
			targetPos = GetCombatTarget().GetWorldPosition();
			distToTarget = VecDistance2D( targetPos, npc.GetWorldPosition() );
			camShakeStrength = ClampF( 1 - ( distToTarget / cameraShakeRange ), 0, 1 ) * ((  maxCameraShakeStrength - minCameraShakeStrength ) + minCameraShakeStrength );
			GCameraShake(camShakeStrength, true, npc.GetWorldPosition(), 30.0f);
		}
		
		if ( lastVictimsTestTime + victimTestInterval < GetLocalTime() )
		{
			lastVictimsTestTime = GetLocalTime();
			victims.Clear();
			FindGameplayEntitiesInRange( victims, npc, affectEnemiesInRangeMax, 99, , FLAG_OnlyAliveActors );
		}
		
		if ( ( debuffTypeInRangeMin != EET_Undefined || debuffTypeInRangeMax != EET_Undefined ) && lastDebuffTime + debuffInterval < GetLocalTime() )
		{
			lastDebuffTime = GetLocalTime();
			
			if ( victims.Size() > 0 )
			{
				for ( i = 0 ; i < victims.Size() ; i += 1 )
				{
					actorVictims = (CActor)victims[i];
					if ( actorVictims != npc )
					{
						if ( VecDistance( actorVictims.GetWorldPosition(), npc.GetWorldPosition() ) <= affectEnemiesInRangeMin )
						{
							if ( !actorVictims.HasBuff( debuffTypeInRangeMin ) )
							{
								params.effectType = debuffTypeInRangeMin;
								if ( debuffDurationInRangeMin > 0 )
									params.duration = debuffDurationInRangeMin;
								
								if ( IsNameValid( rotateToNodeByTagOnDebuffMin ) )
								{
									movementAdjustor = actorVictims.GetMovingAgentComponent().GetMovementAdjustor();
									ticket = movementAdjustor.CreateNewRequest( 'Tornado' );
									targetNode = theGame.GetNodeByTag( rotateToNodeByTagOnDebuffMin );
									movementAdjustor.RotateTowards( ticket, targetNode, 45 );
								}
							}
						}
						else
						{
							if ( !((W3PlayerWitcher)actorVictims).IsQuenActive( true ) && !((W3PlayerWitcher)actorVictims).IsQuenActive( false ) )
							{
								params.effectType = debuffTypeInRangeMax;
								if ( debuffDurationInRangeMax > 0 )
									params.duration = debuffDurationInRangeMax;
							}
						}
						params.creator = npc;
						params.sourceName = npc.GetName();
						
						actorVictims.AddEffectCustom(params);
					}
				}
			}
		}
		
		if ( lastDamageTime + damageInterval < GetLocalTime() )
		{
			lastDamageTime = GetLocalTime();
			if ( victims.Size() > 0 )
			{
				for ( i = 0 ; i < victims.Size() ; i += 1 )
				{
					actorVictims = (CActor)victims[i];
					
					if ( victims[i] != npc && !actorVictims.IsCurrentlyDodging() )
					{
						action.Initialize( npc, actorVictims, this, npc.GetName(), EHRT_None, CPS_Undefined, false, true, false, false );
						action.SetHitAnimationPlayType(EAHA_ForceNo);
						action.attacker = npc;
						action.SetSuppressHitSounds(true);
						action.SetHitEffect( '' );
						damage = 0.02 * ((CActor)victims[i]).GetMaxHealth();
						action.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, damage );
						action.SetIsDoTDamage( damageInterval );
						theGame.damageMgr.ProcessAction( action );
						
						npc.SignalGameplayEventParamObject( 'DamageInstigated', action );
						
						if ( ((W3PlayerWitcher)actorVictims).IsQuenActive( false ) )
							((W3PlayerWitcher)actorVictims).FinishQuen( false );
					}
				}
			}
		}
		
		if ( timeStamp + castingLoopTime < GetLocalTime() && !res )
		{
			npc.SetBehaviorVariable( setBehVarOnDeactivation, setBehVarValueOnDeactivation );
			res = true;
		}
	}
	
	delete action;
	return BTNS_Active;
}