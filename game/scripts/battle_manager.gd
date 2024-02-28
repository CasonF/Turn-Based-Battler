class_name BattleManager
extends Node

@export var music_player: AudioStreamPlayer

#===============================================================================
# Initialize Necessary Classes as objects
#-------------------------------------------------------------------------------
var effect_handler : EffectHandler = EffectHandler.new()

#===============================================================================
# Turn Phase Controls
#-------------------------------------------------------------------------------
enum PHASE {START, SELECT, BATTLE, END}
var turn_phase : Array[PHASE] = [PHASE.START, PHASE.SELECT, PHASE.BATTLE, PHASE.END]
var get_next_turn_phase : bool = false
var get_last_turn_phase : bool = false # Fringe case for forced switches
var current_turn_phase : PHASE

enum WINNER {PLAYER, NPC}

var force_switch : bool = false
var end_of_game : bool = false
var winner : WINNER
var get_ai_action : bool = false

func handle_turn_phases() -> void:
	if current_turn_phase == PHASE.START:
		# Start of turn abilities trigger??
		get_next_turn_phase = true
		get_ai_action = true
		show_base_combat_options()
	elif current_turn_phase == PHASE.SELECT:
		if get_ai_action:
			get_ai_action = false
			var ai_action:Action = BattleAI.get_next_action(active_enemy_monster, active_player_monster, enemy_team)
			battle_queue.append(ai_action) #Add directly to queue...
	elif current_turn_phase == PHASE.BATTLE:
		if battle_queue.size() > 1:
			battle_queue.sort_custom(sort_battle_queue)
		for q:Action in battle_queue:
			handle_battle_action(q)
		battle_queue.clear()
		check_force_switch()
		if force_switch: # This was built for player... having difficulty with ai...
			# Bc we return to select phase...
			get_last_turn_phase = true
		else:
			get_next_turn_phase = true
	elif current_turn_phase == PHASE.END:
		# If status is added, could do something here?
		# Or end-of-turn abilities
		if end_of_game:
			print("Winner is ", WINNER.keys()[winner])
			TeamManager.clear_enemy_team()
			get_tree().change_scene_to_file("res://game/scenes/battle_setup.tscn")
			# take back to Battle Setup screen
		else:
			get_next_turn_phase = true
#===============================================================================
# Battle Phase Manager
#-------------------------------------------------------------------------------
class Action:
	var action : MonsterAction
	var target : Monster
	var user : Monster
	var priority : int = 0 # Priority declared here bc Switching does not pass an action

var battle_queue : Array[Action]
func sort_battle_queue(a:Action, b:Action) -> bool:
	if a.priority > b.priority:
		return true
	elif a.priority == b.priority:
		if (a.user.SPD * stat_multiplier.get(a.user.SPD_STAGE)) > (b.user.SPD * stat_multiplier.get(b.user.SPD_STAGE)):
			return true
		elif (a.user.SPD * stat_multiplier.get(a.user.SPD_STAGE)) == (b.user.SPD * stat_multiplier.get(b.user.SPD_STAGE)):
			return 0.5 < randf_range(0, 1.0)
		else:
			return false
	else:
		return false

func handle_battle_action(action: Action) -> void:
	if action.action:
		effect_handler.pre_battle_effect(action)
		if action.action.action_type == action.action.ACTION_TYPE.PHYSICAL or action.action.action_type == action.action.ACTION_TYPE.MAGICAL:
			if action.user.current_hp > 0 and action.target.current_hp > 0:
				attack_target(action.action, action.user, action.target)
		else:
			if action.user.current_hp > 0:
				special_action(action.action, action.user, action.target)
		effect_handler.post_battle_effect(action)
		update_stat_bars()
	else:
		# Do some basic logic to determine which team is doing the switching
		var team : Array[Monster]
		if player_team.has(action.target):
			team = player_team
		else:
			team = enemy_team
		# We assume if no action passed that we are switching...
		switch_action(team, action.user, action.target)
#===============================================================================
# HP Stuff
#-------------------------------------------------------------------------------
@onready var player_mon_hp : ProgressBar = $BattlePanel/PlayerHealthPanel/HealthBar
@onready var player_mon_armor : ProgressBar = $BattlePanel/PlayerHealthPanel/ArmorPanel/ArmorBar
@onready var player_mon_label : Label = $BattlePanel/PlayerHealthPanel/PlayerMonster

