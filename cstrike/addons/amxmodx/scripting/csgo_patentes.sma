/* Anti Decompiler :) */
#pragma compress 1
#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <geoip>
#include <sqlx>
#include <hamsandwich>

#define PLUGIN 					"CS:GO Rank Patentes"
#define VERSION 				"0.01"
#define AUTHOR 					"Aoi.Kagase"

#define MAX_LEVEL 				58
#define MAX_QUERY_LENGTH		2048
#define MAX_LENGTH				128
#define MAX_ERR_LENGTH			512

#define get_user_lasthit(%1)	get_ent_data(%1, "CBaseMonster","m_LastHitGroup")

enum _:CVAR_LIST
{
	C_XP_KILL_NORMAL,
	C_XP_KILL_KNIFE,
	C_XP_KILL_HS,
	C_XP_KILL_HE,
};

enum _:PLAYER_DATA
{
	P_LEVEL,
	P_XP,
	P_KILLS,
	P_DEATHS,
};

enum DB_CONFIG
{
	DB_HOST[MAX_LENGTH] = 0,
	DB_USER[MAX_LENGTH],
	DB_PASS[MAX_LENGTH],
	DB_NAME[MAX_LENGTH],
}

enum DATA_PATENTES
{
	RANK_NAME	[32],
	RANK_XP,
	RANK_IMAGE	[32],
}
new g_plData	[33][PLAYER_DATA];
new g_cvars			[CVAR_LIST];

//Database Handles
new Handle:g_dbTaple;
new Handle:g_dbConnect;
//Database setting
new g_dbConfig		[DB_CONFIG];
//update time
new g_dbError		[MAX_ERR_LENGTH];

