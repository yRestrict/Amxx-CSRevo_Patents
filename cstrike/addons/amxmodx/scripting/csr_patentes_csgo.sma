/* Anti Decompiler :) */
#pragma compress 1
#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
// #include <fvault>
#include <geoip>
#include <hamsandwich>

#define PLUGIN "CS Revo: Patents"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

#define VIP_FLAG ADMIN_RESERVATION
#define FLAG_RELOADPREFIX ADMIN_CFG

#define PREFIXCHAT 		"!g[!tBRA!g]"
#define PREFIXMENUS 	"\r[\wBRA\r]"


#define HUD_HELP		50, 50, 50, 0.02, 0.20, 2, 1.0, 1.5, .fadeintime = 0.09
#define HUD_HELP2		255, 255, 0, 0.02, 0.20, 2, 1.0, 1.5, .fadeintime = 0.09

#define MAX_PREFIXES 	30
#define MAXLEVEL_CSGO 	58
#define MAXLEVEL_CSGO2 	40
#define TASK_HUDRANK 	1234569
#define TASK_MSGWELCOME 877415
#define TASK_TOPSENTRY 	88833

enum xDataPatents
{
	xRankName[32],
	xRankXp
}

enum _:xTop15Data
{
	szAuthID[35],
	szSkillP_Data[128]
}

enum _:CVAR_LIST
{
	C_RANK_STYLE,
	C_TOP10_SAY_GREEN,
	C_TOP10_SAY_AMOUNT,
	C_XP_KILL_NORMAL,
	C_XP_KILL_KNIFE,
	C_XP_KILL_HS,
	C_XP_KILL_HE,
	C_XP_DEAD_MIN,
	C_XP_DEAD_MAX,
	C_XP_KILL_VIP_MORE,
	C_XP_PREFIX_ON,
	C_XP_PREFIX_ADMIN_VIEW_SAY,
	C_XP_PREFIX_BLOCK_CHARS,
	C_XP_NEGATIVE,
	C_WELCOME_MSG,
};

enum _:PLAYER_DATA
{
	PD_LEVEL,
	PD_XP,
	PD_KILLS,
	PD_DEATHS,
	PD_ID,
	PD_POS_RANK_SAVE,
	bool:PD_HUD_INFO,
	bool:PD_VIEW_MSG,
	bool:PD_HUD_GEOIP,
};

new g_cvars			[CVAR_LIST];
new g_playerData[33][PLAYER_DATA];

new text[128], prefix[32], type[2], key[32], length, line, pre_ips_count, pre_names_count, pre_steamids_count, pre_flags_count;
new xMsgSync[1], xPlayerName[32], xGetAuth[64], xMotd[5000], xSayTyped[192],
xSayMessage[192], temp_cvar[2], file_prefixes[128], str_id[16], temp_key[35], temp_prefix[32], CsTeams:xUserTeam, Trie:pre_ips_collect, Trie:pre_names_collect,
Trie:pre_steamids_collect, Trie:pre_flags_collect, Trie:client_prefix, xUserCity[50], xUserRegion[50], xMaxPlayers, xSayTxt;

new const db_top10_data[] 	= "db_top10_data";
new const db_top10_names[] 	= "db_top10_names";
new const db_patents[] 		= "db_patentes";

new const xSayTeamInfoPrefix[2][CsTeams][] =
{
	{ "*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* " },
	{ "", "", "", "" }
};

new const xSayTeamInfoTeamPrefix[2][CsTeams][] =
 {
	{ "(SPEC) ", "*DEAD* (T) ", "*DEAD* (CT) ", "(SPEC) " },
	{ "(SPEC) ", "(T) ", "(CT) ", "(SPEC) " }
};

new const xBlockSymbolsSayPrefix[] = { "/", "!" /*"%","$"*/ };

new const xPatents[][xDataPatents] =
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

new const xPatents2[][xDataPatents] =
{
	{"Recruit", 				0 		},
	{"Soldier I", 				80 		},
	{"Soldier II",				180 	},
	{"Soldier III", 			240 	},
	{"Cable I", 				300 	},
	{"Cable II", 				350 	},
	{"Cable III", 				400 	},
	{"Cable IV", 				500 	},
	{"3rd Sergeant I", 			550 	},
	{"3rd Sergeant II",			650 	},
	{"3rd Sergeant III", 		800 	},
	{"3rd Sergeant IV", 		950 	},
	{"2nd Sergeant I", 			1200 	},
	{"2nd Sergeant II", 		1600 	},
	{"2nd Sergeant III", 		2200 	},
	{"2nd Sergeant IV", 		3200 	},
	{"1st Sergeant I", 			4100	},
	{"1st Sergeant II", 		5500	},
	{"1st Sergeant III", 		7500	},
	{"1st Sergeant IV", 		9500 	},
	{"Sub-Lieutenant", 			10500 	},
	{"Aspiring Officer I", 		12000 	},
	{"Aspiring Officer II", 	14000 	},
	{"Aspiring Officer III", 	16000 	},
	{"Captain I", 				18000 	},
	{"Captain II",				20000 	},
	{"Captain III", 			22000 	},
	{"Captain IV", 				24000 	},
	{"Major I", 				25000 	},
	{"Major II", 				26000 	},
	{"Major III", 				28000 	},
	{"Major IV", 				29000 	},
	{"Colonel I", 				30000 	},
	{"Colonel II", 				32000 	},
	{"Colonel III", 			34000 	},
	{"Gen. Brigadier", 			36000 	},
	{"Gen. Major", 				38000 	},
	{"Gen. Division", 			40000 	},
	{"General", 				42000 	},
	{"Gen. Global", 			50000 	}
};

new const xPatentsImages[][] =
{
	"http://goo.gl/uAez6z",	// Prata 1
	"http://goo.gl/VG3qn8",	// Prata 2
	"http://goo.gl/kEZ4We",	// Prata 3
	"http://goo.gl/mbEVzy",	// Prata 4
	"http://goo.gl/m2P7ni",	// Prata 5
	"http://goo.gl/Bh1Z4n",	// Prata Elite
	"http://goo.gl/djXwQD",	// Ouro 1
	"http://goo.gl/9LtLSi",	// Ouro 2
	"http://goo.gl/Cr2Mrp",	// Ouro 3
	"http://goo.gl/iPP9Eq",	// Ouro 4
	"http://goo.gl/QRQWY9",	// Ak 1
	"http://goo.gl/dsbScN",	// Ak 2
	"http://goo.gl/up6TSS",	// Ak Cruzada
	"http://goo.gl/cMi8YK",	// Xerife
	"http://goo.gl/wP4VhK",	// Aguia 1
	"http://goo.gl/mXXCF2",	// Aguia 2
	"http://goo.gl/cpLhP7",	// Supremo
	"http://goo.gl/SijqTy"	// Global Elite
};

