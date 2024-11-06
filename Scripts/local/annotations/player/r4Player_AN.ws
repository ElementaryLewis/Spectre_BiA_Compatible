@addField(CR4Player)
public			var castSignHoldTimestamp			: float;

@addMethod(CR4Player) function SetCastSignHoldTimestamp(ts : float)
{
	castSignHoldTimestamp = ts;
}

@wrapMethod(CR4Player) function OnSpawned( spawnData : SEntitySpawnData )
{
	wrappedMethod(spawnData);
	
	spectreInitAttempt();

	AddTimer('spectreWatcher', 0.01f, true);
}

@addMethod( CR4Player ) timer function spectreWatcher( dt : float, id : int )
{
	if ((spectreVersionControl() == 0 || spectreVersionControl() > spectreGetVersion() ) && FactsQuerySum("acs_version_control_toggle") <= 0 )
	{
		FactsAdd("spectre_version_control_toggle");
	}
	
	if ( FactsQuerySum("spectre_version_control_toggle") > 0 )
	{
		if (spectreVersionControl() == 0)
		{
			spectreInitializeSettings();
		}
		else
		{
			theGame.GetInGameConfigWrapper().SetVarValue('spectreMainOptions', 'spectreVersionControl', spectreGetVersion());
		}

		FactsRemove("spectre_version_control_toggle");
	}
}

@wrapMethod(CR4Player) function ReduceAllOilsAmmo( id : SItemUniqueId )
{
	var i : int;
	var oils : array< W3Effect_Oil >;
	
	if(false) 
	{
		wrappedMethod(id);
	}

	if(inv.ItemHasAnyActiveOilApplied(id) && (!CanUseSkill(S_Alchemy_s06) || GetSkillLevel(S_Alchemy_s06) < 3))
	{
		oils = inv.GetOilsAppliedOnItem( id );
		
		for( i=0; i<oils.Size(); i+=1 )
		{
			oils[ i ].ReduceAmmo();

			if( oils[ i ].GetAmmoCurrentCount() < 1 )
				RemoveEffect( oils[ i ] );
		}

		if(oils.Size() > 0 && ShouldProcessTutorial('TutorialOilAmmo'))
		{
			FactsAdd("tut_used_oil_in_combat");
		}
	}
}

@wrapMethod(CR4Player) function ManageAerondightBuff( apply : bool )
{
	var aerondight		: W3Effect_Aerondight;
	var item			: SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod(apply);
	}

	if( !IsInCombat() )
	{
		if( HasBuff( EET_Aerondight ) )
			RemoveBuff( EET_Aerondight );
		return;
	}
	
	item = inv.GetCurrentlyHeldSword();
	
	if( inv.ItemHasTag( item, 'Aerondight' ) )
	{
		aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
		
		if( apply )
		{
			if( !aerondight )
			{
				AddEffectDefault( EET_Aerondight, this, "Aerondight" );
			}
			else
			{
				aerondight.Resume( 'ManageAerondightBuff' );
			}
		}
		else
		{
			aerondight.Pause( 'ManageAerondightBuff' );
		}
	}
}

@addMethod(CR4Player) function ManageIrisBuff( apply : bool )
{
	var phantomWeapon	: W3Effect_PhantomWeapon;
	var item			: SItemUniqueId;
	
	if( !IsInCombat() )
	{
		if( HasBuff( EET_PhantomWeapon ) )
			RemoveBuff( EET_PhantomWeapon );
		return;
	}
	
	item = inv.GetCurrentlyHeldSword();
	
	if( inv.ItemHasTag( item, 'PhantomWeapon' ) )
	{
		phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
		
		if( apply )
		{
			if( !phantomWeapon )
			{
				AddEffectDefault( EET_PhantomWeapon, this, "PhantomWeapon" );
			}
			else
			{
				phantomWeapon.Resume( 'ManageIrisBuff' );
			}
		}
		else
		{
			phantomWeapon.Pause( 'ManageIrisBuff' );
		}
	}
}

