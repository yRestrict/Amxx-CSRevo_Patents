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
	RANK_NAME[32],
	RANK_XP,
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
	// "http://goo.gl/uAez6z",	// Prata 1
	// "http://goo.gl/VG3qn8",	// Prata 2
	// "http://goo.gl/kEZ4We",	// Prata 3
	// "http://goo.gl/mbEVzy",	// Prata 4
	// "http://goo.gl/m2P7ni",	// Prata 5
	// "http://goo.gl/Bh1Z4n",	// Prata Elite
	// "http://goo.gl/djXwQD",	// Ouro 1
	// "http://goo.gl/9LtLSi",	// Ouro 2
	// "http://goo.gl/Cr2Mrp",	// Ouro 3
	// "http://goo.gl/iPP9Eq",	// Ouro 4
	// "http://goo.gl/QRQWY9",	// Ak 1
	// "http://goo.gl/dsbScN",	// Ak 2
	// "http://goo.gl/up6TSS",	// Ak Cruzada
	// "http://goo.gl/cMi8YK",	// Xerife
	// "http://goo.gl/wP4VhK",	// Aguia 1
	// "http://goo.gl/mXXCF2",	// Aguia 2
	// "http://goo.gl/cpLhP7",	// Supremo
	// "http://goo.gl/SijqTy"	// Global Elite
new const PATENTES[][DATA_PATENTES] =
{
	//Rank 		  		XP/Lvl
	{"Silver I"		,		0		,"https://ux.nu/qlBhT"}, // Lvl 0
	{"Silver I"		,		40		}, // Lvl 1
	{"Silver I"		,		60		}, // Lvl 2
	{"Silver II"	,		80		}, // Lvl 3
	{"Silver II"	, 		100		}, // Lvl 4
	{"Silver II"	,		120		}, // Lvl 5
	{"Silver III"	,		140		}, // Lvl 6
	{"Silver III"	,		160		}, // Lvl 7
	{"Silver III"	,		180		}, // Lvl 8
	{"Silver IV"	,		200		}, // Lvl 9
	{"Silver IV"	,		220		}, // Lvl 10
	{"Silver IV"	,		240		}, // Lvl 11
	{"Silver V"		,		260		}, // Lvl 12
	{"Silver V"		,		280		}, // Lvl 13
	{"Silver V"		,		300		}, // Lvl 14
	{"Elite Silver"	,	320		}, // Lvl 15
	{"Elite Silver"	,	340		}, // Lvl 16
	{"Elite Silver"	,	350		}, // Lvl 17
	{"Gold I"		,			500		}, // Lvl 18
	{"Gold I"		,			550		}, // Lvl 19
	{"Gold I"		,			600		}, // Lvl 20
	{"Gold I"		,			650		}, // Lvl 21
	{"Gold I"		,			700		}, // Lvl 22
	{"Gold II"		,			800		}, // Lvl 23
	{"Gold II"		,			900		}, // Lvl 24
	{"Gold II"		,			1000	}, // Lvl 25
	{"Gold II"		,			1100	}, // Lvl 26
	{"Gold II"		,			1200	}, // Lvl 27
	{"Gold III"		,		1400	}, // Lvl 28
	{"Gold III"		,		1500	}, // Lvl 29
	{"Gold III"		,		1600	}, // Lvl 30
	{"Gold IV"		,			1800	}, // Lvl 31
	{"Gold IV"		,			2000	}, // Lvl 32
	{"Gold IV"		,			2200	}, // Lvl 33
	{"AK I"			,			2600	}, // Lvl 34
	{"AK I"			,			2900	}, // Lvl 35
	{"AK I"			,			3200	}, // Lvl 36
	{"AK II"		,			3500	}, // Lvl 37
	{"AK II"		,			3800	}, // Lvl 38
	{"AK II"		,			4100	}, // Lvl 39
	{"AK Crusade"	,		4500	}, // Lvl 40
	{"AK Crusade"	,		5000	}, // Lvl 41
	{"AK Crusade"	,		5500	}, // Lvl 42
	{"Sheriff"		,			6500	}, // Lvl 43
	{"Sheriff"		,			7000	}, // Lvl 44
	{"Sheriff"		,			7500	}, // Lvl 45
	{"Eagle I"		,			8500	}, // Lvl 46
	{"Eagle I"		,			9000	}, // Lvl 47
	{"Eagle I"		,			9500	}, // Lvl 48
	{"Eagle II"		,	10000	}, // Lvl 49
	{"Eagle II"		,	11000	}, // Lvl 50
	{"Eagle II"		,	12000	}, // Lvl 51
	{"Supreme"		,	15000	}, // Lvl 52
	{"Supreme"		,	20000	}, // Lvl 53
	{"Supreme"		,	25000	}, // Lvl 54
	{"Supreme"		,	30000	}, // Lvl 55
	{"Supreme"		,	35000	}, // Lvl 56
	{"Global Elite"	,	50000	}  // Lvl 57
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
	len += formatex(sql[len], MAX_QUERY_LENGTH - len, "CREATE TABLE IF NOT EXISTS `%s`.`t_rank`", g_dbConfig[DB_NAME], g_tblNames[TBL_DATA_USER]);
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

	RegisterHam(Ham_TakeDamage, "player", "PlayerTakeDamage");

	set_task(1.0, "plugin_core");
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


	if (g_plData[iAttacker][P_LEVEL] < MAX_LEVEL - 1)
	{
		if (g_plData[iAttacker][P_XP] >= PATENTES[g_plData[iAttacker][P_LEVEL] + 1][DATA_PATENTES:RANK_XP])
		{
			CheckLevel(iAttacker);
			client_print_color(0, print_chat, "!yPlayer !g%n !yRaised level. Level: !g%d, !Patent: !g%s!y.", iAttacker, g_plData[iAttacker][P_LEVEL], PATENTES[g_plData[iAttacker][P_LEVEL]][RANK_NAME]);
		}
	}
	g_plData[iAttacker][P_KILLS] ++;
	g_plData[iVictim][P_DEATHS] ++;


	//xSaveRanks(xKiller);
	//xSaveRanks(xVictim);
	//xSaveTop10Data(xKiller);
	//xSaveTop10Data(xVictim);
	return HAM_IGNORED;
}

public CheckLevel(id)
{
	if(g_plData[id][P_LEVEL] <= MAX_LEVEL - 1)
	{
		g_plData[id][P_LEVEL] = 0;
						
		while(g_plData[id][P_XP] >= PATENTES[g_plData[id][P_LEVEL] + 1][DATA_PATENTES:RANK_XP])
		{
			g_plData[id][P_LEVEL] ++;
							
			if(g_plData[id][P_LEVEL] == MAX_LEVEL - 1)
				return false;
		}
	}

	return true;
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