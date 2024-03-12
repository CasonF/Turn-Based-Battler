class_name GlobalVariables
extends Node

static var debug_mode : bool = false
static var main_menu_path: String = "res://game/scenes/main_menu.tscn"
static var battle_setup_path: String = "res://game/scenes/battle_setup.tscn"
static var battle_manager_path: String = "res://game/scenes/battle_manager.tscn"
# Change this if the file path for all monster resources changes...
const monster_resource_file_path_ext : String = "res://game/resources/monster_stats/"

enum MONSTERS {
	FRENCHKINGDOG, SPEARBUD, STABBYCORGI, AXEWOLF,
	SHELLCHAMPION, NAUTILUS, GOOPSHELL, CLAMPSHELL, SHIFTYSHELL,
	DESERTHIPPODRAKE, SANDYCALFDRAKE, STONYCALFDRAKE, PRICKLECALFDRAKE,
	SENSHIFROG, SWORDSFROG, MAGEFROG, FROGUE, SPEARFROG,
	EXCALIBLADE, ARCANEBLADE, ARCANEHAMMER, ARCANESHIELD, ARCANEPISTOL,
	ANGRYFIN, GRUMPFLOAT, MOLLOOZK, SEAMARE, JELLYFLOAT,
	POISONOAK, GREENIONY, SNAPTRAP, COOLSHROOM, CHILLROOT,
	INFERNUS, PYRUS, STRATUS, GUSTUS, HYDRUS, AQUARIUS,
	LICHLORD, APOSTLICH, JACKALOPE, JERRY
}

static var MONSTER_DICT : Dictionary = {
	MONSTERS.FRENCHKINGDOG : monster_resource_file_path_ext + "french_kingdog.tres",
	MONSTERS.SPEARBUD : monster_resource_file_path_ext + "spear_bud.tres",
	MONSTERS.STABBYCORGI : monster_resource_file_path_ext + "stabby_corgi.tres",
	MONSTERS.AXEWOLF : monster_resource_file_path_ext + "axe_wolf.tres",
	MONSTERS.SHELLCHAMPION : monster_resource_file_path_ext + "shell_champion.tres",
	MONSTERS.NAUTILUS : monster_resource_file_path_ext + "nautilus.tres",
	MONSTERS.GOOPSHELL : monster_resource_file_path_ext + "goop_shell.tres",
	MONSTERS.CLAMPSHELL : monster_resource_file_path_ext + "clamp_shell.tres",
	MONSTERS.SHIFTYSHELL : monster_resource_file_path_ext + "shifty_shell.tres",
	MONSTERS.DESERTHIPPODRAKE : monster_resource_file_path_ext + "desert_hippodrake.tres",
	MONSTERS.SANDYCALFDRAKE : monster_resource_file_path_ext + "sandy_calfdrake.tres",
	MONSTERS.STONYCALFDRAKE : monster_resource_file_path_ext + "stony_calfdrake.tres",
	MONSTERS.PRICKLECALFDRAKE : monster_resource_file_path_ext + "prickle_calfdrake.tres",
	MONSTERS.SENSHIFROG : monster_resource_file_path_ext + "senshi_frog.tres",
	MONSTERS.SWORDSFROG : monster_resource_file_path_ext + "swordsfrog.tres",
	MONSTERS.MAGEFROG : monster_resource_file_path_ext + "magefrog.tres",
	MONSTERS.FROGUE : monster_resource_file_path_ext + "frogue.tres",
	MONSTERS.SPEARFROG : monster_resource_file_path_ext + "spearfrog.tres",
	MONSTERS.EXCALIBLADE : monster_resource_file_path_ext + "excaliblade.tres",
	MONSTERS.ARCANEBLADE : monster_resource_file_path_ext + "arcane_blade.tres",
	MONSTERS.ARCANEHAMMER : monster_resource_file_path_ext + "arcane_hammer.tres",
	MONSTERS.ARCANESHIELD : monster_resource_file_path_ext + "arcane_shield.tres",
	MONSTERS.ARCANEPISTOL : monster_resource_file_path_ext + "arcane_pistol.tres",
	MONSTERS.ANGRYFIN : monster_resource_file_path_ext + "angryfin.tres",
	MONSTERS.GRUMPFLOAT : monster_resource_file_path_ext + "grumpfloat.tres",
	MONSTERS.MOLLOOZK : monster_resource_file_path_ext + "molloozk.tres",
	MONSTERS.SEAMARE : monster_resource_file_path_ext + "seamare.tres",
	MONSTERS.JELLYFLOAT : monster_resource_file_path_ext + "jellyfloat.tres",
	MONSTERS.POISONOAK : monster_resource_file_path_ext + "poison_oak.tres",
	MONSTERS.GREENIONY : monster_resource_file_path_ext + "greeniony.tres",
	MONSTERS.SNAPTRAP : monster_resource_file_path_ext + "snaptrap.tres",
	MONSTERS.COOLSHROOM : monster_resource_file_path_ext + "coolshroom.tres",
	MONSTERS.CHILLROOT : monster_resource_file_path_ext + "chillroot.tres",
	MONSTERS.INFERNUS : monster_resource_file_path_ext + "infernus.tres",
	MONSTERS.PYRUS : monster_resource_file_path_ext + "pyrus.tres",
	MONSTERS.STRATUS : monster_resource_file_path_ext + "stratus.tres",
	MONSTERS.GUSTUS : monster_resource_file_path_ext + "gustus.tres",
	MONSTERS.HYDRUS : monster_resource_file_path_ext + "hydrus.tres",
	MONSTERS.AQUARIUS : monster_resource_file_path_ext + "aquarius.tres",
	MONSTERS.LICHLORD : monster_resource_file_path_ext + "lich_lord.tres",
	MONSTERS.APOSTLICH : monster_resource_file_path_ext + "apostlich.tres",
	MONSTERS.JACKALOPE : monster_resource_file_path_ext + "jackalope.tres",
	MONSTERS.JERRY : monster_resource_file_path_ext + "jerry.tres"
}

