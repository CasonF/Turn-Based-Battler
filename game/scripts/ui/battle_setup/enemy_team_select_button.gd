class_name EnemyTeamSelButton
extends Button

signal toggle_enemy_team(btn: EnemyTeamSelButton, selected_team: Array[Monster])

var team_name : String
var team : Array[MonsterStats]

var font: Font = preload("res://game/assets/fonts/DungeonFont.ttf")

func _ready() -> void:
	if team:
		text = team_name if team_name else "Unknown Team"
	add_theme_color_override("font_color", Color("ORANGE"))
	add_theme_color_override("font_outline_color", Color("BLACK"))
	add_theme_constant_override("outline_size", 6)
	add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", 32)

func _pressed() -> void:
	if team:
		toggle_enemy_team.emit(self)
