@wrapMethod(CBaseGameplayEffect) function CacheSettings()
{
	var i,size : int;
	var tmpString : string;
	var dm : CDefinitionsManagerAccessor;
	var main,temp : SCustomNode;
	var tmpBool : bool;
	var tmpName, customAbilityName : name;
	var tmpFloat : float;		
	var type : EEffectType;		

	if(false) 
	{
		wrappedMethod();
	}
						
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('effects');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		EffectNameToType(tmpName, type, customAbilityName);
		if(effectType == type)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', tmpName))
				iconPath = theGame.effectMgr.GetPathForEffectIconTypeName(tmpName);
			if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'showOnHUD', tmpBool))
				showOnHUD = tmpBool;
			
			
			
							
			
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'defaultAbilityName_name', tmpName))
				abilityName = tmpName;
								
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cameraEffectName_name', tmpName))
				cameraEffectName = tmpName;				
			if( !IsNameValid(targetEffectName) && dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'targetEffectName_name', tmpName))
				targetEffectName = tmpName;
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'resistStatName_name', tmpName))		
				resistStat = ResistStatNameToEnum(tmpName, tmpBool);
			if( dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'isPotionEffect', tmpBool))		
				isPotionEffect = tmpBool;
				
			
			if(isPotionEffect && !isPositive && !isNeutral && !isNegative)
			{
				isPositive = true;
				isNeutral = false;
				isNegative = false;
			}
				
			
			if((!isPotionEffect || tmpName == 'PotionDigestionEffect') && dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStartSound_name', tmpName))
				onAddedSound = tmpName;
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'onStopSound_name', tmpName))		
				onRemovedSound = tmpName;	
				
			
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectNameLocalisationKey_name', tmpName))		
				effectNameLocalisationKey = tmpName;
			if( dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'effectDescriptionLocalisationKey_name', tmpName))		
				effectDescriptionLocalisationKey = tmpName;
				
			
			temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'denies');
			if(temp.values.Size() > 0)
			{
				size = temp.values.Size();
				for(i=0; i<size; i+=1)
				{
					if(IsNameValid(temp.values[i]))
					{
						EffectNameToType(temp.values[i], type, tmpName);
						deny.PushBack(type);
					}
				}
			}
			temp = dm.GetCustomDefinitionSubNode(main.subNodes[i],'overrides');
			if(temp.values.Size() > 0)
			{
				size = temp.values.Size();
				for(i=0; i<size; i+=1)
				{
					if(IsNameValid(temp.values[i]))
					{
						EffectNameToType(temp.values[i], type, tmpName);
						override.PushBack(type);
					}
				}
			}

			if(iconPath=="" && showOnHUD)
				LogEffects("BaseEffect.Initialize: Effect " + this + " should show in GUI but has no icon defined!");
				
			return;
		}			
	}

	
	LogEffects("BaseEffect.Initialize: Cannot find GUI definitions in xml file for effect " + this);
}

@wrapMethod(CBaseGameplayEffect) function Init(params : SEffectInitInfo)
{
	var min, max, null : SAbilityAttributeValue;
	var durationSet : bool;
	var dm : CDefinitionsManagerAccessor;
	
	if(false) 
	{
		wrappedMethod(params);
	}

	EntityHandleSet(creatorHandle, params.owner);
	effectManager = params.targetEffectManager;
	target = params.target;	
	sourceName = params.sourceName;
	durationSet = false;
	isSignEffect = params.isSignEffect;
	
	if(params.vibratePadLowFreq > 0)
		vibratePadLowFreq = params.vibratePadLowFreq;
	if(params.vibratePadHighFreq > 0)
		vibratePadHighFreq = params.vibratePadHighFreq;
	
	
	if(IsNameValid(params.customAbilityName))
	{
		abilityName = params.customAbilityName;		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, 'duration', min, max);
		duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		durationSet = true;
	}
		
	if(params.duration != 0 && (!durationSet || (durationSet && duration == 0)) )	
		duration = params.duration;
		
	isOnPlayer = (CPlayer)target;
	target.GetResistValue(resistStat, resistancePts, resistance);
	
	if(params.powerStatValue == null)
		params.powerStatValue.valueMultiplicative = 1;					
	creatorPowerStat = params.powerStatValue;
		
	CalculateDuration(true);			
	timeLeft = duration;
	
	if(!IsNameValid(params.customAbilityName) && (params.customEffectValue != null))
		effectValue = params.customEffectValue;		
	else
		SetEffectValue();	
	
	if(IsNameValid(params.customFXName))
		targetEffectName = params.customFXName;
}

@wrapMethod(CBaseGameplayEffect) function RecalcDuration()
{
	var prevDuration, points : float;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if(duration == -1)
		return;
	
	target.GetResistValue(resistStat, points, resistance);
	
	prevDuration = duration;
	duration = initialDuration;
	CalculateDuration();
	
	
	timeLeft = timeLeft * duration / prevDuration;
}