new const xPatents2Images[][] =
{
	"http://goo.gl/2Gk4jq",
	"http://goo.gl/qxLtoi",
	"http://goo.gl/79L31h",
	"http://goo.gl/eoPh1v",
	"http://goo.gl/j9B6Lq",
	"http://goo.gl/ghUjU7",
	"http://goo.gl/JGxhnw",
	"http://goo.gl/3GDGve",
	"http://goo.gl/acg37v",
	"http://goo.gl/rp2zFD",
	"http://goo.gl/SogB8F",
	"http://goo.gl/BVsD39",
	"http://goo.gl/4K7oWx",
	"http://goo.gl/7JGdQd",
	"http://goo.gl/Djhmw9",
	"http://goo.gl/2sNmqa",
	"http://goo.gl/D7tyuz",
	"http://goo.gl/8nZHVG",
	"http://goo.gl/xDQN2Y",
	"http://goo.gl/YLf72R",
	"http://goo.gl/u56j3W",
	"http://goo.gl/27WGWK",
	"http://goo.gl/FqCg2f",
	"http://goo.gl/C6TaLu",
	"http://goo.gl/yrkze5",
	"http://goo.gl/BFkery",
	"http://goo.gl/guEdoZ",
	"http://goo.gl/Y2FBz5",
	"http://goo.gl/NaJjSi",
	"http://goo.gl/nZsG46",
	"http://goo.gl/GHWNi1",
	"http://goo.gl/YJwSnK",
	"http://goo.gl/e1jUNn",
	"http://goo.gl/8yX7dv",
	"http://goo.gl/v6oj3T",
	"http://goo.gl/RNMGmh",
	"http://goo.gl/LnmCWS",
	"http://goo.gl/G95pgb",
	"http://goo.gl/9FPek7",
	"http://goo.gl/VD26pT"
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_cvars[C_RANK_STYLE] 				= register_cvar("csr_ptt_rank_style", 					"1"); // 1= Rank CSGO (ingame) || 2= Rank CSGO Perfil
	g_cvars[C_TOP10_SAY_GREEN] 			= register_cvar("csr_ptt_top10_saygreen", 				"0");
	g_cvars[C_TOP10_SAY_AMOUNT] 		= register_cvar("csr_ptt_top10_say_amount", 			"10");
	g_cvars[C_XP_KILL_NORMAL] 			= register_cvar("csr_ptt_xp_kill_normal", 				"2");
	g_cvars[C_XP_KILL_KNIFE] 			= register_cvar("csr_ptt_xp_kill_knife", 				"4");
	g_cvars[C_XP_KILL_HS] 				= register_cvar("csr_ptt_xp_kill_hs", 					"3");
	g_cvars[C_XP_KILL_HE] 				= register_cvar("csr_ptt_xp_kill_hegrenade",			"5");
	g_cvars[C_XP_DEAD_MIN] 				= register_cvar("csr_ptt_xp_died_min", 					"1");
	g_cvars[C_XP_DEAD_MAX] 				= register_cvar("csr_ptt_xp_died_max", 					"2");
	g_cvars[C_XP_KILL_VIP_MORE] 		= register_cvar("csr_ptt_xp_kill_vip_more", 			"1");
	g_cvars[C_XP_PREFIX_ON] 			= register_cvar("csr_ptt_prefix_on", 					"0");
	g_cvars[C_XP_PREFIX_ADMIN_VIEW_SAY] = register_cvar("csr_ptt_prefix_admin_view_say_flag",	"a");
	g_cvars[C_XP_PREFIX_BLOCK_CHARS] 	= register_cvar("csr_ptt_prefix_block_chars",			"1");
	g_cvars[C_XP_NEGATIVE] 				= register_cvar("csr_ptt_xp_negatives", 				"0");
	g_cvars[C_WELCOME_MSG] 				= register_cvar("csr_ptt_welcome_msg", 					"0");

	register_concmd("amx_reloadprefix", "xLoadPrefix");

	xRegisterSay("hudinfo", 	"xMenuOptHuds");
	xRegisterSay("hudxp", 		"xMenuOptHuds");
	xRegisterSay("hudlocal", 	"xMenuOptHuds");
	xRegisterSay("infolocal", 	"xMenuOptHuds");
	xRegisterSay("huds", 		"xMenuOptHuds");
	xRegisterSay("top10", 		"xMotdTop10");
	xRegisterSay("top15", 		"xMotdTop10");
	xRegisterSay("rank", 		"xSkillTop10");
	xRegisterSay("xp", 			"xMenuPatents");
	xRegisterSay("xps", 		"xMenuPatents");
	xRegisterSay("exp", 		"xMenuPatents");
	xRegisterSay("patente", 	"xMenuPatents");
	xRegisterSay("patentes", 	"xMenuPatents");
	xRegisterSay("offhud", 		"xHudInfoCmd");
	
	register_event("DeathMsg", 	"xDeathMsg", "a");
	register_event("HLTV", 		"xNewRound", "a", "1=0", "2=0");
	register_event("TeamInfo", 	"xTeamInfo", "a");

	//RegisterHam(Ham_Spawn, "player", "xPlayerSpawnPost", 1)

	xSayTxt 	= get_user_msgid("SayText");
	xMaxPlayers = get_maxplayers();
	xMsgSync[0] = CreateHudSyncObj();

	register_clcmd("say", "xHookSay");
	register_clcmd("say_team", "xHookSayTeam");

	xCreateMotdTop10();

	set_task(10.0, "xReloadGambiarra",_,_,_, "b");
}

public xReloadGambiarra()
{
	xLoadPrefix(0);
}

