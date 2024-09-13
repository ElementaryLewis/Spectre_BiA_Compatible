@replaceMethod(W3LevelManager) function AddPoints(type : ESpendablePointType, amount : int, show : bool, optional ignoreNGP : bool )
{
	var total : int;
	var arrInt : array<int>;
	var hudWolfHeadModule : CR4HudModuleWolfHead;		
	var hud : CR4ScriptedHud;
	var extraLevels: int;
	
	hud = (CR4ScriptedHud)theGame.GetHud();

	if(amount <= 0)
	{
		LogAssert(false, "W3LevelManager.AddPoints: amount of <<" + type + ">> is <= 0 !!!");
		return;
	}
	
	if( type == EExperiencePoint && GetLevel() == GetMaxLevel() )
	{
		return;				
	}

	points[type].free += amount;

	if(type == EExperiencePoint)
	{
		
		if ( FactsQuerySum("NewGamePlus") > 0 && !ignoreNGP )
		{
			if ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL > 0 )
			{
				extraLevels = theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL;
			}
		}
		
		if(FactsQuerySum("NewGamePlus") > 0 && !ignoreNGP && GetLevel() < 50 + extraLevels)
		{
			points[type].free += amount;
			amount *= 2;
		}
		
		
		while(true)
		{
			total = GetTotalExpForNextLevel();
			if(total > 0 && GetPointsTotal(EExperiencePoint) >= total)
			{
				if( GainLevel( show ) )
				{
					GetWitcherPlayer().AddAbility( GetWitcherPlayer().GetLevelupAbility( GetWitcherPlayer().GetLevel() ) );
				}
				else
				{
					break;
				}
			}
			else
			{
				break;
			}
		}
		
		
		if( GetLevel() == GetMaxLevel() )
		{
			amount -= 2 * points[type].free;	
			points[type].free = 0;
		}
	
		theTelemetry.LogWithValue(TE_HERO_EXP_EARNED, amount);
		
		arrInt.PushBack(amount);
		
		
		hud.OnExperienceUpdate(amount, show);
	}
	else if(type == ESkillPoint)
	{
		theTelemetry.LogWithValue(TE_HERO_SKILL_POINT_EARNED, amount);
		
		
		hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
		if ( hudWolfHeadModule )
		{
			hudWolfHeadModule.ShowLevelUpIndicator(show);
		}
	}
}