@onready var player_stat_atk : ProgressBar = $BattlePanel/PlayerStatPanel/ATKStatStage
@onready var player_stat_def : ProgressBar = $BattlePanel/PlayerStatPanel/DEFStatStage
@onready var player_stat_matk : ProgressBar = $BattlePanel/PlayerStatPanel/MATKStatStage
@onready var player_stat_mdef : ProgressBar = $BattlePanel/PlayerStatPanel/MDEFStatStage
@onready var player_stat_spd : ProgressBar = $BattlePanel/PlayerStatPanel/SPDStatStage

@onready var enemy_mon_hp : ProgressBar = $BattlePanel/EnemyHealthPanel/HealthBar
@onready var enemy_mon_armor : ProgressBar = $BattlePanel/EnemyHealthPanel/ArmorPanel/ArmorBar
@onready var enemy_mon_label : Label = $BattlePanel/EnemyHealthPanel/EnemyMonster

@onready var enemy_stat_atk : ProgressBar = $BattlePanel/EnemyStatPanel/ATKStatStage
@onready var enemy_stat_def : ProgressBar = $BattlePanel/EnemyStatPanel/DEFStatStage
@onready var enemy_stat_matk : ProgressBar = $BattlePanel/EnemyStatPanel/MATKStatStage
@onready var enemy_stat_mdef : ProgressBar = $BattlePanel/EnemyStatPanel/MDEFStatStage
@onready var enemy_stat_spd : ProgressBar = $BattlePanel/EnemyStatPanel/SPDStatStage

@export var high_hp_color : Color
@export var med_hp_color : Color
@export var low_hp_color : Color

func update_hp_bars() -> void:
	player_mon_label.text = active_player_monster.data.monster_name + " - " + str(active_player_monster.level)
	player_mon_hp.max_value = active_player_monster.HP
	player_mon_hp.value = active_player_monster.current_hp
	player_mon_armor.max_value = active_player_monster.HP
	player_mon_armor.value = active_player_monster.armor
	check_hp_bar_color(player_mon_hp)
	enemy_mon_label.text = active_enemy_monster.data.monster_name + " - " + str(active_enemy_monster.level)
	enemy_mon_hp.max_value = active_enemy_monster.HP
	enemy_mon_hp.value = active_enemy_monster.current_hp
	enemy_mon_armor.max_value = active_enemy_monster.HP
	enemy_mon_armor.value = active_enemy_monster.armor
	check_hp_bar_color(enemy_mon_hp)

func update_stat_bars() -> void:
	setup_player_stat_bars()
	setup_enemy_stat_bars()

func setup_player_stat_bars() -> void:
	player_stat_atk.value = abs(active_player_monster.ATK_STAGE)
	player_stat_def.value = abs(active_player_monster.DEF_STAGE)
	player_stat_matk.value = abs(active_player_monster.MATK_STAGE)
	player_stat_mdef.value = abs(active_player_monster.MDEF_STAGE)
	player_stat_spd.value = abs(active_player_monster.SPD_STAGE)
	# ATK
	if active_player_monster.ATK_STAGE < 0:
		player_stat_atk.fill_mode = player_stat_atk.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		player_stat_atk.add_theme_stylebox_override("fill", stylebox)
	else:
		player_stat_atk.fill_mode = player_stat_atk.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		player_stat_atk.add_theme_stylebox_override("fill", stylebox)
	# DEF
	if active_player_monster.DEF_STAGE < 0:
		player_stat_def.fill_mode = player_stat_def.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		player_stat_def.add_theme_stylebox_override("fill", stylebox)
	else:
		player_stat_def.fill_mode = player_stat_def.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		player_stat_def.add_theme_stylebox_override("fill", stylebox)
	# MATK
	if active_player_monster.MATK_STAGE < 0:
		player_stat_matk.fill_mode = player_stat_matk.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		player_stat_matk.add_theme_stylebox_override("fill", stylebox)
	else:
		player_stat_matk.fill_mode = player_stat_matk.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		player_stat_matk.add_theme_stylebox_override("fill", stylebox)
	# MDEF
	if active_player_monster.MDEF_STAGE < 0:
		player_stat_mdef.fill_mode = player_stat_mdef.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		player_stat_mdef.add_theme_stylebox_override("fill", stylebox)
	else:
		player_stat_mdef.fill_mode = player_stat_mdef.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		player_stat_mdef.add_theme_stylebox_override("fill", stylebox)
	# SPD
	if active_player_monster.SPD_STAGE < 0:
		player_stat_spd.fill_mode = player_stat_spd.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		player_stat_spd.add_theme_stylebox_override("fill", stylebox)
	else:
		player_stat_spd.fill_mode = player_stat_spd.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		player_stat_spd.add_theme_stylebox_override("fill", stylebox)