#===============================================================================
# Testing Only???
#-------------------------------------------------------------------------------
enum ENEMY_TEAM {
	RANDOM, MOLLUSK, DOG, HIPPODRAKE, FROG,
	ARCANE_TOOLS, SEA_CREATURES, BIZARRE_PLANTS, ELEMENTALS
}

static var ENEMY_TEAMS : Dictionary = {
	ENEMY_TEAM.RANDOM : [],
	ENEMY_TEAM.MOLLUSK : [MONSTERS.NAUTILUS, MONSTERS.CLAMPSHELL, MONSTERS.SHIFTYSHELL, MONSTERS.SHELLCHAMPION],
	ENEMY_TEAM.DOG : [MONSTERS.STABBYCORGI, MONSTERS.AXEWOLF, MONSTERS.SPEARBUD, MONSTERS.FRENCHKINGDOG],
	ENEMY_TEAM.HIPPODRAKE : [MONSTERS.PRICKLECALFDRAKE, MONSTERS.STONYCALFDRAKE, MONSTERS.SANDYCALFDRAKE, MONSTERS.DESERTHIPPODRAKE],
	ENEMY_TEAM.FROG : [MONSTERS.SWORDSFROG, MONSTERS.FROGUE, MONSTERS.MAGEFROG, MONSTERS.SENSHIFROG],
	ENEMY_TEAM.ARCANE_TOOLS : [MONSTERS.ARCANEBLADE, MONSTERS.ARCANESHIELD, MONSTERS.ARCANEHAMMER, MONSTERS.EXCALIBLADE],
	ENEMY_TEAM.SEA_CREATURES : [MONSTERS.GRUMPFLOAT, MONSTERS.MOLLOOZK, MONSTERS.JELLYFLOAT, MONSTERS.ANGRYFIN],
	ENEMY_TEAM.BIZARRE_PLANTS : [MONSTERS.GREENIONY, MONSTERS.COOLSHROOM, MONSTERS.CHILLROOT, MONSTERS.POISONOAK],
	ENEMY_TEAM.ELEMENTALS : [MONSTERS.AQUARIUS, MONSTERS.GUSTUS, MONSTERS.PYRUS, MONSTERS.INFERNUS]
}

static func get_random_leader() -> MONSTERS:
	var leaders : Array[MONSTERS] = [
		MONSTERS.FRENCHKINGDOG, MONSTERS.SHELLCHAMPION, MONSTERS.DESERTHIPPODRAKE,
		MONSTERS.SENSHIFROG, MONSTERS.EXCALIBLADE, MONSTERS.ANGRYFIN,
		MONSTERS.POISONOAK, MONSTERS.INFERNUS, MONSTERS.STRATUS,
		MONSTERS.HYDRUS, MONSTERS.LICHLORD, MONSTERS.JACKALOPE
	]
	return leaders[randi_range(0, leaders.size()-1)]

static func get_random_non_leader() -> MONSTERS:
	var monsters : Array[MONSTERS] = [
		MONSTERS.SPEARBUD, MONSTERS.STABBYCORGI, MONSTERS.AXEWOLF,
		MONSTERS.NAUTILUS, MONSTERS.GOOPSHELL, MONSTERS.CLAMPSHELL, MONSTERS.SHIFTYSHELL,
		MONSTERS.SANDYCALFDRAKE, MONSTERS.STONYCALFDRAKE, MONSTERS.PRICKLECALFDRAKE,
		MONSTERS.SWORDSFROG, MONSTERS.MAGEFROG, MONSTERS.FROGUE, MONSTERS.SPEARFROG,
		MONSTERS.ARCANEBLADE, MONSTERS.ARCANEHAMMER, MONSTERS.ARCANESHIELD, MONSTERS.ARCANEPISTOL,
		MONSTERS.GRUMPFLOAT, MONSTERS.MOLLOOZK, MONSTERS.SEAMARE, MONSTERS.JELLYFLOAT,
		MONSTERS.GREENIONY, MONSTERS.SNAPTRAP, MONSTERS.COOLSHROOM, MONSTERS.CHILLROOT,
		MONSTERS.PYRUS, MONSTERS.GUSTUS, MONSTERS.AQUARIUS, MONSTERS.APOSTLICH, MONSTERS.JERRY
	]
	return monsters[randi_range(0, monsters.size()-1)]
