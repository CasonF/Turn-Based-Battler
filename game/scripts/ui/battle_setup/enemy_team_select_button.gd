class_name EnemyTeamSelButton
extends Button

signal toggle_enemy_team(btn: EnemyTeamSelButton, selected_team: Array[Monster])

var team_name : String
var team : Array[MonsterStats]

func _ready() -> void:
	if team:
		text = team_name if team_name else "Unknown Team"

func _pressed() -> void:
	if team:
		toggle_enemy_team.emit(self)