func setup_enemy_stat_bars() -> void:
	enemy_stat_atk.value = abs(active_enemy_monster.ATK_STAGE)
	enemy_stat_def.value = abs(active_enemy_monster.DEF_STAGE)
	enemy_stat_matk.value = abs(active_enemy_monster.MATK_STAGE)
	enemy_stat_mdef.value = abs(active_enemy_monster.MDEF_STAGE)
	enemy_stat_spd.value = abs(active_enemy_monster.SPD_STAGE)
	# ATK
	if active_enemy_monster.ATK_STAGE < 0:
		enemy_stat_atk.fill_mode = enemy_stat_atk.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		enemy_stat_atk.add_theme_stylebox_override("fill", stylebox)
	else:
		enemy_stat_atk.fill_mode = enemy_stat_atk.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		enemy_stat_atk.add_theme_stylebox_override("fill", stylebox)
	# DEF
	if active_enemy_monster.DEF_STAGE < 0:
		enemy_stat_def.fill_mode = enemy_stat_def.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		enemy_stat_def.add_theme_stylebox_override("fill", stylebox)
	else:
		enemy_stat_def.fill_mode = enemy_stat_def.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		enemy_stat_def.add_theme_stylebox_override("fill", stylebox)
	# MATK
	if active_enemy_monster.MATK_STAGE < 0:
		enemy_stat_matk.fill_mode = enemy_stat_matk.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		enemy_stat_matk.add_theme_stylebox_override("fill", stylebox)
	else:
		enemy_stat_matk.fill_mode = enemy_stat_matk.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		enemy_stat_matk.add_theme_stylebox_override("fill", stylebox)
	# MDEF
	if active_enemy_monster.MDEF_STAGE < 0:
		enemy_stat_mdef.fill_mode = enemy_stat_mdef.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		enemy_stat_mdef.add_theme_stylebox_override("fill", stylebox)
	else:
		enemy_stat_mdef.fill_mode = enemy_stat_mdef.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		enemy_stat_mdef.add_theme_stylebox_override("fill", stylebox)
	# SPD
	if active_enemy_monster.SPD_STAGE < 0:
		enemy_stat_spd.fill_mode = enemy_stat_spd.FILL_BEGIN_TO_END
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = low_hp_color
		enemy_stat_spd.add_theme_stylebox_override("fill", stylebox)
	else:
		enemy_stat_spd.fill_mode = enemy_stat_spd.FILL_END_TO_BEGIN
		var stylebox : StyleBoxFlat = StyleBoxFlat.new()
		stylebox.bg_color = high_hp_color
		enemy_stat_spd.add_theme_stylebox_override("fill", stylebox)

func check_hp_bar_color(hp_bar: ProgressBar) -> void:
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
#===============================================================================\
# Initialization
#-------------------------------------------------------------------------------
@onready var combat_options : HBoxContainer = $BattlePanel/CombatOptions

@export var active_player_monster : Monster
@export var active_enemy_monster : Monster

@export var player_team : Array[Monster]
@export var enemy_team : Array[Monster]

@export var test_attack: MonsterAction
@export var test_attack2: MonsterAction

const player_monster_position : Vector2 = Vector2(-250.0, -50.0)
const enemy_monster_position : Vector2 = Vector2(250.0, -50.0)

func _ready() -> void:
	player_team = import_team("player")
	enemy_team = import_team("enemy")
	
	if !player_team or player_team.size() < 1:
		var player_monster = Monster.create(GlobalVariables.MONSTERS.MAGEFROG, 20)
		player_monster.current_hp = player_monster.HP
		player_monster.armor = 0
		player_team.append(player_monster)
	if !enemy_team or enemy_team.size() < 1:
		var enemy_monster = Monster.create()
		enemy_monster.current_hp = enemy_monster.HP
		enemy_monster.armor = 0
		enemy_team.append(enemy_monster)
	
	setup_battle_scene()
	connect_signals()

