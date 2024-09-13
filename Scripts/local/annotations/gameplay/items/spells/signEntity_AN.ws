@addField(W3SignEntity)
protected 	var usedFoA				: bool;
@addField(W3SignEntity)
protected	var foaMult				: float;

@wrapMethod(W3SignEntity) function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
{
	var witcher: W3PlayerWitcher;
	
	if(false) 
	{
		wrappedMethod( inOwner, prevInstance, skipCastingAnimation, notPlayerCast );
	}
	
	owner = inOwner;
	fireMode = 0;
	InitFoA(notPlayerCast);
	GetSignStats();
	
	if ( skipCastingAnimation || owner.InitCastSign( this ) )
	{
		if(!notPlayerCast)
		{
			owner.SetCurrentlyCastSign( GetSignType(), this );				
			CacheActionBuffsFromSkill();
		}
		
		
		if ( !skipCastingAnimation )
		{
			AddTimer( 'BroadcastSignCast', 0.8, false, , , true );
		}
		

		witcher = (W3PlayerWitcher) owner.GetPlayer();
		if( witcher && !notPlayerCast )
		{
			if( witcher.IsMutationActive( EPMT_Mutation1 ) )
			{
				PlayMutation1CastFX();
			}
			else if( witcher.IsMutationActive( EPMT_Mutation6 ) )
			{
				theGame.MutationHUDFeedback( MFT_PlayOnce );
			}
			else if( witcher.IsMutationActive( EPMT_Mutation10 ) )
			{
				witcher.PlayEffect( 'mutation_10_energy' );
			}
		}
		
		return true;
	}
	else
	{
		owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
		CleanUp();
		Destroy();
		return false;
	}
}

@addMethod(W3SignEntity) function GetUsedFoA() : bool
{
	return usedFoA;
}

@addMethod(W3SignEntity) function SetUsedFoA( b : bool )
{
	usedFoA = b;
}

@addMethod(W3SignEntity) function InitFoA(notPlayerCast : bool)
{
	var witcher: W3PlayerWitcher;
	
	foaMult = 1;
	SetUsedFoA(false);
	
	witcher = (W3PlayerWitcher)owner.GetPlayer();
	
	if(!witcher || notPlayerCast)
		return;
	
	if(witcher.AddTemporarySkills_Public())
	{
		foaMult = 3;
		SetUsedFoA(true);
	}
}

@addMethod(W3SignEntity) function CleanUpFoA()
{
	var witcher: W3PlayerWitcher;
	
	witcher = (W3PlayerWitcher)owner.GetPlayer();
	
	if(witcher && GetUsedFoA())
		witcher.RemoveTemporarySkills();
}

@replaceMethod(W3SignEntity) function OnEnded(optional isEnd : bool)
{
	var witcher : W3PlayerWitcher;
	var camHeading : float;
	
	witcher = (W3PlayerWitcher)owner.GetActor();
	if(witcher && witcher.IsCurrentSignChanneled() && witcher.GetCurrentlyCastSign() != ST_Quen && witcher.bRAxisReleased )
	{
		if ( !witcher.lastAxisInputIsMovement )
		{
			camHeading = VecHeading( theCamera.GetCameraDirection() );
			if ( AngleDistance( GetHeading(), camHeading ) < 0 )
				witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading + witcher.GetOTCameraOffset(), 0.0, 0.2, false );
			else
				witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading - witcher.GetOTCameraOffset(), 0.0, 0.2, false );
		}
		witcher.ResetLastAxisInputIsMovement();
	}

	CleanUp();
}

@wrapMethod(W3SignEntity) function CleanUp()
{	
	if(false) 
	{
		wrappedMethod();
	}
	
	owner.GetPlayer().ResetRawPlayerHeading();
	CleanUpFoA();
	
	if( (W3PlayerWitcher)owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
	}
}

@replaceMethod(W3SignEntity) function ManagePlayerStamina()
{
	var l_player			: W3PlayerWitcher;
	var l_cost, l_stamina	: float;
	
	l_player = owner.GetPlayer();

	if( l_player.CanUseSkill( S_Perk_09 ) && l_player.GetStat(BCS_Focus) >= 1 )
	{
		l_player.DrainFocus( 1 * foaMult );
		SetUsedFocus( true );
	}
	else
	{
		l_player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( skillEnum ) );
		SetUsedFocus( false );
		if(usedFoA)
			l_player.DrainFocus( 1 * foaMult );
	}
}

@replaceMethod(W3SignEntity) function ManageGryphonSetBonusBuff()
{

}

@addMethod(W3SignEntity) function ManageFocusGain(cost : float, dt : float)
{
	var player : CR4Player;
	var focus : SAbilityAttributeValue;
	var amount : float;
	var currSign : ESignType;
	
	currSign = GetSignType();

	player = (CR4Player)owner.GetPlayer();

	if(player && player.IsInCombat() && player.CanUseSkill(S_Perk_11) && !usedFocus && !usedFoA)
	{
		focus = player.GetAttributeValue('focus_gain');
		
		if(player.CanUseSkill(S_Sword_s20))
		{
			focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
		}
		
		amount = 0.1f * (1 + CalculateAttributeValue(focus));
		if(IsAlternateCast() && currSign != ST_Aard)
		{
			if(currSign == ST_Quen)
			{
				amount *= cost / ((W3PlayerAbilityManager)player.GetAbilityManager()).GetSkillStaminaUseCost(S_Magic_4);
			}
			else
			{
				amount *= dt;
			}
		}

		if(player.HasBuff(EET_Mutation7Buff))
			amount *= 2;
		else if(player.HasBuff(EET_Mutation7Debuff))
			amount /= 2;
		
		player.GainStat(BCS_Focus, amount);
	}
}

