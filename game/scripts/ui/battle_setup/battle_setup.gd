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
	update_player_party_display()
	#...
	setup_music_player()
	connect_signals()
	connect_team_signals()

func _process(delta) -> void:
	if GlobalVariables.debug_mode:
		debug_checks()
	if monster_spotlight:
		monster_spotlight.rotation += 0.1 * delta

func connect_signals() -> void:
	if music_player:
		music_player.finished.connect(replay_music)

func setup_music_player() -> void:
	if music_player:
		music_player.volume_db = GlobalSettings.get_global_volume()

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
	var selected_enemy_team_btn = toggled
	for btn: EnemyTeamSelButton in enemy_team_list.get_children():
		if btn != selected_enemy_team_btn and btn.button_pressed:
			btn.button_pressed = false
	_set_enemy_team_list(team)

func display_team_monster(mon: Monster) -> void:
	displayed_mon_stats = null
	displayed_team_mon = mon
	monster_display_sprite.texture = mon.data.sprite
	monster_spotlight.show()
	stat_hex.set_monster_stats(mon.data)
	setup_monster_selection_panel(mon)

func display_monster_data(stats: MonsterStats) -> void:
	displayed_team_mon = null
	displayed_mon_stats = stats
	monster_display_sprite.texture = stats.sprite
	monster_spotlight.show()
	stat_hex.set_monster_stats(stats)
	setup_monster_selection_panel(stats)

@onready var monster_action_list: VBoxContainer = $MonsterSelectionPanel/VBoxContainer/MonsterActionList/ActionList
func setup_monster_selection_panel(monster) -> void:
	if monster and monster != null:
		if monster is MonsterStats or monster is Monster:
			setup_action_list(monster)
			show_monster_selection_panel()

@onready var monster_selection_panel: Panel = $MonsterSelectionPanel
@onready var action_description: Label = $MonsterSelectionPanel/VBoxContainer/ActionDescriptionScroll/ActionDescription
func show_monster_selection_panel() -> void:
	monster_selection_panel.show()

func hide_monster_selection_panel() -> void:
	monster_selection_panel.hide()
	action_description.text = ""

func setup_action_list(stats) -> void:
	for child in monster_action_list.get_children():
		child.queue_free()
	
	var final_action_list : Array[MonsterAction] = []
	if stats is MonsterStats:
		final_action_list.append_array(stats.knowable_actions)
		for action in stats.actions:
			if !final_action_list.has(action):
				final_action_list.append(action)
	elif stats is Monster:
		final_action_list.append_array(stats.data.knowable_actions)
		for action in stats.data.actions:
			if !final_action_list.has(action):
				final_action_list.append(action)
	# Now set up buttons... For move selection
	var action_list_height: int = round(float(final_action_list.size()) / 2.0)
	for i:int in action_list_height:
		var action_select_hbox: HBoxContainer = HBoxContainer.new()
		action_select_hbox.size_flags_horizontal = Control.SIZE_FILL
		action_select_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if final_action_list.size() > 1:
			var action_select: MonsterActionSelect = create_mon_action_select_button(final_action_list.pop_front(), stats)
			var action_select_2: MonsterActionSelect = create_mon_action_select_button(final_action_list.pop_front(), stats)
			action_select_hbox.add_child(action_select)
			action_select_hbox.add_child(action_select_2)
		elif final_action_list.size() > 0:
			var action_select: MonsterActionSelect = create_mon_action_select_button(final_action_list.pop_front(), stats)
			action_select_hbox.add_child(action_select)
		monster_action_list.add_child(action_select_hbox)

func create_mon_action_select_button(action: MonsterAction, stats) -> MonsterActionSelect:
	var action_select: MonsterActionSelect = MonsterActionSelect.new()
	action_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_select.toggle_mode = true
	action_select.action = action
	if stats is MonsterStats:
		if stats.actions.has(action_select.action):
			action_select.button_pressed = true
	elif stats is Monster:
		if stats.known_actions.has(action_select.action):
			action_select.button_pressed = true
	action_select.action_selected.connect(can_select_monster_action)
	return action_select

