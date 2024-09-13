/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Mutagen13_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen13;
	
	default dontAddAbilityOnTarget = true;
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
	
	public function ManageMutagen13Bonus()
	{
		if(target == thePlayer && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			AddMutagen13Abilities();
		}
		else
		{
			thePlayer.RemoveAbilityAll(abilityName);
		}
	}
	
	private function AddMutagen13Abilities()
	{
		var abilityCount, ablsToAdd, maxStack : int;
		var min, max : SAbilityAttributeValue;
		
		if(target == GetWitcherPlayer() && thePlayer.IsInCombat() && thePlayer.IsThreatened())
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen13_max_stack', min, max);
			maxStack = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
			abilityCount = thePlayer.GetAbilityCount(abilityName);
			ablsToAdd = GetWitcherPlayer().GetNumHostilesInRange();
			
			if(abilityCount + ablsToAdd < maxStack)
			{
				thePlayer.AddAbilityMultiple(abilityName, ablsToAdd);
			}
			else if(abilityCount < maxStack)
			{
				thePlayer.AddAbilityMultiple(abilityName, maxStack - abilityCount);
			}
		}
	}
}
