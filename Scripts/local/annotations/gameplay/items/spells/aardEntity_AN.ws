@wrapMethod(W3AardEntity) function ProcessThrow_MainTick( alternateCast : bool )
{
	var projectile	: W3AardProjectile;
	var spawnPos, collisionPos, collisionNormal, waterCollTestPos : Vector;
	var spawnRot : EulerAngles;
	var heading : Vector;
	var distance, waterZ, staminaDrain : float;
	var ownerActor : CActor;
	var dispersionLevel : int;
	var attackRange : CAIAttackRange;
	var movingAgent : CMovingPhysicalAgentComponent;
	var hitsWater : bool;
	var collisionGroupNames : array<name>;
	
	if(false) 
	{
		wrappedMethod(alternateCast);
	}
	
	ownerActor = owner.GetActor();
	
	if ( owner.IsPlayer() )
	{
		GCameraShake(effects[fireMode].cameraShakeStrength, true, this.GetWorldPosition(), 30.0f);
	}
	
	
	distance = GetDistance();		
	
	if ( owner.HasCustomAttackRange() )
	{
		attackRange = theGame.GetAttackRangeForEntity( this, owner.GetCustomAttackRange() );
	}
	else if( owner.CanUseSkill( S_Magic_s20 ) )
	{
		dispersionLevel = owner.GetSkillLevel(S_Magic_s20);
		
		if(dispersionLevel == 1)
		{
			if ( !alternateCast )
				attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade1' );
			else
				attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade1' );
		}
		else if(dispersionLevel == 2)
		{
			if ( !alternateCast )
				attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade2' );
			else
				attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade2' );
		}
		else if(dispersionLevel == 3)
		{
			if ( !alternateCast )
				attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade3' );
			else
				attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade3' );
		}
	}
	else
	{
		if ( !alternateCast )
			attackRange = theGame.GetAttackRangeForEntity( this, 'cone' );
		else
			attackRange = theGame.GetAttackRangeForEntity( this, 'blast' );
	}
	
	
	spawnPos = GetWorldPosition();
	spawnRot = GetWorldRotation();
	heading = this.GetHeadingVector();
	
	
	
	
	if ( alternateCast )
	{
		spawnPos.Z -= 0.5;
		
		projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos - heading * 0.7, spawnRot );				
		projectile.ExtInit( owner, skillEnum, this );	
		projectile.SetAttackRange( attackRange );
		projectile.SphereOverlapTest( distance, projectileCollision );			
	}
	else
	{			
		spawnPos -= 0.7 * heading;
		
		projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos, spawnRot );				
		projectile.ExtInit( owner, skillEnum, this );							
		projectile.SetAttackRange( attackRange );
		
		projectile.ShootCakeProjectileAtPosition( aspects[fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, projectileCollision );			
	}
	
	if((W3PlayerWitcher)ownerActor && ((W3PlayerWitcher)ownerActor).HasGlyphwordActive('Glyphword 6 _Stats'))
	{
		staminaDrain = CalculateAttributeValue(ownerActor.GetAttributeValue('glyphword6_stamina_drain_perc'));
		projectile.SetStaminaDrainPerc(staminaDrain);			
	}
	
	if(alternateCast)
	{
		movingAgent = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
		hitsWater = movingAgent.GetSubmergeDepth() < 0;
	}
	else
	{
		waterCollTestPos = GetWorldPosition() + heading * distance * waterTestDistancePerc;			
		waterCollTestPos.Z += waterTestOffsetZ;
		collisionGroupNames.PushBack('Terrain');
		
		
		waterZ = theGame.GetWorld().GetWaterLevel(waterCollTestPos, true);
		
		
		if(theGame.GetWorld().StaticTrace(GetWorldPosition(), waterCollTestPos, collisionPos, collisionNormal, collisionGroupNames))
		{
			
			if(waterZ > collisionPos.Z && waterZ > waterCollTestPos.Z)
				hitsWater = true;
			else
				hitsWater = false;
		}
		else
		{
			
			hitsWater = (waterCollTestPos.Z <= waterZ);
		}
	}
	
	PlayAardFX(hitsWater);
	ownerActor.OnSignCastPerformed(ST_Aard, alternateCast);
	AddTimer('DelayedDestroyTimer', 0.1, true, , , true);
}