public plugin_cfg()
{
	new configs_dir[64];
	get_configsdir(configs_dir, charsmax(configs_dir));
	formatex(file_prefixes, charsmax(file_prefixes), "%s/admin_prefixes.ini", configs_dir);

	server_cmd("exec %s/csr_patentes.cfg", configs_dir);
	
	pre_ips_collect 		= TrieCreate();
	pre_names_collect 		= TrieCreate();
	pre_steamids_collect 	= TrieCreate();
	pre_flags_collect 		= TrieCreate();
	client_prefix 			= TrieCreate();

	xLoadPrefix(0);

	//pause
	server_cmd("amx_pausecfg pause ^"statsx^"");
}

public xResetVarsFull(id)
{
	g_playerData[id][PD_LEVEL] 			= 0;
	g_playerData[id][PD_XP] 			= 0;
	g_playerData[id][PD_KILLS] 			= 0;
	g_playerData[id][PD_DEATHS] 		= 0;
	g_playerData[id][PD_ID] 			= 0;
	g_playerData[id][PD_POS_RANK_SAVE] 	= 0;
	g_playerData[id][PD_HUD_INFO] 		= false;
	g_playerData[id][PD_VIEW_MSG] 		= false;
	g_playerData[id][PD_HUD_GEOIP] 		= false;
}

public xRegUserLogoutPost(id) xResetVarsFull(id);
public client_disconnected(id) xResetVarsFull(id);

public xRegUserLoginPost(id)
{
	xResetVarsFull(id);

	xLoadRanks(id);
	xLoadKillsDeaths(id);
	xSaveTop10Names(id);
}

public client_putinserver(id)
{
	xResetVarsFull(id);

	xLoadRanks(id);
	xLoadKillsDeaths(id);
	xSaveTop10Names(id);

	set_task(3.0, "xTaskTopsEntry", id+TASK_TOPSENTRY);

	// Prefix
	num_to_str(id, str_id, charsmax(str_id));
	TrieSetString(client_prefix, str_id, "");
	xPutPrefix(id);

	return PLUGIN_CONTINUE;
}

public plugin_natives()
{
	register_native("csr_get_user_rankname", "xNtvGetUserRankName");
	register_native("csr_check_user_level", "xNtvCheckUserLvl", 1);
	register_native("csr_get_user_xp", "xNtvGetUserXP", 1);
	register_native("csr_get_user_pos_top10", "xNtvGetUserPosTop10", 1);
	register_native("csr_get_total_top10", "xNtvGetTotalTop10", 1);

	set_native_filter("xNtvFilter");
}

public xNtvFilter(const name[], index, trap)
{
	if(!trap)
		return PLUGIN_HANDLED;
		
	return PLUGIN_CONTINUE;
}

public xTeamInfo()
{
	new id = read_data(1);

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (!get_pcvar_num(g_cvars[C_WELCOME_MSG]))
		return PLUGIN_CONTINUE;

	// already viewed message.
	if (g_playerData[id][PD_VIEW_MSG])
		return PLUGIN_CONTINUE;

	static szUserTeam[32];
	read_data(2, szUserTeam, charsmax(szUserTeam));

	switch(szUserTeam[0])
	{
		case 'C':
			set_task(2.0, "xShowMsgWelcome", id + TASK_MSGWELCOME);

		case 'T':
			set_task(2.0, "xShowMsgWelcome", id + TASK_MSGWELCOME);
	}
	return PLUGIN_CONTINUE;
}

public xTaskTopsEntry(id)
{
	id -= TASK_TOPSENTRY;

	if(!is_user_connected(id))
	{
		remove_task(id+TASK_TOPSENTRY); 
		return;
	}

	new xMyRank = g_playerData[id][PD_POS_RANK_SAVE];

	static xPName[32];
	get_user_name(id, xPName, charsmax(xPName));
	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	if(xMyRank <= 10)
	{
		xClientPrintColor(0, "%s !yJogador !g%s (TOP%d) !yentrou no servidor.", PREFIXCHAT, xPName, xMyRank);
		client_cmd(0, "speak buttons/blip1");
	}
}

public xShowMsgWelcome(id)
{
	id -= TASK_MSGWELCOME;

	if(is_user_connected(id))
	{
		new xMyRank 	 = g_playerData[id][PD_POS_RANK_SAVE];
		new xMyTotalRank = xNtvGetTotalTop10();

		set_dhudmessage(0, 255, 0, 0.06, 0.33, 2, 0.0, 8.0, 0.08, 0.2);
		show_dhudmessage(id, "Hello %n, Welcome to %n...^nYour rank is: %s for %s, have a great game.", id, 0, xAddPoint(xMyRank), xAddPoint(xMyTotalRank));

		g_playerData[id][PD_VIEW_MSG] = true;
	}

	if (task_exists(id + TASK_MSGWELCOME))
		remove_task(id + TASK_MSGWELCOME); 
}

public xNewRound()
{
	xCreateMotdTop10();
}

public xMenuOptHuds(id)
{
	new xFmtxMenu[300];

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wHud options.", PREFIXMENUS);

	new xNewMenu = menu_create(xFmtxMenu, "_xMenuOptHuds");
	
	if(g_playerData[id][PD_HUD_INFO])
		menu_additem(xNewMenu, "Hide \d[\yXP Hud/Patent/Info\d]");
	else 
		menu_additem(xNewMenu, "Show \d[\yXP Hud/Patent/Info\d]");

	if(g_playerData[id][PD_HUD_GEOIP])
		menu_additem(xNewMenu, "Hide my location so others won't see.");
	else 
		menu_additem(xNewMenu, "Show my location for others to see.");
	
	menu_display(id, xNewMenu, 0);
}

public _xMenuOptHuds(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); 
		return;
	}
	
	switch(item)
	{
		case 0:
		{
			xHudInfoCmd(id);
			xMenuOptHuds(id);
		}

		case 1:
		{
			xHudInfoGeoIpCmd(id);
			xMenuOptHuds(id);
		}
	}
}

public xMenuPatents(id)
{
	new xFmtxMenu[300];

	formatex(xFmtxMenu, charsmax(xFmtxMenu), 
		"%s \wPatents Menu.^n^nXP: %s \y| \wLevel: %d \y| \wPatente: %s", 
		PREFIXMENUS, xAddPoint(xPlayerXP[id]), xPlayerLevel[id], xPatents[xPlayerLevel[id]][xRankName]);
	
	new xNewMenu = menu_create(xFmtxMenu, "_xMenuPatents");
	
	menu_additem(xNewMenu, "Top 10");
	menu_additem(xNewMenu, "See a player's patent");
	menu_additem(xNewMenu, "List of available patents^n");
	menu_additem(xNewMenu, "\yHelp");
	
	menu_display(id, xNewMenu, 0);
}

