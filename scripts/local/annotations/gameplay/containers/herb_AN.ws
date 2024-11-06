@addField(W3Herb)
public var adjusted_yield : bool;

@addField(W3Herb)
public var growing : bool;

@wrapMethod(W3Herb) function GetStaticMapPinTag( out tag : name )
{
	var items : array< SItemUniqueId >;

	if(false) 
	{
		wrappedMethod(tag);
	}
	
	tag = '';

	if (theGame.alchexts.hide_herbs) return;

	if ( foliageComponent )
	{
		if ( foliageComponent.GetEntry() == 'empty' )
		{
			return;
		}
	}
	else if ( isEmptyAppearance )
	{
		return;
	}
	if ( IsEmpty() )
	{
		return;
	}
	if ( !inv )
	{
		return;
	}
	if ( inv.GetItemCount() == 0 )
	{
		return;
	}
	inv.GetAllItems( items );
	tag = inv.GetItemName( items[ 0 ] );
}

@wrapMethod(W3Herb) function OnSpawned( spawnData : SEntitySpawnData )
{
	if(false) 
	{
		wrappedMethod(spawnData);
	}

	super.OnStreamIn();
	
	if( inv.IsEmpty() )
	{
		AddTimer('respawn_herb', theGame.alchexts.herbctrl.GetSeededRand(4096, 1024), true); growing = true;
	}	theGame.alchexts.herbctrl.OnHerbSpawnRequest(this);

	if(lootInteractionComponent)
		lootInteractionComponent.SetEnabled( inv && !inv.IsEmpty() ) ;
		
	if ( foliageComponent )
	{
		if ( inv.IsEmpty() )
		{
			foliageComponent.SetAndSaveEntry( 'empty' );
		}
		else
		{
			foliageComponent.SetAndSaveEntry( 'full' );
		}
	}
}

@addMethod(W3Herb) timer function respawn_herb(elapsed : float, id : int)
{
	if (inv && inv.IsLootRenewable() )
		theGame.alchexts.herbctrl.OnRespawnTimerElapsed(this);
	else RemoveTimer('respawn_herb');
}

@addMethod(W3Herb) timer function get_area_name(elapsed : float, id : int)
{
	theGame.alchexts.herbctrl.OnGameAreaLoaded(theGame.GetCommonMapManager().GetCurrentArea() );
}