@wrapMethod(CR4Player) function ApplyOil( oilId : SItemUniqueId, usedOnItem : SItemUniqueId ) : bool
{
	var oilAbilities : array< name >;
	var ammo, ammoBonus : float;
	var dm : CDefinitionsManagerAccessor;		
	var buffParams : SCustomEffectParams;
	var oilParams : W3OilBuffParams;
	var oilName : name;
	var min, max : SAbilityAttributeValue;
	var i : int;
	var oils : array< W3Effect_Oil >;
	var existingOil : W3Effect_Oil;
	
	if(false) 
	{
		wrappedMethod(oilId, usedOnItem);
	}
		
	if( !CanApplyOilOnItem( oilId, usedOnItem ) )
	{
		return false;
	}
	
	dm = theGame.GetDefinitionsManager();
	inv.GetItemAbilitiesWithTag( oilId, theGame.params.OIL_ABILITY_TAG, oilAbilities );
	oilName = inv.GetItemName( oilId );
	oils = inv.GetOilsAppliedOnItem( usedOnItem );
	
	
	for( i=0; i<oils.Size(); i+=1 )
	{
		if( oils[ i ].GetOilItemName() == oilName )
		{
			existingOil = oils[ i ];
			break;
		}
	}
	
	
	if(CanUseSkill(S_Alchemy_s06))
		CheckForPreviousLevelOilExploit(oilName,oils);
	
	
	
	if( !existingOil )
	{


		if( !GetWitcherPlayer() || !GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ) )

		{
			inv.RemoveAllOilsFromItem( usedOnItem );
		}
		else
		{
			dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Wolf_2 ), 'max_oils_count', min, max );


			if( inv.GetActiveOilsAppliedOnItemCount( usedOnItem ) >= CalculateAttributeValue( max ) )

			{
				inv.RemoveOldestOilFromItem( usedOnItem );
			}
		}
	}
	
	
	ammo = CalculateAttributeValue(inv.GetItemAttributeValue(oilId, 'ammo'));
	if(CanUseSkill(S_Alchemy_s06))
	{
		ammoBonus = CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s06, 'ammo_bonus', false, false));
		ammo *= 1 + ammoBonus * GetSkillLevel(S_Alchemy_s06);
	}
	
	
	if( existingOil )
	{
		existingOil.Reapply( RoundMath( ammo ) );
	}
	else
	{
		buffParams.effectType = EET_Oil;
		buffParams.creator = this;
		oilParams = new W3OilBuffParams in this;
		oilParams.iconPath = dm.GetItemIconPath( oilName );
		oilParams.localizedName = dm.GetItemLocalisationKeyName( oilName );
		oilParams.localizedDescription = dm.GetItemLocalisationKeyName( oilName );
		oilParams.sword = usedOnItem;
		oilParams.maxCount = RoundMath( ammo );
		oilParams.currCount = RoundMath( ammo );
		oilParams.oilAbilityName = oilAbilities[ 0 ];
		oilParams.oilItemName = oilName;
		buffParams.buffSpecificParams = oilParams;
		
		AddEffectCustom( buffParams );
		
		delete oilParams;
	}
	
	LogOils("Added oil <<" + oilName + ">> to <<" + inv.GetItemName( usedOnItem ) + ">>");
	
	
	SetFailedFundamentalsFirstAchievementCondition( true );		
	
	theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnOilApplied );
	
	if( !inv.IsItemHeld( usedOnItem ) )
	{
		PauseOilBuffs( inv.IsItemSteelSwordUsableByPlayer( usedOnItem ) );
	}
	
	return true;
}

@wrapMethod(CR4Player) function OnDeath( damageAction : W3DamageAction )
{
	wrappedMethod(damageAction);
	
	StopLowStaminaSFX();
}

