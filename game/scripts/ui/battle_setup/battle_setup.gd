class_name BattleSetup
extends Node

# This may end up just being a test script... But worth the investment to test/learn
@export var music_player: AudioStreamPlayer

@onready var monster_list := $Panel/ScrollContainer/MonsterList
@onready var party_list := $Panel/PlayerParty
@onready var monster_display_sprite := $MonserSpriteScaler/MonsterSprite
@onready var monster_spotlight := $MonserSpriteScaler/MonsterSpotlight
@onready var stat_hex : StatHex = $MonsterStatsPanel/AspectRatioContainer/StatHex

@onready var enemy_team_list := $MonsterStatsPanel/ScrollContainer2/EnemyTeamList

var displayed_mon_stats : MonsterStats
var displayed_team_mon : Monster

var enemy_teams_btns: Dictionary
var toggled_enemy_team_btn : EnemyTeamSelButton

var monsters: Array[MonsterStats]

func _ready() -> void:
	get_monster_list()
	setup_monster_buttons()
	setup_enemy_team_list()
	setup_enemy_team_buttons()
	get_updated_player_party()
	#...
	connect_signals()

func _process(delta) -> void:
	if GlobalVariables.debug_mode:
		debug_checks()
	if monster_spotlight:
		monster_spotlight.rotation += 0.1 * delta

func connect_signals() -> void:
	if music_player:
		music_player.finished.connect(replay_music)

func replay_music() -> void:
	music_player.play()

func get_monster_list() -> void:
	var monster_dict : Dictionary = GlobalVariables.MONSTER_DICT
	for key in monster_dict.keys():
		var monster_stats : MonsterStats = load(monster_dict.get(key))
		if monster_stats:
			monsters.append(monster_stats)

func setup_monster_buttons() -> void:
	for mon: MonsterStats in monsters:
		var button : MonsterSelButton = MonsterSelButton.new()
		button.selected_monster.connect(display_monster_data)
		button.monster_stats = mon
		monster_list.add_child(button)

func setup_enemy_team_list() -> void:
	var enemy_teams : Dictionary = GlobalVariables.ENEMY_TEAMS
	for key in enemy_teams.keys():
		var team_stat_array: Array[MonsterStats]
		if enemy_teams.get(key).size() == 0:
			for i:int in 3:
				var monster_stats : MonsterStats = load(GlobalVariables.MONSTER_DICT.get(GlobalVariables.get_random_non_leader()))
				if monster_stats:
					team_stat_array.append(monster_stats)
			var leader_stats : MonsterStats = load(GlobalVariables.MONSTER_DICT.get(GlobalVariables.get_random_leader()))
			if leader_stats:
				team_stat_array.append(leader_stats)
		else:
			for mon in enemy_teams.get(key):
				var monster_stats : MonsterStats = load(GlobalVariables.MONSTER_DICT.get(mon))
				if monster_stats:
					team_stat_array.append(monster_stats)
		enemy_teams_btns[key] = team_stat_array

func setup_enemy_team_buttons() -> void:
	for key in enemy_teams_btns:
		var enemy_team_btn : EnemyTeamSelButton = EnemyTeamSelButton.new()
		enemy_team_btn.toggle_mode = true
		enemy_team_btn.add_theme_color_override("font_pressed_color", Color("b88b1c"))
		enemy_team_btn.team_name = GlobalVariables.ENEMY_TEAM.keys()[key]
		enemy_team_btn.team = enemy_teams_btns[key]
		enemy_team_btn.toggle_enemy_team.connect(select_enemy_team)
		enemy_team_list.add_child(enemy_team_btn)

func select_enemy_team(toggled: EnemyTeamSelButton) -> void:
	var team : Array[MonsterStats]
	if toggled.button_pressed:
		team = toggled.team
	var toggled_enemy_team_btn = toggled
	for btn: EnemyTeamSelButton in enemy_team_list.get_children():
		if btn != toggled_enemy_team_btn and btn.button_pressed:
			btn.button_pressed = false
	_set_enemy_team_list(team)

func display_team_monster(mon: Monster) -> void:
	displayed_mon_stats = null
	displayed_team_mon = mon
	monster_display_sprite.texture = mon.data.sprite
	monster_spotlight.show()
	stat_hex.set_monster_stats(mon.data)

func display_monster_data(stats: MonsterStats) -> void:
	displayed_team_mon = null
	displayed_mon_stats = stats
	monster_display_sprite.texture = stats.sprite
	monster_spotlight.show()
	stat_hex.set_monster_stats(stats)

func clear_monster_data_display() -> void:
	monster_display_sprite.texture = null
	monster_spotlight.hide()
	stat_hex.set_monster_stats(null)

func _add_monster_to_player_party() -> void:
	if displayed_mon_stats:
		if displayed_mon_stats.is_monster_leader:
			if !TeamManager.add_player_leader(displayed_mon_stats, 20):
				print("Team cannot exceed 4 members")
		else:
			if !TeamManager.add_player_monster(displayed_mon_stats, 20):
				print("Team cannot exceed 4 members")
	get_updated_player_party()

func get_updated_player_party() -> void:
	for child in party_list.get_children():
		child.queue_free()
	for mem in TeamManager.PLAYER_TEAM:
		var button : MonsterSelButton = MonsterSelButton.new()
		button.team_monster.connect(display_team_monster)
		button.monster = mem
		party_list.add_child(button)

func _remove_monster_from_player_party() -> void:
	if displayed_team_mon:
		TeamManager.remove_player_monster(displayed_team_mon)
		displayed_team_mon = null
		get_updated_player_party()
		clear_monster_data_display()
	elif GlobalVariables.debug_mode:
		print("Party monster not selected!")

func _set_enemy_team_list(team: Array[MonsterStats]) -> void:
	TeamManager.set_enemy_team(team)

func load_battle_scene() -> void:
	if TeamManager.PLAYER_TEAM.size() > 0 and TeamManager.ENEMY_TEAM.size() > 0:
		get_tree().change_scene_to_file("res://game/scenes/battle_manager.tscn")

func debug_checks() -> void:
	if Input.is_action_just_pressed("check_player_party"): # G key
		for m: Monster in TeamManager.PLAYER_TEAM:
			print(m.data.monster_name + "," + str(m.level))
	if Input.is_action_just_pressed("check_enemy_party"): # B key
		for m: Monster in TeamManager.ENEMY_TEAM:
			print(m.data.monster_name + "," + str(m.level))
