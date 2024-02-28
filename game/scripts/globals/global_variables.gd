class_name GlobalVariables
extends Node

static var debug_mode : bool = true
# Change this if the file path for all monster resources changes...
const monster_resource_file_path_ext : String = "res://game/resources/monster_stats/"

enum MONSTERS {
	FRENCHKINGDOG, SPEARBUD, STABBYCORGI, AXEWOLF,
	SHELLCHAMPION, NAUTILUS, GOOPSHELL, CLAMPSHELL, SHIFTYSHELL,
	DESERTHIPPODRAKE, SANDYCALFDRAKE, STONYCALFDRAKE, PRICKLECALFDRAKE,
	SENSHIFROG, SWORDSFROG, MAGEFROG, FROGUE, SPEARFROG,
	EXCALIBLADE, ARCANEBLADE, ARCANEHAMMER, ARCANESHIELD, ARCANEPISTOL,
	ANGRYFIN, GRUMPFLOAT, MOLLOOZK, SEAMARE, JELLYFLOAT
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
	MONSTERS.JELLYFLOAT : monster_resource_file_path_ext + "jellyfloat.tres"
}

#===============================================================================
# Testing Only???
#-------------------------------------------------------------------------------
enum ENEMY_TEAM {
	RANDOM, MOLLUSK, DOG, HIPPODRAKE, FROG, ARCANE_TOOLS, SEA_CREATURES
}

static var ENEMY_TEAMS : Dictionary = {
	ENEMY_TEAM.RANDOM : [],
	ENEMY_TEAM.MOLLUSK : [MONSTERS.NAUTILUS, MONSTERS.CLAMPSHELL, MONSTERS.SHIFTYSHELL, MONSTERS.SHELLCHAMPION],
	ENEMY_TEAM.DOG : [MONSTERS.STABBYCORGI, MONSTERS.AXEWOLF, MONSTERS.SPEARBUD, MONSTERS.FRENCHKINGDOG],
	ENEMY_TEAM.HIPPODRAKE : [MONSTERS.PRICKLECALFDRAKE, MONSTERS.STONYCALFDRAKE, MONSTERS.SANDYCALFDRAKE, MONSTERS.DESERTHIPPODRAKE],
	ENEMY_TEAM.FROG : [MONSTERS.SWORDSFROG, MONSTERS.FROGUE, MONSTERS.MAGEFROG, MONSTERS.SENSHIFROG],
	ENEMY_TEAM.ARCANE_TOOLS : [MONSTERS.ARCANEBLADE, MONSTERS.ARCANESHIELD, MONSTERS.ARCANEHAMMER, MONSTERS.EXCALIBLADE],
	ENEMY_TEAM.SEA_CREATURES : [MONSTERS.GRUMPFLOAT, MONSTERS.MOLLOOZK, MONSTERS.JELLYFLOAT, MONSTERS.ANGRYFIN]
}

static func get_random_leader() -> MONSTERS:
	var leaders : Array[MONSTERS] = [
		MONSTERS.FRENCHKINGDOG, MONSTERS.SHELLCHAMPION, MONSTERS.DESERTHIPPODRAKE,
		MONSTERS.SENSHIFROG, MONSTERS.EXCALIBLADE, MONSTERS.ANGRYFIN
	]
	return leaders[randi_range(0, leaders.size()-1)]

static func get_random_non_leader() -> MONSTERS:
	var monsters : Array[MONSTERS] = [
		MONSTERS.SPEARBUD, MONSTERS.STABBYCORGI, MONSTERS.AXEWOLF,
		MONSTERS.NAUTILUS, MONSTERS.GOOPSHELL, MONSTERS.CLAMPSHELL, MONSTERS.SHIFTYSHELL,
		MONSTERS.SANDYCALFDRAKE, MONSTERS.STONYCALFDRAKE, MONSTERS.PRICKLECALFDRAKE,
		MONSTERS.SWORDSFROG, MONSTERS.MAGEFROG, MONSTERS.FROGUE, MONSTERS.SPEARFROG,
		MONSTERS.ARCANEBLADE, MONSTERS.ARCANEHAMMER, MONSTERS.ARCANESHIELD, MONSTERS.ARCANEPISTOL,
		MONSTERS.GRUMPFLOAT, MONSTERS.MOLLOOZK, MONSTERS.SEAMARE, MONSTERS.JELLYFLOAT
	]
	return monsters[randi_range(0, monsters.size()-1)]
