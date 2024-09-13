@wrapMethod(W3IgniEntity) function OnStarted()
{
	var player : CR4Player;
	
	if(false) 
	{
		wrappedMethod();
	}
		
	Attach( true );
	
	channelBurnTestDT.Clear();
	
	player = (CR4Player)owner.GetActor();
	if(player)
	{
		GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		player.AddTimer('ResetPadBacklightColorTimer', 2);
	}
	
	projectileCollision.Clear();
	projectileCollision.PushBack( 'Projectile' );
	projectileCollision.PushBack( 'Door' );
	projectileCollision.PushBack( 'Static' );		
	projectileCollision.PushBack( 'Character' );
	projectileCollision.PushBack( 'Terrain' );
	projectileCollision.PushBack( 'Ragdoll' );
	projectileCollision.PushBack( 'Destructible' );
	projectileCollision.PushBack( 'RigidBody' );
	projectileCollision.PushBack( 'Dangles' );
	projectileCollision.PushBack( 'Water' );
	projectileCollision.PushBack( 'Projectile' );
	projectileCollision.PushBack( 'Foliage' );
	projectileCollision.PushBack( 'Boat' );
	projectileCollision.PushBack( 'BoatDocking' );
	projectileCollision.PushBack( 'Platforms' );
	projectileCollision.PushBack( 'Corpse' );
	projectileCollision.PushBack( 'ParticleCollider' ); 

	if ( owner.ChangeAspect( this, S_Magic_s02 ) )
	{
		CacheActionBuffsFromSkill();
		GotoState( 'IgniChanneled' );
	}
	else
	{
		if((W3PlayerWitcher)owner.GetActor() && ((W3PlayerWitcher)owner.GetActor()).HasGlyphwordActive('Glyphword 7 _Stats'))
			fireMode = 2;
			
		GotoState( 'IgniCast' );
	}
}

@wrapMethod(W3IgniEntity) function InitThrown()
{
	var entity : CEntity;
	var spellPower : SAbilityAttributeValue;
	var sp : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	entity = theGame.GetEntityByTag( 'forest' );
	
	if(entity)
	forestTrigger = (W3ForestTrigger)entity;

	spellPower = owner.GetActor().GetTotalSignSpellPower(GetSkill());
	sp = spellPower.valueMultiplicative - 1;
	
	if(fireMode == 0 && sp > 1.0)
	{							 
		PlayEffect( effects[fireMode].throwEffectSpellPower );
	}
	else
	{
		PlayEffect( effects[fireMode].throwEffect );
	}
		
	
	if(!IsAlternateCast())
	{

		if(owner.CanUseSkill(S_Magic_s08))
		{
			PlayEffect(effects[fireMode].meltArmorEffect);
		}
		
		if(owner.CanUseSkill(S_Magic_s09))
		{
			PlayEffect(effects[fireMode].combustibleEffect);
		}
	}
	
	if( owner.IsPlayer() && forestTrigger && forestTrigger.IsPlayerInForest() )
	{
		PlayEffect( effects[fireMode].forestEffect );
	}
}

@wrapMethod(IgniCast) function OnThrowing()
{
	var player			: CR4Player;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( super.OnThrowing() )
	{
		parent.InitThrown();
		
		ProcessThrow();
		
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			parent.ManageGryphonSetBonusBuff();
			thePlayer.AddEffectDefault(EET_IgniCooldown, NULL, "normal_cast");
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

@wrapMethod(IgniChanneled) function OnEnded(optional isEnd : bool)
{
	if(false) 
	{
		wrappedMethod(isEnd);
	}
	
	super.OnEnded(isEnd);
	
	if ( caster.IsPlayer() )
	{
		caster.GetPlayer().LockToTarget( false );
		caster.GetPlayer().ResetRawPlayerHeading();		
	}		
	
	parent.AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
	parent.AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
	
	CleanUp();
	
	parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
	parent.StopEffect( parent.effects[parent.fireMode].throwEffectSpellPower );	
}

@replaceMethod(IgniChanneled) function ChannelIgni()
{
	caster.GetActor().OnSignCastPerformed(ST_Igni, true);
	
	while( Update(theTimer.timeDelta) )
	{
		ProcessThrow(theTimer.timeDelta);
		Sleep(theTimer.timeDelta);
	}
}

@wrapMethod(IgniChanneled) function CleanUp()
{
	var i, size : int;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(caster.IsPlayer())
	{
		thePlayer.AddEffectDefault(EET_IgniCooldown, NULL, "alt_cast");
		if(thePlayer.HasBuff(EET_Mutagen10))
			((W3Mutagen10_Effect)thePlayer.GetBuff(EET_Mutagen10)).AddMutagen10Ability();
		if(thePlayer.HasBuff(EET_Mutagen17))
			((W3Mutagen17_Effect)thePlayer.GetBuff(EET_Mutagen17)).RemoveMutagen17Abilities();
		if(thePlayer.HasBuff(EET_Mutagen22))
			((W3Mutagen22_Effect)thePlayer.GetBuff(EET_Mutagen22)).AddMutagen22Ability();
	}
	
	size = reusableProjectiles.Size();
	for ( i = 0; i < size; i+=1 )
	{
		if ( reusableProjectiles[i] )
		{
			reusableProjectiles[i].Destroy();
		}		
	}
	reusableProjectiles.Clear();
	
	parent.CleanUp();
}