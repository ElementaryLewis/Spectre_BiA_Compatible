@wrapMethod(W3ReplacerCiri) function OnSpawned( spawnData : SEntitySpawnData )
{
	if(false) 
	{
		wrappedMethod(spawnData);
	}
	
	if ( spawnData.restored && !inputHandler )
	{
		spawnData.restored = false;
	}

	super.OnSpawned( spawnData );
	
	
	RemoveNotNeededWeaponsFromInventory();
	
	
	BlockAction( EIAB_Signs, 'being_ciri' );
	BlockAction( EIAB_OpenInventory, 'being_ciri' );
	BlockAction( EIAB_OpenGwint, 'being_ciri' );
	BlockAction( EIAB_FastTravel, 'being_ciri' );
	BlockAction( EIAB_Fists, 'being_ciri' );
	BlockAction( EIAB_OpenMeditation, 'being_ciri' );
	BlockAction( EIAB_OpenCharacterPanel, 'being_ciri' );
	BlockAction( EIAB_OpenJournal, 'being_ciri' );
	BlockAction( EIAB_OpenAlchemy, 'being_ciri' );	
	BlockAction( EIAB_OpenGlossary, 'being_ciri' );	
	BlockAction( EIAB_CallHorse, 'being_ciri' );
	BlockAction( EIAB_ExplorationFocus, 'being_ciri' );
	
	SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
	
	abilityManager.DrainStamina(ESAT_FixedValue, 99.f);
	this.AddEffectDefault(EET_StaminaDrain, this, this.GetName());
	
	isInitialized = true;
	
	AddAnimEventCallback( 'ActionBlend', 	'OnAnimEvent_ActionBlend' );
	AddAnimEventCallback( 'fx_trail', 		'OnAnimEvent_fx_trail' );
	AddAnimEventCallback( 'rage', 			'OnAnimEvent_rage' );
	AddAnimEventCallback( 'SlideToTarget', 	'OnAnimEvent_SlideToTarget' );
	
	if ( !bloodExplode )
		bloodExplode = (CEntityTemplate)LoadResource('blood_explode');
	
	
	theGame.UpdateStatsForDifficultyLevel( MinDiffMode( theGame.GetDifficultyMode(), EDM_Medium ) );
	
	if ( spawnData.restored )
	{
		
		theGame.RemoveTimeScale( 'CiriSpecialAttackHeavy' );
		theGame.RemoveTimeScale( 'CiriPhantom' );
	}
	
	
	if ( !this.HasAbility( 'Ciri_CombatRegen' ) )
	{
		this.AddAbility( 'Ciri_CombatRegen' );
	}
	
	theGame.GameplayFactsRemove( "PlayerIsGeralt" );
	
	CheckCiriAbilities();
}

@addMethod(W3ReplacerCiri) function CheckCiriAbilities()
{
	var journalManager : CWitcherJournalManager;
	var journalEntry : CJournalBase;
	var entryStatus : EJournalStatus;
	var isActive : bool;
	

	journalManager = theGame.GetJournalManager();
	journalEntry = journalManager.GetEntryByString("Q302 Ciri - Rescuing Dudu DC58A7F2-49D51834-AC99B3A6-6106D4CC");
	entryStatus = journalManager.GetEntryStatus(journalEntry);
	isActive = (entryStatus == JS_Active);
	journalEntry = journalManager.GetEntryByString("Q305 Ciri - chase to the temple 12B8D11E-4BF80285-D48C5CAF-A75A0887");
	entryStatus = journalManager.GetEntryStatus(journalEntry);
	isActive = (isActive || (entryStatus == JS_Active));
	if(isActive && !HasAbility('Ciri_Q305'))
		AddAbility('Ciri_Q305');
	else if(!isActive && HasAbility('Ciri_Q305'))
		RemoveAbility('Ciri_Q305');



	journalEntry = journalManager.GetEntryByString("Q205 Ciri - safe heaven");
	entryStatus = journalManager.GetEntryStatus(journalEntry);
	isActive = (entryStatus == JS_Active);
	if(isActive && !HasAbility('Ciri_Q205'))
		AddAbility('Ciri_Q205');
	else if(!isActive && HasAbility('Ciri_Q205'))
		RemoveAbility('Ciri_Q205');
}

