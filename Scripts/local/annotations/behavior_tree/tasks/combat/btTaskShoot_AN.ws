@wrapMethod(CBTTaskShoot) function IsAvailable() : bool
{
	if(false) 
	{
		wrappedMethod();
	}
	
	InitializeCombatDataStorage();
	if ( !((CHumanAICombatStorage)combatDataStorage).GetProjectile() )
	{
		return CreateProjectile() && super.IsAvailable();
	}
	return super.IsAvailable();
}

@wrapMethod(CBTTaskShoot)  function ShootProjectile()
{
	var npc 					: CNewNPC = GetNPC();
	var target 					: CNode;
	var targetEntity			: CGameplayEntity;
	var desiredHeadingVec 		: Vector;
	var distanceToTarget 		: float;
	var projectileFlightTime 	: float;
	var targetPos 				: Vector;
	var collisionGroups 		: array<name>;
	var headBoneIdx 			: int;
	var entMat					: Matrix;
	var targetMAC				: CMovingPhysicalAgentComponent;
	var yrdenShockEntity		: W3YrdenEntityStateYrdenShock;
	
	if(false) 
	{
		wrappedMethod();
	}
			
	collisionGroups.PushBack('Ragdoll');
	collisionGroups.PushBack('Terrain');
	collisionGroups.PushBack('Static');
	collisionGroups.PushBack('Debris');
	collisionGroups.PushBack('Destructible');
	collisionGroups.PushBack('RigidBody');
	collisionGroups.PushBack('Foliage');
	collisionGroups.PushBack('Door');
	collisionGroups.PushBack('Platforms');
	collisionGroups.PushBack('Fence');
	
	if ( this.useCombatTarget )
	{
		target = GetCombatTarget();
		targetPos = npc.GetBehaviorVectorVariable('lookAtTarget');
	}
	else
	{
		target = GetActionTarget();
		if ( (CActor)target )
		{
			headBoneIdx = ((CActor)target).GetHeadBoneIndex();
			if ( headBoneIdx >= 0 )
			{
				targetPos = MatrixGetTranslation( ((CActor)target).GetBoneWorldMatrixByIndex( headBoneIdx ) );
			}
			else
			{
				targetPos = target.GetWorldPosition();
				targetPos.Z += ((CMovingPhysicalAgentComponent)((CActor)target).GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
			}
		}
		else if ( (CGameplayEntity)target )
		{
			targetEntity = (CGameplayEntity)target;
			if ( !( targetEntity.aimVector.X == 0 && targetEntity.aimVector.Y == 0 && targetEntity.aimVector.Z == 0 ) )
			{
				entMat = targetEntity.GetLocalToWorld();
				targetPos = VecTransform( entMat, targetEntity.aimVector );
			}
			else
			{
				targetPos = targetEntity.GetWorldPosition();
			}
		}
		else
		{
			targetPos = target.GetWorldPosition();
		}
	}
	
	distanceToTarget = VecDistance(npc.GetWorldPosition(),targetPos);
	
	
	desiredHeadingVec = arrow.GetHeadingVector();
	
	
	if ( targetPos == Vector(0,0,0) || distanceToTarget < 6.f )
	{
		targetPos = npc.GetWorldPosition();
		
		if ( (CActor)target )
		{
			targetMAC = (CMovingPhysicalAgentComponent)((CActor)target).GetMovingAgentComponent();
			if ( targetMAC )
				targetPos.Z += 0.8 * targetMAC.GetCapsuleHeight();
		}
		targetPos = targetPos +  desiredHeadingVec*distanceToTarget;
	}
	
	arrow.BreakAttachment();
	arrow.Init( npc );
	
	if ( arrow.yrdenAlternate )
	{
		yrdenShockEntity = (W3YrdenEntityStateYrdenShock)arrow.yrdenAlternate.GetCurrentState();
		if( yrdenShockEntity )
			yrdenShockEntity.ShootDownProjectile( arrow );
		projShot = false;
	}
	else
	{
		arrow.ShootProjectileAtPosition( 7, arrow.projSpeed, targetPos, attackRange, collisionGroups );
		projShot = true;
	}
	
	if ( projShot && dodgeable )
	{
		
		projectileFlightTime = distanceToTarget / arrow.projSpeed;
		
		((CActor)target).SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
	}
	npc.SetCounterWindowStartTime(theGame.GetEngineTime());
	npc.BlinkWeapon();
}

@wrapMethod(CBTTaskShootDef) function Initialize()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	xmlStaminaCostName 					= 'light_action_stamina_cost';
	drainStaminaOnUse					= true; 

	
	SetValFloat(attackRange,10.f);
}