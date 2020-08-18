/* Anti Decompiler :) */
#pragma compress 1

#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <cstrike>
#include <fakemeta>
#include <fvault>
#include <geoip>
#include <hamsandwich>

#define PLUGIN "CS Revo: Patents"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

#define VIP_FLAG ADMIN_RESERVATION
#define FLAG_RELOADPREFIX ADMIN_CFG

#define PREFIXCHAT "!g[!tBRA!g]"
#define PREFIXMENUS "\r[\wBRA\r]"


#define HUD_HELP					50, 50, 50, 0.02, 0.20, 2, 1.0, 1.5, .fadeintime = 0.09
#define HUD_HELP2					255, 255, 0, 0.02, 0.20, 2, 1.0, 1.5, .fadeintime = 0.09

#define MAX_PREFIXES 30
#define MAXLEVEL_CSGO 58
#define MAXLEVEL_CSGO2 40
#define TASK_HUDRANK 1234569
#define TASK_MSGWELCOME 877415
#define TASK_TOPSENTRY 88833

native reg_get_user_logged(id)
native reg_get_user_account(id, account[], len)
forward reg_user_login_post(id)
forward reg_user_logout_post(id)

#define xRegGetUserLogged(%1) reg_get_user_logged(%1)
#define xRegGetUserAccount(%1,%2,%3) reg_get_user_account(%1,%2,%3)
#define xRegUserLoginPost(%1) reg_user_login_post(%1)
#define xRegUserLogoutPost(%1) reg_user_logout_post(%1)

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

new text[128], prefix[32], type[2], key[32], length, line, pre_ips_count, pre_names_count, pre_steamids_count, pre_flags_count
new xPlayerID[33], xMsgSync[1], xPlayerXP[33], xPlayerLevel[33], xPlayerName[32], xPlayerHudInfo[33], xGetAuth[64], xPlayerKills[33], xPlayerDeaths[33], xMotd[5000], xSayTyped[192],
xSayMessage[192], xPlayerViewMsg[33], temp_cvar[2], file_prefixes[128], str_id[16], temp_key[35], temp_prefix[32], CsTeams:xUserTeam, Trie:pre_ips_collect, Trie:pre_names_collect,
Trie:pre_steamids_collect, Trie:pre_flags_collect, Trie:client_prefix, xUserCity[50], xUserRegion[50], xMaxPlayers, xSayTxt, xCvarSaveType, xCvarXpKillNormal, xCvarXpKillKnife, xCvarXpKillHs,
xCvarXpDiedMin, xCvarXpDiedMax, xCvarXpKillHeGrenade, xCvarXpKillVipMore, xCvarPrefixOn, xCvarPrefixAdminViewSayFlag, xCvarPrefixBlockChars, xCvarXpNegative, xCvarWelcomeMsg, xCvarPttRankStyle,
xMyPosRankSave[33], xCvarTop10SayGreen, xCvarTop10SayAmount, xPlayerHudGeoIp[33]

new const db_top10_data[] = "db_top10_data"
new const db_top10_names[] = "db_top10_nomes"
new const db_patents[] = "db_patentes"

new const xSayTeamInfoPrefix[2][CsTeams][] =
{
	{ "*SPEC* ", "*MORTO* ", "*MORTO* ", "*SPEC* " },
	{ "", "", "", "" }
}

new const xSayTeamInfoTeamPrefix[2][CsTeams][] =
 {
	{ "(SPEC) ", "*MORTO* (T) ", "*MORTO* (CT) ", "(SPEC) " },
	{ "(SPEC) ", "(T) ", "(CT) ", "(SPEC) " }
}

new const xBlockSymbolsSayPrefix[] = { "/", "!" /*"%","$"*/ }

new const xPatents[][xDataPatents] =
{
		//Rank 		  XP/Lvl
	{	"Prata I",		0		}, // Lvl 0
	{	"Prata I",		40		}, // Lvl 1
	{	"Prata I",		60		}, // Lvl 2
	{	"Prata II",		80		}, // Lvl 3
	{	"Prata II", 		100		}, // Lvl 4
	{	"Prata II",		120		}, // Lvl 5
	{	"Prata III",		140		}, // Lvl 6
	{	"Prata III",		160		}, // Lvl 7
	{	"Prata III",		180		}, // Lvl 8
	{	"Prata IV",		200		}, // Lvl 9
	{	"Prata IV",		220		}, // Lvl 10
	{	"Prata IV",		240		}, // Lvl 11
	{	"Prata V",		260		}, // Lvl 12
	{	"Prata V",		280		}, // Lvl 13
	{	"Prata V",		300		}, // Lvl 14
	{	"Prata Elite",	320		}, // Lvl 15
	{	"Prata Elite",	340		}, // Lvl 16
	{	"Prata Elite",	350		}, // Lvl 17
	{	"Ouro I",		500		}, // Lvl 18
	{	"Ouro I",		550		}, // Lvl 19
	{	"Ouro I",		600		}, // Lvl 20
	{	"Ouro I",		650		}, // Lvl 21
	{	"Ouro I",		700		}, // Lvl 22
	{	"Ouro II",		800		}, // Lvl 23
	{	"Ouro II",		900		}, // Lvl 24
	{	"Ouro II",		1000	}, // Lvl 25
	{	"Ouro II",		1100	}, // Lvl 26
	{	"Ouro II",		1200	}, // Lvl 27
	{	"Ouro III",		1400	}, // Lvl 28
	{	"Ouro III",		1500	}, // Lvl 29
	{	"Ouro III",		1600	}, // Lvl 30
	{	"Ouro IV",		1800	}, // Lvl 31
	{	"Ouro IV",		2000	}, // Lvl 32
	{	"Ouro IV",		2200	}, // Lvl 33
	{	"AK I",			2600	}, // Lvl 34
	{	"AK I",			2900	}, // Lvl 35
	{	"AK I",			3200	}, // Lvl 36
	{	"AK II",			3500	}, // Lvl 37
	{	"AK II",			3800	}, // Lvl 38
	{	"AK II",			4100	}, // Lvl 39
	{	"AK Cruzada",	4500	}, // Lvl 40
	{	"AK Cruzada",	5000	}, // Lvl 41
	{	"AK Cruzada",	5500	}, // Lvl 42
	{	"Xerife",		6500	}, // Lvl 43
	{	"Xerife",		7000	}, // Lvl 44
	{	"Xerife",		7500	}, // Lvl 45
	{	"Aguia I",		8500	}, // Lvl 46
	{	"Aguia I",		9000	}, // Lvl 47
	{	"Aguia I",		9500	}, // Lvl 48
	{	"Aguia II",		10000	}, // Lvl 49
	{	"Aguia II",		11000	}, // Lvl 50
	{	"Aguia II",		12000	}, // Lvl 51
	{	"Supremo",		15000	}, // Lvl 52
	{	"Supremo",		20000	}, // Lvl 53
	{	"Supremo",		25000	}, // Lvl 54
	{	"Supremo",		30000	}, // Lvl 55
	{	"Supremo",		35000	}, // Lvl 56
	{	"Global Elite",	50000	}  // Lvl 57
}

