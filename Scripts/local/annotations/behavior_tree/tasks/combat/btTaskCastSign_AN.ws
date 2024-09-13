@wrapMethod( CBTTaskCastQuen )function ProcessAction( data : CDamageData )
{
	var npc 	: CNewNPC = GetNPC();
	var params 	: SCustomEffectParams;
	
	if(false) 
	{
		wrappedMethod(data);
	}
	
	if ( data.isActionMelee )
	{
		((CActor)data.attacker).AddEffectDefault( EET_Stagger, GetActor(), "quen", true );
	}
	
}

@addMethod( CBTTaskCastQuenDef ) function OnSpawn( task : IBehTreeTask )
{
	var thisTask : CBTTaskCastQuen;
	
	thisTask = (CBTTaskCastQuen)task;
	thisTask.xmlStaminaCostName = '';
	thisTask.drainStaminaOnUse = false;
}