@wrapMethod(CR4Player) function PerformCounterCheck(parryInfo: SParryInfo) : bool
{
	var attType						: float; 
	var parryType					: EParryType;
	var validCounter, useKnockdown, sword_s11_knockdown : bool;
	var slideDistance, duration 	: float;
	var playerToTargetRot			: EulerAngles;
	var zDifference					: float;
	var effectType 					: EEffectType;
	var repelType					: EPlayerRepelType = PRT_Random;
	var params						: SCustomEffectParams;
	var thisPos, attackerPos 		: Vector;
	var fistFightCheck, isMutation8 : bool;
	var fistFightCounter 			: bool;
	var attackerInventory			: CInventoryComponent;
	var weaponId					: SItemUniqueId;
	var weaponTags					: array<name>;
	var playerToAttackerVector 		: Vector;
	var tracePosStart				: Vector;
	var tracePosEnd					: Vector;
	var hitPos						: Vector;
	var hitNormal					: Vector;
	var min, max					: SAbilityAttributeValue;
	var npc 						: CNewNPC;
	
	if(false) 
	{
		wrappedMethod(parryInfo);
	}
	
	if(ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter'))
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
		FactsRemove("tut_fight_slomo_ON");
	}
	
	fistFightCheck = FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightCounter );

	if( !HasStaminaToCounter(parryInfo.attackActionName) )
	{
		return false;
	}
		
	if( ParryCounterCheck() && parryInfo.targetToAttackerAngleAbs < theGame.params.PARRY_HALF_ANGLE && fistFightCheck )
	{
		
		validCounter = CheckCounterSpamming(parryInfo.attacker);
		
		if(validCounter)
		{
			if ( IsInCombatActionFriendly() )
				RaiseEvent('CombatActionFriendlyEnd');
			
			SetBehaviorVariable( 'parryType', ChooseParryTypeIndex( parryInfo ) );
			SetBehaviorVariable( 'counter', (float)validCounter);			
			
			
			
			SetBehaviorVariable( 'parryType', ChooseParryTypeIndex( parryInfo ) );
			SetBehaviorVariable( 'counter', (float)validCounter);			
			this.SetBehaviorVariable( 'combatActionType', (int)CAT_Parry );

			DrainStamina(ESAT_Counterattack, 0, 0, '', 0);
			
			if(GetWitcherPlayer() && CanUseSkill(S_Perk_21))
			{
				GetWitcherPlayer().GainAdrenalineFromPerk21('counter');
			}
			
			if ( !fistFightCounter )
			{
				attackerInventory = parryInfo.attacker.GetInventory();
				weaponId = attackerInventory.GetItemFromSlot('r_weapon');
				attackerInventory.GetItemTags( weaponId , weaponTags );
				
				if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) )
				{
					isMutation8 = true;
				}
				
				
				
				npc = (CNewNPC)parryInfo.attacker;
				attType = npc.GetBehaviorVariable( 'AttackType' ); 
				
				repelType = PRT_Random; 

				if ( isMutation8 && npc && !npc.Mutation8RepelToFinisherImmune() )
				{
					repelType = PRT_RepelToFinisher;
					npc.AddEffectDefault( EET_CounterStrikeHit, this, "ReflexParryPerformed" );
					SetTarget(npc, true);
					PerformFinisher(0.f, 0);
				}
				else
				{
					if ( parryInfo.attacker.HasAbility('mon_gravehag') && (attType == 6 || attType == 19) && parryInfo.attacker.HasAbility('TongueAttack') )
					{
						repelType = PRT_Slash;
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, this, 'ReflexParryPerformed');
					}
					else if ( npc && !npc.IsHuman() && !npc.HasTag( 'dettlaff_vampire' ) )
					{
						repelType = PRT_SideStepSlash;
					}
					else if ( npc.IsHuman() && (npc.HasAbility('SkillTwoHanded') || npc.HasAbility('sq701_tournament_npcs')) )
					{
						repelType = PRT_SideStepSlash;
					}
					else
					{
						thisPos = this.GetWorldPosition();
						attackerPos = parryInfo.attacker.GetWorldPosition();
						playerToTargetRot = VecToRotation( thisPos - attackerPos );
						zDifference = thisPos.Z - attackerPos.Z;
						
						if ( playerToTargetRot.Pitch < -5.f && zDifference > 0.35 )
						{
							repelType = PRT_Kick;
							
							ragdollTarget = parryInfo.attacker;
							AddTimer( 'ApplyCounterRagdollTimer', 0.3 );
						}
						else
						{
							useKnockdown = false;
							if ( parryInfo.attacker.IsHuman() )
							{ 
								tracePosStart = parryInfo.attacker.GetWorldPosition();
								tracePosStart.Z += 1.f;
								playerToAttackerVector = VecNormalize( parryInfo.attacker.GetWorldPosition() -  parryInfo.target.GetWorldPosition() );
								tracePosEnd = ( playerToAttackerVector * 0.75f ) + ( playerToAttackerVector * parryInfo.attacker.GetRadius() ) + parryInfo.attacker.GetWorldPosition();
								tracePosEnd.Z += 1.f;

								if ( !theGame.GetWorld().StaticTrace( tracePosStart, tracePosEnd, hitPos, hitNormal, counterCollisionGroupNames ) )
								{
									tracePosStart = tracePosEnd;
									tracePosEnd -= 3.f;
									
									if ( !theGame.GetWorld().StaticTrace( tracePosStart, tracePosEnd, hitPos, hitNormal, counterCollisionGroupNames ) )
									{
										useKnockdown = true;
									}
								}
							}
						}
					}
					
					parryInfo.attacker.GetInventory().PlayItemEffect(parryInfo.attackerWeaponId, 'counterattack');
					
					if ( repelType == PRT_Random )
						if ( RandRange(100) > 50 )
							repelType = PRT_Bash;
						else
							repelType = PRT_Kick;

					if ( useKnockdown || CanUseSkill(S_Sword_s11) && GetSkillLevel(S_Sword_s11) >= 3 && GetStat(BCS_Focus) >= 1.0 && RandF() < GetStat(BCS_Focus)*CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s11, 's11_knockdown_chance', false, true)) )
					{
						duration = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s11, 'duration', false, true));
						if(!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown))
						{
							if(!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown))
								params.effectType = EET_HeavyKnockdown;
							else
								params.effectType = EET_Knockdown;
							params.creator = this;
							params.sourceName = "ReflexParryPerformed";
							params.duration = duration;
							parryInfo.attacker.AddEffectCustom(params);
							repelType = PRT_Kick;
							useKnockdown = true;
						}
						else
							useKnockdown = false;
					}
					
					if( !useKnockdown && (repelType == PRT_Kick || repelType == PRT_Bash ) )
					{
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, this, "ReflexParryPerformed");

						if( (W3PlayerWitcher)this && this.HasBuff( EET_LynxSetBonus ) )
						{
							((W3Effect_LynxSetBonus)this.GetBuff( EET_LynxSetBonus )).ResetDecay();
						}
					}
				}
				
				this.SetBehaviorVariable( 'repelType', (int)repelType );
				parryInfo.attacker.SetBehaviorVariable( 'repelType', (int)repelType );
			}
			else
			{
				parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, this, "ReflexParryPerformed");
			}
			
			
			SetParryTarget ( parryInfo.attacker );
			SetSlideTarget( parryInfo.attacker );
			if ( !IsActorLockedToTarget() )
				SetMoveTarget( parryInfo.attacker );
			
			if ( RaiseForceEvent( 'PerformCounter' ) )
				OnCombatActionStart();
			
			SetCustomRotation( 'Counter', VecHeading( parryInfo.attacker.GetWorldPosition() - this.GetWorldPosition() ), 0.0f, 0.2f, false );
			AddTimer( 'UpdateCounterRotation', 0.4f, true );
			AddTimer( 'SetCounterRotation', 0.2f );
			
			IncreaseUninterruptedHitsCount();	
			
			theGame.GetGamerProfile().IncStat(ES_CounterattackChain);
			
		}
		else
		{
			ResetUninterruptedHitsCount();
		}
		return validCounter;
	}			
	
	return false;
}

@wrapMethod(CR4Player) function CheckCounterSpamming(attacker : CActor) : bool
{	
	var counterWindowStartTime : EngineTime;		
	var i, spamCounter : int;
	var reflexAction : bool;
	var testEngineTime : EngineTime;

	if(false) 
	{
		wrappedMethod(attacker);
	}

	if ( thePlayer.GetSkillLevel(S_Sword_s11) == 10 )
	{
		return true;
	}
	
	if(!attacker)
		return false;
	
	counterWindowStartTime = ((CNewNPC)attacker).GetCounterWindowStartTime();
	spamCounter = 0;
	reflexAction = false;
	
	
	if ( counterWindowStartTime == testEngineTime )
	{
		return false;
	}
	
	for(i = counterTimestamps.Size() - 1; i>=0; i-=1)
	{
		
		if(counterTimestamps[i] >= (counterWindowStartTime - EngineTimeFromFloat(0.4)) )
		{
			spamCounter += 1;
		}
		
		else
		{
			counterTimestamps.Remove(counterTimestamps[i]);
			continue;
		}
		
		
		if(!reflexAction && (counterTimestamps[i] >= counterWindowStartTime))
			reflexAction = true;
	}
	
	
	if(spamCounter == 1 && reflexAction)
		return true;
		
	return false;
}