new const xPatents2[][xDataPatents] =
{
	{	"Recruta", 0 },
	{	"Soldado I", 80 },
	{	"Soldado II", 180 },
	{	"Soldado III", 240 },
	{	"Cabo I", 300 },
	{	"Cabo II", 350 },
	{	"Cabo III", 400 },
	{	"Cabo IV", 500 },
	{	"3º Sargento I", 550 },
	{	"3º Sargento II", 650 },
	{	"3º Sargento III", 800 },
	{	"3º Sargento IV", 950 },
	{	"2º Sargento I", 1200 },
	{	"2º Sargento II", 1600 },
	{	"2º Sargento III", 2200 },
	{	"2º Sargento IV", 3200 },
	{	"1º Sargento I", 4100	},
	{	"1º Sargento II", 5500	},
	{	"1º Sargento III", 7500	},
	{	"1º Sargento IV", 9500 },
	{	"Subtenente", 10500 },
	{	"Aspirante a Oficial I", 12000 },
	{	"Aspirante a Oficial II", 14000 },
	{	"Aspirante a Oficial III", 16000 },
	{	"Capitão I", 18000 },
	{	"Capitão II", 20000 },
	{	"Capitão III", 22000 },
	{	"Capitão IV", 24000 },
	{	"Major I", 25000 },
	{	"Major II", 26000 },
	{	"Major III", 28000 },
	{	"Major IV", 29000 },
	{	"Coronel I", 30000 },
	{	"Coronel II", 32000 },
	{	"Coronel III", 34000 },
	{	"General Brigadeiro", 36000 },
	{	"General Major", 38000 },
	{	"General de Divisão", 40000 },
	{	"General", 42000 },
	{	"General Global", 50000 }
}

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
}

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
}
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	xCvarSaveType = register_cvar("csr_ptt_savetype_data", "1") // 1= Steam + NoSteam com Sxe || 2= Por conta/registro
	xCvarPttRankStyle = register_cvar("csr_ptt_rank_style", "1") // 1= Rank CSGO (ingame) || 2= Rank CSGO Perfil
	xCvarTop10SayGreen = register_cvar("csr_ptt_top10_saygreen", "0")
	xCvarTop10SayAmount = register_cvar("csr_ptt_top10_say_amount", "10")
	xCvarXpKillNormal = register_cvar("csr_ptt_xp_kill_normal", "2")
	xCvarXpKillKnife = register_cvar("csr_ptt_xp_kill_knife", "4")
	xCvarXpKillHs = register_cvar("csr_ptt_xp_kill_hs", "3")
	xCvarXpKillHeGrenade = register_cvar("csr_ptt_xp_kill_hegrenade", "5")
	xCvarXpDiedMin = register_cvar("csr_ptt_xp_died_min", "1")
	xCvarXpDiedMax = register_cvar("csr_ptt_xp_died_max", "2")
	xCvarXpKillVipMore = register_cvar("csr_ptt_xp_kill_vip_more", "1")
	xCvarPrefixOn = register_cvar("csr_ptt_prefix_on", "0")
	xCvarPrefixAdminViewSayFlag = register_cvar("csr_ptt_prefix_admin_view_say_flag", "a")
	xCvarPrefixBlockChars = register_cvar("csr_ptt_prefix_block_chars", "1")
	xCvarXpNegative = register_cvar("csr_ptt_xp_negatives", "0")
	xCvarWelcomeMsg = register_cvar("csr_ptt_welcome_msg", "0")

	register_concmd("amx_reloadprefix", "xLoadPrefix")

	xRegisterSay("hudinfo", "xMenuOptHuds")
	xRegisterSay("hudxp", "xMenuOptHuds")
	xRegisterSay("hudlocal", "xMenuOptHuds")
	xRegisterSay("infolocal", "xMenuOptHuds")
	xRegisterSay("huds", "xMenuOptHuds")
	xRegisterSay("top10", "xMotdTop10")
	xRegisterSay("top15", "xMotdTop10")
	xRegisterSay("rank", "xSkillTop10")
	xRegisterSay("xp", "xMenuPatents")
	xRegisterSay("xps", "xMenuPatents")
	xRegisterSay("exp", "xMenuPatents")
	xRegisterSay("patente", "xMenuPatents")
	xRegisterSay("patentes", "xMenuPatents")
	xRegisterSay("offhud", "xHudInfoCmd")
	
	register_event("DeathMsg", "xDeathMsg", "a")
	register_event("HLTV", "xNewRound", "a", "1=0", "2=0")
	register_event("TeamInfo", "xTeamInfo", "a")

	register_forward(FM_ClientPutInServer, "xClientPutInServer")
	register_forward(FM_ClientDisconnect, "xClientDisconnect")
	register_forward(FM_ClientUserInfoChanged, "xClientUserInfoChanged", 1)
	//RegisterHam(Ham_Spawn, "player", "xPlayerSpawnPost", 1)

	xSayTxt = get_user_msgid("SayText")
	xMaxPlayers = get_maxplayers()
	xMsgSync[0] = CreateHudSyncObj()

	register_clcmd("say", "xHookSay")
	register_clcmd("say_team", "xHookSayTeam")

	xCreateMotdTop10()

	set_task(10.0, "xReloadGambiarra",_,_,_, "b")
}

public xReloadGambiarra()
{
	xLoadPrefix(0)
}

/*
public xPlayerSpawnPost(id)
{
	if(!is_user_alive(id) || !get_user_team(id))
		return;

	set_hudmessage(0, 0, 255, 0.02, 0.20, 2, 0.08, 10.0, 0.01, 0.02)

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			if(xPlayerLevel[id] < MAXLEVEL_CSGO-1)
			{
				if(equali(xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName]))
					ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: Suba mais seu level.^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]))
				else
					ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: %s^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]))
			}
			else
			{
				ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Level: %d^n• Exp: %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]))
			}
		}

		case 2:
		{
			if(xPlayerLevel[id] < MAXLEVEL_CSGO2-1)
			{
				ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: %s^n• Level: %d^n• Exp: %s / %s", xPatents2[xPlayerLevel[id]][xRankName], xPatents2[xPlayerLevel[id]+1][xRankName], xPlayerLevel[id],
				xAddPoint(xPlayerXP[id]), xAddPoint(xPatents2[xPlayerLevel[id]+1][xRankXp]))
			}
			else
			{
				ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Level: %d^n• Exp: %s", xPatents2[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]))
			}
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
}*/


public plugin_cfg()
{
	new configs_dir[64]
	get_configsdir(configs_dir, charsmax(configs_dir))
	formatex(file_prefixes, charsmax(file_prefixes), "%s/admin_prefixes.ini", configs_dir)

	server_cmd("exec %s/csr_patentes.cfg", configs_dir)
	
	pre_ips_collect = TrieCreate()
	pre_names_collect = TrieCreate()
	pre_steamids_collect = TrieCreate()
	pre_flags_collect = TrieCreate()
	client_prefix = TrieCreate()

	xLoadPrefix(0)

	//pause
	server_cmd("amx_pausecfg pause ^"statsx^"")
}

public xResetVarsFull(id)
{
	xPlayerLevel[id] = 0
	xPlayerXP[id] = 0
	xPlayerHudInfo[id] = false
	xPlayerKills[id] = 0
	xPlayerDeaths[id] = 0
	xPlayerID[id] = 0
	xPlayerViewMsg[id] = false
	xMyPosRankSave[id] = 0
	xPlayerHudGeoIp[id] = false
}

public xRegUserLogoutPost(id) xResetVarsFull(id)
public xClientDisconnect(id) xResetVarsFull(id)

public xRegUserLoginPost(id)
{
	xResetVarsFull(id)

	xLoadRanks(id)
	xLoadKillsDeaths(id)
	xSaveTop10Names(id)
}

public xClientPutInServer(id)
{
	xResetVarsFull(id)

	if(xIsUserNoSxe(id) && get_pcvar_num(xCvarSaveType) == 1)
	{
		set_task(15.0, "xMsgNoSave", id, _, _, "a", 5)

		return PLUGIN_HANDLED
	}

	xLoadRanks(id)
	xLoadKillsDeaths(id)
	xSaveTop10Names(id)

	if(get_pcvar_num(xCvarSaveType) == 2)
		set_task(15.0, "xMsgLoginInAccount", id, _, _, "a", 5)

	set_task(3.0, "xTaskTopsEntry", id+TASK_TOPSENTRY)

	// Prefix
	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")
	xPutPrefix(id)

	return PLUGIN_CONTINUE
}

public plugin_natives()
{
	register_native("csr_get_user_rankname", "xNtvGetUserRankName")
	register_native("csr_check_user_level", "xNtvCheckUserLvl", 1)
	register_native("csr_get_user_xp", "xNtvGetUserXP", 1)
	register_native("csr_get_user_pos_top10", "xNtvGetUserPosTop10", 1)
	register_native("csr_get_total_top10", "xNtvGetTotalTop10", 1)

	set_native_filter("xNtvFilter")
}