public _xMenuPatents(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return;
	}
	
	switch(item)
	{
		case 0:
		{
			xMenuSelectTop(id);
		}

		case 1:
		{
			xViewPatentPlayer(id);
		}

		case 2:
		{
			xListPatents(id);
			show_motd(id, xMotd, "PATENT LIST");
			xMenuPatents(id);
		}

		case 3:
		{
			xMotdHelp(id);
			show_motd(id, xMotd, "HELP");
			xMenuPatents(id);
		}
	}
}

public xMotdHelp(id)
{
	new iLen;
	iLen = formatex(xMotd, charsmax(xMotd), "<html><head><meta charset=UTF-8>\
	<style>body{background: #000 url(^"http://i.imgur.com/FDiuoIk.jpg^") no-repeat fixed center;}table, th, td{border: 1px solid black;border-collapse: collapse;}</style></head><body><table width=100%% cellpadding=2 cellspacing=0 border=1><tr align=center bgcolor=#eeeeee><th width=110%%>HELP</tr>");
	
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr align=center style=^"color:#fff;font-size:130%%^">");
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>- First, in order for your data to be saved in the database you need to be sxe or (be logged into the account, if activated!).<br><br> For every Kill you make, you earn <b>[%d XP]</b>, if you die you lose from <b>[%d XP]</b> to <b>[%d XP]</b>.<br><br> Players <b>VIPS</b> win from <b>+%d</b> more XP, at the same time you lose from <b>+%d XP</b>.", get_pcvar_num(xCvarXpKillNormal), get_pcvar_num(xCvarXpDiedMin), get_pcvar_num(xCvarXpDiedMax), get_pcvar_num(xCvarXpKillVipMore), get_pcvar_num(xCvarXpKillVipMore));

	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "</table></body></html>");
}

public xListPatents(id)
{
	new iLen, i;
	iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
	<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/RBEw1K^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
	<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=50%%>RANK<th width=50%%>XP");
	for(i = 0; i < sizeof(xPatentsImages); i++)
	{
		iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%s<td>%s", xGetListRankName(i), xAddPoint(xGetListRankExp(i)));
	}
}

public xViewPatentPlayer(id)
{
	new xFmtxMenu[300];

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wChoose a player to see the patent.", PREFIXMENUS);

	new xNewMenu = menu_create(xFmtxMenu, "_xViewPatentPlayer");
	
	new xPlayers[32], xPnum, xTempId, xSzTempId[10];
	
	get_players(xPlayers, xPnum, "ch");
	
	for(new i; i < xPnum; i++)
	{
		xTempId = xPlayers[i];
		
		if(id != xTempId)
		{
			get_user_name(xTempId, xPlayerName, charsmax(xPlayerName));
			num_to_str(xTempId, xSzTempId, 9);
			menu_additem(xNewMenu, xPlayerName, xSzTempId, 0);
		}
	}
	
	menu_display(id, xNewMenu);
}

public _xViewPatentPlayer(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return;
	}
	
	new data[20], iname[100], access, callback;
	
	menu_item_getinfo(menu, item, access, data, 19, iname, 99, callback);
	
	xPlayerID[id] = str_to_num(data);

	get_user_name(xPlayerID[id], xPlayerName, charsmax(xPlayerName));

	xViewPatentPlayerMotd(id);
	show_motd(id, xMotd, "INFO PLAYER");
	xViewPatentPlayer(id);
}

public xViewPatentPlayerMotd(id)
{
	new xMyPosTop10;
	xMyPosTop10 = xMyPosRankSave[xPlayerID[id]];

	new iLen;
	iLen = formatex(xMotd, charsmax(xMotd), "<head><meta charset=UTF-8>\
	<style>body{background: #000 url(^"http://i.imgur.com/FDiuoIk.jpg^") no-repeat fixed center;}table, th, td{border: 1px solid black;border-collapse: collapse;}</style></head>\
	<body><table width=100%% cellpadding=2 cellspacing=0 border=1>\
	<tr align=center bgcolor=#eeeeee><th width=20%%>POS RANK.<th width=40%%>NOME<th width=10%%>KILLS<th width=10%%>MORTES<th width=15%%>XP<th width=20%%>PATENTE</tr>");

	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr align=center style=^"color:#fff^">");
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xMyPosTop10));
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xPlayerName);
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerKills[xPlayerID[id]]));
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerDeaths[xPlayerID[id]]));
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerXP[xPlayerID[id]]));
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td><img src=^"%s^" width=80 hight=30/>", xGetUserImgRank(xPlayerLevel[xPlayerID[id]]));
}

public xMenuSelectTop(id)
{
	new xFmtxMenu[300];

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wWhat do you want to see?", PREFIXMENUS);

	new xNewMenu = menu_create(xFmtxMenu, "_xMenuSelectTop");
	
	menu_additem(xNewMenu, "Top 10");
	menu_additem(xNewMenu, "See my position");
	
	menu_display(id, xNewMenu, 0);
}

public _xMenuSelectTop(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return;
	}
	
	switch(item)
	{
		case 0:
		{
			xMotdTop10(id);
			xMenuSelectTop(id);
		}

		case 1:
		{
			xSkillTop10(id);
			xMenuSelectTop(id);
		}
	}
}

public xSkillTop10(id)
{
	new xMyPosTop10;
	xMyPosTop10 = xMyPosRankSave[id];

	xClientPrintColor(id, "%s !yYour position is: !g%s !yof !g%s !ywith !g%s !ykills and !g%s !ydeaths.", PREFIXCHAT, xAddPoint(xMyPosTop10), xAddPoint(xNtvGetTotalTop10()), xAddPoint(xPlayerKills[id]), xAddPoint(xPlayerDeaths[id]));
}