func can_select_monster_action(action: MonsterAction, btn: MonsterActionSelect) -> void:
	action_description.text = str(action.ACTION_TYPE.keys()[action.action_type]).to_pascal_case()
	action_description.text += " - " + str(action.ATTACK_TYPE.keys()[action.attack_type]).to_pascal_case()
	action_description.text += " : Power - " + str(action.power)
	action_description.text += " : AP Cost - " + action.AP
	if action.description.size() > 0:
		action_description.text += "\n" + action.description[0]
	var selected: int = 0
	var action_arr: Array[MonsterAction] = []
	for child in monster_action_list.get_children(true):
		for ch in child.get_children():
			if ch is MonsterActionSelect:
				if ch.button_pressed:
					selected += 1
					action_arr.append(ch.action)
	if btn.button_pressed and selected > 4:
		btn.button_pressed = false
		action_arr.pop_at(action_arr.find(action))
	setup_team_mon_moves(action_arr)

func check_selected_actions() -> Array[MonsterAction]:
	var action_arr: Array[MonsterAction] = []
	for child in monster_action_list.get_children(true):
		for ch in child.get_children():
			if ch is MonsterActionSelect:
				if ch.button_pressed and action_arr.size() < 4:
					action_arr.append(ch.action)
	return action_arr

func setup_team_mon_moves(action_array: Array[MonsterAction]) -> void:
	if displayed_team_mon:
		if action_array.size() > 0:
			displayed_team_mon.known_actions = action_array
		else:
			displayed_team_mon.known_actions = displayed_team_mon.data.actions
		update_player_party()

func clear_monster_data_display() -> void:
	monster_display_sprite.texture = null
	monster_spotlight.hide()
	stat_hex.set_monster_stats(null)

func _add_monster_to_player_party() -> void:
	if displayed_mon_stats:
		var actions: Array[MonsterAction] = check_selected_actions()
		if displayed_mon_stats.is_monster_leader:
			if !TeamManager.add_player_leader(displayed_mon_stats, 20, actions):
				print("Team cannot exceed 4 members")
		else:
			if !TeamManager.add_player_monster(displayed_mon_stats, 20, actions):
				print("Team cannot exceed 4 members")
	update_player_party_display()
#===============================================================================
# Player Party Manip
#-------------------------------------------------------------------------------
@onready var team_mon_1: TeamMonsterSelBtn = $Panel/PlayerParty/PartyRow1/TeamMonsterSelect
@onready var team_mon_2: TeamMonsterSelBtn = $Panel/PlayerParty/PartyRow1/TeamMonsterSelect2
@onready var team_mon_3: TeamMonsterSelBtn = $Panel/PlayerParty/PartyRow2/TeamMonsterSelect
@onready var team_mon_4: TeamMonsterSelBtn = $Panel/PlayerParty/PartyRow2/TeamMonsterSelect2

func connect_team_signals() -> void:
	team_mon_1.team_monster.connect(display_team_monster)
	team_mon_1.dropped_team_monster.connect(reorder_party)
	team_mon_1.remove_from_party.connect(_remove_player_mon)
	team_mon_2.team_monster.connect(display_team_monster)
	team_mon_2.dropped_team_monster.connect(reorder_party)
	team_mon_2.remove_from_party.connect(_remove_player_mon)
	team_mon_3.team_monster.connect(display_team_monster)
	team_mon_3.dropped_team_monster.connect(reorder_party)
	team_mon_3.remove_from_party.connect(_remove_player_mon)
	team_mon_4.team_monster.connect(display_team_monster)
	team_mon_4.dropped_team_monster.connect(reorder_party)
	team_mon_4.remove_from_party.connect(_remove_player_mon)