new const PATENTES[][DATA_PATENTES] =
{
	//Rank 		  		XP/Lvl
	{"Silver I"		,	0		,"http://bit.do/fHF7P"}, // Lvl 0
	{"Silver I"		,	40		,"http://bit.do/fHF7P"}, // Lvl 1
	{"Silver I"		,	60		,"http://bit.do/fHF7P"}, // Lvl 2
	{"Silver II"	,	80		,"http://bit.do/fHF7U"}, // Lvl 3
	{"Silver II"	, 	100		,"http://bit.do/fHF7U"}, // Lvl 4
	{"Silver II"	,	120		,"http://bit.do/fHF7U"}, // Lvl 5
	{"Silver III"	,	140		,"http://bit.do/fHF7Y"}, // Lvl 6
	{"Silver III"	,	160		,"http://bit.do/fHF7Y"}, // Lvl 7
	{"Silver III"	,	180		,"http://bit.do/fHF7Y"}, // Lvl 8
	{"Silver IV"	,	200		,"http://bit.do/fHF75"}, // Lvl 9
	{"Silver IV"	,	220		,"http://bit.do/fHF75"}, // Lvl 10
	{"Silver IV"	,	240		,"http://bit.do/fHF75"}, // Lvl 11
	{"Silver V"		,	260		,"http://bit.do/fHF79"}, // Lvl 12
	{"Silver V"		,	280		,"http://bit.do/fHF79"}, // Lvl 13
	{"Silver V"		,	300		,"http://bit.do/fHF79"}, // Lvl 14
	{"Elite Silver"	,	320		,"http://bit.do/fHF8c"}, // Lvl 15
	{"Elite Silver"	,	340		,"http://bit.do/fHF8c"}, // Lvl 16
	{"Elite Silver"	,	350		,"http://bit.do/fHF8c"}, // Lvl 17
	{"Gold I"		,	500		,"http://bit.do/fHF8e"}, // Lvl 18
	{"Gold I"		,	550		,"http://bit.do/fHF8e"}, // Lvl 19
	{"Gold I"		,	600		,"http://bit.do/fHF8e"}, // Lvl 20
	{"Gold I"		,	650		,"http://bit.do/fHF8e"}, // Lvl 21
	{"Gold I"		,	700		,"http://bit.do/fHF8e"}, // Lvl 22
	{"Gold II"		,	800		,"http://bit.do/fHF8h"}, // Lvl 23
	{"Gold II"		,	900		,"http://bit.do/fHF8h"}, // Lvl 24
	{"Gold II"		,	1000	,"http://bit.do/fHF8h"}, // Lvl 25
	{"Gold II"		,	1100	,"http://bit.do/fHF8h"}, // Lvl 26
	{"Gold II"		,	1200	,"http://bit.do/fHF8h"}, // Lvl 27
	{"Gold III"		,	1400	,"http://bit.do/fHF8t"}, // Lvl 28
	{"Gold III"		,	1500	,"http://bit.do/fHF8t"}, // Lvl 29
	{"Gold III"		,	1600	,"http://bit.do/fHF8t"}, // Lvl 30
	{"Gold IV"		,	1800	,"http://bit.do/fHF8u"}, // Lvl 31
	{"Gold IV"		,	2000	,"http://bit.do/fHF8u"}, // Lvl 32
	{"Gold IV"		,	2200	,"http://bit.do/fHF8u"}, // Lvl 33
	{"AK I"			,	2600	,"http://bit.do/fHF8D"}, // Lvl 34
	{"AK I"			,	2900	,"http://bit.do/fHF8D"}, // Lvl 35
	{"AK I"			,	3200	,"http://bit.do/fHF8D"}, // Lvl 36
	{"AK II"		,	3500	,"http://bit.do/fHF8G"}, // Lvl 37
	{"AK II"		,	3800	,"http://bit.do/fHF8G"}, // Lvl 38
	{"AK II"		,	4100	,"http://bit.do/fHF8G"}, // Lvl 39
	{"AK Crusade"	,	4500	,"http://bit.do/fHF8J"}, // Lvl 40
	{"AK Crusade"	,	5000	,"http://bit.do/fHF8J"}, // Lvl 41
	{"AK Crusade"	,	5500	,"http://bit.do/fHF8J"}, // Lvl 42
	{"Sheriff"		,	6500	,"http://bit.do/fHF8N"}, // Lvl 43
	{"Sheriff"		,	7000	,"http://bit.do/fHF8N"}, // Lvl 44
	{"Sheriff"		,	7500	,"http://bit.do/fHF8N"}, // Lvl 45
	{"Eagle I"		,	8500	,"http://bit.do/fHF8V"}, // Lvl 46
	{"Eagle I"		,	9000	,"http://bit.do/fHF8V"}, // Lvl 47
	{"Eagle I"		,	9500	,"http://bit.do/fHF8V"}, // Lvl 48
	{"Eagle II"		,	10000	,"http://bit.do/fHF8Z"}, // Lvl 49
	{"Eagle II"		,	11000	,"http://bit.do/fHF8Z"}, // Lvl 50
	{"Eagle II"		,	12000	,"http://bit.do/fHF8Z"}, // Lvl 51
	{"Supreme"		,	15000	,"http://bit.do/fHF83"}, // Lvl 52
	{"Supreme"		,	20000	,"http://bit.do/fHF83"}, // Lvl 53
	{"Supreme"		,	25000	,"http://bit.do/fHF83"}, // Lvl 54
	{"Supreme"		,	30000	,"http://bit.do/fHF83"}, // Lvl 55
	{"Supreme"		,	35000	,"http://bit.do/fHF83"}, // Lvl 56
	{"Global Elite"	,	50000	,"http://bit.do/fHF85"}  // Lvl 57
};

//Create Table
init_database()
{
	new sql[MAX_QUERY_LENGTH + 1];
	new Handle:queries[10];
	new len = 0, i = 0;

	// CREATE TABLE user_info.
	len = 0;
	sql = "";
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`t_rank`", g_dbConfig[DB_NAME]);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " (`auth_id`		VARCHAR(%d)			NOT NULL,", MAX_AUTHID_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `latest_ip`	VARCHAR(%d)			NOT NULL,", MAX_IP_LENGTH);
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `online_time`	BIGINT UNSIGNED 	DEFAULT  0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `level`		BIGINT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `xp`			BIGINT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `kills`		BIGINT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `deaths`		BIGINT UNSIGNED 	NOT NULL DEFAULT 0,");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `created_at`	DATETIME			NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "  `updated_at`	DATETIME			NOT NULL DEFAULT CURRENT_TIMESTAMP(),");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " PRIMARY KEY (`auth_id`)");
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, " );");
	queries[i++] = SQL_PrepareQuery(g_dbConnect, sql);
	execute_insert_multi_query(queries ,i);

	return PLUGIN_CONTINUE;
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_cvars[C_XP_KILL_NORMAL] 			= register_cvar("ptt_xp_kill_normal", 				"2");
	g_cvars[C_XP_KILL_KNIFE] 			= register_cvar("ptt_xp_kill_knife", 				"4");
	g_cvars[C_XP_KILL_HS] 				= register_cvar("ptt_xp_kill_hs", 					"3");
	g_cvars[C_XP_KILL_HE] 				= register_cvar("ptt_xp_kill_hegrenade",			"5");

	new iMax = get_plugins_cvarsnum();
	new iTempId, iPcvar, szCvarName[256], szCvarValue[128];
	for(new i; i<iMax; i++)
	{
		get_plugins_cvar(i, szCvarName, charsmax(szCvarName), _, iTempId, iPcvar);
		get_pcvar_string(iPcvar, szCvarValue, charsmax(szCvarValue));
		server_print("%s: %s", szCvarName, szCvarValue);
	}

	RegisterHam(Ham_TakeDamage, "player", "PlayerTakeDamage");