@replaceMethod(BaseCast) function OnThrowing()
{		
	var l_player : W3PlayerWitcher;
	var abilityName : name;
	var abilityCount, maxStack : float;
	var min, max : SAbilityAttributeValue;
	var addAbility : bool;
	
	l_player = caster.GetPlayer();
	
	if( l_player )
	{
		FactsAdd("ach_sign", 1, 4 );		
		theGame.GetGamerProfile().CheckLearningTheRopes();
		
		if(l_player.HasBuff(EET_Mutagen22) && l_player.IsInCombat() && l_player.IsThreatened())
		{
			abilityName = l_player.GetBuff(EET_Mutagen22).GetAbilityName();
			abilityCount = l_player.GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}

			if(addAbility)
			{
				l_player.AddAbility(abilityName, true);
			}
			
		}
	}

	return true;
}

@replaceMethod(BaseCast) function OnSignAborted( optional force : bool )
{
	parent.CleanUp();
	parent.StopAllEffects();
	parent.GotoState( 'Finished' );
}

@addField(Channeling)
var normalCastCost : float;

@wrapMethod(Channeling) function OnEnterState( prevStateName : name )
{
	if(false) 
	{
		wrappedMethod(prevStateName);
	}
	
	super.OnEnterState( prevStateName );
	parent.cachedCost = -1.0f;
	normalCastCost = -1.0f; 							  
	
	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, 0.2f, -1, true );
	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true );
}

@wrapMethod(Channeling) function OnThrowing()
{
	var actor : CActor;
	var player : CR4Player;
	var stamina : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if( super.OnThrowing() )
	{
		actor = caster.GetActor();
		player = (CR4Player)actor;
		
		if(player)
		{
			if( parent.cachedCost <= 0.0f )
			{
				parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
			}
		
			stamina = player.GetStat(BCS_Stamina);
		}
		
		if( player && player.CanUseSkill(S_Perk_09) && player.GetStat(BCS_Focus) >= 1 )
		{
			if( parent.cachedCost > 0 )
			{
				player.DrainFocus( 1 * parent.foaMult );
			}
			parent.SetUsedFocus( true );
		}
		else
		{
			actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			actor.StartStaminaRegen();
			actor.PauseStaminaRegen( 'SignCast' );
			parent.SetUsedFocus( false );
			if(parent.GetUsedFoA())
				player.DrainFocus( 1 * parent.foaMult );
		}
		
		return true;
	}
	
	return false;
}

@replaceMethod(Channeling) function Update(dt : float) : bool
{
	var multiplier, stamina, leftStaminaCostPerc, leftStaminaCost : float;
	var player : CR4Player;
	var reductionCounter : int;
	var stop, abortAxii : bool;
	var costReduction : SAbilityAttributeValue;
	
	player = caster.GetPlayer();
	abortAxii = false;
	
	if(player)
	{
		if( player.HasBuff( EET_Mutation11Buff ) )
		{
			return true;
		}
		
		stop = false;
		if( ShouldStopChanneling() )
		{
			stop = true;
			abortAxii = true;
		}
		else
		{
			if(player.CanUseSkill(S_Perk_09) && parent.usedFocus)
			{
				stop = (player.GetStat(BCS_Focus) <= 0);
			}
			else
			{
				stop = (player.GetStat( BCS_Stamina ) <= 0);
			}
			
			if( parent.skillEnum == S_Magic_s03 || parent.skillEnum == S_Magic_s05 )
			{
				stop = false;
			}
		}
	}		
	
	if(stop)
	{
		if( parent.skillEnum == S_Magic_s05 && abortAxii )		
		{
			OnSignAborted( true );
		}
		else
		{
			OnEnded();
		}
		
		return false;
	}
	else
	{
		if(player && !((W3QuenEntity)parent) )	
		{
			theGame.VibrateControllerLight();	
		}
		
		reductionCounter = caster.GetSkillLevel(virtual_parent.skillEnum) - 1;
		multiplier = 1;
		if(reductionCounter > 0)
		{
			costReduction = caster.GetSkillAttributeValue(virtual_parent.skillEnum, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
			multiplier = 1 - costReduction.valueMultiplicative;
		}
		
		if(player)
		{
			if( parent.cachedCost <= 0.0f )
			{	
				parent.cachedCost = multiplier * player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), dt );
			}
		
			stamina = player.GetStat(BCS_Stamina);

			if(normalCastCost <= 0.0f) 
			{
				normalCastCost = ((W3PlayerAbilityManager)player.GetAbilityManager()).GetSkillStaminaUseCost(GetBaseSignSkill(parent.skillEnum));
				if(normalCastCost <= 0.0f)
					normalCastCost = player.GetStatMax(BCS_Stamina);
			}
			
			leftStaminaCostPerc = parent.cachedCost / normalCastCost;
		}

		if(player && player.CanUseSkill(S_Perk_09) && parent.usedFocus)
		{
			player.DrainFocus( MinF(player.GetStat(BCS_Focus), leftStaminaCostPerc * parent.foaMult) ); 							
		}
		else if(multiplier > 0.f)
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ), dt, multiplier );
		}
		caster.OnProcessCastingOrientation( true );
	}
	return true;
}