public xNtvFilter(const name[], index, trap)
{
	if(!trap)
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

public xTeamInfo()
{
	new id = read_data(1)

	if(is_user_connected(id) && get_pcvar_num(xCvarWelcomeMsg) && !xPlayerViewMsg[id])
	{
		static xUserTeam[32]
		
		read_data(2, xUserTeam, charsmax(xUserTeam))

		switch(xUserTeam[0])
		{
			case 'C':
			{
				set_task(2.0, "xShowMsgWelcome", id+TASK_MSGWELCOME)
			}

			case 'T':
			{
				set_task(2.0, "xShowMsgWelcome", id+TASK_MSGWELCOME)
			}
		}
	}
}

public xTaskTopsEntry(id)
{
	id -= TASK_TOPSENTRY

	if(!is_user_connected(id))
	{
		remove_task(id+TASK_TOPSENTRY); return
	}

	new xMyRank = xMyPosRankSave[id]

	static xPName[32]
	get_user_name(id, xPName, charsmax(xPName))
	get_user_authid(id, xGetAuth, charsmax(xGetAuth))

	if(xMyRank <= 10)
	{
		xClientPrintColor(0, "%s !yJogador !g%s (TOP%d) !yentrou no servidor.", PREFIXCHAT, xPName, xMyRank)
		client_cmd(0, "speak buttons/blip1")
	}
}

public xShowMsgWelcome(id)
{
	id -= TASK_MSGWELCOME

	if(!is_user_connected(id))
	{
		remove_task(id+TASK_MSGWELCOME); return
	}

	new xMyRank = xMyPosRankSave[id]
	new xMyTotalRank = xNtvGetTotalTop10()

	static xSvName[20]
	static xPName[25]
	get_user_name(id, xPName, charsmax(xPName))
	get_user_name(0, xSvName, charsmax(xSvName))

	set_dhudmessage(0, 255, 0, 0.06, 0.33, 2, 0.0, 8.0, 0.08, 0.2)
	show_dhudmessage(id, "Olá %s, Bem vindo ao %s...^nSeu rank é: %s de %s, tenha um ótimo jogo.", xPName, xSvName, xAddPoint(xMyRank), xAddPoint(xMyTotalRank))

	xPlayerViewMsg[id] = true
}

public xNewRound()
{
	xCreateMotdTop10()
}

public xMenuOptHuds(id)
{
	new xFmtxMenu[300]

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wOpções de hud.", PREFIXMENUS)

	new xNewMenu = menu_create(xFmtxMenu, "_xMenuOptHuds")
	
	if(xPlayerHudInfo[id]) menu_additem(xNewMenu, "Ocultar \d[\yHud de XP/Patente/Info Telando\d]")
	else menu_additem(xNewMenu, "Mostrar \d[\yHud de XP/Patente/Info Telando\d]")

	if(xPlayerHudGeoIp[id]) menu_additem(xNewMenu, "Ocultar minha localização para os outros não verem.")
	else menu_additem(xNewMenu, "Mostrar minha localização para os outros verem.")
	
	menu_setprop(xNewMenu, MPROP_EXITNAME, "Sair")
	menu_display(id, xNewMenu, 0)
}

public _xMenuOptHuds(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return
	}
	
	switch(item)
	{
		case 0:
		{
			xHudInfoCmd(id)
			xMenuOptHuds(id)
		}

		case 1:
		{
			xHudInfoGeoIpCmd(id)
			xMenuOptHuds(id)
		}
	}
}

public xMenuPatents(id)
{
	new xFmtxMenu[300]

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wMenu das Patentes.^n^n\
			XP: %s \y| \wLevel: %d \y| \wPatente: %s", PREFIXMENUS, xAddPoint(xPlayerXP[id]), xPlayerLevel[id], xPatents[xPlayerLevel[id]][xRankName])
		}

		case 2:
		{
			formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wMenu das Patentes.^n^n\
			XP: %s \y| \wLevel: %d \y| \wPatente: %s", PREFIXMENUS, xAddPoint(xPlayerXP[id]), xPlayerLevel[id], xPatents2[xPlayerLevel[id]][xRankName])
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
	
	new xNewMenu = menu_create(xFmtxMenu, "_xMenuPatents")
	
	menu_additem(xNewMenu, "Top 10")
	menu_additem(xNewMenu, "Ver patente de um jogador")
	menu_additem(xNewMenu, "Lista de patentes disponíveis^n")
	menu_additem(xNewMenu, "\yAjuda")
	
	menu_setprop(xNewMenu, MPROP_EXITNAME, "Sair")
	menu_display(id, xNewMenu, 0)
}

public _xMenuPatents(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return
	}
	
	switch(item)
	{
		case 0:
		{
			xMenuSelectTop(id)
		}

		case 1:
		{
			xViewPatentPlayer(id)
		}

		case 2:
		{
			xListPatents(id)
			show_motd(id, xMotd, "LISTA DE PATENTES")
			xMenuPatents(id)
		}

		case 3:
		{
			xMotdHelp(id)
			show_motd(id, xMotd, "AJUDA")
			xMenuPatents(id)
		}
	}
}

public xMotdHelp(id)
{
	new iLen
	iLen = formatex(xMotd, charsmax(xMotd), "<html><head><meta charset=UTF-8>\
	<style>body{background: #000 url(^"http://i.imgur.com/FDiuoIk.jpg^") no-repeat fixed center;}table, th, td{border: 1px solid black;border-collapse: collapse;}</style></head><body><table width=100%% cellpadding=2 cellspacing=0 border=1><tr align=center bgcolor=#eeeeee><th width=110%%>AJUDA</tr>")
	
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr align=center style=^"color:#fff;font-size:130%%^">")
	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>- Primeiramente, para que seus dados fiquem salvos no banco de dados você precisa estar de sxe ou (estar logado na conta, se ativado!).<br><br> À cada Kill que você faz, você ganha <b>[%d XP]</b>, se morrer você perde de <b>[%d XP]</b> a <b>[%d XP]</b>.<br><br>Jogadores <b>VIPS</b> ganha <b>+%d</b> a mais de XP, ao mesmo perde <b>+%d XP</b>.", get_pcvar_num(xCvarXpKillNormal), get_pcvar_num(xCvarXpDiedMin), get_pcvar_num(xCvarXpDiedMax), get_pcvar_num(xCvarXpKillVipMore), get_pcvar_num(xCvarXpKillVipMore))

	iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "</table></body></html>")
}

public xListPatents(id)
{
	new iLen, i
	iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
	<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/RBEw1K^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
	<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=50%%>RANK<th width=50%%>XP")

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			for(i = 0; i < sizeof(xPatentsImages); i++)
			{
				iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%s<td>%s", xGetListRankName(i), xAddPoint(xGetListRankExp(i)))
			}
		}

		case 2:
		{
			for(i = 1; i < sizeof(xPatents2Images); i++)
			{
				iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%s<td>%s", xPatents2[i][xRankName], xAddPoint(xPatents2[i][xRankXp]))
			}
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
}

public xViewPatentPlayer(id)
{
	new xFmtxMenu[300]

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wEscolha um jogador para ver a patente.", PREFIXMENUS)

	new xNewMenu = menu_create(xFmtxMenu, "_xViewPatentPlayer")
	
	new xPlayers[32], xPnum, xTempId, xSzTempId[10]
	
	get_players(xPlayers, xPnum, "ch")
	
	for(new i; i < xPnum; i++)
	{
		xTempId = xPlayers[i]
		
		if(id != xTempId)
		{
			get_user_name(xTempId, xPlayerName, charsmax(xPlayerName))
			num_to_str(xTempId, xSzTempId, 9)
			menu_additem(xNewMenu, xPlayerName, xSzTempId, 0)
		}
	}

	menu_setprop(xNewMenu, MPROP_BACKNAME, "Voltar")
	menu_setprop(xNewMenu, MPROP_NEXTNAME, "Proxima")
	menu_setprop(xNewMenu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, xNewMenu)
}

