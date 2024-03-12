class_name Monster
extends Sprite2D

@export var data : MonsterStats

signal knocked_out(mon: Monster)

func _ready() -> void:
	if data:
		texture = data.sprite

@export_range(1, 100, 1) var level : int = 1
var current_hp : int
var armor : int
var AP : int = 0

var known_actions: Array[MonsterAction] = []
#===============================================================================
# Field Effects and Status
#-------------------------------------------------------------------------------
enum STATUSES {BURN, FREEZE, POISON}
var active_statuses: Array[STATUSES] = []

var has_sigil_sphere : bool = false

var chain_lightning_counter : int = 0
#===============================================================================
# Get calc'd stats
#-------------------------------------------------------------------------------
var HP : int :
	get: return ((data.hp * 2 * level) / 100) + level + 10
var ATK : int :
	get: return ((data.atk * 2 * level) / 100) + 4
var DEF : int :
	get: return ((data.def * 2 * level) / 100) + 4
var MATK : int :
	get: return ((data.matk * 2 * level) / 100) + 4
var MDEF : int :
	get: return ((data.mdef * 2 * level) / 100) + 4
var SPD : int :
	get: return ((data.spd * 2 * level) / 100) + 4

enum STAT_STAGE {ATK, DEF, MATK, MDEF, SPD}
var ATK_STAGE : int = 0
var DEF_STAGE : int = 0
var MATK_STAGE : int = 0
var MDEF_STAGE : int = 0
var SPD_STAGE : int = 0

func _process(_delta) -> void:
	if GlobalVariables.debug_mode:
		debug_actions()

func take_damage(damage: int) -> void:
	print(data.monster_name + " took " + str(damage) + " damage!")
	if armor >= damage:
		armor -= damage
	else:
		var remainder : int = damage - armor
		armor = 0
		if remainder >= current_hp:
			current_hp = 0
		else:
			current_hp -= remainder
	
	if current_hp <= 0:
		knocked_out.emit(self)

func heal(amount: int) -> void:
	if (amount + current_hp) >= HP:
		print(data.monster_name + " healed " + str(clamp(HP - (amount + current_hp), 0, amount)) + " HP!")
		current_hp = HP
	else:
		print(data.monster_name + " healed " + str(amount) + " HP!")
		current_hp += amount

func gain_armor(amount: int) -> void:
	if (amount + armor) >= HP:
		print(data.monster_name + " gained " + str(clamp(HP - (amount + armor), 0, amount)) + " armor!")
		armor = HP
	else:
		print(data.monster_name + " gained " + str(amount) + " armor!")
		armor += amount

func gain_AP(amount: int = 1) -> void:
	if (amount + AP) >= 5:
		AP = 5
	else:
		AP += amount

func update_stat_stage(stat: STAT_STAGE, amount: int) -> void:
	if stat == STAT_STAGE.ATK:
		if ATK_STAGE + amount > 3:
			print(data.monster_name, "'s ATK cannot be raised higher!")
			ATK_STAGE = 3
		elif ATK_STAGE + amount < -3:
			print(data.monster_name, "'s ATK cannot be lowered further!")
			ATK_STAGE = -3
		else:
			if amount > 0:
				print(data.monster_name, " gained ", amount, " stages in ATK!")
			else:
				print(data.monster_name, " lost ", abs(amount), " stages in ATK!")
			ATK_STAGE += amount
	elif stat == STAT_STAGE.DEF:
		if DEF_STAGE + amount > 3:
			DEF_STAGE = 3
		elif DEF_STAGE + amount < -3:
			DEF_STAGE = -3
		else:
			DEF_STAGE += amount
	elif stat == STAT_STAGE.MATK:
		if MATK_STAGE + amount > 3:
			MATK_STAGE = 3
		elif MATK_STAGE + amount < -3:
			MATK_STAGE = -3
		else:
			MATK_STAGE += amount
	elif stat == STAT_STAGE.MDEF:
		if MDEF_STAGE + amount > 3:
			MDEF_STAGE = 3
		elif MDEF_STAGE + amount < -3:
			MDEF_STAGE = -3
		else:
			MDEF_STAGE += amount
	elif stat == STAT_STAGE.SPD:
		if SPD_STAGE + amount > 3:
			SPD_STAGE = 3
		elif SPD_STAGE + amount < -3:
			SPD_STAGE = -3
		else:
			SPD_STAGE += amount
	else:
		print("Unhandled stat type.")

func reset_stat_stages() -> void:
	ATK_STAGE = 0
	DEF_STAGE = 0
	MATK_STAGE = 0
	MDEF_STAGE = 0
	SPD_STAGE = 0
#===============================================================================
static func create(monster = GlobalVariables.MONSTERS.FRENCHKINGDOG, monster_level: int = 20) -> Monster:
	var mon: Monster = Monster.new()
	var stats: MonsterStats
	if monster is String:
		stats = load("res://game/resources/monster_stats/" + monster.to_snake_case() + ".tres")
		mon.known_actions = stats.actions
		mon.level = monster_level
	elif monster is GlobalVariables.MONSTERS:
		stats = load(GlobalVariables.MONSTER_DICT.get(monster))
		mon.known_actions = stats.actions
		mon.level = monster_level
	elif monster is MonsterStats:
		stats = monster
		mon.known_actions = stats.actions
		mon.level = monster_level
	elif monster is Monster:
		stats = monster.data
		mon.level = monster.level
		mon.current_hp = monster.current_hp
		mon.active_statuses = monster.active_statuses
		mon.known_actions = monster.known_actions
	mon.data = stats
	return mon

func print_stats() -> void:
	prints("Monster:", data.monster_name, "Level:", str(level))
	prints("HP:", str(HP), "ATK:", str(ATK), "DEF:", str(DEF))
	prints("SPD:", str(SPD), "MATK:", str(MATK), "MDEF:", str(MDEF))

func debug_actions() -> void:
	if Input.is_action_just_pressed("debug_checkstats"):
		pass
