/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Aerondight extends CBaseGameplayEffect
{
	default effectType 				= EET_Aerondight;
	default isPositive 				= true;

	private var xml_crit_dmg_bonus			: float;
	private var xml_dmg_boost_per_enemy		: float;
	private var xml_collateral_dmg			: float;
	private var xml_hitsToCharge			: int;
	private var xml_stackDrainDelay			: float;

	var aerondightEnt						: CItemEntity;
	private var visualEffects				: array<name>;
	var effectComponent						: W3AerondightFXComponent;

	private var currCount					: int;
	private var drainDelay					: float;
	
	private function InitXmlValues()
	{
		var defMgr : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
	
		defMgr.GetAbilityAttributeValue(abilityName, 'crit_dmg_bonus', min, max);
		xml_crit_dmg_bonus = CalculateAttributeValue(min);
		defMgr.GetAbilityAttributeValue(abilityName, 'dmg_boost_per_enemy', min, max);
		xml_dmg_boost_per_enemy = CalculateAttributeValue(min);
		defMgr.GetAbilityAttributeValue(abilityName, 'collateral_dmg', min, max);
		xml_collateral_dmg = CalculateAttributeValue(min);
		defMgr.GetAbilityAttributeValue(abilityName, 'hitsToCharge', min, max);
		xml_hitsToCharge = RoundMath(CalculateAttributeValue(min));
		defMgr.GetAbilityAttributeValue(abilityName, 'stackDrainDelay', min, max);
		xml_stackDrainDelay = CalculateAttributeValue(min);
	}
	
	private function InitSword()
	{
		target.GetInventory().GetCurrentlyHeldSwordEntity(aerondightEnt);
		effectComponent = (W3AerondightFXComponent)aerondightEnt.GetComponentByClassName('W3AerondightFXComponent');
		visualEffects = effectComponent.m_visualEffects;
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		InitXmlValues();
		InitSword();
		ResetCharges();
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectRemoved()
	{
		StopAerondightEffects();
		super.OnEffectRemoved();
	}
		
	event OnUpdate( deltaTime : float )
	{
		drainDelay -= deltaTime;
		
		if(drainDelay <=0)
			RemoveCharge();
		
		super.OnUpdate(deltaTime);
	}
	
	public function RemoveCharge()
	{
		drainDelay = xml_stackDrainDelay;
		
		if(currCount <= 0)
			return;
		
		currCount -= 1;
		if(currCount == 0)
			StopAerondightEffects();
		UpdateAerondightFX();
	}
	
	public function AddCharge()
	{
		drainDelay = xml_stackDrainDelay;
		
		if(IsFullyCharged())
			return;
		
		currCount += 1;
		UpdateAerondightFX();
	}
	
	public function ResetCharges()
	{
		currCount = 0;
		StopAerondightEffects();
		UpdateAerondightFX();
	}
	
	private function UpdateAerondightFX()
	{
		if(currCount > 0)
		{
			aerondightEnt.PlayEffect(visualEffects[Modded2Vanilla()]);
		}
		else
			aerondightEnt.PlayEffect(visualEffects[0]);
	}
	
	private function Modded2Vanilla() : int
	{
		return RoundMath(1.0 * currCount / xml_hitsToCharge * visualEffects.Size()) - 1;
	}
	
	public function StopAerondightEffects()
	{
		aerondightEnt.StopAllEffects();
	}
	
	public function DischargeAerondight(optional excludeEnt : CGameplayEntity)
	{
		var ents					: array<CGameplayEntity>;
		var i						: int;
		var action					: W3DamageAction;
		var ent                     : CEntity;
		
		FindGameplayEntitiesInRange(ents, target, 3, 100, , FLAG_OnlyAliveActors + FLAG_Attitude_Hostile, target);
		for(i = 0; i < ents.Size(); i += 1)
		{
			if(excludeEnt && ents[i] == excludeEnt)
			{
				
			}
			else
			{
				
			}

			action = new W3DamageAction in theGame;
			action.Initialize(target, ents[i], this, "AerondightDischarge", EHRT_Heavy, CPS_AttackPower, false, false, false, false);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			action.SetHitEffectAllTypes('hit_electric');
			action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, xml_collateral_dmg);
			action.AddEffectInfo(EET_Stagger);
			theGame.damageMgr.ProcessAction(action);
			delete action;

			ent = theGame.CreateEntity( (CEntityTemplate)LoadResource( 

			"dlc\bob\data\fx\quest\q704\q704_13_fountain\q704_fairlytale_portal.w2ent"

			, true ), ents[i].GetWorldPosition(), ents[i].GetWorldRotation() );

			ent.CreateAttachment( ents[i], , Vector( 0, 0, 1.5 ), EulerAngles( 0, 0, 0 ) );

			ent.PlayEffectSingle('portal');

			ent.DestroyAfter(3);
		}

		target.SoundEvent('magic_geralt_teleport');
		target.SoundEvent('magic_geralt_teleport');
		target.SoundEvent('magic_geralt_teleport');
		target.SoundEvent('magic_geralt_teleport');
		target.SoundEvent('magic_geralt_teleport');
		
		ResetCharges();
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		
		SetShowOnHUD(false);
		ResetCharges();
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		
		SetShowOnHUD(true);
		InitSword();
		ResetCharges();
	}
	
	protected function StopTargetFX()
	{
		super.StopTargetFX();
		
		StopAerondightEffects();
	}
	
	public function PlayTrailEffect(bloodType : EBloodType)
	{
		var trailFxName				: name;
		
		switch(bloodType)
		{
			case BT_Red : 
				trailFxName = 'aerondight_blood_red';
				break;
			case BT_Yellow :
				trailFxName = 'aerondight_blood_yellow';
				break;
			case BT_Black : 
				trailFxName = 'aerondight_blood_black';
				break;
			case BT_Green :
				trailFxName = 'aerondight_blood_green';
				break;
		}
		aerondightEnt.PlayEffect(trailFxName);
	}
	
	public function GetDamageBoost() : float
	{
		return ((W3PlayerWitcher)target).GetNumHostilesInRange() * xml_dmg_boost_per_enemy;
	}
	
	public function GetCritPowerBoost() : float
	{
		return xml_crit_dmg_bonus;
	}
	
	public function IsFullyCharged() : bool
	{
		return currCount == xml_hitsToCharge;
	}
	
	public function GetCurrentCount() : int
	{
		return currCount;
	}
	
	public function GetMaxCount() : int
	{
		return xml_hitsToCharge;
	}

	public function ReduceAerondightStacks() 
	{
		
	}
}

class W3AerondightFXComponent extends CScriptedComponent
{
	editable var m_visualEffects	: array<name>;
}