public _xViewPatentPlayer(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return
	}
	
	new data[20], iname[100], access, callback
	
	menu_item_getinfo(menu, item, access, data, 19, iname, 99, callback)
	
	xPlayerID[id] = str_to_num(data)

	get_user_name(xPlayerID[id], xPlayerName, charsmax(xPlayerName))

	xViewPatentPlayerMotd(id)
	show_motd(id, xMotd, "INFO PLAYER")
	xViewPatentPlayer(id)
}

public xViewPatentPlayerMotd(id)
{
	new xMyPosTop10
	xMyPosTop10 = xMyPosRankSave[xPlayerID[id]]

	new iLen
	iLen = formatex(xMotd, charsmax(xMotd), "<head><meta charset=UTF-8>\
	<style>body{background: #000 url(^"http://i.imgur.com/FDiuoIk.jpg^") no-repeat fixed center;}table, th, td{border: 1px solid black;border-collapse: collapse;}</style></head>\
	<body><table width=100%% cellpadding=2 cellspacing=0 border=1>\
	<tr align=center bgcolor=#eeeeee><th width=20%%>POS RANK.<th width=40%%>NOME<th width=10%%>KILLS<th width=10%%>MORTES<th width=15%%>XP<th width=20%%>PATENTE</tr>")

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr align=center style=^"color:#fff^">")
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xMyPosTop10))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xPlayerName)
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerKills[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerDeaths[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerXP[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td><img src=^"%s^" width=80 hight=30/>", xGetUserImgRank(xPlayerLevel[xPlayerID[id]]))
		}

		case 2:
		{
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr align=center style=^"color:#fff^">")
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xMyPosTop10))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xPlayerName)
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerKills[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerDeaths[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td>%s", xAddPoint(xPlayerXP[xPlayerID[id]]))
			iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<td><img src=^"%s^" width=40 hight=40/>", xPatents2Images[xPlayerLevel[xPlayerID[id]]])
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
}

public xMenuSelectTop(id)
{
	new xFmtxMenu[300]

	formatex(xFmtxMenu, charsmax(xFmtxMenu), "%s \wOque você deseja ver?", PREFIXMENUS)

	new xNewMenu = menu_create(xFmtxMenu, "_xMenuSelectTop")
	
	menu_additem(xNewMenu, "Top 10")
	menu_additem(xNewMenu, "Ver minha Posição")
	
	menu_setprop(xNewMenu, MPROP_EXITNAME, "Sair")
	menu_display(id, xNewMenu, 0)
}

public _xMenuSelectTop(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu); return
	}
	
	switch(item)
	{
		case 0:
		{
			xMotdTop10(id)
			xMenuSelectTop(id)
		}

		case 1:
		{
			xSkillTop10(id)
			xMenuSelectTop(id)
		}
	}
}

public xSkillTop10(id)
{
	new xMyPosTop10
	xMyPosTop10 = xMyPosRankSave[id]

	xClientPrintColor(id, "%s !ySua posição é: !g%s !yde !g%s !ycom !g%s !ykills e !g%s !ymortes.", PREFIXCHAT, xAddPoint(xMyPosTop10), xAddPoint(xNtvGetTotalTop10()), xAddPoint(xPlayerKills[id]), xAddPoint(xPlayerDeaths[id]))
}

public xLoadPrefix(id)
{
	if(!(get_user_flags(id) & FLAG_RELOADPREFIX))
		return PLUGIN_HANDLED

	TrieClear(pre_ips_collect); TrieClear(pre_names_collect); TrieClear(pre_steamids_collect); TrieClear(pre_flags_collect)

	line = 0, length = 0, pre_flags_count = 0, pre_ips_count = 0, pre_names_count = 0;

	if(!file_exists(file_prefixes)) set_fail_state("Arquivo admin_prefix.ini nao encontrado.")

	while(read_file(file_prefixes, line++ , text, charsmax(text), length) && (pre_ips_count + pre_names_count + pre_steamids_count + pre_flags_count) <= MAX_PREFIXES)
	{
		if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
			continue

		parse(text, type, charsmax(type), key, charsmax(key), prefix, charsmax(prefix))
		trim(prefix)

		if(!type[0] || !prefix[0] || !key[0])
			continue

		replace_all(prefix, charsmax(prefix), "!g", "^x04")
		replace_all(prefix, charsmax(prefix), "!t", "^x03")
		replace_all(prefix, charsmax(prefix), "!y", "^x01")

		switch(type[0])
		{
			case 'f':
			{
				pre_flags_count++
				TrieSetString(pre_flags_collect, key, prefix)
				
			}
			case 'i':
			{
				pre_ips_count++
				TrieSetString(pre_ips_collect, key, prefix)
				
			}
			case 's':
			{
				pre_steamids_count++
				TrieSetString(pre_steamids_collect, key, prefix)
				
			}
			case 'n':
			{
				pre_names_count++
				TrieSetString(pre_names_collect, key, prefix)
				
			}
			default:
			{
				continue
			}
		}
	}

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		num_to_str(i, str_id, charsmax(str_id))
		TrieDeleteKey(client_prefix, str_id)
		xPutPrefix(i)
	}
	
	if(id)
		console_print(id, "Prefix re-carregado :)")
	
	return PLUGIN_HANDLED
}