func _process(_delta) -> void:
	if GlobalVariables.debug_mode:
		debug_actions()
	if get_next_turn_phase:
		get_next_turn_phase = false
		current_turn_phase = turn_phase.pop_front()
		turn_phase.append(current_turn_phase) # Append to back of phase queue
	elif get_last_turn_phase:
		get_last_turn_phase = false
		var set_phase = turn_phase.pop_back()
		turn_phase.push_front(set_phase)
		current_turn_phase = turn_phase.back()
	handle_turn_phases()

func connect_signals() -> void:
	if music_player:
		music_player.finished.connect(replay_music)

func replay_music() -> void:
	music_player.play()

func import_team(team: String) -> Array[Monster]:
	var monsters : Array[Monster] = []
	if "player" == team:
		for mon:Monster in TeamManager.PLAYER_TEAM:
			var copy: Monster = Monster.create(mon)
			monsters.append(copy)
	elif "enemy" == team:
		for mon:Monster in TeamManager.ENEMY_TEAM:
			var copy: Monster = Monster.create(mon)
			monsters.append(copy)
	return monsters

func setup_battle_scene() -> void:
	#...
	active_player_monster = player_team.pop_front()
	active_enemy_monster = enemy_team.pop_front()
	show_monsters()
	update_hp_bars()
	#...
	get_next_turn_phase = true

func show_monsters() -> void:
	active_player_monster.scale = Vector2(2.0, 2.0)
	active_player_monster.global_position = player_monster_position + Vector2(0.0, active_player_monster.data.y_offset)
	active_enemy_monster.scale = Vector2(2.0, 2.0)
	active_enemy_monster.global_position = enemy_monster_position + Vector2(0.0, active_enemy_monster.data.y_offset)
	add_child(active_player_monster)
	add_child(active_enemy_monster)

#===============================================================================
# Select Phase Management
#-------------------------------------------------------------------------------
@onready var fight_button : Button = $BattlePanel/CombatOptions/FightButton
@onready var switch_button : Button = $BattlePanel/CombatOptions/SwitchButton

func get_return_button() -> Button:
	var return_button : Button = Button.new()
	return_button.text = "BACK"
	return_button.pressed.connect(return_to_base_options)
	return return_button

func select_attack(attack: MonsterAction, attacker: Monster, defender: Monster) -> void:
	var action : Action = Action.new()
	action.action = attack
	action.priority = attack.priority
	action.target = defender
	action.user = attacker
	battle_queue.append(action)
	get_next_turn_phase = true
	clear_select_options()

func select_switch(current: Monster, target: Monster) -> void:
	if target.current_hp > 0:
		var action : Action = Action.new()
		action.priority = 100
		action.target = target
		action.user = current
		battle_queue.append(action)
		get_next_turn_phase = true
		clear_select_options()

func hide_base_combat_options() -> void:
	fight_button.hide()
	switch_button.hide()

func show_base_combat_options() -> void:
	fight_button.show()
	switch_button.show()

func clear_select_options() -> void:
	for child in combat_options.get_children():
		if !child.is_in_group("BaseCombatOptions"):
			child.queue_free()

func return_to_base_options() -> void:
	clear_select_options()
	show_base_combat_options()
#===============================================================================
# Extra Switch Logic
#-------------------------------------------------------------------------------
@onready var switch_mon_button := preload("res://game/scenes/ui/switch_battler_button.tscn")

func check_force_switch() -> void:
	force_switch = false
	if active_player_monster.current_hp <= 0:
		force_switch = has_available_mons(player_team)
		if force_switch:
			show_switch_options()
		else:
			end_of_game = true
			winner = WINNER.NPC
	if active_enemy_monster.current_hp <= 0:
		var check_force_switch = has_available_mons(enemy_team)
		if check_force_switch:
			# Do Battle AI switch logic... do switch action and add directly to queue
			var ai_action:Action = BattleAI.get_next_action(active_enemy_monster, active_player_monster, enemy_team)
			handle_battle_action(ai_action)
		else:
			end_of_game = true
			winner = WINNER.PLAYER

func has_available_mons(team: Array[Monster]) -> bool:
	var can_switch : bool = false
	for mem:Monster in team:
		if mem.current_hp > 0:
			can_switch = true
	return can_switch

func show_switch_options() -> void:
	hide_base_combat_options()
	for m:Monster in player_team:
		var b = switch_mon_button.instantiate()
		if b is SwitchBattlerButton:
			b.monster = m
			b.switch_to_monster.connect(switch_active_monster)
		combat_options.add_child(b)
	if !force_switch:
		combat_options.add_child(get_return_button())

func switch_active_monster(mon: Monster) -> void:
	select_switch(active_player_monster, mon)
