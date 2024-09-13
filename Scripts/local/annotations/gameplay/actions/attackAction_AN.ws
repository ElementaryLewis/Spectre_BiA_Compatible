@wrapMethod( W3Action_Attack ) function Init( attackr : CGameplayEntity, victm : CGameplayEntity, causr : IScriptable, weapId : SItemUniqueId, attName : name, src :string, hrt : EHitReactionType, canParry : bool, canDodge : bool, skillName : name, swType : EAttackSwingType, swDir : EAttackSwingDirection, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name, optional crossId : SItemUniqueId)
{		
	var player : CR4Player;
	var powerStat : ECharacterPowerStats;
	var weaponName : name;
	
	if(false) 
	{
		wrappedMethod( attackr, victm, causr, weapId, attName, src, hrt, canParry, canDodge, skillName, swType, swDir, isM, isR, isW, isE, hitFX_, hitBackFX_, hitParriedFX_, hitBackParriedFX_, crossId);
	}

	if(attName == '' || !attackr)
	{
		LogAssert(false, "W3Action_Attack.Init: missing attack data - debug (attack name OR attacker)!");
		return;
	}
	
	
	if(theGame.GetDefinitionsManager().AbilityHasTag(attName, 'UsesSpellPower'))
		powerStat = CPS_SpellPower;
	else
		powerStat = CPS_AttackPower;
	
	weaponName = ((CActor)attackr).GetInventory().GetItemName(weapId);
	if(weaponName == 'fists_lightning' || weaponName == 'fists_fire')
	{
		isM = false;
		isR = true;
	}
	
	super.Initialize( attackr, victm, causr, src, hrt, powerStat, isM, isR, isW, isE, hitFX_, hitBackFX_, hitParriedFX_, hitBackParriedFX_);
	
	swingType = swType;
	swingDirection = swDir;
	attackName = attName;
	weaponId = weapId;
	crossbowId = crossId;
	canBeParried = canParry && !attackr.HasAbility( 'UnblockableAttacks' );
	canBeDodged = canDodge;
	soundAttackType = 'empty';
	boneIndex = -1;	
	
	player = (CR4Player)attacker;
	if(IsBasicAttack(skillName) || (player && player.CanUseSkill(SkillNameToEnum(skillName))) )
		attackTypeName = skillName;
	else
		attackTypeName = '';
	
	FillDataFromWeapon();
	FillDataFromAttackName();		
}

@replaceMethod( W3Action_Attack ) function GetPowerStatValue() : SAbilityAttributeValue
{
	var min, max, result, horseDamageBonus : SAbilityAttributeValue;
	var witcherAttacker : W3PlayerWitcher;
	var temp : name;
	var actorVictim, actorAttacker : CActor;
	var monsterCategory : EMonsterCategory;
	var tmpBool : bool;
	var horseSpeed, holdRatio : float;
	var i : int;
	var dm : CDefinitionsManagerAccessor;
	var attributes : array<name>;

	result = super.GetPowerStatValue();
	actorVictim = (CActor)victim;
	actorAttacker = (CActor)attacker;		
			
	if(actorVictim && actorAttacker)
	{
		
		theGame.GetMonsterParamsForActor( actorVictim, monsterCategory, temp, tmpBool, tmpBool, tmpBool);

		if( actorAttacker.GetInventory().ItemHasActiveOilApplied( weaponId, monsterCategory ) )
		{
			result += actorAttacker.GetInventory().GetOilAttackPowerBonus( weaponId, monsterCategory );
		}
	}
	
	
	witcherAttacker = (W3PlayerWitcher)attacker;
	if(witcherAttacker)
	{		
		if(IsActionMelee())
		{
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_2))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_2, PowerStatEnumToName(CPS_AttackPower), false, true);
			
			
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s04))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s04);
			
			
			if(witcherAttacker.IsLightAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s21))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s21);
						
			if(witcherAttacker.CanUseSkill(S_Sword_s11) && actorVictim && actorVictim.WasCountered())
			{
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s11, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s11);
			}
		}
	}
	
	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributes(attackName, attributes);		
	for(i=0; i<attributes.Size(); i+=1)
	{
		if(PowerStatNameToEnum(attributes[i]) == powerStatType)
		{
			dm.GetAbilityAttributeValue(attackName, attributes[i], min, max);
			result += GetAttributeRandomizedValue(min, max);
			break;
		}
	}
	
	
	if(result.valueMultiplicative < 0)
		result.valueMultiplicative = 0.001;
	
	return result;
}