public xHookSay(id)
{
	read_args(xSayTyped, charsmax(xSayTyped)); remove_quotes(xSayTyped); trim(xSayTyped)

	if(equal(xSayTyped, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 2) || get_pcvar_num(xCvarPrefixBlockChars) == 3)
	{
		if(check_say_characters(xSayTyped))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, xPlayerName, charsmax(xPlayerName))

	xUserTeam = cs_get_user_team(id)

	new xMyRank, xMyRankName[32]

	xMyRank = xMyPosRankSave[id]

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1: formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents[xPlayerLevel[id]][xRankName])
		case 2: formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents2[xPlayerLevel[id]][xRankName])

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}

	/*
	if(temp_prefix[0])
	{
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xMyRankName, xPlayerName, xSayTyped)
	}
	else
	{
		if((get_pcvar_num(xCvarSaveType) == 1 && !xIsUserNoSxe(id)) || (get_pcvar_num(xCvarSaveType) == 2 && xRegGetUserLogged(id)))
		{
			if(xMyRank <= get_pcvar_num(xCvarTop10SayAmount) && get_pcvar_num(xCvarTop10SayGreen))
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
			else
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^1%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
		}
		else
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped)
		}
	}*/
	

	
	if((get_pcvar_num(xCvarSaveType) == 1 && !xIsUserNoSxe(id)) || (get_pcvar_num(xCvarSaveType) == 2 && xRegGetUserLogged(id)))
	{
		if(temp_prefix[0])
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xMyRankName, xPlayerName, xSayTyped)
		}
		else
		{
			if(xMyRank <= get_pcvar_num(xCvarTop10SayAmount) && get_pcvar_num(xCvarTop10SayGreen))
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
			else
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^1%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
		}
	}
	else
	{
		if(temp_prefix[0])
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^3%s: ^4%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xPlayerName, xSayTyped)
		}
		else
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped)
		}
	}

	get_pcvar_string(xCvarPrefixAdminViewSayFlag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue

		if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
		{
			xPrefixSendMessage(xSayMessage, id, i)
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public xHookSayTeam(id)
{
	read_args(xSayTyped, charsmax(xSayTyped)); remove_quotes(xSayTyped); trim(xSayTyped)
	
	if(equal(xSayTyped, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(xCvarPrefixBlockChars) == 2) || get_pcvar_num(xCvarPrefixBlockChars) == 3)
	{
		if(check_say_characters(xSayTyped))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, xPlayerName, charsmax(xPlayerName))

	xUserTeam = cs_get_user_team(id)

	new xMyRank, xMyRankName[32]

	xMyRank = xMyPosRankSave[id]

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1: formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents[xPlayerLevel[id]][xRankName])
		case 2: formatex(xMyRankName, charsmax(xMyRankName), "%s", xPatents2[xPlayerLevel[id]][xRankName])

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}


	/*
	if(temp_prefix[0])
	{
		formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xMyRankName, xPlayerName, xSayTyped)
	}
	else
	{
		if((get_pcvar_num(xCvarSaveType) == 1 && !xIsUserNoSxe(id)) || (get_pcvar_num(xCvarSaveType) == 2 && xRegGetUserLogged(id)))
		{
			if(xMyRank <= get_pcvar_num(xCvarTop10SayAmount) && get_pcvar_num(xCvarTop10SayGreen))
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
			else
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^1%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
		}
		else
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped)
		}
		
	}*/
	

	
	if((get_pcvar_num(xCvarSaveType) == 1 && !xIsUserNoSxe(id)) || (get_pcvar_num(xCvarSaveType) == 2 && xRegGetUserLogged(id)))
	{
		if(temp_prefix[0])
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xMyRankName, xPlayerName, xSayTyped)
		}
		else
		{
			if(xMyRank <= get_pcvar_num(xCvarTop10SayAmount) && get_pcvar_num(xCvarTop10SayGreen))
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
			else
			{
				formatex(xSayMessage, charsmax(xSayMessage), "^1%s^1» ^4%s ^1« ^3%s: ^1%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xMyRankName, xPlayerName, xSayTyped)
			}
		}
	}
	else
	{
		if(temp_prefix[0])
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^4%s ^3%s: ^4%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], temp_prefix, xPlayerName, xSayTyped)
		}
		else
		{
			formatex(xSayMessage, charsmax(xSayMessage), "^1%s^3%s: ^1%s", xSayTeamInfoTeamPrefix[is_user_alive(id)][xUserTeam], xPlayerName, xSayTyped)
		}
	}
	

	get_pcvar_string(xCvarPrefixAdminViewSayFlag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= xMaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue

		if(get_user_team(id) == get_user_team(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
		{
			if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(xCvarPrefixOn) && get_user_flags(i) & read_flags(temp_cvar))
			{
				xPrefixSendMessage(xSayMessage, id, i)
			}
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public xPutPrefix(id)
{
	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")

	new sflags[32], temp_flag[2];
	get_flags(get_user_flags(id), sflags, charsmax(sflags))

	for(new i = 0; i <= charsmax(sflags); i++)
	{
		formatex(temp_flag, charsmax(temp_flag), "%c", sflags[i])

		if(TrieGetString(pre_flags_collect, temp_flag, temp_prefix, charsmax(temp_prefix)))
		{
			TrieSetString(client_prefix, str_id, temp_prefix)
		}
	}

	get_user_ip(id, temp_key, charsmax(temp_key), 1)

	if(TrieGetString(pre_ips_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	get_user_authid(id, temp_key, charsmax(temp_key))

	if(TrieGetString(pre_steamids_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	get_user_name(id, temp_key, charsmax(temp_key))

	if(TrieGetString(pre_names_collect, temp_key, temp_prefix, charsmax(temp_prefix)))
	{
		TrieSetString(client_prefix, str_id, temp_prefix)
	}

	return PLUGIN_HANDLED
}

public xPrefixSendMessage(const message[], const id, const i)
{
	message_begin(MSG_ONE, xSayTxt, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}

bool:check_say_characters(const check_message[])
{
	for(new i = 0; i < charsmax(xBlockSymbolsSayPrefix); i++)
	{
		if(check_message[0] == xBlockSymbolsSayPrefix[i])
		{
			return true
		}
	}
	return false
}

public xNtvGetUserPosTop10(id)
{
	new Array:aKey = ArrayCreate(35)
	new Array:aData = ArrayCreate(128)
	new Array:aAll = ArrayCreate(xTop15Data)
	
	fvault_load(db_top10_data, aKey, aData)
	
	new iArraySize = ArraySize(aKey)
	
	new Data[xTop15Data]
	
	new i
	for(i = 0; i < iArraySize; i++)
	{
		ArrayGetString(aKey, i, Data[szAuthID ], sizeof Data[szAuthID]-1)
		ArrayGetString(aData, i, Data[szSkillP_Data], sizeof Data[szSkillP_Data]-1)
		
		ArrayPushArray(aAll, Data)
	}
	
	ArraySort(aAll, "xSortData")
	
	new szAuthIdFromArray[64]
	
	new j
	for(j = 0; j < iArraySize; j++ )
	{
		ArrayGetString(aAll, j, szAuthIdFromArray, charsmax(szAuthIdFromArray))
		
		switch(get_pcvar_num(xCvarSaveType))
		{
			case 1: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
			case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
			default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		}

		if(equal(szAuthIdFromArray, xGetAuth)) break
		
	}
	
	ArrayDestroy(aKey)
	ArrayDestroy(aData)
	ArrayDestroy(aAll)

	return j + 1
}

public xNtvGetTotalTop10()
{
	new Array:aKey = ArrayCreate(64)
	new Array:aData = ArrayCreate(512)
		
	new xTotalVaults = fvault_load(db_top10_data, aKey, aData)

	ArrayDestroy(aKey)
	ArrayDestroy(aData)

	return xTotalVaults
}

public xNtvGetUserXP(id)
{
	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(!is_user_connected(id))
				return false
		}

		case 2:
		{
			if(!xRegGetUserLogged(id))
				return false
		}

		default:
		{
			if(!is_user_connected(id))
				return false
		}
	}
	
	return xPlayerXP[id]
}

public xNtvCheckUserLvl(id)
{
	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(!is_user_connected(id))
				return false
		}

		case 2:
		{
			if(!xRegGetUserLogged(id))
				return false
		}

		default:
		{
			if(!is_user_connected(id))
				return false
		}
	}
	
	return xCheckLevel(id)
}

public xNtvGetUserRankName(xPluginId, xNumParams)
{
	new id = get_param(1)

	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(!is_user_connected(id))
				return false
		}

		case 2:
		{
			if(!xRegGetUserLogged(id))
				return false
		}

		default:
		{
			if(!is_user_connected(id))
				return false
		}
	}
	
	new xUserName[64]

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1: formatex(xUserName, charsmax(xUserName), "%s", xPatents[xPlayerLevel[id]][xRankName])
		case 2: formatex(xUserName, charsmax(xUserName), "%s", xPatents2[xPlayerLevel[id]][xRankName])

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
	
	new len = get_param(3)
	set_string(2, xUserName, len)

	return true
}

public xDeathMsg()
{
	new xAddXp
	new xKiller = read_data(1)
	new xVictim = read_data(2)
	new xHeadShot = read_data(3)

	new xWeapon[24]
	read_data(4, xWeapon, charsmax(xWeapon))

	if(xKiller != xVictim && is_user_connected(xKiller) && is_user_connected(xVictim))
	{
		new xDiedXp = random_num(get_pcvar_num(xCvarXpDiedMin), get_pcvar_num(xCvarXpDiedMax))

		if(xHeadShot == 1 && !(xWeapon[0] == 'k') && xKiller != xVictim) // Hs
			xAddXp = get_pcvar_num(xCvarXpKillHs)
		else xAddXp = get_pcvar_num(xCvarXpKillNormal) // Normal

		if(xWeapon[1] == 'r' && xKiller != xVictim) // He Grenade
			xAddXp = get_pcvar_num(xCvarXpKillHeGrenade)

		if(xWeapon[0] == 'k') // Knife
			xAddXp = get_pcvar_num(xCvarXpKillKnife)

		if(get_user_flags(xKiller) & VIP_FLAG)
		{
			xPlayerXP[xKiller] += xAddXp + get_pcvar_num(xCvarXpKillVipMore)
			if(get_pcvar_num(xCvarXpNegative)) xPlayerXP[xVictim] -= xDiedXp - get_pcvar_num(xCvarXpKillVipMore)
		}
		else
		{
			xPlayerXP[xKiller] += xAddXp
			if(get_pcvar_num(xCvarXpNegative)) xPlayerXP[xVictim] -= xDiedXp
		}

		switch(get_pcvar_num(xCvarPttRankStyle))
		{
			case 1:
			{
				if(xPlayerLevel[xKiller] < MAXLEVEL_CSGO-1)
				{
					if(xPlayerXP[xKiller] >= xPatents[xPlayerLevel[xKiller]+1][xRankXp])
					{
						xCheckLevel(xKiller)

						get_user_name(xKiller, xPlayerName, charsmax(xPlayerName))
							
						//client_cmd(0, "speak ambience/3dmeagle")
						xClientPrintColor(0, "%s !yJogador !g%s !ySubiu de level. Level: !g%d, !yPatente: !g%s!y.", PREFIXCHAT, xPlayerName, xPlayerLevel[xKiller], xPatents[xPlayerLevel[xKiller]][xRankName])
					}
				}
			}

			case 2:
			{
				if(xPlayerLevel[xKiller] < MAXLEVEL_CSGO2-1)
				{
					if(xPlayerXP[xKiller] >= xPatents2[xPlayerLevel[xKiller]+1][xRankXp])
					{
						xCheckLevel(xKiller)

						get_user_name(xKiller, xPlayerName, charsmax(xPlayerName))
							
						//client_cmd(0, "speak ambience/3dmeagle")
						xClientPrintColor(0, "%s !yJogador !g%s !ySubiu de level. Level: !g%d, !yPatente: !g%s!y.", PREFIXCHAT, xPlayerName, xPlayerLevel[xKiller], xPatents2[xPlayerLevel[xKiller]][xRankName])
					}
				}
			}

			default: set_pcvar_num(xCvarPttRankStyle, 1)
		}

		xPlayerKills[xKiller] ++
		xPlayerDeaths[xVictim] ++

		xSaveRanks(xKiller)
		xSaveRanks(xVictim)
		xSaveTop10Data(xKiller)
		xSaveTop10Data(xVictim)
	}
}

public xMotdTop10(id)
{
	xCreateMotdTop10()
	show_motd(id, xMotd, "TOP 10")
}

public xCreateMotdTop10()
{
	new iLen, xRandomCss

	xRandomCss = random_num(0, 1)

	switch(xRandomCss)
	{
		case 0:
		{
			iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
			<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/RBEw1K^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
			<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=5%%>POS.<th width=50%%>NOME<th width=15%%>KILLS\
			<th width=15%%>MORTES<th width=10%%>XP<th width=20%%>PATENTE")
		}

		case 1:
		{
			iLen = formatex(xMotd, charsmax(xMotd), "<meta charset=UTF-8>\
			<style>*{margin:0px;}body{color:#fff;background:url(^"http://goo.gl/gBqWyy^")}table{border-collapse:collapse;border: 1px solid #000;text-align:center;}</style>\
			<body><table width=100%% height=100%% border=1><tr bgcolor=#4c4c4c style=^"color:#fff;^"><th width=5%%>POS.<th width=50%%>NOME<th width=15%%>KILLS\
			<th width=15%%>MORTES<th width=10%%>XP<th width=20%%>PATENTE")
		}
	}
	
	new Array:aKey = ArrayCreate(35)
	new Array:aData = ArrayCreate(128)
	new Array:aAll = ArrayCreate(xTop15Data)
	
	fvault_load(db_top10_data, aKey, aData)
	
	new iArraySize = ArraySize(aKey)
	
	new Data[xTop15Data]
	
	new i
	for( i = 0; i < iArraySize; i++ )
	{
		ArrayGetString(aKey, i, Data[szAuthID], sizeof Data[szAuthID]-1)
		ArrayGetString(aData, i, Data[szSkillP_Data], sizeof Data[szSkillP_Data]-1)
		
		ArrayPushArray(aAll, Data)
	}
	
	ArraySort(aAll, "xSortData")
	
	new szPlayerKills[10]
	new szPlayerDeahts[10]
	
	new szName[25], xGetDataXps[50]
	new iSize = clamp( iArraySize, 0, 10)

	new j
	for(j = 0; j < iSize; j++)
	{
		ArrayGetArray( aAll, j, Data )
		
		fvault_get_data( db_top10_names, Data[ szAuthID ], szName, charsmax( szName ) )
		
		replace_all(szName, charsmax(szName), "<", "")
		replace_all(szName, charsmax(szName), ">", "")
		replace_all(szName, charsmax(szName), "%", "")
		
		parse(Data[szSkillP_Data],szPlayerKills, charsmax(szPlayerKills), szPlayerDeahts, charsmax(szPlayerDeahts))
		
		fvault_get_data(db_patents, Data[ szAuthID ], xGetDataXps, charsmax(xGetDataXps))

		new xPlayerXpRank = str_to_num(xGetDataXps)
		new xPlayerLvlRank

		switch(get_pcvar_num(xCvarPttRankStyle))
		{
			case 1:
			{
				if(xPlayerLvlRank <= MAXLEVEL_CSGO-1)
				{
					xPlayerLvlRank = 0
					
					while(xPlayerXpRank >= xPatents[xPlayerLvlRank+1][xRankXp])
					{
						xPlayerLvlRank ++
							
						if(xPlayerLvlRank == MAXLEVEL_CSGO-1)
							break
					}
				}

				iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%i<td>%s<td>%s<td>%s<td>%s<td><img src=^"%s^" width=80 hight=30/>", j + 1, szName, xAddPoint(str_to_num(szPlayerKills)),
				xAddPoint(str_to_num(szPlayerDeahts)), xAddPoint(xPlayerXpRank), xGetUserImgRank(xPlayerLvlRank))
			}

			case 2:
			{
				if(xPlayerLvlRank <= MAXLEVEL_CSGO2-1)
				{
					xPlayerLvlRank = 0
					
					while(xPlayerXpRank >= xPatents2[xPlayerLvlRank+1][xRankXp])
					{
						xPlayerLvlRank ++
						
						if(xPlayerLvlRank == MAXLEVEL_CSGO2-1)
							break
					}

				}

				iLen += formatex(xMotd[iLen], charsmax(xMotd) - iLen, "<tr><td>%i<td>%s<td>%s<td>%s<td>%s<td><img src=^"%s^" width=40 hight=40/>", j + 1, szName, xAddPoint(str_to_num(szPlayerKills)),
				xAddPoint(str_to_num(szPlayerDeahts)), xAddPoint(xPlayerXpRank), xPatents2Images[xPlayerLvlRank])
			}

			default: set_pcvar_num(xCvarPttRankStyle, 1)
		}
	}
	
	ArrayDestroy(aKey)
	ArrayDestroy(aData)
	ArrayDestroy(aAll)
}

/*
public xSortData(Array:aArray, iItem1, iItem2, iData[], iDataSize)
{	
	new Data1[ xTop15Data ]
	new Data2[ xTop15Data ]
	
	ArrayGetArray( aArray, iItem1, Data1 )
	ArrayGetArray( aArray, iItem2, Data2 )
	
	new szPlayerKills[7], szPlayerDeahts[7]
	parse(Data1[ szSkillP_Data ], szPlayerKills, charsmax( szPlayerKills ), szPlayerDeahts, charsmax( szPlayerDeahts ))
	new Count1_1 = str_to_num(szPlayerKills)
	new Count1_2 = str_to_num(szPlayerDeahts)

	new Count1_f
	if(Count1_2 >= Count1_1) Count1_f = Count1_1
	else Count1_f = ((Count1_1+Count1_2)/2)

	new szPlayerKills2[7], szPlayerDeahts2[7]
	parse(Data2[ szSkillP_Data ], szPlayerKills2, charsmax( szPlayerKills2 ), szPlayerDeahts2, charsmax( szPlayerDeahts2 ))
	new Count2_1 = str_to_num(szPlayerKills2)
	new Count2_2 = str_to_num(szPlayerDeahts2)

	new Count2_f
	if(Count2_2 >= Count2_1) Count1_f = Count2_1
	else Count2_f = ((Count2_1+Count2_2)/2)
	
	new iCount1 = Count1_f
	new iCount2 = Count2_f
	
	return (iCount1 > iCount2) ? -1 : ((iCount1 < iCount2) ? 1 : 0)
}*/

public xSortData(Array:aArray, iItem1, iItem2, iData[], iDataSize)
{	
	new Data1[ xTop15Data ]
	new Data2[ xTop15Data ]
	
	ArrayGetArray( aArray, iItem1, Data1 )
	ArrayGetArray( aArray, iItem2, Data2 )
	
	new szPlayerKills[7], szPlayerDeahts[7]
	parse(Data1[ szSkillP_Data ], szPlayerKills, charsmax( szPlayerKills ), szPlayerDeahts, charsmax( szPlayerDeahts ))
	new Count1_1 = str_to_num(szPlayerKills)
	new Count1_2 = str_to_num(szPlayerDeahts)

	new Count1_f
	if(Count1_2 >= Count1_1) Count1_f = Count1_1
	else Count1_f = ((Count1_1-Count1_2))

	new szPlayerKills2[7], szPlayerDeahts2[7]
	parse(Data2[ szSkillP_Data ], szPlayerKills2, charsmax( szPlayerKills2 ), szPlayerDeahts2, charsmax( szPlayerDeahts2 ))
	new Count2_1 = str_to_num(szPlayerKills2)
	new Count2_2 = str_to_num(szPlayerDeahts2)

	new Count2_f
	if(Count2_2 >= Count2_1) Count1_f = Count2_1
	else Count2_f = ((Count2_1-Count2_2))
	
	new iCount1 = Count1_f
	new iCount2 = Count2_f
	
	return (iCount1 > iCount2) ? -1 : ((iCount1 < iCount2) ? 1 : 0)
}

public xCheckLevel(id)
{
	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			if(xPlayerLevel[id] <= MAXLEVEL_CSGO-1)
			{
				xPlayerLevel[id] = 0
						
				while(xPlayerXP[id] >= xPatents[xPlayerLevel[id]+1][xRankXp])
				{
					xPlayerLevel[id]++
							
					if(xPlayerLevel[id] == MAXLEVEL_CSGO-1)
						return false
				}
			}
		}

		case 2:
		{
			if(xPlayerLevel[id] <= MAXLEVEL_CSGO2-1)
			{
				xPlayerLevel[id] = 0
						
				while(xPlayerXP[id] >= xPatents2[xPlayerLevel[id]+1][xRankXp])
				{
					xPlayerLevel[id]++
							
					if(xPlayerLevel[id] == MAXLEVEL_CSGO2-1)
						return false
				}
			}
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}

	return true
}

public xSaveRanks(id)
{
	new xData[30]

	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED

	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(xIsUserNoSxe(id))
				return PLUGIN_HANDLED

			get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		}

		case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
		default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	}

	num_to_str(xPlayerXP[id], xData, charsmax(xData))
	fvault_set_data(db_patents, xGetAuth, xData)

	return PLUGIN_HANDLED
}