public xLoadPrefix(id)
{
	if(!(get_user_flags(id) & FLAG_RELOADPREFIX))
		return PLUGIN_HANDLED;

	TrieClear(pre_ips_collect); TrieClear(pre_names_collect); TrieClear(pre_steamids_collect); TrieClear(pre_flags_collect);

	line = 0, length = 0, pre_flags_count = 0, pre_ips_count = 0, pre_names_count = 0;

	if(!file_exists(file_prefixes)) set_fail_state("Archive admin_prefix.ini not found.");

	while(read_file(file_prefixes, line++ , text, charsmax(text), length) && (pre_ips_count + pre_names_count + pre_steamids_count + pre_flags_count) <= MAX_PREFIXES)
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
			continue;

		parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix));
		trim(prefix);

		if(!type[0] || !prefix[0] || !key[0])
			continue;

		replace_all(prefix, charsmax(prefix), "!g", "^x04");
		replace_all(prefix, charsmax(prefix), "!t", "^x03");
		replace_all(prefix, charsmax(prefix), "!y", "^x01");

		switch(type[0])
		{
			case 'f':
			{
				pre_flags_count++;
				TrieSetString(pre_flags_collect, key, prefix);
				
			}
			case 'i':
			{
				pre_ips_count++;
				TrieSetString(pre_ips_collect, key, prefix);
				
			}
			case 's':
			{
				pre_steamids_count++;
				TrieSetString(pre_steamids_collect, key, prefix);
				
			}
			case 'n':
			{
				pre_names_count++;
				TrieSetString(pre_names_collect, key, prefix);
				
			}
			default:
			{
				continue;
			}
		}
	}

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		num_to_str(i, str_id, charsmax(str_id));
		TrieDeleteKey(client_prefix, str_id);
		xPutPrefix(i);
	}
	
	if(id)
		console_print(id, "Prefix reloaded :)");
	
	return PLUGIN_HANDLED;
}

public xHookSay(id)
{
	read_args(xSayTyped, charsmax(xSayTyped)); 
	remove_quotes(xSayTyped); 

	trim(xSayTyped);

	if(equal(xSayTyped, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN;

	num_to_str(id, str_id, charsmax(str_id));

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 2) || get_pcvar_num(xCvarPrefixBlockChars) == 3)
	{
		if(check_say_characters(xSayTyped))
			return PLUGIN_HANDLED_MAIN;
	}

	get_user_name(id, xPlayerName, charsmax(xPlayerName));

	xUserTeam = cs_get_user_team(id);

	new xMyRankName[32];
	formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents[xPlayerLevel[id]][xRankName]);
	
	if(temp_prefix[0])
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xPlayerName, xSayTyped);
	else
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped);

	get_pcvar_string(xCvarPrefixAdminViewSayFlag, temp_cvar, charsmax(temp_cvar));

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue;

		if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
		{
			xPrefixSendMessage(xSayMessage, id, i);
		}
	}

	return PLUGIN_HANDLED_MAIN;
}

public xHookSayTeam(id)
{
	read_args(xSayTyped, charsmax(xSayTyped)); remove_quotes(xSayTyped); trim(xSayTyped);
	
	if(equal(xSayTyped, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN;

	num_to_str(id, str_id, charsmax(str_id));

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 2) || get_pcvar_num(xCvarPrefixBlockChars) == 3)
	{
		if(check_say_characters(xSayTyped))
			return PLUGIN_HANDLED_MAIN;
	}

	get_user_name(id, xPlayerName, charsmax(xPlayerName));

	xUserTeam = cs_get_user_team(id);

	new xMyRankName[32];
	formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents[xPlayerLevel[id]][xRankName]);

	if(temp_prefix[0])
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xPlayerName, xSayTyped);
	else
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped);
	

	get_pcvar_string(xCvarPrefixAdminViewSayFlag, temp_cvar, charsmax(temp_cvar));

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue;

		if(get_user_team(id) == get_user_team(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
		{
			if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
			{
				xPrefixSendMessage(xSayMessage, id, i);
			}
		}
	}

	return PLUGIN_HANDLED_MAIN;
}

public xPutPrefix(id)
{
	num_to_str(id, str_id, charsmax(str_id));
	TrieSetString(client_prefix, str_id, "");

	new sflags[32], temp_flag[2];
	get_flags(get_user_flags(id), sflags, charsmax(sflags));

	for(new i = 0; i <= charsmax(sflags); i++)
	{
		formatex(temp_flag, charsmax(temp_flag), "%c", sflags[i]);

		if(TrieGetString(pre_flags_collect, temp_flag, temp_prefix, charsmax(temp_prefix)))
		{
			TrieSetString(client_prefix, str_id, temp_prefix);
		}
	}

	get_user_ip(id, temp_key, charsmax(temp_key), 1);

	if(TrieGetString(pre_ips_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix);
	}

	get_user_authid(id, temp_key, charsmax(temp_key));

	if(TrieGetString(pre_steamids_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix);
	}

	get_user_name(id, temp_key, charsmax(temp_key));

	if(TrieGetString(pre_names_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix);
	}

	return PLUGIN_HANDLED;
}

public xPrefixSendMessage(const message[], const id, const i)
{
	message_begin(MSG_ONE, xSayTxt, {0, 0, 0}, i);
	write_byte(id);
	write_string(message);
	message_end();
}

bool:check_say_characters(const check_message[])
{
	for(new i = 0; i < charsmax(xBlockSymbolsSayPrefix); i++)
	{
		if(check_message[0] == xBlockSymbolsSayPrefix[i])
		{
			return true;
		}
	}
	return false;
}

public xNtvGetUserPosTop10(id)
{
	new Array:aKey = ArrayCreate(35);
	new Array:aData = ArrayCreate(128);
	new Array:aAll = ArrayCreate(xTop15Data);
	
	// fvault_load(db_top10_data, aKey, aData);
	
	new iArraySize = ArraySize(aKey);
	
	new Data[xTop15Data];
	
	new i;
	for(i = 0; i < iArraySize; i++)
	{
		ArrayGetString(aKey, i, Data[szAuthID ], sizeof Data[szAuthID]-1);
		ArrayGetString(aData, i, Data[szSkillP_Data], sizeof Data[szSkillP_Data]-1);
		
		ArrayPushArray(aAll, Data);
	}
	
	ArraySort(aAll, "xSortData");
	
	new szAuthIdFromArray[64];
	
	new j;
	for(j = 0; j < iArraySize; j++ )
	{
		ArrayGetString(aAll, j, szAuthIdFromArray, charsmax(szAuthIdFromArray));
		get_user_authid(id, xGetAuth, charsmax(xGetAuth));

		if(equal(szAuthIdFromArray, xGetAuth)) break;
		
	}
	
	ArrayDestroy(aKey);
	ArrayDestroy(aData);
	ArrayDestroy(aAll);

	return j + 1;
}

