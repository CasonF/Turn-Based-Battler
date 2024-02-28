class_name MonsterSelButton
extends Button

signal selected_monster(monster: MonsterStats)
signal team_monster(monster: Monster)

var monster_stats : MonsterStats
var monster : Monster

func _ready() -> void:
	if monster_stats:
		text = monster_stats.monster_name
		if monster_stats.is_monster_leader:
			add_theme_color_override("font_color", Color("YELLOW"))
	elif monster:
		text = monster.data.monster_name + " - LV" + str(monster.level)
		if monster.data.is_monster_leader:
			add_theme_color_override("font_color", Color("YELLOW"))

func _pressed() -> void:
	if monster_stats:
		selected_monster.emit(monster_stats)
	elif monster:
		team_monster.emit(monster)