public xSaveTop10Data(id)
{
	new xData[128]

	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED

	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(xIsUserNoSxe(id))
				return PLUGIN_HANDLED
				
			get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		}
		
		case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
		default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	}

	formatex(xData, charsmax(xData), "%i %i", xPlayerKills[id], xPlayerDeaths[id])
	fvault_set_data(db_top10_data, xGetAuth, xData)

	return PLUGIN_HANDLED
}

public xSaveTop10Names(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED
		
	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1:
		{
			if(xIsUserNoSxe(id))
				return PLUGIN_HANDLED
				
			get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		}

		case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
		default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	}

	get_user_name(id, xPlayerName, charsmax(xPlayerName))
	fvault_set_data(db_top10_names, xGetAuth, xPlayerName)

	return PLUGIN_HANDLED
}

public xLoadKillsDeaths(id)
{
	new xData[128], xMyKills[50], xMyDeaths[50]

	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
		default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	}

	if(fvault_get_data(db_top10_data, xGetAuth, xData, charsmax(xData)))
	{
		parse(xData, xMyKills, charsmax(xMyKills), xMyDeaths, charsmax(xMyDeaths))
				
		xPlayerKills[id] = str_to_num(xMyKills)
		xPlayerDeaths[id] = str_to_num(xMyDeaths)
	}
}