#===============================================================================
# Extra Fight Logic
#-------------------------------------------------------------------------------
@onready var fight_mon_button := preload("res://game/scenes/ui/monster_action_button.tscn")

func show_fight_options() -> void:
	hide_base_combat_options()
	for a:MonsterAction in active_player_monster.data.actions:
		var b = fight_mon_button.instantiate()
		if b is MonsterActionButton:
			b.action = a
			b.use_action.connect(select_monster_attack)
		combat_options.add_child(b)
	combat_options.add_child(get_return_button())

func select_monster_attack(mon_action: MonsterAction) -> void:
	select_attack(mon_action, active_player_monster, active_enemy_monster)
#===============================================================================
# Actions and Calcs
#-------------------------------------------------------------------------------
func attack_target(attack: MonsterAction, attacker: Monster, defender: Monster) -> void:
	defender = check_defender(attacker, defender)
	var damage: int = calc_damage(attack, attacker, defender)
	defender.take_damage(damage)
	update_hp_bars()

func check_defender(attacker:Monster, defender:Monster) -> Monster:
	var target: Monster = defender
	if attacker == active_player_monster:
		if defender != active_enemy_monster:
			target = active_enemy_monster
	elif attacker == active_enemy_monster:
		if defender != active_player_monster:
			target = active_player_monster
	return target

func special_action(action: MonsterAction, attacker: Monster, defender: Monster) -> void:
	# This should handle heal, defend, other...?
	if action.action_type == action.ACTION_TYPE.STATUS:
		if action.attack_type == action.ATTACK_TYPE.HEAL:
			attacker.heal(calc_heal(action, attacker))
			update_hp_bars()
	elif action.action_type == action.ACTION_TYPE.OTHER:
		if action.attack_type == action.ATTACK_TYPE.DEFEND:
			attacker.gain_armor(calc_armor(action, attacker))
			update_hp_bars()
	else:
		print("Unhandled type: ", action.action_type, " - ", action.attack_type)

func switch_action(team: Array[Monster], current: Monster, target: Monster) -> void:
	# Using Monster.create() auto-resets armor and stat changes
	var mon_copy : Monster = Monster.create(current, current.level)
	if team == player_team:
		player_team.append(mon_copy)
		active_player_monster.queue_free()
		active_player_monster = player_team.pop_at(player_team.find(target))
	else:
		enemy_team.append(mon_copy)
		active_enemy_monster.queue_free()
		active_enemy_monster = enemy_team.pop_at(enemy_team.find(target))
	show_monsters()
	update_hp_bars()
	update_stat_bars()

func calc_damage(attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var damage : int = 1
	if attack.action_type == attack.ACTION_TYPE.PHYSICAL:
		print("Attack is Physical: ", attack.action_name)
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.ATK * stat_multiplier.get(attacker.ATK_STAGE)) / (defender.DEF * stat_multiplier.get(defender.DEF_STAGE)))) / 50) * randf_range(0.85, 1.15) + 1
	elif attack.action_type == attack.ACTION_TYPE.MAGICAL:
		print("Attack is Magical: ", attack.action_name)
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15) + 1
	return damage

func calc_heal(action: MonsterAction, user: Monster) -> int:
	return ((((2 * user.level) / 5) * action.power * (user.MATK / user.level)) / 50) * stat_multiplier.get(user.MATK_STAGE) + 1

func calc_armor(action: MonsterAction, user: Monster) -> int:
	return (((2 * user.level) / 5) * action.power * ((user.DEF + user.MDEF) / (user.level * 2))) / 50 + 1

const stat_multiplier : Dictionary = {
	-3:0.4, -2:0.5, -1:0.67, 0:1.0, 1:1.5, 2:2.0, 3:2.5
}
#===============================================================================
# DEBUG
#-------------------------------------------------------------------------------
func debug_actions() -> void:
	if Input.is_action_just_pressed("debug_checkstats"): # C key
		active_player_monster.print_stats()
		active_enemy_monster.print_stats()
	if Input.is_action_just_pressed("check_player_party"): # G key
		#attack_target(test_attack, active_player_monster, active_enemy_monster)
		special_action(test_attack, active_player_monster, active_enemy_monster)
	if Input.is_action_just_pressed("check_enemy_party"): # B key
		attack_target(test_attack2, active_enemy_monster, active_player_monster)
		#special_action(test_attack, active_enemy_monster, active_player_monster)
