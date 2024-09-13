@wrapMethod(W3DamageOverTimeEffect) function OnEffectAdded(optional customParams : W3BuffCustomParams)
{
	var params : W3BuffDoTParams;
	var perk20Bonus :SAbilityAttributeValue;
	
	if(false) 
	{
		wrappedMethod(customParams);
	}
	
	params = (W3BuffDoTParams)customParams;
	if(params)
	{
		isEnvironment = params.isEnvironment;
	}

	if( params && params.isPerk20Active )
	{
		perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
		effectValue.valueAdditive *= ( 1 + perk20Bonus.valueMultiplicative );
	}
	
	AddHealthRegenReductionBuff();		
	
	super.OnEffectAdded(customParams);
}

@addField(W3DamageOverTimeEffect)
private var cumulDt : float;

@addField(W3DamageOverTimeEffect)
private var cumulDmgDt : float;

@wrapMethod(W3DamageOverTimeEffect) function OnUpdate(dt : float)
{	
	var resistPoints, resistPercents : float;
	var dmg, maxVit, maxEss : float;
	var i : int;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	super.OnUpdate(dt);	
	
	if(!target.IsAlive())
		return true;
	
	if(!isActive || duration != -1 && timeLeft <= 0)
		return true;
	
	maxVit = target.GetStatMax( BCS_Vitality);
	maxEss = target.GetStatMax( BCS_Essence);
	
	cumulDt += dt;
			
	for(i=0; i<damages.Size(); i+=1)
	{
		dmg = CalculateDamage(i, maxVit, maxEss, dt);
			
		if( (!damages[i].hitsVitality && !damages[i].hitsEssence) || dmg <= 0)
		{
			LogAssert(false, "W3DamageOverTimeEffect: effect " + this + " on " + target.GetReadableName() + " is dealing no damage");
		}
		else
		{
			effectManager.CacheDamage(damages[i].damageTypeName, dmg, GetCreator(), this, dt, true, powerStatType, isEnvironment);		
			cumulDmgDt += dmg;
			if( FactsQuerySum( "modSpectre_debug_dot" ) > 0 )
			{
				if(cumulDt >= 1.0)
				{
					target.GetResistValue(damages[i].resistance, resistPoints, resistPercents);
					theGame.witcherLog.AddMessage("DoT raw damage:");
					theGame.witcherLog.AddMessage("Target: " + target.GetDisplayName());
					if(damages.Size() > 1)
						theGame.witcherLog.AddMessage("Dmg idx: " + IntToString(i));
					theGame.witcherLog.AddMessage("Dmg type: " + NameToString(damages[i].damageTypeName));
					theGame.witcherLog.AddMessage("Resist type: " + damages[i].resistance);
					theGame.witcherLog.AddMessage("Resist pts: " + FloatToString(resistPoints));
					theGame.witcherLog.AddMessage("Resist %: " + FloatToString(resistPercents));
					if(maxVit > 0)
						theGame.witcherLog.AddMessage("Max vit: " + FloatToString(maxVit));
					if(maxEss > 0)
						theGame.witcherLog.AddMessage("Max ess: " + FloatToString(maxEss));
					theGame.witcherLog.AddMessage("Mult: " + FloatToString(effectValue.valueMultiplicative));
					theGame.witcherLog.AddMessage("Add: " + FloatToString(effectValue.valueAdditive));
					theGame.witcherLog.AddMessage("Time: " + FloatToString(cumulDt));
					theGame.witcherLog.AddMessage("Raw dmg: " + FloatToString(cumulDmgDt));
				}
			}
		}
		
		
		if(effectValue.valueBase != 0)
			LogAssert(false, "W3DamageOverTimeEffect.OnUpdate: effect <<" + this + ">> has baseValue set which makes no sense!!!!");				
		else if(effectValue.valueMultiplicative == 1)
			LogAssert(false, "W3DamageOverTimeEffect.OnUpdate: effect <<" + this + ">> has valueMultiplicative set to 1 which results in 100% MAX HP damage /sec!!!!!");
	}
	
	if(cumulDt >= 1.0) // modSpectre: for logging
	{
		cumulDt = 0;
		cumulDmgDt = 0;
	}
}

@wrapMethod(W3DamageOverTimeEffect) function CalculateDamage(arrayIndex : int, maxVit : float, maxEss : float, dt : float) : float
{
	var dmg, dmgV, dmgE : float;
	
	if(false) 
	{
		wrappedMethod(arrayIndex, maxVit, maxEss, dt);
	}
	
	if(damages[arrayIndex].hitsVitality && target.UsesVitality())
	{
		dmgV = MaxF(0, dt * (effectValue.valueAdditive + (effectValue.valueMultiplicative * maxVit) ));
	}
	if(damages[arrayIndex].hitsEssence && target.UsesEssence())
	{
		dmgE = MaxF(0, dt * (effectValue.valueAdditive + (effectValue.valueMultiplicative * maxEss) ));
	}
	
	dmg = MaxF(dmgE, dmgV);
	dmg = MaxF(dt, dmg);
	
	return dmg;
}