public xLoadRanks(id)
{
	xPlayerViewMsg[id] = false
	xPlayerHudInfo[id] = true
	xPlayerHudGeoIp[id] = false

	new xData[30]

	switch(get_pcvar_num(xCvarSaveType))
	{
		case 1: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
		case 2: xRegGetUserAccount(id, xGetAuth, charsmax(xGetAuth))
		default: get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	}

	if(fvault_get_data(db_patents, xGetAuth, xData, charsmax(xData)))
		xPlayerXP[id] = str_to_num(xData)

	xCheckLevel(id)

	set_task(1.0, "xHudInfo", id+TASK_HUDRANK, _, _, "b")

	xMyPosRankSave[id] = xNtvGetUserPosTop10(id)
}

public xMsgNoSave(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id); return
	}

	xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT)
	xClientPrintColor(id, "%s !tA.T.E.N.Ç.Ã.O !ySeus dados como !gRank, Patente !yetc, não estão sendo salvos. Entre com !gsXe !ypara salva-los.", PREFIXCHAT)
	xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT)
	client_cmd(id, "speak buttons/blip2")
}

public xMsgLoginInAccount(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id); return
	}

	if(!xRegGetUserLogged(id))
	{
		xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT)
		xClientPrintColor(id, "%s !tA.T.E.N.Ç.Ã.O !ySeus dados como !gRank, Patente !yetc, não estão sendo salvos. Digite !g.login !ypara salva-los.", PREFIXCHAT)
		xClientPrintColor(id, "%s !t------------------------------------------------------------------------------------------------------------------------", PREFIXCHAT)
		client_cmd(id, "speak buttons/blip2")
	}
}

public xClientUserInfoChanged(id)
{
	if(!is_user_connected(id))
		return FMRES_IGNORED

	new xOldName[32]//, xData[128]

	get_user_info(id, "name", xPlayerName, charsmax(xPlayerName))
	get_user_name(id, xOldName, charsmax(xOldName))

	if(!equal(xPlayerName, xOldName))
	{
		num_to_str(id, str_id, charsmax(str_id))
		TrieSetString(client_prefix, str_id, "")
		set_task(0.5, "xPutPrefix", id)

		return FMRES_HANDLED
	}

	xSaveTop10Names(id)

	return FMRES_IGNORED
}

