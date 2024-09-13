@replaceMethod(CR4HudModuleBuffs) function OnTick( timeDelta : float )
{
	var effectsSize : int;
	var effectArray : array< CBaseGameplayEffect >;
	var i : int;
	var offset : int;
	var duration : float;
	var extraValue : int;
	var initialDuration : float;
	var hasRunword5 : bool;
	var oilEffect : W3Effect_Oil;
	var aerondightEffect	: W3Effect_Aerondight;
	var phantomWeapon		: W3Effect_PhantomWeapon;
	var runeword4			: W3Effect_Runeword4;
	var runeword11			: W3Effect_Runeword11;
	var effectType : EEffectType;
	
	if ( !CanTick( timeDelta ) )
		return true;

	_previousEffects = _currentEffects;
	_currentEffects.Clear();
	
	if( bDisplayBuffs && GetEnabled() )
	{		
		offset = 0;
		
		effectArray = thePlayer.GetCurrentEffects();
		effectsSize = effectArray.Size();
		hasRunword5 = false;
		
		for ( i = 0; i < effectsSize; i += 1 )
		{
			if(effectArray[i].ShowOnHUD() && effectArray[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
			{	
				
				initialDuration = effectArray[i].GetInitialDurationAfterResists();
				
				if ( (W3RepairObjectEnhancement)effectArray[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
				{
					hasRunword5 = true;
					
					if (!m_runword5Applied)
					{
						m_runword5Applied = true;
						UpdateBuffs();
						break;
					}
				}

				effectType = effectArray[i].GetEffectType();

				if( initialDuration < 1.0)
				{
					initialDuration = 1;
					duration = 1;
				}
				else
				{
					duration = effectArray[i].GetDurationLeft();
					if ( thePlayer.CanUseSkill( S_Perk_14 ) &&
						( effectType == EET_ShrineAxii || 
						  effectType == EET_ShrineIgni || 
						  effectType == EET_ShrineQuen || 
						  effectType == EET_ShrineYrden || 
						  effectType == EET_ShrineAard
						)
					   )
					{
						
						duration = effectArray[i].GetInitialDuration() + 1;
					}
					else if ( effectType == EET_EnhancedWeapon ||
							  effectType == EET_EnhancedArmor )
					{
						if ( GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
						{
							
							duration = effectArray[i].GetInitialDuration() + 1;
						}
					}
					else
					{
						if(duration < 0.f)
							duration = 0.f;		
					}
				}
				
				if ( effectType == EET_Oil )
				{
					oilEffect = (W3Effect_Oil)effectArray[ i ];
					if ( oilEffect )
					{
						
						if (oilEffect.GetAmmoCurrentCount() > 0 && GetWitcherPlayer().CanUseSkill(S_Alchemy_s06) && GetWitcherPlayer().GetSkillLevel(S_Alchemy_s06) > 2)
						{
							initialDuration = oilEffect.GetAmmoMaxCount();
							duration		= oilEffect.GetAmmoMaxCount();
						}
						else
						{
							initialDuration = oilEffect.GetAmmoMaxCount();
							duration		= oilEffect.GetAmmoCurrentCount();
						}
					}
				}					
				else if( effectType == EET_Aerondight )
				{
					aerondightEffect = (W3Effect_Aerondight)effectArray[i];
					if( aerondightEffect )
					{
						initialDuration = aerondightEffect.GetMaxCount();
						duration		= aerondightEffect.GetCurrentCount();
					}
				}
				else if( effectType == EET_PhantomWeapon ) 
				{
					phantomWeapon = (W3Effect_PhantomWeapon)effectArray[i];
					if( phantomWeapon )
					{
						initialDuration = phantomWeapon.GetMaxCount();
						duration		= phantomWeapon.GetCurrentCount();
					}
				}
				else if( effectType == EET_BasicQuen )
				{
					
					extraValue = ( ( W3Effect_BasicQuen ) effectArray[i] ).GetStacks();
					
				}
				else if( effectType == EET_Mutation3 )
				{						
					duration = ( ( W3Effect_Mutation3 ) effectArray[i] ).GetStacks();
					initialDuration = duration;
				}
				else if( effectType == EET_Mutation4 )
				{						
					duration = ( ( W3Effect_Mutation4 ) effectArray[i] ).GetStacks();
					initialDuration = duration;
				}
				else if( effectType == EET_Mutation7Buff || effectType == EET_Mutation7Debuff )
				{	
					
					extraValue = ( ( W3Mutation7BaseEffect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutation10 )
				{						
					duration = ( ( W3Effect_Mutation10 ) effectArray[i] ).GetStacks();
					initialDuration = duration;
				}
				else if( effectType == EET_LynxSetBonus )
				{
					duration = ( ( W3Effect_LynxSetBonus ) effectArray[i] ).GetStacks();
					initialDuration = ( ( W3Effect_LynxSetBonus ) effectArray[i] ).GetMaxStacks();
				}
				else if( effectType == EET_Runeword4 )
				{
					runeword4 = (W3Effect_Runeword4)effectArray[i];
					if( runeword4 )
					{
						initialDuration = runeword4.GetMaxStacks();
						duration		= runeword4.GetStacks();
					}
				}
				else if( effectType == EET_Runeword11 )
				{
					runeword11 = (W3Effect_Runeword11)effectArray[i];
					if( runeword11 )
					{
						initialDuration = runeword11.GetMaxStacks();
						duration		= runeword11.GetStacks();
					}
				}
				else if( effectType == EET_Mutagen01 )
				{
					extraValue = ( ( W3Mutagen01_Effect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutagen05 )
				{
					extraValue = ( ( W3Mutagen05_Effect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutagen15 )
				{
					extraValue = ( ( W3Mutagen15_Effect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutagen10 )
				{
					extraValue = ( ( W3Mutagen10_Effect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutagen17 )
				{
					extraValue = ( ( W3Mutagen17_Effect ) effectArray[i] ).GetStacks();
				}
				else if( effectType == EET_Mutagen22 )
				{
					extraValue = ( ( W3Mutagen22_Effect ) effectArray[i] ).GetStacks();
				}
				if(_currentEffects.Size() < i+1-offset)
				{
					_currentEffects.PushBack(effectArray[i]);
					m_fxSetPercentSFF.InvokeSelfFourArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ), FlashArgInt( extraValue ) );
				}
				else if( effectArray[i].GetEffectType() == _currentEffects[i-offset].GetEffectType() )
				{
					m_fxSetPercentSFF.InvokeSelfFourArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ), FlashArgInt( extraValue ) );
				}
				else
				{
					LogChannel('HUDBuffs',i+" something wrong");
				}
			}
			else
			{
				offset += 1;
				
			}
		}
		
		if (!hasRunword5 && m_runword5Applied)
		{
			m_runword5Applied = false;
			UpdateBuffs();
		}
	}

	
	if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0 )
		return true;

	
	if ( buffListHasChanged(_currentEffects, _previousEffects) || _forceUpdate )
	{
		_forceUpdate = false;
		UpdateBuffs();
	}

}

@replaceMethod(CR4HudModuleBuffs) function UpdateBuffs()
{
	var l_flashObject			: CScriptedFlashObject;
	var l_flashArray			: CScriptedFlashArray;
	var i 						: int;
	var oilEffect				: W3Effect_Oil;
	var aerondightEffect		: W3Effect_Aerondight;
	var phantomWeapon			: W3Effect_PhantomWeapon;
	var runeword4				: W3Effect_Runeword4;
	var runeword11				: W3Effect_Runeword11;
	var buffDisplayLimit		: int = 16;
	var mut3Buff 				: W3Effect_Mutation3;
	var mut4Buff 				: W3Effect_Mutation4;
	var effectType				: EEffectType;
	var mut7Buff 				: W3Mutation7BaseEffect;
	var mut10Buff 				: W3Effect_Mutation10;
	var buffState				: int;
	var format					: int;
	var quenBuff 				: W3Effect_BasicQuen;
	var isOilInfinite : bool;
	
	l_flashArray = GetModuleFlashValueStorage()().CreateTempFlashArray();
	for(i = 0; i < Min(buffDisplayLimit,_currentEffects.Size()); i += 1) 
	{
		if(_currentEffects[i].ShowOnHUD() && _currentEffects[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
		{
			if(_currentEffects[i].IsNegative())
			{
				buffState = 0;
			}
			else if ( _currentEffects[i].IsPositive() )
			{
				buffState = 1;
			}
			else if ( _currentEffects[i].IsNeutral() )
			{
				buffState = 2;
			}

			effectType = _currentEffects[i].GetEffectType();

			
			if(thePlayer.IsSkillEquipped( S_Alchemy_s06 ) && GetWitcherPlayer().CanUseSkill(S_Alchemy_s06) && GetWitcherPlayer().GetSkillLevel(S_Alchemy_s06) > 2)
				isOilInfinite = true;
			
			if ( effectType == EET_Oil && isOilInfinite )
			{
				
				format = 0;
			}
			else if ( effectType == EET_Oil || effectType == EET_Aerondight || effectType == EET_PhantomWeapon || effectType == EET_Mutation4 || effectType == EET_Mutation10 )
			{
				
				format = 1;
			}
			else if ( effectType == EET_Mutation3 || effectType == EET_LynxSetBonus || effectType == EET_Runeword4 || effectType == EET_Runeword11 )
			{
				
				format = 2;
			}
			else if ( effectType == EET_Mutation7Buff || effectType == EET_Mutation7Debuff || effectType == EET_BasicQuen || effectType == EET_Mutagen01 || effectType == EET_Mutagen05 || effectType == EET_Mutagen10 || effectType == EET_Mutagen15 || effectType == EET_Mutagen17 || effectType == EET_Mutagen22 )
			{
				
				format = 4;
			}
			else
			{
				
				format = 3;
			}
			
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashBool("isVisible",_currentEffects[i].ShowOnHUD());
			l_flashObject.SetMemberFlashString("iconName",_currentEffects[i].GetIcon());
			l_flashObject.SetMemberFlashString("title",GetLocStringByKeyExt(_currentEffects[i].GetEffectNameLocalisationKey()));
			l_flashObject.SetMemberFlashBool("IsPotion",_currentEffects[i].IsPotionEffect());
			l_flashObject.SetMemberFlashInt("isPositive", buffState);
			l_flashObject.SetMemberFlashInt("format", format);
			
			if ( effectType == EET_Oil )
			{	
				oilEffect = (W3Effect_Oil)_currentEffects[i];
				if ( oilEffect )
				{
					
					if (oilEffect.GetAmmoCurrentCount() > 0 && isOilInfinite)
					{
						l_flashObject.SetMemberFlashNumber("duration",        oilEffect.GetAmmoMaxCount() 	  * 1.0 );
						l_flashObject.SetMemberFlashNumber("initialDuration", oilEffect.GetAmmoMaxCount() 	  * 1.0 );
						l_flashObject.SetMemberFlashInt("format", 0);
					}
					
					else
					{
						l_flashObject.SetMemberFlashNumber("duration",        oilEffect.GetAmmoCurrentCount() * 1.0 );
						l_flashObject.SetMemberFlashNumber("initialDuration", oilEffect.GetAmmoMaxCount() 	  * 1.0 );
					}
				}
			}
			else if( effectType == EET_Aerondight )
			{
				aerondightEffect = (W3Effect_Aerondight)_currentEffects[i];
				if( aerondightEffect )
				{
					l_flashObject.SetMemberFlashNumber("duration",        aerondightEffect.GetCurrentCount() * 1.0 );
					l_flashObject.SetMemberFlashNumber("initialDuration", aerondightEffect.GetMaxCount()	 * 1.0 );
				}
			}
			else if( effectType == EET_PhantomWeapon )
			{
				phantomWeapon = (W3Effect_PhantomWeapon)_currentEffects[i];
				if( phantomWeapon )
				{
					l_flashObject.SetMemberFlashNumber("duration",        phantomWeapon.GetCurrentCount() * 1.0 );
					l_flashObject.SetMemberFlashNumber("initialDuration", phantomWeapon.GetMaxCount()	 * 1.0 );
				}
			}										
			
			
			else if( effectType == EET_Mutation3 )
			{						
				mut3Buff = ( W3Effect_Mutation3 ) _currentEffects[i];						
				l_flashObject.SetMemberFlashNumber("duration", 			mut3Buff.GetStacks() );
				l_flashObject.SetMemberFlashNumber("initialDuration", 	mut3Buff.GetStacks() );
			}
			else if( effectType == EET_Mutation4 )
			{						
				mut4Buff = ( W3Effect_Mutation4 ) _currentEffects[i];						
				l_flashObject.SetMemberFlashNumber("duration", 			mut4Buff.GetStacks() );
				l_flashObject.SetMemberFlashNumber("initialDuration", 	mut4Buff.GetStacks() );
			}
			else if( effectType == EET_Mutation10 )
			{						
				mut10Buff = ( W3Effect_Mutation10 ) _currentEffects[i];						
				l_flashObject.SetMemberFlashNumber("duration", 			mut10Buff.GetStacks() );
				l_flashObject.SetMemberFlashNumber("initialDuration", 	mut10Buff.GetStacks() );
			}
			else if( effectType == EET_LynxSetBonus )
			{
				l_flashObject.SetMemberFlashNumber("duration", 			( ( W3Effect_LynxSetBonus ) _currentEffects[i] ).GetStacks() );
				l_flashObject.SetMemberFlashNumber("initialDuration", 	( ( W3Effect_LynxSetBonus ) _currentEffects[i] ).GetMaxStacks() );
			}
			else if( effectType == EET_Runeword4 )
			{
				runeword4 = (W3Effect_Runeword4)_currentEffects[i];
				if( runeword4 )
				{
					l_flashObject.SetMemberFlashNumber("duration",        runeword4.GetStacks() );
					l_flashObject.SetMemberFlashNumber("initialDuration", runeword4.GetMaxStacks() );
				}
			}
			else if( effectType == EET_Runeword11 )
			{
				runeword11 = (W3Effect_Runeword11)_currentEffects[i];
				if( runeword11 )
				{
					l_flashObject.SetMemberFlashNumber("duration",        runeword11.GetStacks() );
					l_flashObject.SetMemberFlashNumber("initialDuration", runeword11.GetMaxStacks() );
				}
			}
			else if ( (W3RepairObjectEnhancement)_currentEffects[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
			{
				l_flashObject.SetMemberFlashNumber("duration", -1 );
				l_flashObject.SetMemberFlashNumber("initialDuration", -1 );
			}
			else
			{
				l_flashObject.SetMemberFlashNumber("duration",_currentEffects[i].GetDurationLeft() );
				l_flashObject.SetMemberFlashNumber("initialDuration", _currentEffects[i].GetInitialDurationAfterResists());
			}
			l_flashArray.PushBackFlashObject(l_flashObject);	
		}
	}
	
	m_flashValueStorage.SetFlashArray( "hud.buffs", l_flashArray );
}