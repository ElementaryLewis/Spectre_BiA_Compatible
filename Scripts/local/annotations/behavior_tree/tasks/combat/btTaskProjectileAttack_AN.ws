@wrapMethod(CBTTaskProjectileAttack) function Initialize()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	if( !useCustomCollisionGroups )
	{
		collisionGroups.PushBack('Ragdoll');
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Water');
		collisionGroups.PushBack('Debris');
		collisionGroups.PushBack('RigidBody');
		collisionGroups.PushBack('Foliage');
		collisionGroups.PushBack('Door');
		collisionGroups.PushBack('Fence');
	}
	else
	{
		if( collideWithRagdoll )
		{
			collisionGroups.PushBack('Ragdoll');
		}
		if( collideWithTerrain )
		{
			collisionGroups.PushBack('Terrain');
		}
		if( collideWithStatic )
		{
			collisionGroups.PushBack('Static');
			collisionGroups.PushBack('Debris');
			collisionGroups.PushBack('RigidBody');
			collisionGroups.PushBack('Foliage');
			collisionGroups.PushBack('Door');
			collisionGroups.PushBack('Fence');
		}
		if( collideWithWater )
		{
			collisionGroups.PushBack('Water');
		}
	}
}