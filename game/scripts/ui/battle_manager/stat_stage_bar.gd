class_name StatStageBar
extends ProgressBar

@onready var neg_stat_bar: ProgressBar = $StatStageBarNeg

@export var stat_stage: Monster.STAT_STAGE
var monster: Monster
var stage: int = 0

func _ready() -> void:
	_setup()

func _setup() -> void:
	if monster:
		if stat_stage == Monster.STAT_STAGE.ATK:
			stage = abs(monster.ATK_STAGE)
			setup_stat_bar(monster.ATK_STAGE)
		elif stat_stage == Monster.STAT_STAGE.DEF:
			stage = abs(monster.DEF_STAGE)
			setup_stat_bar(monster.DEF_STAGE)
		elif stat_stage == Monster.STAT_STAGE.MATK:
			stage = abs(monster.MATK_STAGE)
			setup_stat_bar(monster.MATK_STAGE)
		elif stat_stage == Monster.STAT_STAGE.MDEF:
			stage = abs(monster.MDEF_STAGE)
			setup_stat_bar(monster.MDEF_STAGE)
		elif stat_stage == Monster.STAT_STAGE.SPD:
			stage = abs(monster.SPD_STAGE)
			setup_stat_bar(monster.SPD_STAGE)
		else:
			print("Unknown monster stat: ", Monster.STAT_STAGE.keys()[stat_stage])

func set_monster(mon: Monster) -> void:
	monster = mon
	_setup()

func setup_stat_bar(passed_stat_stage: int) -> void:
	if passed_stat_stage > 0:
		neg_stat_bar.value = 0
		value = stage
	elif passed_stat_stage < 0:
		value = 0
		neg_stat_bar.value = stage
	else:
		neg_stat_bar.value = 0
		value = 0