@wrapMethod(W3AardEntity) function PlayAardFX(hitsWater : bool)
{
	var dispersionLevel : int;
	var hasMutation6 : bool;
	var spellPower : SAbilityAttributeValue;
	var sp : float;
	
	if(false) 
	{
		wrappedMethod(hitsWater);
	}
	
	hasMutation6 = owner.GetPlayer().IsMutationActive(EPMT_Mutation6);
	
	if ( owner.CanUseSkill( S_Magic_s20 ) )
	{
		dispersionLevel = owner.GetSkillLevel(S_Magic_s20);
		
		if(dispersionLevel == 1)
		{			
			
			PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade1 );
		
			
			if(!hasMutation6)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWaterUpgrade1 );
				else
					PlayEffect( effects[fireMode].throwEffectSoilUpgrade1 );
			}
		}
		else if(dispersionLevel == 2)
		{			
			
			PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade2 );
		
			
			if(!hasMutation6)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWaterUpgrade2 );
				else
					PlayEffect( effects[fireMode].throwEffectSoilUpgrade2 );
			}
		}
		else if(dispersionLevel == 3)
		{			
			
			PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade3 );
		
			
			if(!hasMutation6)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWaterUpgrade3 );
				else
					PlayEffect( effects[fireMode].throwEffectSoilUpgrade3 );
			}
		}
	}
	else
	{
		
		PlayEffect( effects[fireMode].baseCommonThrowEffect );
	
		
		if(!hasMutation6)
		{
			if(hitsWater)
				PlayEffect( effects[fireMode].throwEffectWater );
			else
				PlayEffect( effects[fireMode].throwEffectSoil );
		}
	}

	spellPower = owner.GetActor().GetTotalSignSpellPower(GetSkill());
	sp = spellPower.valueMultiplicative - 1;
	if(sp >= 1.5)
		PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
	else if(sp >= 1.0)
		PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
	else if(sp >= 0.5)
		PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
	else
		PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
	
	if(owner.CanUseSkill(S_Magic_s06))
	{
		dispersionLevel = owner.GetSkillLevel(S_Magic_s06);
		
		switch(dispersionLevel)
		{
			case 1:
				PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
				break;
			case 2:
				PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
				break;
			case 3:
				PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
				break;
			default:
				PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
				break;
		}
	}
	
	
	if( hasMutation6 )
	{
		thePlayer.PlayEffect( 'mutation_6_power' );
		
		if( fireMode == 0 )
		{
			PlayEffect( 'cone_ground_mutation_6' );
		}
		else
		{
			PlayEffect( 'blast_ground_mutation_6' );
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(GetWorldPosition(), 0.3f, 3.f, 2.f, GetDistance(), 0 );
		}
	}
}

@wrapMethod(AardConeCast) function OnThrowing()
{
	var player				: CR4Player;
	
	if(false) 
	{
		wrappedMethod();
	}

	if( super.OnThrowing() )
	{
		parent.ProcessThrow( false );
		
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			parent.ManageGryphonSetBonusBuff();
			thePlayer.AddEffectDefault(EET_AardCooldown, NULL, "normal_cast");
			if(thePlayer.HasBuff(EET_Mutagen10))
				((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
			if(thePlayer.HasBuff(EET_Mutagen17))
				((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
			if(thePlayer.HasBuff(EET_Mutagen22))
				((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
}

@wrapMethod(AardCircleCast) function OnThrowing()
{
	var player : CR4Player;
	var cost, stamina : float;
	var pos : Vector;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( super.OnThrowing() )
	{
		pos = parent.GetWorldPosition();
		pos.Z -= 1;
		parent.Teleport(pos);
		
		
		parent.ProcessThrow( true );
		
		player = caster.GetPlayer();
		if(player == caster.GetActor() && player && player.CanUseSkill(S_Perk_09) && player.GetStat(BCS_Focus) >= 1)
		{
			player.DrainFocus(1 * parent.foaMult);
			parent.SetUsedFocus( true );
		}	
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			parent.SetUsedFocus( false );
			if(parent.GetUsedFoA())
				player.DrainFocus( 1 * parent.foaMult );
		}
		if(player == caster.GetActor() && player)
		{
			thePlayer.AddEffectDefault(EET_AardCooldown, NULL, "alt_cast");
			if(thePlayer.HasBuff(EET_Mutagen10))
				((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
			if(thePlayer.HasBuff(EET_Mutagen17))
				((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
			if(thePlayer.HasBuff(EET_Mutagen22))
				((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
		}
	}
}