public xNtvGetTotalTop10()
{
	new Array:aKey = ArrayCreate(64);
	new Array:aData = ArrayCreate(512);
		
	new xTotalVaults; // = fvault_load(db_top10_data, aKey, aData);

	ArrayDestroy(aKey);
	ArrayDestroy(aData);

	return xTotalVaults;
}

public xNtvGetUserXP(id)
{
	if(!is_user_connected(id))
		return false;

	return xPlayerXP[id];
}

public xNtvCheckUserLvl(id)
{
	if(!is_user_connected(id))
		return false;
	
	return xCheckLevel(id);
}

public xNtvGetUserRankName(xPluginId, xNumParams)
{
	new id = get_param(1);
	if(!is_user_connected(id))
		return false;

	new xUserName[64];
	formatex(xUserName, charsmax(xUserName), "%s", xPatents[xPlayerLevel[id]][xRankName]);
	
	new len = get_param(3);
	set_string(2, xUserName, len);

	return true;
}

public xDeathMsg()
{
	new xAddXp;
	new xKiller = read_data(1);
	new xVictim = read_data(2);
	new xHeadShot = read_data(3);

	new xWeapon[24];
	read_data(4, xWeapon, charsmax(xWeapon));

	if(xKiller != xVictim && is_user_connected(xKiller) && is_user_connected(xVictim))
	{
		new xDiedXp = random_num(get_pcvar_num(xCvarXpDiedMin), get_pcvar_num(xCvarXpDiedMax));

		if(xHeadShot == 1 && !(xWeapon[0] == 'k') && xKiller != xVictim) // Hs
			xAddXp = get_pcvar_num(xCvarXpKillHs);
		else xAddXp = get_pcvar_num(xCvarXpKillNormal) ;// Normal

		if(xWeapon[1] == 'r' && xKiller != xVictim) // He Grenade
			xAddXp = get_pcvar_num(xCvarXpKillHeGrenade);

		if(xWeapon[0] == 'k') // Knife
			xAddXp = get_pcvar_num(xCvarXpKillKnife);

		if(get_user_flags(xKiller) & VIP_FLAG)
		{
			xPlayerXP[xKiller] += xAddXp + get_pcvar_num(xCvarXpKillVipMore);
			if(get_pcvar_num(xCvarXpNegative)) xPlayerXP[xVictim] -= xDiedXp - get_pcvar_num(xCvarXpKillVipMore);
		}
		else
		{
			xPlayerXP[xKiller] += xAddXp;
			if(get_pcvar_num(xCvarXpNegative)) xPlayerXP[xVictim] -= xDiedXp;
		}

		if(xPlayerLevel[xKiller] < MAXLEVEL_CSGO-1)
		{
			if(xPlayerXP[xKiller] >= xPatents[xPlayerLevel[xKiller]+1][xRankXp])
			{
				xCheckLevel(xKiller);

				get_user_name(xKiller, xPlayerName, charsmax(xPlayerName));
							
				//client_cmd(0, "speak ambience/3dmeagle")
				xClientPrintColor(0, "%s !yPlayer !g%s !yRaised level. Level: !g%d, !Patent: !g%s!y.", PREFIXCHAT, xPlayerName, xPlayerLevel[xKiller], xPatents[xPlayerLevel[xKiller]][xRankName]);
			}
		}

		xPlayerKills[xKiller] ++;
		xPlayerDeaths[xVictim] ++;

		xSaveRanks(xKiller);
		xSaveRanks(xVictim);
		xSaveTop10Data(xKiller);
		xSaveTop10Data(xVictim);
	}
}

public xMotdTop10(id)
{
	xCreateMotdTop10();
	show_motd(id, xMotd, "TOP 10");
}

public xCreateMotdTop10()
{
	new iLen, xRandomCss;

	xRandomCss = random_num(0, 1);

	switch(xRandomCss)
	{
		case 0:
		{
			iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
			<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/RBEw1K^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
			<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=5%%>POS.<th width=50%%>NOME<th width=15%%>KILLS\
			<th width=15%%>MORTES<th width=10%%>XP<th width=20%%>PATENTE");
		}

		case 1:
		{
			iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
			<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/gBqWyy^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
			<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=5%%>POS.<th width=50%%>NOME<th width=15%%>KILLS\
			<th width=15%%>MORTES<th width=10%%>XP<th width=20%%>PATENTE");
		}
	}
	
	new Array:aKey = ArrayCreate(35);
	new Array:aData = ArrayCreate(128);
	new Array:aAll = ArrayCreate(xTop15Data);
	
	// fvault_load(db_top10_data, aKey, aData);
	
	new iArraySize = ArraySize(aKey);
	
	new Data[xTop15Data];
	
	new i;
	for( i = 0; i < iArraySize; i++ )
	{
		ArrayGetString(aKey, i, Data[szAuthID], sizeof Data[szAuthID]-1);
		ArrayGetString(aData, i, Data[szSkillP_Data], sizeof Data[szSkillP_Data]-1);
		
		ArrayPushArray(aAll, Data);
	}
	
	ArraySort(aAll, "xSortData");
	
	new szPlayerKills[10];
	new szPlayerDeahts[10];
	
	new szName[25], xGetDataXps[50];
	new iSize = clamp( iArraySize, 0, 10);

	new j;
	for(j = 0; j < iSize; j++)
	{
		ArrayGetArray( aAll, j, Data );
		
//		fvault_get_data( db_top10_names, Data[ szAuthID ], szName, charsmax( szName ) );
		
		replace_all(szName, charsmax(szName), "<", "");
		replace_all(szName, charsmax(szName), ">", "");
		replace_all(szName, charsmax(szName), "%", "");
		
		parse(Data[szSkillP_Data],szPlayerKills, charsmax(szPlayerKills), szPlayerDeahts, charsmax(szPlayerDeahts));
		
//		fvault_get_data(db_patents, Data[ szAuthID ], xGetDataXps, charsmax(xGetDataXps));

		new xPlayerXpRank = str_to_num(xGetDataXps);
		new xPlayerLvlRank;

		if(xPlayerLvlRank <= MAXLEVEL_CSGO-1)
		{
			xPlayerLvlRank = 0;
			
			while(xPlayerXpRank >= xPatents[xPlayerLvlRank+1][xRankXp])
			{
				xPlayerLvlRank ++;
							
				if(xPlayerLvlRank == MAXLEVEL_CSGO-1)
					break;
			}
		}

		iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%i<td>%s<td>%s<td>%s<td>%s<td><img src=^"%s^" width=80 hight=30/>", j + 1, szName, xAddPoint(str_to_num(szPlayerKills)),
		xAddPoint(str_to_num(szPlayerDeahts)), xAddPoint(xPlayerXpRank), xGetUserImgRank(xPlayerLvlRank));
	}
	
	ArrayDestroy(aKey);
	ArrayDestroy(aData);
	ArrayDestroy(aAll);
}

