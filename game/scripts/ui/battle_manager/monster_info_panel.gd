class_name MonsterInfoPanel
extends Label

@onready var info_panel := $InfoPanel

@onready var atk_stage : StatStageBar = $InfoPanel/StatStages/ATKStage
@onready var def_stage : StatStageBar = $InfoPanel/StatStages/DEFStage
@onready var matk_stage : StatStageBar = $InfoPanel/StatStages/MATKStage
@onready var mdef_stage : StatStageBar = $InfoPanel/StatStages/MDEFStage
@onready var spd_stage : StatStageBar = $InfoPanel/StatStages/SPDStage

@onready var i_burn : Sprite2D = $InfoPanel/Status/BurnControl/BurnStatus
@onready var i_freeze : Sprite2D = $InfoPanel/Status/FreezeControl/FreezeStatus
@onready var i_poison : Sprite2D = $InfoPanel/Status/PoisonControl/PoisonStatus

var monster: Monster:
	set(value):
		monster = value
		text = monster.data.monster_name + " - " + str(monster.level)
		setup_info_panel()

var mouse_hovering: bool = false
var set_monster: bool = false

func _ready() -> void:
	if monster:
		text = monster.data.monster_name + " - " + str(monster.level)

func _process(delta) -> void:
	if mouse_hovering:
		show_info_panel(delta)
	else:
		hide_info_panel(delta)

func _mouse_entered() -> void:
	mouse_hovering = true
	setup_statuses()

func _mouse_exited() -> void:
	mouse_hovering = false

func show_info_panel(delta) -> void:
	if !set_monster:
		setup_info_panel()
	if info_panel.modulate.a < 1:
		info_panel.modulate.a += delta

func hide_info_panel(delta) -> void:
	if info_panel.modulate.a > 0:
		info_panel.modulate.a -= delta
	set_monster = false

func setup_info_panel() -> void:
	if monster:
		set_monster = true
		# Do status stuff here...
		# ...
		setup_stat_stages()
		setup_statuses()

func setup_stat_stages() -> void:
	atk_stage.set_monster(monster)
	def_stage.set_monster(monster)
	matk_stage.set_monster(monster)
	mdef_stage.set_monster(monster)
	spd_stage.set_monster(monster)

func setup_statuses() -> void:
	if monster.active_statuses.has(monster.STATUSES.BURN):
		i_burn.self_modulate.a = 5
	else:
		i_burn.self_modulate.a = 1
	if monster.active_statuses.has(monster.STATUSES.FREEZE):
		i_freeze.self_modulate.a = 5
	else:
		i_freeze.self_modulate.a = 1
	if monster.active_statuses.has(monster.STATUSES.POISON):
		i_poison.self_modulate.a = 5
	else:
		i_poison.self_modulate.a = 1
