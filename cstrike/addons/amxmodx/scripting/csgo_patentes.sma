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

#define PLUGIN 			"CS:GO Rank Patentes"
#define VERSION 		"0.01"
#define AUTHOR 			"Aoi.Kagase"

#define MAX_LEVEL 		58

#define get_user_lasthit(%1)	get_ent_data(%1, "CBaseMonster","m_LastHitGroup")

enum DATA_PATENTES
{
	RANK_NAME[32],
	RANK_XP,
}

new const PATENTES[][DATA_PATENTES] =
{
	//Rank 		  		XP/Lvl
	{"Silver I",		0		}, // Lvl 0
	{"Silver I",		40		}, // Lvl 1
	{"Silver I",		60		}, // Lvl 2
	{"Silver II",		80		}, // Lvl 3
	{"Silver II", 		100		}, // Lvl 4
	{"Silver II",		120		}, // Lvl 5
	{"Silver III",		140		}, // Lvl 6
	{"Silver III",		160		}, // Lvl 7
	{"Silver III",		180		}, // Lvl 8
	{"Silver IV",		200		}, // Lvl 9
	{"Silver IV",		220		}, // Lvl 10
	{"Silver IV",		240		}, // Lvl 11
	{"Silver V",		260		}, // Lvl 12
	{"Silver V",		280		}, // Lvl 13
	{"Silver V",		300		}, // Lvl 14
	{"Elite Silver",	320		}, // Lvl 15
	{"Elite Silver",	340		}, // Lvl 16
	{"Elite Silver",	350		}, // Lvl 17
	{"Gold I",			500		}, // Lvl 18
	{"Gold I",			550		}, // Lvl 19
	{"Gold I",			600		}, // Lvl 20
	{"Gold I",			650		}, // Lvl 21
	{"Gold I",			700		}, // Lvl 22
	{"Gold II",			800		}, // Lvl 23
	{"Gold II",			900		}, // Lvl 24
	{"Gold II",			1000	}, // Lvl 25
	{"Gold II",			1100	}, // Lvl 26
	{"Gold II",			1200	}, // Lvl 27
	{"Gold III",		1400	}, // Lvl 28
	{"Gold III",		1500	}, // Lvl 29
	{"Gold III",		1600	}, // Lvl 30
	{"Gold IV",			1800	}, // Lvl 31
	{"Gold IV",			2000	}, // Lvl 32
	{"Gold IV",			2200	}, // Lvl 33
	{"AK I",			2600	}, // Lvl 34
	{"AK I",			2900	}, // Lvl 35
	{"AK I",			3200	}, // Lvl 36
	{"AK II",			3500	}, // Lvl 37
	{"AK II",			3800	}, // Lvl 38
	{"AK II",			4100	}, // Lvl 39
	{"AK Crusade",		4500	}, // Lvl 40
	{"AK Crusade",		5000	}, // Lvl 41
	{"AK Crusade",		5500	}, // Lvl 42
	{"Sheriff",			6500	}, // Lvl 43
	{"Sheriff",			7000	}, // Lvl 44
	{"Sheriff",			7500	}, // Lvl 45
	{"Eagle I",			8500	}, // Lvl 46
	{"Eagle I",			9000	}, // Lvl 47
	{"Eagle I",			9500	}, // Lvl 48
	{"Eagle II",		10000	}, // Lvl 49
	{"Eagle II",		11000	}, // Lvl 50
	{"Eagle II",		12000	}, // Lvl 51
	{"Supreme",			15000	}, // Lvl 52
	{"Supreme",			20000	}, // Lvl 53
	{"Supreme",			25000	}, // Lvl 54
	{"Supreme",			30000	}, // Lvl 55
	{"Supreme",			35000	}, // Lvl 56
	{"Global Elite",	50000	}  // Lvl 57
};

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

new g_plData[33][PLAYER_DATA];
new g_cvars		[CVAR_LIST];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_cvars[C_XP_KILL_NORMAL] 			= register_cvar("ptt_xp_kill_normal", 				"2");
	g_cvars[C_XP_KILL_KNIFE] 			= register_cvar("ptt_xp_kill_knife", 				"4");
	g_cvars[C_XP_KILL_HS] 				= register_cvar("ptt_xp_kill_hs", 					"3");
	g_cvars[C_XP_KILL_HE] 				= register_cvar("ptt_xp_kill_hegrenade",			"5");

	RegisterHam(Ham_TakeDamage, "player", "PlayerTakeDamage");
}

public PlayerTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, bit_Damage)
{
	new bool:bHeadShot 	= (get_user_lasthit(iVictim) == HIT_HEAD);
	new bool:bGrenade	= (bit_Damage & DMG_GRENADE) > 0;
	new iWeapon			= (bGrenade ? CSW_HEGRENADE : cs_get_user_weapon(iInflictor));
	new iAddXP 			= 0;

	if (!is_user_connected(iAttacker) || !is_user_connected(iVictim))
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