public xSortData(Array:aArray, iItem1, iItem2, iData[], iDataSize)
{	
	new Data1[ xTop15Data ];
	new Data2[ xTop15Data ];
	
	ArrayGetArray( aArray, iItem1, Data1 );
	ArrayGetArray( aArray, iItem2, Data2 );
	
	new szPlayerKills[7], szPlayerDeahts[7];
	parse(Data1[ szSkillP_Data ], szPlayerKills, charsmax( szPlayerKills ), szPlayerDeahts, charsmax( szPlayerDeahts ));
	new Count1_1 = str_to_num(szPlayerKills);
	new Count1_2 = str_to_num(szPlayerDeahts);

	new Count1_f;
	if(Count1_2 >= Count1_1) Count1_f = Count1_1;
	else Count1_f = ((Count1_1-Count1_2));

	new szPlayerKills2[7], szPlayerDeahts2[7];
	parse(Data2[ szSkillP_Data ], szPlayerKills2, charsmax( szPlayerKills2 ), szPlayerDeahts2, charsmax( szPlayerDeahts2 ));
	new Count2_1 = str_to_num(szPlayerKills2);
	new Count2_2 = str_to_num(szPlayerDeahts2);

	new Count2_f;
	if(Count2_2 >= Count2_1) Count1_f = Count2_1;
	else Count2_f = ((Count2_1-Count2_2));
	
	new iCount1 = Count1_f;
	new iCount2 = Count2_f;
	
	return (iCount1 > iCount2) ? -1 : ((iCount1 < iCount2) ? 1 : 0);
}

public xCheckLevel(id)
{
	if(xPlayerLevel[id] <= MAXLEVEL_CSGO-1)
	{
		xPlayerLevel[id] = 0;
						
		while(xPlayerXP[id] >= xPatents[xPlayerLevel[id]+1][xRankXp])
		{
			xPlayerLevel[id]++;
							
			if(xPlayerLevel[id] == MAXLEVEL_CSGO-1)
				return false;
		}
	}

	return true;
}

public xSaveRanks(id)
{
	new xData[30];

	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED;

	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	num_to_str(xPlayerXP[id], xData, charsmax(xData));
	// fvault_set_data(db_patents, xGetAuth, xData);

	return PLUGIN_HANDLED;
}

public xSaveTop10Data(id)
{
	new xData[128];

	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED;

	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	formatex(xData, charsmax(xData), "%i %i", xPlayerKills[id], xPlayerDeaths[id]);
	// fvault_set_data(db_top10_data, xGetAuth, xData);

	return PLUGIN_HANDLED;
}

public xSaveTop10Names(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED;
		
	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	get_user_name(id, xPlayerName, charsmax(xPlayerName));
	// fvault_set_data(db_top10_names, xGetAuth, xPlayerName);

	return PLUGIN_HANDLED;
}

public xLoadKillsDeaths(id)
{
	new xData[128], xMyKills[50], xMyDeaths[50];
	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	// if(fvault_get_data(db_top10_data, xGetAuth, xData, charsmax(xData)))
	{
		parse(xData, xMyKills, charsmax(xMyKills), xMyDeaths, charsmax(xMyDeaths));
				
		xPlayerKills[id] = str_to_num(xMyKills);
		xPlayerDeaths[id] = str_to_num(xMyDeaths);
	}
}

public xLoadRanks(id)
{
	xPlayerViewMsg[id] = false;
	xPlayerHudInfo[id] = true;
	xPlayerHudGeoIp[id] = false;

	new xData[30];
	get_user_authid(id, xGetAuth, charsmax(xGetAuth));

	// if(fvault_get_data(db_patents, xGetAuth, xData, charsmax(xData)))
		xPlayerXP[id] = str_to_num(xData);

	xCheckLevel(id);

	set_task(1.0, "xHudInfo", id+TASK_HUDRANK, _, _, "b");

	g_playerData[id][PD_POS_RANK_SAVE] = xNtvGetUserPosTop10(id);
}

public xMsgNoSave(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id); return;
	}

	xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT);
	xClientPrintColor(id, "%s !tA.T.E.N.Ç.Ã.O !ySeus dados como !gRank, Patente !yetc, não estão sendo salvos. Entre com !gsXe !ypara salva-los.", PREFIXCHAT);
	xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT);
	client_cmd(id, "speak buttons/blip2");
}

public xMsgLoginInAccount(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id); 
		return;
	}
}

public client_infochanged(id)
{
	if(!is_user_connected(id))
		return FMRES_IGNORED;

	new xOldName[32];//, xData[128]

	get_user_info(id, "name", xPlayerName, charsmax(xPlayerName));
	get_user_name(id, xOldName, charsmax(xOldName));

	if(!equal(xPlayerName, xOldName))
	{
		num_to_str(id, str_id, charsmax(str_id));
		TrieSetString(client_prefix, str_id, "");
		set_task(0.5, "xPutPrefix", id);

		return FMRES_HANDLED;
	}

	xSaveTop10Names(id);

	return FMRES_IGNORED;
}