public xHudInfo(id)
{
	id -= TASK_HUDRANK

	if(!is_user_connected(id))
	{
		remove_task(id+TASK_HUDRANK); return
	}

	switch(get_pcvar_num(xCvarPttRankStyle))
	{
		case 1:
		{
			if(is_user_alive(id) && xPlayerHudInfo[id])
			{
				set_hudmessage(HUD_HELP)

				if(xPlayerLevel[id] < MAXLEVEL_CSGO-1)
				{
					if(equali(xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName]))
						ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: Suba mais seu level.^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]))
					else
						ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: %s^n• Level: %d^n• Exp: %s / %s", xPatents[xPlayerLevel[id]][xRankName], xPatents[xPlayerLevel[id]+1][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]), xAddPoint(xPatents[xPlayerLevel[id]+1][xRankXp]))
				}
				else
				{
					ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Level: %d^n• Exp: %s", xPatents[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]))
				}
			}
			else if(xPlayerHudInfo[id])
			{
				static id2
				id2 = pev(id, pev_iuser2)

				if(!is_user_alive(id2)) return

				static xPlayerIp[20]
				get_user_ip(id2, xPlayerIp, charsmax(xPlayerIp), 1)

				geoip_city(xPlayerIp, xUserCity, charsmax(xUserCity))
				geoip_region_name(xPlayerIp, xUserRegion, charsmax(xUserRegion))
				get_user_name(id2, xPlayerName, charsmax(xPlayerName))

				set_hudmessage(0, 255, 0, 0.02, 0.20, 0, 0.01, 1.0, 1.0, 1.0)

				if(!xPlayerHudGeoIp[id2] || equal(xUserCity, "") || equal(xUserRegion, ""))
					ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s", xPlayerName, xPatents[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]))
				else ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s^n• Cidade: %s^n• Estado: %s", xPlayerName, xPatents[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]), xUserCity, xUserRegion)
			}
		}

		case 2:
		{
			if(is_user_alive(id) && xPlayerHudInfo[id])
			{
				set_hudmessage(HUD_HELP2)

				if(xPlayerLevel[id] < MAXLEVEL_CSGO2-1)
				{
					ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Prox. Patente: %s^n• Level: %d^n• Exp: %s / %s", xPatents2[xPlayerLevel[id]][xRankName], xPatents2[xPlayerLevel[id]+1][xRankName], xPlayerLevel[id],
					xAddPoint(xPlayerXP[id]), xAddPoint(xPatents2[xPlayerLevel[id]+1][xRankXp]))
				}
				else
				{
					ShowSyncHudMsg(id, xMsgSync[0], "• Patente: %s^n• Level: %d^n• Exp: %s", xPatents2[xPlayerLevel[id]][xRankName], xPlayerLevel[id], xAddPoint(xPlayerXP[id]))
				}
			}
			else if(xPlayerHudInfo[id])
			{
				new id2
				id2 = pev(id, pev_iuser2)

				if(!is_user_alive(id2)) return

				static xPlayerIp[20]
				get_user_ip(id2, xPlayerIp, charsmax(xPlayerIp), 1)

				geoip_city(xPlayerIp, xUserCity, charsmax(xUserCity))
				geoip_region_name(xPlayerIp, xUserRegion, charsmax(xUserRegion))
				get_user_name(id2, xPlayerName, charsmax(xPlayerName))

				set_hudmessage(0, 255, 0, 0.02, 0.20, 0, 0.01, 1.0, 1.0, 1.0)

				if(!xPlayerHudGeoIp[id2] || equal(xUserCity, "") || equal(xUserRegion, ""))
					ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s", xPlayerName, xPatents2[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]))
				else ShowSyncHudMsg(id, xMsgSync[0], "Observando: %s^n^n• Patente: %s^n• Level: %d^n• Exp: %s^n• Cidade: %s^n• Estado: %s", xPlayerName, xPatents2[xPlayerLevel[id2]][xRankName], xPlayerLevel[id2], xAddPoint(xPlayerXP[id2]), xUserCity, xUserRegion)
			}
		}

		default: set_pcvar_num(xCvarPttRankStyle, 1)
	}
}

public xHudInfoGeoIpCmd(id)
{
	if(!xPlayerHudGeoIp[id])
	{
		xPlayerHudGeoIp[id] = true
		
		xClientPrintColor(id, "%s !yVoce !tAtivou !ya hudinfo de localização.", PREFIXCHAT)
	}
	else
	{
		xPlayerHudGeoIp[id] = false
		
		xClientPrintColor(id, "%s !yVoce !tDesativou !ya hudinfo de localização.", PREFIXCHAT)
	}
}

public xHudInfoCmd(id)
{
	if(!xPlayerHudInfo[id])
	{
		xPlayerHudInfo[id] = true
		
		xClientPrintColor(id, "%s !yVoce !gAtivou !ya hudinfo.", PREFIXCHAT)
	
		set_task(1.0, "xHudInfo", id+TASK_HUDRANK, _, _, "b")
	}
	else
	{
		xPlayerHudInfo[id] = false
		
		xClientPrintColor(id, "%s !yVoce !gDesativou !ya hudinfo.", PREFIXCHAT)
		
		remove_task(id+TASK_HUDRANK)
	}
}

stock xGetListRankExp(num)
{
	switch(num)
	{
		case 0: return xPatents[2][xRankXp]
		case 1: return xPatents[5][xRankXp]
		case 2: return xPatents[8][xRankXp]
		case 3: return xPatents[11][xRankXp]
		case 4: return xPatents[14][xRankXp]
		case 5: return xPatents[17][xRankXp]
		case 6: return xPatents[22][xRankXp]
		case 7: return xPatents[27][xRankXp]
		case 8: return xPatents[30][xRankXp]
		case 9: return xPatents[33][xRankXp]
		case 10: return xPatents[36][xRankXp]
		case 11: return xPatents[39][xRankXp]
		case 12: return xPatents[42][xRankXp]
		case 13: return xPatents[45][xRankXp]
		case 14: return xPatents[48][xRankXp]
		case 15: return xPatents[51][xRankXp]
		case 16: return xPatents[56][xRankXp]
		case 17: return xPatents[57][xRankXp]
	
		default: return xPatents[2][xRankXp]
	}

	return xPatents[2][xRankXp]
}

stock xGetListRankName(num)
{
	switch(num)
	{
		case 0: return xPatents[2]
		case 1: return xPatents[5]
		case 2: return xPatents[8]
		case 3: return xPatents[11]
		case 4: return xPatents[14]
		case 5: return xPatents[17]
		case 6: return xPatents[22]
		case 7: return xPatents[27]
		case 8: return xPatents[30]
		case 9: return xPatents[33]
		case 10: return xPatents[36]
		case 11: return xPatents[39]
		case 12: return xPatents[42]
		case 13: return xPatents[45]
		case 14: return xPatents[48]
		case 15: return xPatents[51]
		case 16: return xPatents[56]
		case 17: return xPatents[57]
	
		default: return xPatents[2]
	}

	return xPatents[2]
}

stock xGetUserImgRank(num)
{
	switch(num)
	{
		case 0..2: return xPatentsImages[0]
		case 3..5: return xPatentsImages[1]
		case 6..8: return xPatentsImages[2]
		case 9..11: return xPatentsImages[3]
		case 12..14: return xPatentsImages[4]
		case 15..17: return xPatentsImages[5]
		case 18..22: return xPatentsImages[6]
		case 23..27: return xPatentsImages[7]
		case 28..30: return xPatentsImages[8]
		case 31..33: return xPatentsImages[9]
		case 34..36: return xPatentsImages[10]
		case 37..39: return xPatentsImages[11]
		case 40..42: return xPatentsImages[12]
		case 43..45: return xPatentsImages[13]
		case 46..48: return xPatentsImages[14]
		case 49..51: return xPatentsImages[15]
		case 52..56: return xPatentsImages[16]
		case 57: return xPatentsImages[17]

		default: return xPatentsImages[0]
	}

	return xPatentsImages[0]
}

stock xIsUserNoSxe(id)
{
	get_user_authid(id, xGetAuth, charsmax(xGetAuth))
	
	if(equal(xGetAuth, "VALVE_4:4", 9))
		return true
	
	return false
}

stock xAddPoint(number)
{
	new count, i, str[29], str2[35], len
	num_to_str(number, str, charsmax(str))
	len = strlen(str)

	for (i = 0; i < len; i++)
	{
		if(i != 0 && ((len - i) %3 == 0))
		{
			add(str2, charsmax(str2), ".", 1)
			count++
			add(str2[i+count], 1, str[i], 1)
		}
		else add(str2[i+count], 1, str[i], 1)
	}
	
	return str2
}

stock xClientPrintColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}

stock xRegisterSay(szsay[], szfunction[])
{
	new sztemp[64]
	formatex(sztemp, 63 , "say /%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say .%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say_team /%s", szsay)
	register_clcmd(sztemp, szfunction )
	
	formatex(sztemp, 63 , "say_team .%s", szsay)
	register_clcmd(sztemp, szfunction)
}
