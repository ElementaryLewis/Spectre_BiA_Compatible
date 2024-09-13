@addField(W3DamageAction)
protected var grazeDamageReduction: float; 

@addField(W3DamageAction)
protected var mutation5Triggered : bool;

@wrapMethod( W3DamageAction ) function Clear()
{
	wrappedMethod();
	
	grazeDamageReduction = 0.f;
}

@addMethod(W3DamageAction) function SetDTs( dmgTypes : array< SRawDamage > ) : int
{
	dmgInfos.Clear();
	dmgInfos = dmgTypes;
	
	return dmgInfos.Size();
}

@addMethod(W3DamageAction) function SetCanBeDodged(b : bool)					
{
	canBeDodged = b;
}

@addMethod(W3DamageAction) function SetGrazeDamageReduction(dmg : float)		
{
	grazeDamageReduction = dmg;
}	

@addMethod(W3DamageAction) function IsGrazeDamage() : bool						
{
	return grazeDamageReduction > 0;
}

@addMethod(W3DamageAction) function GetGrazeDamageReduction() : float			
{
	return grazeDamageReduction;
}

@addMethod(W3DamageAction) function SetMutation5Triggered()				
{
	mutation5Triggered = true;
}

@addMethod(W3DamageAction) function GetMutation5Triggered() : bool		
{
	return mutation5Triggered;
}

@addMethod(W3DamageAction) function GetVitalityDamageTotal() : float
{
	var i : int;
	var ret : float;
	
	ret = 0;
	for(i = 0; i < dmgInfos.Size(); i += 1)
	{
		if(DamageHitsVitality(dmgInfos[i].dmgType))
			ret += dmgInfos[i].dmgVal;
	}
			
	return ret;
}

@addMethod(W3DamageAction) function GetEssenceDamageTotal() : float
{
	var i : int;
	var ret : float;
	
	ret = 0;
	for(i = 0; i < dmgInfos.Size(); i += 1)
	{
		if(DamageHitsEssence(dmgInfos[i].dmgType))
			ret += dmgInfos[i].dmgVal;
	}
			
	return ret;
}

@replaceMethod( W3DamageAction ) function IsMutation2PotentialKill() : bool
{
	var isOk : bool;
	var burning : W3Effect_Burning;
	
	isOk = ( attacker == thePlayer && IsActionWitcherSign() && IsCriticalHit() && ( GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) ) );
	
	if( !isOk )
	{
		burning = ( W3Effect_Burning ) causer;
		isOk = burning && burning.IsFromMutation2();
	}
	
	return isOk;
}