@wrapMethod(CR4Player) function OnCombatFinished()
{
	wrappedMethod();
	
	ResumeStaminaRegen( 'IsPerformingFinisher' ); 
}

@wrapMethod(CR4Player) function OnHolsteredItem( category :  name, slotName : name )
{
	wrappedMethod(category, slotName);
	
	if ( slotName == 'r_weapon' && (category == 'steelsword'))
	{
		ManageIrisBuff( false );
	}
}

@wrapMethod(CR4Player) function OnAnimEvent_pad_vibration( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
{
	if(false) 
	{
		wrappedMethod(animEventName, animEventType, animInfo);
	}
	
	theGame.VibrateControllerHard();
}

@wrapMethod(CR4Player) function FistFightHealthChange( val : bool )
{
	if(false) 
	{
		wrappedMethod(val);
	}
	
	if( val == true )
	{
		SetHealthPerc( 100 );
	}
	else
	{
		SetHealthPerc( 100 );
	}
}

@wrapMethod(CR4Player) function OnDelayOrientationChange()
{
	var delayOrientation 	: bool;
	var delayCameraRotation	: bool;
	var moveData 			: SCameraMovementData;
	var time				: float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	time = 0.01f;

	if ( spectreTestCastSignHold() )
	{
		actionType = 0;
		if ( moveTarget )
			delayOrientation = true;
		else
		{
			if ( !GetBIsCombatActionAllowed() )
				delayOrientation = true;
		}
		

	}
	else if ( theInput.GetActionValue( 'ThrowItemHold' ) == 1.f )
	{
		actionType = 3;
		delayOrientation = true;		
	}
	else if ( theInput.GetActionValue( 'SpecialAttackHeavy' ) == 1.f )
	{
		actionType = 2;
		if ( !slideTarget )
			delayOrientation = true;
		else
			delayOrientation = true;
	}
	else if ( IsGuarded() && !moveTarget )
	{
		actionType = 1;
		delayOrientation = true;
	}
	
	if ( delayOrientation )
	{ 
		delayOrientationChange = true;
		theGame.GetGameCamera().ForceManualControlHorTimeout();
		theGame.GetGameCamera().ForceManualControlVerTimeout();
		AddTimer( 'DelayOrientationChangeTimer', time, true );
	}
	
	if ( delayCameraRotation )
	{
		delayCameraOrientationChange = true;
		theGame.GetGameCamera().ForceManualControlHorTimeout();
		theGame.GetGameCamera().ForceManualControlVerTimeout();
		AddTimer( 'DelayOrientationChangeTimer', time, true );			
	}
}

@wrapMethod(CR4Player) function PlayRuneword4FX(optional weaponType : EPlayerWeapon)
{
	if(false) 
	{
		wrappedMethod(weaponType);
	}
}

@wrapMethod(CR4Player) function CanSprint( speed : float ) : bool
{
	if(false) 
	{
		wrappedMethod(speed);
	}
	
	if( speed <= 0.8f )
	{
		return false;
	}
	
	if ( thePlayer.GetIsSprintToggled() )
	{
	}
	
	else if(GetLeftStickSprint() && theInput.LastUsedGamepad())
	{		
		if(GetIsSprintToggled() && GetIsSprinting())
		{
		}
		else if(!GetIsSprintToggled())
			return false;
	}
	
	else if ( !sprintActionPressed )
	{
		return false;
	}
	else if( !theInput.IsActionPressed('Sprint') || ( theInput.LastUsedGamepad() && IsInsideInteraction() && GetHowLongSprintButtonWasPressed() < 0.12 ) )
	{
		return false;
	}
	
	if ( thePlayer.HasBuff( EET_OverEncumbered ) )
	{
		return false;
	}
	if ( !IsSwimming() )
	{
		if ( ShouldUseStaminaWhileSprinting() && !GetIsSprinting() && !IsInCombat() && GetStat(BCS_Stamina) <= 0 )
		{
			return false;
		}
		if( ( !IsCombatMusicEnabled() || IsInFistFightMiniGame() ) && ( !IsActionAllowed(EIAB_RunAndSprint) || !IsActionAllowed(EIAB_Sprint) )  )
		{
			return false;
		}
		if( IsTerrainTooSteepToRunUp() )
		{
			return false;
		}
		if( IsInCombatAction() )
		{
			return false;
		}
		if( IsInAir() )
		{
			return false;
		}
	}
	if( theGame.IsFocusModeActive() )
	{
		return false;
	}
	
	return true;
}

@wrapMethod(CR4Player) function ReduceDamage( out damageData : W3DamageAction)
{
	if(false) 
	{
		wrappedMethod(damageData);
	}
	
	super.ReduceDamage(damageData);
}

@wrapMethod(CR4Player) function GetCriticalHitChance( isLightAttack : bool, isHeavyAttack : bool, target : CActor, victimMonsterCategory : EMonsterCategory, isBolt : bool ) : float
{
	var critChance : float;
	var oilChanceAttribute : name;
	var weapons : array< SItemUniqueId >;
	var i : int;
	var holdsCrossbow : bool;
	var critVal : SAbilityAttributeValue;
	var weaponId : SItemUniqueId;
	
	if(false) 
	{
		wrappedMethod(isLightAttack, isHeavyAttack, target, victimMonsterCategory, isBolt);
	}
	
	critChance = 0;
	
	if( FactsQuerySum( 'debug_fact_critical_boy' ) > 0 )
	{
		critChance += 1;
	}
	
	critChance += CalculateAttributeValue( GetAttributeValue( theGame.params.CRITICAL_HIT_CHANCE ) );

	if( !isBolt )
	{
		if( IsInState( 'HorseRiding' ) && ( ( CActor )GetUsedVehicle() ).GetMovingAgentComponent().GetRelativeMoveSpeed() >= 4.0 )
		{
			critChance += 1;
		}
		
		if( isHeavyAttack && CanUseSkill( S_Sword_s08 ) )
		{
			critChance += CalculateAttributeValue( GetSkillAttributeValue( S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, true ) ) * GetSkillLevel( S_Sword_s08 );
		}
		else if( isLightAttack && CanUseSkill( S_Sword_s17 ) )
		{
			critChance += CalculateAttributeValue( GetSkillAttributeValue( S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, true ) ) * GetSkillLevel( S_Sword_s17 );
		}
	
		weaponId = inv.GetCurrentlyHeldSword();
		if( isHeavyAttack || isLightAttack )
		{
			critChance += CalculateAttributeValue( inv.GetOilCriticalChanceBonus( weaponId, victimMonsterCategory ) );
		}
	}
	
	weapons = inv.GetHeldWeapons();
	for( i=0; i<weapons.Size(); i+=1 )
	{			
		holdsCrossbow = ( inv.IsItemCrossbow( weapons[i] ) || inv.IsItemBolt( weapons[i] ) );
		if( holdsCrossbow != isBolt )
		{
			critVal = inv.GetItemAttributeValue( weapons[i], theGame.params.CRITICAL_HIT_CHANCE );
			critChance -= CalculateAttributeValue( critVal );
		}
	}

	return critChance;
}

@wrapMethod(CR4Player) function GetCriticalHitDamageBonus(weaponId : SItemUniqueId, victimMonsterCategory : EMonsterCategory, isStrikeAtBack : bool) : SAbilityAttributeValue
{
	var bonus, oilBonus : SAbilityAttributeValue;
	var vsAttributeName : name;
	var weapons : array< SItemUniqueId >;
	var i : int;
	var isBolt, holdsCrossbow : bool;
	
	if(false) 
	{
		wrappedMethod(weaponId, victimMonsterCategory, isStrikeAtBack);
	}

	bonus = super.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, isStrikeAtBack);
	
	bonus += inv.GetOilCriticalDamageBonus( weaponId, victimMonsterCategory );

	isBolt = inv.IsItemCrossbow( weaponId ) || inv.IsItemBolt( weaponId );
	weapons = inv.GetHeldWeapons();
	for( i = 0; i < weapons.Size(); i += 1 )
	{			
		holdsCrossbow = ( inv.IsItemCrossbow( weapons[i] ) || inv.IsItemBolt( weapons[i] ) );
		if( holdsCrossbow != isBolt )
		{
			bonus -= inv.GetItemAttributeValue( weapons[i], theGame.params.CRITICAL_HIT_DAMAGE_BONUS );
		}
	}

	return bonus;
}