@wrapMethod(W3ReplacerCiri) function ProcessCombatActionBuffer() : bool
{
	var action	 			: EBufferActionType			= this.BufferCombatAction;
	var stage	 			: EButtonStage 				= this.BufferButtonStage;		
	var throwStage			: EThrowStage;		
	var actionResult : bool = true;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(super.ProcessCombatActionBuffer())
		return true;		
		
	switch ( action )
	{
		case EBAT_LightAttack :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					if ( this.HasAbility('Ciri_Rage') )
						actionResult = this.OnPerformDashAttack();
					else
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
			switch ( stage )
			{
				case BS_Released :
				{
					if ( this.HasAbility('Ciri_Rage') )
						actionResult = this.OnPerformDashAttack();
					else
						actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
				} break;
				
				case BS_Pressed :
				{
					if ( this.GetCurrentStateName() == 'CombatFists' )
					{
						if ( this.HasAbility('Ciri_Rage') )
						actionResult = this.OnPerformDashAttack();
					else
						actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
					}
				} break;					
				
				default :
				{
					actionResult = false;
					
				} break;
			}
		} break;
		case EBAT_Ciri_SpecialAttack :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					actionResult = this.OnPerformSpecialAttack( true );
				} break;
				
				case BS_Released :
				{
					actionResult = this.OnPerformSpecialAttack( false );
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		case EBAT_Ciri_SpecialAttack_Heavy :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					actionResult = this.OnPerformSpecialAttackHeavy( true );
				} break;
				
				case BS_Released :
				{
					actionResult = this.OnPerformSpecialAttackHeavy( false );
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		case EBAT_Ciri_Counter :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					actionResult = this.OnPerformSpecialAttack( true );
				} break;
				
				case BS_Released :
				{
					actionResult = this.OnPerformSpecialAttack( false );
				} break;
				
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		case EBAT_Ciri_Dodge :
		{
			switch ( stage )
			{
				case BS_Pressed :
				{
					actionResult = this.OnPerformDodge();
				} break;
				default :
				{
					actionResult = false;
				} break;
			}
		} break;
		
		case EBAT_Roll :
		{
			switch ( stage )
			{
				case BS_Released :
				{
					actionResult = this.OnPerformDash();
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
	
	
	this.CleanCombatActionBuffer();
	
	if (actionResult)
	{
		SetCombatAction( action ) ;
	}
	
	return true;
}

@wrapMethod(W3ReplacerCiri) function OnCombatStart()
{
	wrappedMethod();
	
	CheckCiriAbilities();
}

@wrapMethod(W3ReplacerCiri) function DrainResourceForSpecialAttack()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	abilityManager.DrainStamina(ESAT_FixedValue, 100.f);
}

@replaceMethod(W3ReplacerCiri) function HasStaminaToParry( attActionName : name, optional mult : float ) : bool
{
	return true;
}

@addMethod(W3ReplacerCiri) function HasStaminaToCounter( attActionName : name, optional mult : float ) : bool
{
	return true;
}

@addMethod(W3ReplacerCiri)  function HasStaminaToUseAction( action : EStaminaActionType, optional abilityName : name, optional dt :float, optional multiplier : float ) : bool
{
	return true;
}

@addMethod(W3ReplacerCiri)  function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float)
{
}

@wrapMethod(W3ReplacerCiri) function ReduceDamage(out damageData : W3DamageAction)
{
	var actorAttacker : CActor;
	
	if(false) 
	{
		wrappedMethod(damageData);
	}
	
	super.DodgeDamage(damageData);
		
	actorAttacker = (CActor)damageData.attacker;
	
	if(actorAttacker)
	{			
		if(IsCurrentlyDodging() && damageData.CanBeDodged())
		{
			if ( theGame.CanLog() )
			{
				LogDMHits("W3ReplacerCiri.ReduceDamage: Attack dodged by Ciri - no damage done", damageData);
			}
			damageData.SetAllProcessedDamageAs(0);
			damageData.SetWasDodged();
			damageData.ClearEffects(); 
			damageData.SetHitAnimationPlayType(EAHA_ForceNo); 
			GainResource();
		}
	}
	
}