class_name StatHex
extends Node

@onready var stat_display : StatChart = $StatChart
# Stat Value Displays
@onready var hp_val : Label = $HP/HPValue
@onready var atk_val : Label = $ATK/ATKValue
@onready var def_val : Label = $DEF/DEFValue
@onready var spd_val : Label = $SPD/SPDValue
@onready var matk_val : Label = $MATK/MATKValue
@onready var mdef_val : Label = $MDEF/MDEFValue

@export var monster_stats : MonsterStats

@export var hp_point: Vector2 = Vector2(0, -180)
@export var atk_point: Vector2 = Vector2(157.5, -90)
@export var def_point: Vector2 = Vector2(157.5, 90)
@export var spd_point: Vector2 = Vector2(0, 180)
@export var mdef_point: Vector2 = Vector2(-157.5, 90)
@export var matk_point: Vector2 = Vector2(-157.5, -90)

func _ready() -> void:
	if monster_stats:
		setup_hex_display()

func setup_hex_display() -> void:
	if monster_stats:
		var hp : Vector2 = hp_point * (float(monster_stats.hp) / 200.0)
		var atk : Vector2 = atk_point * (float(monster_stats.atk) / 200.0)
		var def : Vector2 = def_point * (float(monster_stats.def) / 200.0)
		var spd : Vector2 = spd_point * (float(monster_stats.spd) / 200.0)
		var mdef : Vector2 = mdef_point * (float(monster_stats.mdef) / 200.0)
		var matk : Vector2 = matk_point * (float(monster_stats.matk) / 200.0)
		
		hp_val.text = str(monster_stats.hp)
		atk_val.text = str(monster_stats.atk)
		def_val.text = str(monster_stats.def)
		spd_val.text = str(monster_stats.spd)
		mdef_val.text = str(monster_stats.mdef)
		matk_val.text = str(monster_stats.matk)
		
		stat_display.points = PackedVector2Array([hp, atk, def, spd, mdef, matk])
	else:
		hp_val.text = ""
		atk_val.text = ""
		def_val.text = ""
		spd_val.text = ""
		mdef_val.text = ""
		matk_val.text = ""
		
		stat_display.points = PackedVector2Array([])
	stat_display.queue_redraw()

func set_monster_stats(stats: MonsterStats) -> void:
	monster_stats = stats
	setup_hex_display()