@wrapMethod(CR4Player) function PerformParryCheck( parryInfo : SParryInfo) : bool
{
	var mult					: float;
	var parryType 				: EParryType;
	var parryDir 				: EPlayerParryDirection;
	var parryHeading			: float;
	var fistFightParry 			: bool;
	var action					: W3DamageAction;
	var counter 				: int;
	var onHitCounter 			: SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(parryInfo);
	}
	
	if( CanParryAttack() && FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightParry ) )
	{
		parryHeading = GetParryHeading( parryInfo, parryDir ) ;
		
		SetBehaviorVariable( 'parryDirection', (float)( (int)( parryDir ) ) );
		SetBehaviorVariable( 'parryDirectionOverlay', (float)( (int)( parryDir ) ) );
		SetBehaviorVariable( 'parryType', ChooseParryTypeIndex( parryInfo ) );
		
		if ( IsInCombatActionFriendly() )
			RaiseEvent('CombatActionFriendlyEnd');
			
		if( IsSuperHeavyAttack( parryInfo.attackActionName ) )
			mult = theGame.params.SUPERHEAVY_STRIKE_COST_MULTIPLIER;
		else if( IsHeavyAttack( parryInfo.attackActionName ) )
			mult = theGame.params.HEAVY_STRIKE_COST_MULTIPLIER;
		else
			mult = 0.0f;

		if(!HasStaminaToParry(parryInfo.attackActionName, mult))
		{
			SoundEvent("gui_no_stamina");
			parryingWithNotEnoughStamina = true;
		}
		else
			parryingWithNotEnoughStamina = false;
		

		this.SetBehaviorVariable( 'combatActionType', (int)CAT_Parry );
		
		if ( parryInfo.targetToAttackerDist > 3.f && !bLAxisReleased && !thePlayer.IsCiri() )
		{
			if ( RaiseForceEvent( 'PerformParryOverlay' ) )
			{
				ClearCustomOrientationInfoStack();
				IncDefendCounter();
			}
			else
				return false;
		}
		else
		{
			if ( RaiseForceEvent( 'PerformParry' ) )
			{
				OnCombatActionStart();
				ClearCustomOrientationInfoStack();
				SetSlideTarget( parryInfo.attacker );
				SetCustomRotation( 'Parry', parryHeading, 1080.f, 0.1f, false );
				IncDefendCounter();
			}
			else
				return false;
		}

		DrainStamina(ESAT_Parry, 0, 0, '', 0, mult);

		if ( parryInfo.attacker.IsWeaponHeld( 'fist' ) && !parryInfo.target.IsWeaponHeld( 'fist' ) )
		{
			parryInfo.attacker.ReactToReflectedAttack(parryInfo.target);
			return false;
		}
		else
		{
			if(IsLightAttack(parryInfo.attackActionName))
				parryInfo.target.PlayEffectOnHeldWeapon('light_block');
			else
				parryInfo.target.PlayEffectOnHeldWeapon('heavy_block');
		}

		return true;
	}			
	
	return false;
}

