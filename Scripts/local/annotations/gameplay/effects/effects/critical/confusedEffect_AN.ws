@addField(W3ConfuseEffect)
private saved var glyphwordAblAdded : bool;

@addMethod(W3ConfuseEffect) function CacheCritChanceBonus()
{
	var dm : CDefinitionsManagerAccessor;
	var min, max : SAbilityAttributeValue;
	
	dm = theGame.GetDefinitionsManager();		
	dm.GetAbilityAttributeValue(abilityName, 'critical_hit_chance', min, max);
	criticalHitBonus = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	
	if(!isOnPlayer && GetCreator() == thePlayer && isSignEffect)
	{
		if(thePlayer.CanUseSkill(S_Magic_s17))
			criticalHitBonus += CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Magic_s17, 'crit_chance_bonus', false, true)) * thePlayer.GetSkillLevel(S_Magic_s17);
	}
}

@addMethod(W3ConfuseEffect) function AddGlyphwordBonuses()
{
	var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
	var min, max : SAbilityAttributeValue;
	var count, maxStacks : float;
	
	if(!isOnPlayer && GetCreator() == thePlayer && isSignEffect)
	{
		dm.GetAbilityAttributeValue('Glyphword 14 abl', 'g14_max_stacks', min, max);
		maxStacks = CalculateAttributeValue(min);
		count = thePlayer.GetAbilityCount('Glyphword 14 abl');
		if(count < maxStacks)
		{
			thePlayer.AddAbility('Glyphword 14 abl', true);
			glyphwordAblAdded = true;
		}
	}
}

@addMethod(W3ConfuseEffect) function RemoveGlyphwordBonuses()
{
	if(glyphwordAblAdded)
		thePlayer.RemoveAbility('Glyphword 14 abl');
}

@wrapMethod(W3ConfuseEffect) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var params : W3ConfuseEffectCustomParams;
	var npc : CNewNPC;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}
		
	super.OnEffectAdded(customParams);
	
	dontAddAbilityOnTarget = true;
	
	if(isOnPlayer)
	{
		thePlayer.HardLockToTarget( false );
	}
	
	
	params = (W3ConfuseEffectCustomParams)customParams;
	if(params)
	{
		criticalHitBonus = params.criticalHitChanceBonus;
	}
	
	if(criticalHitBonus <= 0)
		CacheCritChanceBonus();
	
	AddGlyphwordBonuses();
	
	npc = (CNewNPC)target;
	
	if(npc)
	{
		
		npc.LowerGuard();
		
		if (npc.IsHorse())
		{
			if( npc.GetHorseComponent().IsDismounted() )
				npc.GetHorseComponent().ResetPanic();
			
			if ( IsSignEffect() &&  npc.IsHorse() )
			{
				npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
				npc.SignalGameplayEvent('NoticedObjectReevaluation');
			}
		}
	}
}

@wrapMethod(W3ConfuseEffect) function OnEffectRemoved()
{
	var npc : CNewNPC;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	super.OnEffectRemoved();
	
	RemoveGlyphwordBonuses();
	
	npc = (CNewNPC)target;
	
	if(npc)
	{
		npc.ResetTemporaryAttitudeGroup(AGP_Axii);
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
	}
	
	if (npc && npc.IsHorse())
		npc.SignalGameplayEvent('WasCharmed');
		
	if(drainStaminaOnExit)
	{
		target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
	}
}