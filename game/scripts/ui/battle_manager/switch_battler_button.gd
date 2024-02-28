class_name SwitchBattlerButton
extends Button

signal switch_to_monster(mon: Monster)

var monster: Monster
@onready var hp_bar : ProgressBar = $DisplayHP

@export var high_hp_color : Color
@export var med_hp_color : Color
@export var low_hp_color : Color

func _ready() -> void:
	if monster:
		icon = monster.data.sprite
		text = monster.data.monster_name + " - " + str(monster.level)
		update_hp_bar()

func update_hp_bar() -> void:
	hp_bar.max_value = monster.HP
	hp_bar.value = monster.current_hp
	check_hp_bar_color()

func check_hp_bar_color() -> void:
	var hp_stylebox : StyleBoxFlat = StyleBoxFlat.new()
	if float(hp_bar.value) / float(hp_bar.max_value) > 0.5:
		hp_stylebox.bg_color = high_hp_color
		hp_bar.add_theme_stylebox_override("fill", hp_stylebox)
	elif float(hp_bar.value) / float(hp_bar.max_value) > 0.25:
		hp_stylebox.bg_color = med_hp_color
		hp_bar.add_theme_stylebox_override("fill", hp_stylebox)
	else:
		hp_stylebox.bg_color = low_hp_color
		hp_bar.add_theme_stylebox_override("fill", hp_stylebox)

func _pressed() -> void:
	switch_to_monster.emit(monster)