@addField(CR4Player)
protected var parryingWithNotEnoughStamina : bool;
	
@addMethod(CR4Player) function IsParryingWithNotEnoughStamina() : bool
{
	return parryingWithNotEnoughStamina;
}

@addMethod(CR4Player) function SetIsParryingWithNotEnoughStamina(b : bool)
{
	parryingWithNotEnoughStamina = b;
}

@wrapMethod(CR4Player) function SetIsCurrentlyDodging(enable : bool, optional isRolling : bool)
{
	wrappedMethod(enable, isRolling);
	
	if ( isRolling )
	{
		this.AddBuffImmunity( EET_LongStagger, 'Roll', false );				  
	}
	else
	{
		this.RemoveBuffImmunity( EET_LongStagger, 'Roll' );
	}
}

@wrapMethod(CR4Player) function DoAttack(animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float)
{
	wrappedMethod(animData, weaponId, parried ,countered, parriedBy, attackAnimationName, hitTime);
	
	if(!IsPerformingFinisher())
	{
		if(animData.attackName == 'attack_light')
			DrainStamina(ESAT_LightAttack);
		if(animData.attackName == 'attack_heavy')
			DrainStamina(ESAT_HeavyAttack);
	}
}

@addMethod(CR4Player) function CheckForLowStamina()
{

}

@addMethod(CR4Player) function StopLowStaminaSFX()
{

}

@wrapMethod(CR4Player) function SetupCombatAction( action : EBufferActionType, stage : EButtonStage )
{
	var hasResources : bool;
	
	if (this == GetWitcherPlayer())
	{
		switch ( action )
		{
			case EBAT_LightAttack:
				hasResources = HasStaminaToUseAction(ESAT_LightAttack);
				break;
			case EBAT_HeavyAttack:
				hasResources = HasStaminaToUseAction(ESAT_HeavyAttack);
				break;
			default:
				hasResources = true;
				break;
		}
		if (!hasResources)
		{
			thePlayer.SoundEvent("gui_no_stamina");
			return;
		}
	}
	
	wrappedMethod(action, stage);
}