public xHudInfo(id)
{
	id -= TASK_HUDRANK;

	if(!is_user_connected(id))
	{
		remove_task(id+TASK_HUDRANK); return;
	}
	
	if(is_user_alive(id) && xPlayerHudInfo[id])
	{
		set_hudmessage(HUD_HELP);

		if(xPlayerLevel[id] < MAXLEVEL_CSGO-1)
		{
			if(equali(xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName]))
				ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: Suba mais seu level.^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]));
			else
				ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: %s^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]));
		}
		else
		{
			ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Level: %d^n• Exp: %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]));
		}
	}
	else if(xPlayerHudInfo[id])
	{
		static id2;
		id2 = pev(id, pev_iuser2);

		if(!is_user_alive(id2)) return;

		static xPlayerIp[20];
		get_user_ip(id2, xPlayerIp, charsmax(xPlayerIp), 1);

		geoip_city(xPlayerIp, xUserCity, charsmax(xUserCity));
		geoip_region_name(xPlayerIp, xUserRegion, charsmax(xUserRegion));
		get_user_name(id2, xPlayerName, charsmax(xPlayerName));

		set_hudmessage(0, 255, 0, 0.02, 0.20, 0, 0.01, 1.0, 1.0, 1.0);

		if(!xPlayerHudGeoIp[id2] || equal(xUserCity, "") || equal(xUserRegion, ""))
			ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s", xPlayerName, xPatents[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]));
		else 
			ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s^n• Cidade: %s^n• Estado: %s", xPlayerName, xPatents[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]), xUserCity, xUserRegion);
	}
}

public xHudInfoGeoIpCmd(id)
{
	if(!xPlayerHudGeoIp[id])
	{
		xPlayerHudGeoIp[id] = true;
		
		xClientPrintColor(id, "%s !yVoce !tAtivou !ya hudinfo de localização.", PREFIXCHAT);
	}
	else
	{
		xPlayerHudGeoIp[id] = false;
		
		xClientPrintColor(id, "%s !yVoce !tDesativou !ya hudinfo de localização.", PREFIXCHAT);
	}
}

public xHudInfoCmd(id)
{
	if(!xPlayerHudInfo[id])
	{
		xPlayerHudInfo[id] = true;
		
		xClientPrintColor(id, "%s !yVoce !gAtivou !ya hudinfo.", PREFIXCHAT);
	
		set_task(1.0, "xHudInfo", id+TASK_HUDRANK, _, _, "b");
	}
	else
	{
		xPlayerHudInfo[id] = false;
		
		xClientPrintColor(id, "%s !yVoce !gDesativou !ya hudinfo.", PREFIXCHAT);
		
		remove_task(id+TASK_HUDRANK);
	}
}

stock xGetListRankExp(num)
{
	switch(num)
	{
		case 0: return xPatents[2][xRankXp];
		case 1: return xPatents[5][xRankXp];
		case 2: return xPatents[8][xRankXp];
		case 3: return xPatents[11][xRankXp];
		case 4: return xPatents[14][xRankXp];
		case 5: return xPatents[17][xRankXp];
		case 6: return xPatents[22][xRankXp];
		case 7: return xPatents[27][xRankXp];
		case 8: return xPatents[30][xRankXp];
		case 9: return xPatents[33][xRankXp];
		case 10: return xPatents[36][xRankXp];
		case 11: return xPatents[39][xRankXp];
		case 12: return xPatents[42][xRankXp];
		case 13: return xPatents[45][xRankXp];
		case 14: return xPatents[48][xRankXp];
		case 15: return xPatents[51][xRankXp];
		case 16: return xPatents[56][xRankXp];
		case 17: return xPatents[57][xRankXp];
	
		default: return xPatents[2][xRankXp];
	}

	return xPatents[2][xRankXp];
}

stock xGetListRankName(num)
{
	switch(num)
	{
		case 0: return xPatents[2];
		case 1: return xPatents[5];
		case 2: return xPatents[8];
		case 3: return xPatents[11];
		case 4: return xPatents[14];
		case 5: return xPatents[17];
		case 6: return xPatents[22];
		case 7: return xPatents[27];
		case 8: return xPatents[30];
		case 9: return xPatents[33];
		case 10: return xPatents[36];
		case 11: return xPatents[39];
		case 12: return xPatents[42];
		case 13: return xPatents[45];
		case 14: return xPatents[48];
		case 15: return xPatents[51];
		case 16: return xPatents[56];
		case 17: return xPatents[57];
	
		default: return xPatents[2];
	}

	return xPatents[2];
}

stock xGetUserImgRank(num)
{
	switch(num)
	{
		case 0..2: return xPatentsImages[0];
		case 3..5: return xPatentsImages[1];
		case 6..8: return xPatentsImages[2];
		case 9..11: return xPatentsImages[3];
		case 12..14: return xPatentsImages[4];
		case 15..17: return xPatentsImages[5];
		case 18..22: return xPatentsImages[6];
		case 23..27: return xPatentsImages[7];
		case 28..30: return xPatentsImages[8];
		case 31..33: return xPatentsImages[9];
		case 34..36: return xPatentsImages[10];
		case 37..39: return xPatentsImages[11];
		case 40..42: return xPatentsImages[12];
		case 43..45: return xPatentsImages[13];
		case 46..48: return xPatentsImages[14];
		case 49..51: return xPatentsImages[15];
		case 52..56: return xPatentsImages[16];
		case 57: return xPatentsImages[17];

		default: return xPatentsImages[0];
	}

	return xPatentsImages[0];
}

stock xAddPoint(number)
{
	new count, i, str[29], str2[35], len;
	num_to_str(number, str, charsmax(str));
	len = strlen(str);

	for (i = 0; i < len; i++)
	{
		if(i != 0 && ((len - i) %3 == 0))
		{
			add(str2, charsmax(str2), ".", 1);
			count++;
			add(str2[i+count], 1, str[i], 1);
		}
		else add(str2[i+count], 1, str[i], 1);
	}
	
	return str2;
}

stock xClientPrintColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!t2", "^0");
	
	if (id) players[0] = id; else get_players(players, count, "ch");

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}
	}
}

stock xRegisterSay(szsay[], szfunction[])
{
	new sztemp[64];
	formatex(sztemp, 63 , "say /%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say .%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say_team /%s", szsay);
	register_clcmd(sztemp, szfunction );
	
	formatex(sztemp, 63 , "say_team .%s", szsay);
	register_clcmd(sztemp, szfunction);
}
