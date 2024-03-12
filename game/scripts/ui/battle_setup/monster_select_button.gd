class_name MonsterSelButton
extends Button

signal selected_monster(monster: MonsterStats)
signal team_monster(monster: Monster)
#signal remove_from_party

var monster_stats : MonsterStats
var monster : Monster

var font: Font = preload("res://game/assets/fonts/DungeonFont.ttf")

func _ready() -> void:
	if monster_stats:
		text = monster_stats.monster_name
		if monster_stats.is_monster_leader:
			add_theme_color_override("font_color", Color("YELLOW"))
	elif monster:
		text = monster.data.monster_name + " - LV" + str(monster.level)
		if monster.data.is_monster_leader:
			add_theme_color_override("font_color", Color("YELLOW"))
	add_theme_color_override("font_outline_color", Color("BLACK"))
	add_theme_constant_override("outline_size", 5)
	add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", 24)

func _pressed() -> void:
	if monster_stats:
		selected_monster.emit(monster_stats)
	elif monster:
		team_monster.emit(monster)