@wrapMethod(CBaseGameplayEffect) function CalculateDuration(optional setInitialDuration : bool)
{
	var durationResistance : float;
	var min, max : SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(setInitialDuration);
	}
	
	if(duration == 0)
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'duration', min, max);
		duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	if(setInitialDuration)
		initialDuration = duration;

	if( duration == -1)
		return;
		
	if(isNegative)
	{
		
		if(IsCriticalEffect(this))
			durationResistance = MinF(0.99f, resistance);
		else
			durationResistance = resistance;

		duration = MaxF(0, duration * (1 - durationResistance));
		if(isSignEffect && duration > 0 && (W3PlayerWitcher)GetCreator() && ((W3PlayerWitcher)GetCreator()).GetPotionBuffLevel(EET_PetriPhiltre) == 3)
		{
			if( effectType == EET_HeavyKnockdown || effectType == EET_Confusion || effectType == EET_AxiiGuardMe || effectType == EET_Burning )
			{
				duration *= 1.34;
			}
		}
		LogEffects("BaseEffect.CalculateDuration: " + effectType + " duration with target resistance (" + NoTrailZeros(resistance) + ") and attacker power mul of (" + NoTrailZeros(creatorPowerStat.valueMultiplicative) + ") is " + NoTrailZeros(duration) + ", base was " + NoTrailZeros(initialDuration));
	}		
}

@wrapMethod(CBaseGameplayEffect) function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
{
	var thisVal, otherVal : float;
	
	if(false) 
	{
		wrappedMethod(e);
	}

	if(sourceName != e.sourceName)
	{
		return EI_Undefined;
	}

	thisVal = GetEffectStrength();
	otherVal = e.GetEffectStrength();
	
	if(thisVal > otherVal)
	{
		return EI_Override;
	}
	else if(thisVal < otherVal)
	{
		return EI_Pass;				
	}
	else
	{
		if(!((W3Mutagen_Effect)this) && isPotionEffect && e.isPotionEffect)
			return EI_Cumulate;
		
		if(timeLeft <= 0 && IsCriticalEffect(this))
			return EI_Pass;
	
		if(timeLeft > e.timeLeft)
			return EI_Override;
		
		return EI_Cumulate;
	}
}

@wrapMethod(CBaseGameplayEffect) function CumulateWith(effect: CBaseGameplayEffect)
{
	if(false) 
	{
		wrappedMethod(effect);
	}
	
	if(!((W3Mutagen_Effect)this) && isPotionEffect && effect.isPotionEffect)
	{
		timeLeft += effect.timeLeft;
		duration += effect.duration;
		initialDuration = duration;
	}
	else
	{
		timeLeft = effect.timeLeft;
		duration = effect.duration;
	}
	isPotionEffect = effect.isPotionEffect;
	creatorHandle = effect.creatorHandle;
	sourceName = effect.sourceName;
	
	if(abilityName != effect.abilityName && !dontAddAbilityOnTarget)
	{
		target.RemoveAbility(abilityName);
		target.AddAbility(effect.abilityName);
	}
	
	abilityName = effect.abilityName;	
	
	if(isOnPlayer)
	{
		vibratePadLowFreq = effect.vibratePadLowFreq;
		vibratePadHighFreq = effect.vibratePadHighFreq;
		
		if(vibratePadLowFreq > 0 || vibratePadHighFreq > 0)
			theGame.OverrideRumbleDuration(vibratePadLowFreq, vibratePadHighFreq, timeLeft);
	}
	
	if(isOnPlayer && IsNameValid(onAddedSound))
		theSound.SoundEvent(onAddedSound);
}

@wrapMethod(CBaseGameplayEffect) function OnTimeUpdated(dt : float)
{	
	var runeword11Bonus : float;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	if( isActive && pauseCounters.Size() == 0)
	{
		timeActive += dt;	
		if( duration != -1 )
		{
			if(isPotionEffect && !((W3Mutagen_Effect)this) && isOnPlayer && thePlayer.HasBuff(EET_Runeword11) && effectType != EET_WhiteRaffardDecoction)
			{
				runeword11Bonus = ((W3Effect_Runeword11)thePlayer.GetBuff(EET_Runeword11)).GetExpirationBonus();
				if(runeword11Bonus > 0)
					timeLeft -= dt * (1 - runeword11Bonus);
			}
			else
				timeLeft -= dt;
			
			if( timeLeft <= 0 )
			{
				isActive = false;
			}
		}
		
		OnUpdate(dt);	
	}
}

@addMethod(CBaseGameplayEffect) function PauseSources() : array<name>
{
	var outNames : array<name>;
	var i : int;

	for(i = 0; i < pauseCounters.Size(); i += 1)
		outNames.PushBack(pauseCounters[i].sourceName);

	return outNames;
}