//	set_task(1.0, "plugin_core");
	return PLUGIN_HANDLED_MAIN;
}

public PlayerTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, bit_Damage)
{
	new bool:bHeadShot 	= (get_user_lasthit(iVictim) == HIT_HEAD);
	new bool:bGrenade	= (bit_Damage & DMG_GRENADE) > 0;
	new iWeapon			= (bGrenade ? CSW_HEGRENADE : cs_get_user_weapon(iInflictor));
	new iAddXP 			= 0;

	if (!is_user_connected(iAttacker)
	||	!is_user_connected(iVictim))
		return HAM_IGNORED;

	if (iAttacker == iVictim)
		return HAM_IGNORED;

	if (get_user_health(iVictim) - fDamage > 0.0)
		return HAM_IGNORED;

	if (iWeapon != CSW_KNIFE)
	{
		// HEADSHOT
		if (bHeadShot)
			iAddXP = get_pcvar_num(g_cvars[C_XP_KILL_HS]);
		// Normal
		else
			iAddXP = get_pcvar_num(g_cvars[C_XP_KILL_NORMAL]);

		// HE GRENADE
		if (bGrenade)
			iAddXP = get_pcvar_num(g_cvars[C_XP_KILL_HE]);
	}
	else
		// KNIFE
			iAddXP = get_pcvar_num(g_cvars[C_XP_KILL_KNIFE]);

	g_plData[iAttacker][P_XP] += iAddXP; 

	new iLevel 	= g_plData[iAttacker][P_LEVEL];
	new iXP		= g_plData[iAttacker][P_XP];
	while (iXP > PATENTES[iLevel][RANK_XP])
	{
		if (iLevel < MAX_LEVEL - 1)
			iLevel++;
	}

	if (g_plData[iAttacker][P_LEVEL] < iLevel)
	{
		client_print_color(0, print_chat, "^1Player ^4%n ^1Raised level. Level: ^4%d, !Patent: ^4%s^1.", iAttacker, g_plData[iAttacker][P_LEVEL], PATENTES[g_plData[iAttacker][P_LEVEL]][RANK_NAME]);
		g_plData[iAttacker][P_LEVEL] = iLevel;
	}

	g_plData[iAttacker][P_KILLS] ++;
	g_plData[iVictim][P_DEATHS] ++;


	//xSaveRanks(xKiller);
	//xSaveRanks(xVictim);
	//xSaveTop10Data(xKiller);
	//xSaveTop10Data(xVictim);
	return HAM_IGNORED;
}

//LoadPlugin
public plugin_core()
{
	new error[MAX_ERR_LENGTH + 1];
	new ercode;

	// Get Database Configs.
	get_cvar_string("amx_sql_host", g_dbConfig[DB_HOST], charsmax(g_dbConfig[DB_HOST]));
	get_cvar_string("amx_sql_user", g_dbConfig[DB_USER], charsmax(g_dbConfig[DB_USER]));
	get_cvar_string("amx_sql_pass", g_dbConfig[DB_PASS], charsmax(g_dbConfig[DB_PASS]));
	get_cvar_string("amx_sql_db",	g_dbConfig[DB_NAME], charsmax(g_dbConfig[DB_NAME]));

	g_dbTaple 	= SQL_MakeDbTuple(
		g_dbConfig[DB_HOST],
		g_dbConfig[DB_USER],
		g_dbConfig[DB_PASS],
		g_dbConfig[DB_NAME]
	);
	g_dbConnect = SQL_Connect(g_dbTaple, ercode, error, charsmax(error));
	
	if (g_dbConnect == Empty_Handle)
	    server_print("[CSGO:PATENTES] Error No.%d: %s", ercode, error);
	else 
	{
	  	server_print("[CSGO:PATENTES] Connecting successful.");
	  	init_database();
  	}
	return PLUGIN_CONTINUE;
}

