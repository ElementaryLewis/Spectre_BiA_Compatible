@wrapMethod(CToadAcidPool) function OnFireHit( source : CGameplayEntity )
{
	var i : int;
	
	if(false) 
	{
		wrappedMethod(source);
	}
	
	
	if(! hasExploded)
	{
		hasExploded = true;
		
		StopAllEffects();
		PlayEffect( 'toxic_gas_explosion' );
		GCameraShake( 1.5, true, GetWorldPosition(), 20.0f );
		
		
		if ( thePlayer.IsCameraLockedToTarget() && thePlayer.GetDisplayTarget() == this )
		{
			thePlayer.OnForceSelectLockTarget();
		}
		
		FindGameplayEntitiesInSphere(entitiesInRange, this.GetWorldPosition(), explosionRange, 10);		
		entitiesInRange.Remove(this);
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			targetEntity = (CActor)entitiesInRange[i];
			
			if(targetEntity)
			{
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_Heavy, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, MaxF(damageVal, 0.2 * ((CActor)targetEntity).GetMaxHealth())  );
				damage.AddEffectInfo(EET_KnockdownTypeApplicator);
				damage.SetProcessBuffsIfNoDamage(true);
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				entitiesInRange[i].OnFireHit(this);
			}
		}
		
		super.OnFireHit(source);
		RemoveTimer( 'PoisonVictim' );
		this.StopEffect(fxOnSpawn);
		this.DestroyAfter(3.f);
		
	}
}