@wrapMethod(W3ReactToBeingHitEntity) function DealDamage( action : W3DamageAction )
{
	var attacker 		: CActor;
	var params 			: SCustomEffectParams;
	var damage 			: float;
	
	if(false) 
	{
		wrappedMethod(action);
	}
	
	if ( !IsNameValid( attributeName ) )
	{
		attributeName = damageTypeName;
	}
	attacker = (CActor) action.attacker;
	if ( attacker )
	{
		damage = CalculateAttributeValue( attacker.GetAttributeValue( attributeName ) );
		if ( damage < 1 )
		{
			damage = MaxF(500, 0.5 * thePlayer.GetMaxHealth());
		}
		if ( killOnHpBelowPerc > 0 && attacker.GetHealthPercents() <= killOnHpBelowPerc )
		{
			if ( IsNameValid( setBehVarOnKill ) )
			{
				attacker.SetBehaviorVariable( setBehVarOnKill, behVarValue );
			}
			attacker.Kill( 'W3ReactToBeingHitEntity' );
		}
		else
		{
			action = new W3DamageAction in this;
			
			if ( debuffType != EET_Undefined )
			{
				params.effectType = debuffType;
				params.creator = this;
				params.sourceName = this.GetName();
				if ( debuffDuration > 0 )
				{
					params.duration = debuffDuration;
				}
				((CActor)attacker).AddEffectCustom(params);
			}
			
			action.attacker = this;
			action.Initialize( this, attacker, NULL, this.GetName(), EHRT_Heavy, CPS_Undefined, false, false, false, true );
			action.AddDamage( damageTypeName, damage );
			theGame.damageMgr.ProcessAction( action );
			if ( IsNameValid( effectOnHitVictim ) )
			{
				PlayEffectSingle( effectOnHitVictim );
			}
			delete action;
		}
	}
}