@wrapMethod(CR4Player) function ProcessCombatActionBuffer() : bool
{
	var actionResult 		: bool;
	var action	 			: EBufferActionType			= this.BufferCombatAction;
	var stage	 			: EButtonStage 				= this.BufferButtonStage;
	var s					: SNotWorkingOutFunctionParametersHackStruct1;
	var allSteps 			: bool						= this.BufferAllSteps;
	
	if(false) 
	{
		wrappedMethod();
	}

	if ( IsInCombatActionFriendly() )
	{
		RaiseEvent('CombatActionFriendlyEnd');
	}
	
	
	if ( ( action != EBAT_SpecialAttack_Heavy && action != EBAT_ItemUse )
		|| ( action == EBAT_SpecialAttack_Heavy && stage == BS_Pressed ) 
		|| ( action == EBAT_ItemUse && stage != BS_Released )  )
	{
		GetMovingAgentComponent().GetMovementAdjustor().CancelAll();
		SetUnpushableTarget( NULL );
	}
	
	
	if ( !( action == EBAT_Dodge || action == EBAT_Roll ) )
	{
		SetIsCurrentlyDodging(false);
	}
	
	SetCombatActionHeading( ProcessCombatActionHeading( action ) );
	
	
	
	if ( action == EBAT_ItemUse && GetInventory().IsItemCrossbow( selectedItemId ) )
	{
		
		if ( rangedWeapon 
			&& ( ( rangedWeapon.GetCurrentStateName() != 'State_WeaponShoot' && rangedWeapon.GetCurrentStateName() != 'State_WeaponAim' ) || GetIsShootingFriendly() ) )
		{
			SetSlideTarget( GetCombatActionTarget( action ) );
		}
	}
	else if ( !( ( action == EBAT_SpecialAttack_Heavy && stage == BS_Released ) || GetCurrentStateName() == 'AimThrow' ) )
	{
		SetSlideTarget( GetCombatActionTarget( action ) );
	}
	
	if( !slideTarget )
		LogChannel( 'Targeting', "NO SLIDE TARGET" );
		
	
	actionResult = true;
	
	switch ( action )
	{
		case EBAT_EMPTY :
		{
			this.BufferAllSteps = false;
			return true;
		} break;
		
		case EBAT_LightAttack :
		{
			if ( IsCiri() )
				return false;
			
			switch ( stage )
			{
				case BS_Pressed :
				{

						thePlayer.BreakPheromoneEffect();
						actionResult = OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
					
				} break;
				
				default :
				{
					actionResult = false;
				}break;
			}
		}break;
		
		case  EBAT_HeavyAttack :
		{
			if ( IsCiri() )
				return false;
			
			switch ( stage )
			{
				case BS_Released :
				{

						thePlayer.BreakPheromoneEffect();		
						actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_HEAVY);
					
				} break;
				
				case BS_Pressed :
				{
					if ( this.GetCurrentStateName() == 'CombatFists' )
					{

							thePlayer.BreakPheromoneEffect();		
							actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_HEAVY);
						
					}
				} break;					
				
				default :
				{
					actionResult = false;
					
				} break;
			}
		} break;
		
		case EBAT_ItemUse :		
		{				
			switch ( stage )
			{
				case BS_Pressed :
				{
					if ( !( (W3PlayerWitcher)this ) || 
						( !IsInCombatActionFriendly() && !( !GetBIsCombatActionAllowed() && ( GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack || GetBehaviorVariable( 'combatActionType' ) == (int)CAT_CastSign ) ) ) )						
						
					{
						if ( inv.IsItemCrossbow( selectedItemId ) )
						{
							rangedWeapon = ( Crossbow )( inv.GetItemEntityUnsafe( selectedItemId ) );
							rangedWeapon.OnRangedWeaponPress();
							GetTarget().SignalGameplayEvent( 'Approach' );
							GetTarget().SignalGameplayEvent( 'ShootingCrossbow' );
						}
						else if(inv.IsItemBomb(selectedItemId) && this.inv.SingletonItemGetAmmo(selectedItemId) > 0 )
						{
							if( ((W3PlayerWitcher)this).GetBombDelay( ((W3PlayerWitcher)this).GetItemSlot( selectedItemId ) ) <= 0.0f )
							{
								BombThrowStart();
								GetTarget().SignalGameplayEvent( 'Approach' );
							}
						}
						else
						{
							DrainStamina(ESAT_UsableItem);
							UsableItemStart();				
						}
					}
					
				} if (!allSteps) break;
				
				case BS_Released:
				{
					if ( !( (W3PlayerWitcher)this ) || 
						( !IsInCombatActionFriendly() && ( GetBIsCombatActionAllowed() || !( !GetBIsCombatActionAllowed() && ( GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack || GetBehaviorVariable( 'combatActionType' ) == (int)CAT_CastSign ) ) ) ) )						
						
					{
						if ( inv.IsItemCrossbow( selectedItemId ) )
						{
							
							rangedWeapon.OnRangedWeaponRelease();
						}
						else if(inv.IsItemBomb(selectedItemId))
						{
							BombThrowRelease();
						}
						else						
						{
							UsableItemRelease();
						}
					}
				} break;
				
				default :
				{
					actionResult = false;
					break;
				}
			}
		} break;
		
		case EBAT_Dodge :
		{
			switch ( stage )
			{
				case BS_Released :
				{
					theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'PlayerEvade', 1.0f, 10.0f, -1.0f, -1 );
					thePlayer.BreakPheromoneEffect();
					actionResult = this.OnPerformEvade( PET_Dodge );
				} break;
				
				
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		case EBAT_Roll :
		{
			if ( IsCiri() )
				return false;
			
			switch ( stage )
			{
				case BS_Released :
				{
					theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'PlayerEvade', 1.0f, 10.0f, -1.0f, -1 );
					thePlayer.BreakPheromoneEffect();
					actionResult = this.OnPerformEvade( PET_Roll );
				} break;
				
				case BS_Pressed :
				{
					if ( this.GetBehaviorVariable( 'combatActionType' ) == 2.f )
					{
						if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
							actionResult = this.OnPerformEvade( PET_Pirouette );
						else	
							actionResult = this.OnPerformEvade( PET_Roll );
					}
					else
					{
						if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
						{
							actionResult = this.OnPerformEvade( PET_Dodge );
							actionResult = this.OnPerformEvade( PET_Pirouette );
						}
						else
						{
							actionResult = this.OnPerformEvade( PET_Dodge );
							actionResult = this.OnPerformEvade( PET_Roll );
						}
					}
					
					
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		case EBAT_Draw_Steel :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					if( !IsActionAllowed(EIAB_DrawWeapon) )
					{
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_DrawWeapon);
						actionResult = false;
						break;
					}
					if( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
					{
						OnEquipMeleeWeapon( PW_Steel, false, true );
					}
					
					actionResult = false;
					
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		case EBAT_Draw_Silver :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					if( !IsActionAllowed(EIAB_DrawWeapon) )
					{
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_DrawWeapon);							
						actionResult = false;
						break;
					}
					if( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
					{
						OnEquipMeleeWeapon( PW_Silver, false, true );
					}
					
					actionResult = false;
					
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		case EBAT_Sheathe_Sword :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					if( GetCurrentMeleeWeaponType() == PW_Silver )
					{
						if( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
						{
							OnEquipMeleeWeapon( PW_Silver, false, true );
						}
					}
					else if( GetCurrentMeleeWeaponType() == PW_Steel )
					{
						if( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
						{
							OnEquipMeleeWeapon( PW_Steel, false, true );
						}
					}
					
					actionResult = false;
					
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		default:
			return false;	
	}

	
	CleanCombatActionBuffer();
	
	if (actionResult)
	{
		SetCombatAction( action ) ;
		
		if(GetWitcherPlayer().IsInFrenzy())
			GetWitcherPlayer().SkillFrenzyFinish(0);
	}
	
	return true;		
}

@wrapMethod(CR4Player) function CancelHoldAttacks()
{
	ResumeStaminaRegen('RendSkill');
	
	wrappedMethod();
}

@wrapMethod(CR4Player) function ConsumeItem( itemId : SItemUniqueId ) : bool
{
	var params : SCustomEffectParams;
	var buffs : array<SEffectInfo>;
	var i : int;
	var category : name;
	var potionToxicity : float;
	
	if(false) 
	{
		wrappedMethod(itemId);
	}
	
	if(!inv.IsIdValid(itemId))
		return false;
	
	
	category = inv.GetItemCategory(itemId);
	if(category == 'edibles' || inv.ItemHasTag(itemId, 'Drinks') || ( category == 'alchemy_ingredient' && inv.ItemHasTag(itemId, 'Alcohol')) )
	{
		
		if(IsFistFightMinigameEnabled() || IsDiving())
		{
			DisplayActionDisallowedHudMessage(EIAB_Undefined, false, false, true);
			return false;
		}
	
		
		inv.GetItemBuffs(itemId, buffs);
		
		for(i=0; i<buffs.Size(); i+=1)
		{
			params.effectType = buffs[i].effectType;
			params.creator = this;
	  
			if(inv.ItemHasTag(itemId, 'Alcohol'))
				params.sourceName = "alcohol";
			else
			params.sourceName = "edible";
			params.customAbilityName = buffs[i].effectAbilityName;
			AddEffectCustom(params);
		}
		
		if(!CanUseSkill(S_Perk_15) && (inv.ItemHasTag(itemId, 'Alcohol') || inv.ItemHasTag(itemId, 'Uncooked')))
		{
			potionToxicity = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'toxicity'));
			abilityManager.GainStat(BCS_Toxicity, potionToxicity );
			if(inv.ItemHasTag(itemId, 'Alcohol')) 
				AddEffectDefault(EET_Drunkenness, NULL, inv.GetItemName(itemId));
		}
		PlayItemConsumeSound( itemId );
	}
	
	if(inv.IsItemFood(itemId))
		FactsAdd("consumed_food_cnt");
	
	
	if(!inv.ItemHasTag(itemId, theGame.params.TAG_INFINITE_USE) && !inv.RemoveItem(itemId))
	{
		LogAssert(false,"Failed to remove consumable item from player inventory!" + inv.GetItemName( itemId ) );
		return false;
	}
	
	return true;
}

@wrapMethod(CR4Player) function HasStaminaToUseSkill(skill : ESkill, optional perSec : bool, optional signHack : bool) : bool
{
	var ret : bool;
	var cost : float;
	
	if(false) 
	{
		wrappedMethod(skill, perSec, signHack);
	}

	cost = GetSkillStaminaUseCost(skill, perSec);
	
	ret = ( CanUseSkill(skill) && (abilityManager.GetStat(BCS_Stamina, signHack) >= cost) )
			|| ( IsSkillSign(skill) && CanUseSkill(S_Perk_09) && GetStat(BCS_Focus) >= 1 ); 
	
	if(!ret)
	{
		SetCombatActionHeading( GetHeading() );
		SetShowToLowStaminaIndication(cost);
	}
		
	return ret;
}

@wrapMethod(CR4Player) function IsLightAttack(attackName : name) : bool
{
	var skill : ESkill;
	var sup : bool;
	
	if(false) 
	{
		wrappedMethod(attackName);
	}

	sup = super.IsLightAttack(attackName);
	if(sup)
		return true;
		
	if(attackName == 'attack_light_special')
		return true;
	
	if(attackName == 'counter_attack_light')
		return true;
	
	skill = SkillNameToEnum(attackName);
	
	return skill == S_Sword_1 || skill == S_Sword_s01;
}

@wrapMethod(CR4Player) function OnFinisherStart()
{
	wrappedMethod();
	
	PauseStaminaRegen( 'IsPerformingFinisher' );
}

@wrapMethod(CR4Player) function OnFinisherEnd()
{
	wrappedMethod();
	
	ResumeStaminaRegen( 'IsPerformingFinisher' );
}

@wrapMethod(CR4Player) function OnProcessActionPost(action : W3DamageAction)
{
	var npc : CNewNPC;
	var attackAction : W3Action_Attack;
	var lifeLeech : float;
	
	if(false) 
	{
		wrappedMethod(action);
	}
	
	super.OnProcessActionPost(action);
	
	attackAction = (W3Action_Attack)action;
	
	if(attackAction)
	{
		npc = (CNewNPC)action.victim;
		
		
		if ( npc && npc.UsesEssence() )
		{
			PlayBattleCry( 'BattleCryMonstersSilverHit', 0.09f );
		}
		
		else if(npc && (npc.IsHuman() || npc.GetMovingAgentComponent().GetName() == "wild_hunt_base") )
		{
			PlayBattleCry('BattleCryHumansHit', 0.09f );
		}
		else
		{
			PlayBattleCry('BattleCryMonstersHit', 0.09f );
		}
		
		if(attackAction.IsActionMelee())
		{
			IncreaseUninterruptedHitsCount();
			
		
			if( IsLightAttack( attackAction.GetAttackName() ) )
			{
				GCameraShake(0.1, false, GetWorldPosition(), 10);
			}
		}
	}
}

@replaceMethod(CR4Player) function InitPhantomWeaponMgr()
{

}

@replaceMethod(CR4Player) function DestroyPhantomWeaponMgr()
{

}

@replaceMethod(CR4Player) function GetPhantomWeaponMgr() : W3Effect_PhantomWeapon
{
	var phantomWeapon : W3Effect_PhantomWeapon;

	if( phantomWeapon )
	{
		return phantomWeapon;
	}
	else
	{
		return NULL;
	}
} 

@replaceMethod(CR4Player) function DischargeWeaponAfter( td : float, id : int )
{

} 

@wrapMethod( CR4Player ) function HasRequiredLevelToEquipItem(item : SItemUniqueId) : bool
{
	if (false)
	{
		wrappedMethod(item);
	}
	
	return true;
}