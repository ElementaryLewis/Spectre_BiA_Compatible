@replaceMethod function ProcessMonsterHuntTrophyQuest( trophyName : name, dontTeleportHorse : bool)
{
	var playerHorse			 : CNewNPC;
	var playerPosition 		 : Vector;
	var newPosition			 : Vector;
	var playerRotation 		 : EulerAngles;
	var witcher 			 : W3PlayerWitcher;
	var ids    				 : array<SItemUniqueId>;
	var eqId	 			 : SItemUniqueId;
	var horseManager		 : W3HorseManager;
	var horse				 : CNewNPC;
	var current_trophy		 : SItemUniqueId;
	
	witcher = GetWitcherPlayer();	
	playerHorse = (CNewNPC) witcher.GetHorseWithInventory();
	
	if( !dontTeleportHorse )
	{
		if(playerHorse)
		{
			playerPosition = witcher.GetWorldPosition();
			playerRotation = witcher.GetWorldRotation();
			
			newPosition = Vector(playerPosition.X, playerPosition.Y, playerPosition.Z + 0.1);
			
			if( theGame.GetWorld().NavigationFindSafeSpot( newPosition, 2.0, 6.0, newPosition ) )
			{
				playerHorse.TeleportWithRotation(playerPosition + witcher.GetHeadingVector() * 1.5, EulerNeg(playerRotation, EulerAngles(0.0,-90.0,0.0) ) );
			}
		}
	}
	
	ids = witcher.inv.GetItemsByName( trophyName );
	
	if( ids.Size() > 0 )
	{
		horseManager = witcher.GetHorseManager();

		horse = (CNewNPC)theGame.GetNodeByTag('playerHorse');
		ids = horse.GetInventory().AddAnItem( trophyName , 1);
		
		if(horseManager)
		{
			current_trophy = horseManager.GetItemInSlot(EES_HorseTrophy);
			horse.GetInventory().MountItem( current_trophy );
			// eqId = witcher.GetHorseManager().MoveItemToHorse(ids[0]);
			// horseManager.EquipItem(eqId);
		}
		else
		{
			horse.GetInventory().MountItem( ids[0] );
		}
	}
	
	Sleep(0.5f);
}

@replaceMethod function SetGeraltLevelHandsOn()
{
	var iID : array<SItemUniqueId>;
	var level : int = 15;
	
	spectreResetLevels_internal(level);
	
	GetWitcherPlayer().AddSkill(S_Sword_s21);
	GetWitcherPlayer().AddSkill(S_Sword_s21);
	GetWitcherPlayer().AddSkill(S_Sword_s21);
	GetWitcherPlayer().AddSkill(S_Sword_s17);
	GetWitcherPlayer().AddSkill(S_Sword_s17);
	GetWitcherPlayer().AddSkill(S_Sword_s17);
	GetWitcherPlayer().AddSkill(S_Sword_s04);
	GetWitcherPlayer().AddSkill(S_Sword_s04);
	GetWitcherPlayer().AddSkill(S_Sword_s04);
	GetWitcherPlayer().AddSkill(S_Sword_4);
	GetWitcherPlayer().AddSkill(S_Sword_s10);
	GetWitcherPlayer().AddSkill(S_Sword_s13);
	GetWitcherPlayer().AddSkill(S_Sword_s13);
	
	GetWitcherPlayer().EquipSkill(S_Sword_s21, 1);
	GetWitcherPlayer().EquipSkill(S_Sword_s17, 3);
	GetWitcherPlayer().EquipSkill(S_Sword_s04, 5);
	GetWitcherPlayer().EquipSkill(S_Sword_s10, 2);
	GetWitcherPlayer().EquipSkill(S_Sword_s13, 4);
	
	iID = GetWitcherPlayer().inv.AddAnItem('Nilfgaardian sword 2', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Silver sword 2', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Pants 02', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Gloves 04', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Boots 04', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	iID = GetWitcherPlayer().inv.AddAnItem('Lynx Armor 1', 1);
	GetWitcherPlayer().EquipItem(iID[0]);
	
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Long Steel Sword' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Witcher Silver Sword' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Starting Gloves' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Starting Pants' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Starting Boots' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Starting Armor' );
	GetWitcherPlayer().inv.RemoveItem( iID[0] );
	
	GetWitcherPlayer().inv.AddAnItem('Geralt Shirt');
	GetWitcherPlayer().inv.AddAnItem('Skellige Casual Suit');
	
	GetWitcherPlayer().inv.AddAnItem('Recipe for Necrophage Oil', 1);
	GetWitcherPlayer().inv.AddAnItem('Necrophage Oil', 1);
	GetWitcherPlayer().inv.AddAnItem('Recipe for Hanged Man Venom', 1);
	GetWitcherPlayer().inv.AddAnItem('Recipe for Beast Oil', 1);
	GetWitcherPlayer().inv.AddAnItem('Dog tallow', 4);
	GetWitcherPlayer().inv.AddAnItem('Wolf liver', 4);
	GetWitcherPlayer().inv.AddAnItem('Celandine', 5);
	GetWitcherPlayer().inv.AddAnItem('Wolfsbane', 4);
	GetWitcherPlayer().inv.AddAnItem('Grave Hag ear', 2);
	GetWitcherPlayer().inv.AddAnItem('Honeysuckle', 6);
	GetWitcherPlayer().inv.AddAnItem('Fools parsley leaves', 8);
	
	GetWitcherPlayer().inv.AddAnItem('Recipe for Samum', 1);
	GetWitcherPlayer().inv.AddAnItem('Samum', 1);
	GetWitcherPlayer().inv.AddAnItem('Dwarven spirit', 1);
	GetWitcherPlayer().inv.AddAnItem('Berbercane fruit', 7);
	GetWitcherPlayer().inv.AddAnItem('Hellebore petals', 4);
	GetWitcherPlayer().inv.AddAnItem('Cortinarius', 4);
	GetWitcherPlayer().inv.AddAnItem('Recipe for Grapeshot', 1);
	GetWitcherPlayer().inv.AddAnItem('Saltpetre', 2);
	GetWitcherPlayer().inv.AddAnItem('Calcium equum', 1);
	GetWitcherPlayer().inv.AddAnItem('Blowbill', 4);
	GetWitcherPlayer().inv.AddAnItem('Crows eye', 2);
	
	GetWitcherPlayer().inv.AddAnItem('Recipe for Cat', 1);
	GetWitcherPlayer().inv.AddAnItem('Recipe for Swallow', 1);
	GetWitcherPlayer().inv.AddAnItem('Swallow', 1);
	GetWitcherPlayer().inv.AddAnItem('Recipe for White Honey', 1);
	GetWitcherPlayer().inv.AddAnItem('White Honey', 1);
	
	GetWitcherPlayer().inv.AddAnItem('Mahakam Spirit', 10);
	
	GetWitcherPlayer().inv.AddAnItem('Bread', 5);
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Bread' );
	GetWitcherPlayer().EquipItem(iID[0]);
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Tawny Owl 1' );
	GetWitcherPlayer().EquipItem(iID[0]);
	iID =  GetWitcherPlayer().inv.GetItemsByName( 'Torch' );
	GetWitcherPlayer().EquipItem(iID[0]);	
	
	GetWitcherPlayer().AddPoints(EExperiencePoint, 850, false );
}

@replaceMethod function SetGeraltLevel( level : int, path : EGeraltPath )
{
	spectreResetLevels_internal(level);
	spectreAddAutogenEquipment_internal();
}