func reorder_party() -> void:
	# True means slot is occupied, false means it is not
	var party_slots := [team_mon_1.monster != null, team_mon_2.monster != null,
	team_mon_3.monster != null, team_mon_4.monster != null]
	
	if party_slots.has(true):
		if !party_slots[0]:
			if party_slots[1]:
				team_mon_1.monster = team_mon_2.monster
				team_mon_2.monster = null
				team_mon_2.monster_backup = null
				party_slots[1] = false
			elif party_slots[2]:
				team_mon_1.monster = team_mon_3.monster
				team_mon_3.monster = null
				team_mon_3.monster_backup = null
				party_slots[2] = false
			elif party_slots[3]:
				team_mon_1.monster = team_mon_4.monster
				team_mon_4.monster = null
				team_mon_4.monster_backup = null
				party_slots[3] = false
		if !party_slots[1]:
			if party_slots[2]:
				team_mon_2.monster = team_mon_3.monster
				team_mon_3.monster = null
				team_mon_3.monster_backup = null
				party_slots[2] = false
			elif party_slots[3]:
				team_mon_2.monster = team_mon_4.monster
				team_mon_4.monster = null
				team_mon_4.monster_backup = null
				party_slots[3] = false
		if !party_slots[2]:
			if party_slots[3]:
				team_mon_3.monster = team_mon_4.monster
				team_mon_4.monster = null
				team_mon_4.monster_backup = null
				party_slots[3] = false
		if !party_slots[3]:
			team_mon_4.monster = null
			team_mon_4.monster_backup = null
			party_slots[3] = false
	update_player_party()

func update_player_party() -> void:
	if team_mon_1.monster != null:
		TeamManager.PLAYER_TEAM[0] = team_mon_1.monster
	elif TeamManager.PLAYER_TEAM.size() == 1:
		TeamManager.PLAYER_TEAM.pop_back()
	if team_mon_2.monster != null:
		TeamManager.PLAYER_TEAM[1] = team_mon_2.monster
	elif TeamManager.PLAYER_TEAM.size() == 2:
		TeamManager.PLAYER_TEAM.pop_back()
	if team_mon_3.monster != null:
		TeamManager.PLAYER_TEAM[2] = team_mon_3.monster
	elif TeamManager.PLAYER_TEAM.size() == 3:
		TeamManager.PLAYER_TEAM.pop_back()
	if team_mon_4.monster != null:
		TeamManager.PLAYER_TEAM[3] = team_mon_4.monster
	elif TeamManager.PLAYER_TEAM.size() == 4:
		TeamManager.PLAYER_TEAM.pop_back()

func update_player_party_display() -> void:
	if TeamManager.PLAYER_TEAM.size() > 0:
		team_mon_1.monster = TeamManager.PLAYER_TEAM[0]
	if TeamManager.PLAYER_TEAM.size() > 1:
		team_mon_2.monster = TeamManager.PLAYER_TEAM[1]
	if TeamManager.PLAYER_TEAM.size() > 2:
		team_mon_3.monster = TeamManager.PLAYER_TEAM[2]
	if TeamManager.PLAYER_TEAM.size() > 3:
		team_mon_4.monster = TeamManager.PLAYER_TEAM[3]

func _remove_player_mon() -> void:
	clear_monster_data_display()
	hide_monster_selection_panel()
	# Do other stuff...?
	reorder_party()

func _clear_player_party() -> void:
	team_mon_1.monster = null
	team_mon_1.monster_backup = null
	team_mon_2.monster = null
	team_mon_2.monster_backup = null
	team_mon_3.monster = null
	team_mon_3.monster_backup = null
	team_mon_4.monster = null
	team_mon_4.monster_backup = null
	displayed_team_mon = null
	update_player_party()
	clear_monster_data_display()

func _set_enemy_team_list(team: Array[MonsterStats]) -> void:
	TeamManager.set_enemy_team(team)

func load_battle_scene() -> void:
	if TeamManager.PLAYER_TEAM.size() > 0 and TeamManager.ENEMY_TEAM.size() > 0:
		get_tree().change_scene_to_file(GlobalVariables.battle_manager_path)


#===============================================================================
# Input Handling and Debug
#-------------------------------------------------------------------------------
func debug_checks() -> void:
	if Input.is_action_just_pressed("check_player_party"): # G key
		for m: Monster in TeamManager.PLAYER_TEAM:
			print(m.data.monster_name + "," + str(m.level))
	if Input.is_action_just_pressed("check_enemy_party"): # B key
		for m: Monster in TeamManager.ENEMY_TEAM:
			print(m.data.monster_name + "," + str(m.level))

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://game/scenes/main_menu.tscn")