stock execute_insert_multi_query(Handle:query[], count)
{
	if (!g_dbConnect)
		return;

	for(new i = 0; i < count;i++)
	{
		if(!SQL_Execute(query[i]))
		{
			// if there were any problems
			SQL_QueryError(query[i], g_dbError, charsmax(g_dbError));
			set_fail_state(g_dbError);
		}
		SQL_FreeHandle(query[i]);
	}
}

stock mysql_escape_string(dest[],len)
{
    //copy(dest, len, source);
    replace_all(dest,len,"\\","\\\\");
    replace_all(dest,len,"\0","\\0");
    replace_all(dest,len,"\n","\\n");
    replace_all(dest,len,"\r","\\r");
    replace_all(dest,len,"\x1a","\Z");
    replace_all(dest,len,"'","\'");
    replace_all(dest,len,"^"","\^"");
} 

public CreateMotdTop10()
{
	new iLen, iRandomCss;
	new xMotd[1024];

	iRandomCss = random_num(0, 1);

	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<meta charset=UTF-8>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "*{margin:0px;}");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<style>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "body{color:#fff;background:url(^"%s^")}", iRandomCss ? "http://bit.do/fHGu6" : "http://bit.do/fHGu4");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "table{border-collapse:collapse;border: 1px solid #000;text-align:center;}");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "</style>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<body>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<table width=100%% height=100%% border=1>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<tr bgcolor=#4c4c4c style=^"color:#fff;^">");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=5%%>#</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=50%%>NAME</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=15%%>KILLS</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=15%%>DEATHS</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=10%%>XP</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "<th width=20%%>PATENTES</th>");
	iLen += formatex(xMotd[iLen], charsmax(xMotd), "</tr>");

	// new Array:aKey = ArrayCreate(35);
	// new Array:aData = ArrayCreate(128);
///	new Array:aAll = ArrayCreate(xTop15Data);
	
	// fvault_load(db_top10_data, aKey, aData);
	
	// new iArraySize = ArraySize(aKey);
	
///	new Data[xTop15Data];
	
	// new i;
	// for( i = 0; i < iArraySize; i++ )
	// {
	// 	ArrayGetString(aKey, i, Data[szAuthID], sizeof Data[szAuthID]-1);
	// 	ArrayGetString(aData, i, Data[szSkillP_Data], sizeof Data[szSkillP_Data]-1);
		
	// 	ArrayPushArray(aAll, Data);
	// }
	
	// ArraySort(aAll, "xSortData");
	
// 	new szPlayerKills[10];
// 	new szPlayerDeahts[10];
	
// 	new szName[25], xGetDataXps[50];
// 	new iSize = clamp( iArraySize, 0, 10);

// 	new j;
// 	for(j = 0; j < iSize; j++)
// 	{
// 		ArrayGetArray( aAll, j, Data );
		
// //		fvault_get_data( db_top10_names, Data[ szAuthID ], szName, charsmax( szName ) );
		
// 		replace_all(szName, charsmax(szName), "<", "");
// 		replace_all(szName, charsmax(szName), ">", "");
// 		replace_all(szName, charsmax(szName), "%", "");
		
// 		parse(Data[szSkillP_Data],szPlayerKills, charsmax(szPlayerKills), szPlayerDeahts, charsmax(szPlayerDeahts));
		
// //		fvault_get_data(db_patents, Data[ szAuthID ], xGetDataXps, charsmax(xGetDataXps));

// 		new xPlayerXpRank = str_to_num(xGetDataXps);
// 		new xPlayerLvlRank;

// 		if(xPlayerLvlRank <= MAXLEVEL_CSGO-1)
// 		{
// 			xPlayerLvlRank = 0;
			
// 			while(xPlayerXpRank >= xPatents[xPlayerLvlRank+1][xRankXp])
// 			{
// 				xPlayerLvlRank ++;
							
// 				if(xPlayerLvlRank == MAXLEVEL_CSGO-1)
// 					break;
// 			}
// 		}

// 		iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%i<td>%s<td>%s<td>%s<td>%s<td><img src=^"%s^" width=80 hight=30/>", j + 1, szName, xAddPoint(str_to_num(szPlayerKills)),
// 		xAddPoint(str_to_num(szPlayerDeahts)), xAddPoint(xPlayerXpRank), xGetUserImgRank(xPlayerLvlRank));
// 	}
	
	// ArrayDestroy(aKey);
	// ArrayDestroy(aData);
	// ArrayDestroy(aAll);
}