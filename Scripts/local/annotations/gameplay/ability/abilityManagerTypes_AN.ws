function GetBaseSignSkill(skill : ESkill) : ESkill
{
	switch(skill)
	{
		case S_Magic_1:
		case S_Magic_s01:
			return S_Magic_1;
		case S_Magic_2:
		case S_Magic_s02:
			return S_Magic_2;
		case S_Magic_3:
		case S_Magic_s03:
			return S_Magic_3;
		case S_Magic_4:
		case S_Magic_s04:
			return S_Magic_4;
		case S_Magic_5:
		case S_Magic_s05:
			return S_Magic_5;
		default:
			return S_SUndefined;
	}
}

function SignSkillToSignType(skill : ESkill) : ESignType
{
	switch(skill)
	{
		case S_Magic_1:
		case S_Magic_s01:
			return ST_Aard;
		case S_Magic_2:
		case S_Magic_s02:
			return ST_Igni;
		case S_Magic_3:
		case S_Magic_s03:
			return ST_Yrden;
		case S_Magic_4:
		case S_Magic_s04:
			return ST_Quen;
		case S_Magic_5:
		case S_Magic_s05:
			return ST_Axii;
		default:
			return ST_None;
	}
}