class_name BattleManager
extends Node

@export var music_player: AudioStreamPlayer

#===============================================================================
# Initialize Necessary Classes as objects
#-------------------------------------------------------------------------------
var effect_handler : EffectHandler = EffectHandler.new()

#===============================================================================
# Field Effects
#-------------------------------------------------------------------------------
var player_wish_counter: int = 0
var enemy_wish_counter: int = 0
#===============================================================================
# Turn Phase Controls
#-------------------------------------------------------------------------------
enum PHASE {START, SELECT, BATTLE, END}
var turn_phase : Array[PHASE] = [PHASE.START, PHASE.SELECT, PHASE.BATTLE, PHASE.END]
var get_next_turn_phase : bool = false
var get_last_turn_phase : bool = false
var get_select_turn_phase : bool = false
var current_turn_phase : PHASE
@onready var battle_timer : Timer = $BattleTimer

enum WINNER {PLAYER, NPC}

var force_switch : bool = false
var end_of_game : bool = false
var winner : WINNER
var displayed_winner_message: bool = false
var game_end_timer: float = 2.5
var get_ai_action : bool = false

func handle_turn_phases() -> void:
	if current_turn_phase == PHASE.START:
		start_of_turn_effects()
		# Always start turn by gaining AP??
		active_player_monster.gain_AP()
		active_enemy_monster.gain_AP()
		update_ap_bars()
		# Start of turn abilities trigger??
		get_next_turn_phase = true
		get_ai_action = true
		show_base_combat_options()
	elif current_turn_phase == PHASE.SELECT:
		if get_ai_action:
			get_ai_action = false
			queue_ai_action()
	elif current_turn_phase == PHASE.BATTLE:
		var next_action: Action
		if battle_queue.size() > 1:
			battle_queue.sort_custom(sort_battle_queue)
		if battle_queue.size() > 0:
			if battle_timer.is_stopped():
				next_action = battle_queue.pop_front()
				handle_battle_action(next_action)
				battle_timer.start(1.0)
		if battle_queue.size() < 1 and battle_timer.is_stopped():
			check_force_switch()
			if force_switch: # This was built for player...
				# Bc we return to select phase...
				get_last_turn_phase = true
			else:
				get_next_turn_phase = true
	elif current_turn_phase == PHASE.END:
		end_of_turn_effects()
		if force_switch:
			get_select_turn_phase = true
		# If status is added, could do something here?
		# Or end-of-turn abilities
		if force_switch:
			get_select_turn_phase = true
		else:
			if end_of_game:
				#print("Winner is ", WINNER.keys()[winner])
				_append_winner_message(WINNER.keys()[winner])
				if game_end_timer <= 0:
					TeamManager.clear_enemy_team()
					TeamManager.clean_player_team()
					get_tree().change_scene_to_file(GlobalVariables.battle_setup_path)
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
	enum TYPES {ATTACK, SWITCH, WAIT}
	var type : TYPES
	# Fringe effect cases
	var user_party : Array[Monster]
	var enemy_party : Array[Monster]

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
	if action.type == action.TYPES.ATTACK:
		action = check_action_legality(action)
		effect_handler.pre_battle_effect(action)
		if action.action.action_type == action.action.ACTION_TYPE.PHYSICAL or action.action.action_type == action.action.ACTION_TYPE.MAGICAL:
			if action.user.current_hp > 0 and action.target.current_hp > 0:
				_append_action_message(action.action, action.user)
				attack_target(action.action, action.user, action.target)
		else:
			if action.user.current_hp > 0:
				_append_action_message(action.action, action.user)
				special_action(action.action, action.user, action.target)
		effect_handler.post_battle_effect(action)
		check_local_action_effects(action)
	elif action.type == action.TYPES.SWITCH:
		# Do some basic logic to determine which team is doing the switching
		var team : Array[Monster]
		if player_team.has(action.target):
			team = player_team
		else:
			team = enemy_team
		# We assume if no action passed that we are switching...
		switch_action(team, action.user, action.target)
		_append_switch_message(action.user, action.target)
	elif action.type == action.TYPES.WAIT:
		if action.user.current_hp > 0:
			_append_wait_message(action.user)
			wait_action(action.user)
	
	check_battle_attributes(action)
	update_hp_bars()
	update_ap_bars()

func queue_ai_action() -> void:
	var ai_action:Action = BattleAI.get_next_action(active_enemy_monster, active_player_monster, enemy_team)
	if ai_action.action and ai_action.action.multi_attack:
		var num:int = randi_range(0, ai_action.action.range.size() - 1)
		var count:int = ai_action.action.range[num]
		for i in count:
			var action : Action = Action.new()
			action.action = ai_action.action.multi_attack_action
			action.priority = ai_action.action.multi_attack_action.priority
			action.target = ai_action.target
			action.user = ai_action.user
			action.type = action.TYPES.ATTACK
			if PASS_PARTY_EFFECTS.has(action.action.action_effect):
				action.enemy_party = player_team
				action.user_party = enemy_team
			battle_queue.append(action)
	else:
		if ai_action.action:
			if PASS_PARTY_EFFECTS.has(ai_action.action.action_effect):
				ai_action.enemy_party = player_team
				ai_action.user_party = enemy_team
		battle_queue.append(ai_action) #Add directly to queue...

func check_battle_attributes(action:Action) -> void:
	if !action.action or (action.action.action_effect != action.action.EFFECTS.CHAINLIGHTNING):
		action.user.chain_lightning_counter = 0

func check_action_legality(action:Action) -> Action:
	var a:Action = action
	if a.user == active_player_monster:
		if a.target != active_enemy_monster:
			a.target = active_enemy_monster
	elif a.user == active_enemy_monster:
		if a.target != active_player_monster:
			a.target = active_player_monster
	return a
#===============================================================================
# HP and Stat Display Stuff
#-------------------------------------------------------------------------------
@onready var player_mon_hp : ProgressBar = $BattlePanel/PlayerHealthPanel/HealthBar
@onready var player_mon_hp_value : Label = $BattlePanel/PlayerHealthPanel/HealthBar/PlayerHP
@onready var player_mon_armor : ProgressBar = $BattlePanel/PlayerHealthPanel/ArmorPanel/ArmorBar
@onready var player_mon_label : MonsterInfoPanel = $BattlePanel/PlayerHealthPanel/PlayerMonster

@onready var player_mon_ap : ProgressBar = $BattlePanel/PlayerAPPanel/APBar
@onready var player_mon_ap_value : Label = $BattlePanel/PlayerAPPanel/APBar/APValue

@onready var enemy_mon_hp : ProgressBar = $BattlePanel/EnemyHealthPanel/HealthBar
@onready var enemy_mon_hp_value : Label = $BattlePanel/EnemyHealthPanel/HealthBar/EnemyHP
@onready var enemy_mon_armor : ProgressBar = $BattlePanel/EnemyHealthPanel/ArmorPanel/ArmorBar
@onready var enemy_mon_label : MonsterInfoPanel = $BattlePanel/EnemyHealthPanel/EnemyMonster

@onready var enemy_mon_ap : ProgressBar = $BattlePanel/EnemyAPPanel/APBar
@onready var enemy_mon_ap_value : Label = $BattlePanel/EnemyAPPanel/APBar/APValue

@export var high_hp_color : Color
@export var med_hp_color : Color
@export var low_hp_color : Color

func update_hp_bars() -> void:
	player_mon_label.monster = active_player_monster
	player_mon_hp.max_value = active_player_monster.HP
	player_mon_hp.value = active_player_monster.current_hp
	player_mon_hp_value.text = str(active_player_monster.current_hp) + " / " + str(active_player_monster.HP)
	player_mon_armor.max_value = active_player_monster.HP
	player_mon_armor.value = active_player_monster.armor
	check_hp_bar_color(player_mon_hp)
	enemy_mon_label.monster = active_enemy_monster
	enemy_mon_hp.max_value = active_enemy_monster.HP
	enemy_mon_hp.value = active_enemy_monster.current_hp
	enemy_mon_hp_value.text = str(active_enemy_monster.current_hp) + " / " + str(active_enemy_monster.HP)
	enemy_mon_armor.max_value = active_enemy_monster.HP
	enemy_mon_armor.value = active_enemy_monster.armor
	check_hp_bar_color(enemy_mon_hp)

func update_ap_bars() -> void:
	player_mon_ap.value = active_player_monster.AP
	player_mon_ap_value.text = str(active_player_monster.AP)
	enemy_mon_ap.value = active_enemy_monster.AP
	enemy_mon_ap_value.text = str(active_enemy_monster.AP)

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
	setup_music_player()
	connect_signals()

func _process(delta) -> void:
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
	elif get_select_turn_phase:
		get_select_turn_phase = false
		var sel_pos: int = turn_phase.find(PHASE.SELECT) + 1
		var set_phase
		for i in sel_pos:
			set_phase = turn_phase.pop_front()
			turn_phase.append(set_phase)
		current_turn_phase = set_phase
	
	if end_of_game:
		game_end_timer -= delta
	handle_turn_phases()

func connect_signals() -> void:
	if music_player:
		music_player.finished.connect(replay_music)

func replay_music() -> void:
	music_player.play()

func setup_music_player() -> void:
	if music_player:
		music_player.volume_db = GlobalSettings.get_global_volume()

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
	active_player_monster.knocked_out.connect(_append_ko_message)
	active_enemy_monster = enemy_team.pop_front()
	active_enemy_monster.knocked_out.connect(_append_ko_message)
	show_monsters()
	update_hp_bars()
	#...
	get_next_turn_phase = true

func show_monsters() -> void:
	active_player_monster.scale = Vector2(2.0, 2.0)
	active_player_monster.global_position = player_monster_position + Vector2(0.0, active_player_monster.data.y_offset)
	if active_player_monster.data.default_direction_left:
		active_player_monster.flip_h = true
	active_enemy_monster.scale = Vector2(2.0, 2.0)
	active_enemy_monster.global_position = enemy_monster_position + Vector2(0.0, active_enemy_monster.data.y_offset)
	if !active_enemy_monster.data.default_direction_left:
		active_enemy_monster.flip_h = true
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

func get_wait_action_button() -> Button:
	var wait_button : Button = Button.new()
	wait_button.text = "WAIT"
	wait_button.pressed.connect(select_wait_action)
	return wait_button

func select_attack(attack: MonsterAction, attacker: Monster, defender: Monster) -> void:
	if attack.ap_cost <= attacker.AP:
		if attack.multi_attack:
			var num : int = randi_range(0, attack.range.size() - 1)
			var count:int = attack.range[num]
			for i in count:
				var action : Action = Action.new()
				action.action = attack.multi_attack_action
				action.priority = attack.multi_attack_action.priority
				action.target = defender
				action.user = attacker
				action.type = action.TYPES.ATTACK
				if PASS_PARTY_EFFECTS.has(attack.action_effect):
					if attacker == active_player_monster:
						action.user_party = player_team
						action.enemy_party = enemy_team
					else:
						action.enemy_party = player_team
						action.user_party = enemy_team
				battle_queue.append(action)
		else:
			var action : Action = Action.new()
			action.action = attack
			action.priority = attack.priority
			action.target = defender
			action.user = attacker
			action.type = action.TYPES.ATTACK
			if PASS_PARTY_EFFECTS.has(attack.action_effect):
				if attacker == active_player_monster:
					action.user_party = player_team
					action.enemy_party = enemy_team
				else:
					action.enemy_party = player_team
					action.user_party = enemy_team
			battle_queue.append(action)
		
		get_next_turn_phase = true
		clear_select_options()

var PASS_PARTY_EFFECTS : Array[MonsterAction.EFFECTS] = [
	MonsterAction.EFFECTS._SUPERNOVA, MonsterAction.EFFECTS._TSUNAMI
]

func select_switch(current: Monster, target: Monster) -> void:
	if target.current_hp > 0:
		var action : Action = Action.new()
		action.priority = 100
		action.target = target
		action.user = current
		action.type = action.TYPES.SWITCH
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

func select_wait_action() -> void:
	var action : Action = Action.new()
	action.user = active_player_monster
	action.type = action.TYPES.WAIT
	battle_queue.append(action)
	get_next_turn_phase = true
	clear_select_options()
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
	for a:MonsterAction in active_player_monster.known_actions:
		var b = fight_mon_button.instantiate()
		if b is MonsterActionButton:
			b.action = a
			b.use_action.connect(select_monster_attack)
		combat_options.add_child(b)
	combat_options.add_child(get_wait_action_button())
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
	if attack.ap_cost >= 0:
		attacker.AP -= attack.ap_cost
	else:
		attacker.AP = 0
	update_ap_bars()
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
			attacker.AP -= action.ap_cost
			update_ap_bars()
			update_hp_bars()
		else:
			attacker.AP -= action.ap_cost
			update_ap_bars()
			update_hp_bars()
	elif action.action_type == action.ACTION_TYPE.OTHER:
		if action.attack_type == action.ATTACK_TYPE.DEFEND:
			attacker.gain_armor(calc_armor(action, attacker))
			attacker.AP -= action.ap_cost
			update_ap_bars()
			update_hp_bars()
		else:
			attacker.AP -= action.ap_cost
			update_ap_bars()
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
		active_player_monster.knocked_out.connect(_append_ko_message)
	else:
		enemy_team.append(mon_copy)
		active_enemy_monster.queue_free()
		active_enemy_monster = enemy_team.pop_at(enemy_team.find(target))
		active_enemy_monster.knocked_out.connect(_append_ko_message)
	show_monsters()
	update_hp_bars()
	update_ap_bars()

func wait_action(active_mon: Monster) -> void:
	active_mon.gain_AP()
	update_ap_bars()

func calc_damage(attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var damage : int = 1
	if attack.action_type == attack.ACTION_TYPE.PHYSICAL:
		print("Attack is Physical: ", attack.action_name)
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.ATK * stat_multiplier.get(attacker.ATK_STAGE)) / (defender.DEF * stat_multiplier.get(defender.DEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
	elif attack.action_type == attack.ACTION_TYPE.MAGICAL:
		print("Attack is Magical: ", attack.action_name)
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
	damage = calc_damage_effects(damage, attack, attacker, defender)
	return damage + 1

func calc_damage_effects(damage:int, attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var _damage:int = damage
	_damage = check_attack_damage(_damage, attack, attacker, defender)
	_damage = check_attacker_damage(_damage, attack, attacker, defender)
	_damage = check_defender_damage(_damage, attack, attacker, defender)
	return _damage

func check_attack_damage(damage:int, attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var _damage:int = damage
	if attack.action_effect == attack.EFFECTS.REVERSAL:
		var power:int = 20
		if float(attacker.current_hp) / float(attacker.HP) <= 0.05:
			power = 120
		elif float(attacker.current_hp) / float(attacker.HP) <= 0.25:
			power = 80
		elif float(attacker.current_hp) / float(attacker.HP) <= 0.5:
			power = 60
		elif float(attacker.current_hp) / float(attacker.HP) <= 0.75:
			power = 40
		_damage = ((((2 * attacker.level) / 5) * power * ((attacker.ATK * stat_multiplier.get(attacker.ATK_STAGE)) / (defender.DEF * stat_multiplier.get(defender.DEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
	elif attack.action_effect == attack.EFFECTS.CHAINLIGHTNING:
		_damage = ((((2 * attacker.level) / 5) * (attack.power + (30 * attacker.chain_lightning_counter)) * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
		attacker.chain_lightning_counter += 1
	elif attack.action_effect == attack.EFFECTS.CHARGEBEAM:
		_damage = ((((2 * attacker.level) / 5) * (40 * attacker.AP) * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
	elif attack.action_effect == attack.EFFECTS.BODYSPLASH:
		_damage = ((((2 * attacker.level) / 5) * attacker.data.hp * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15)
	return _damage

func check_attacker_damage(damage:int, attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var _damage:int = damage
	var defender_is_player : bool = active_player_monster == defender
	if attacker.active_statuses.has(attacker.STATUSES.BURN) and attack.action_type == attack.ACTION_TYPE.PHYSICAL:
		_append_message(attacker.data.monster_name + " inflicted less damage because of their burns...", !defender_is_player)
		_damage = _damage / 2
	return _damage

func check_defender_damage(damage:int, attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var _damage:int = damage
	var defender_is_player : bool = active_player_monster == defender
	if defender.has_sigil_sphere:
		if attack.action_type == attack.ACTION_TYPE.MAGICAL:
			_append_message(defender.data.monster_name + " was greatly protected by their Sigil Sphere!", defender_is_player)
			_damage = float(damage) * 0.1
		elif attack.action_type == attack.ACTION_TYPE.PHYSICAL:
			_append_message(defender.data.monster_name + " was somewhat protected by their Sigil Sphere!", defender_is_player)
			_damage = float(damage) * 0.7
	
	if defender.active_statuses.has(defender.STATUSES.FREEZE) and attack.action_type == attack.ACTION_TYPE.PHYSICAL:
		_append_message(defender.data.monster_name + " took more damage because they're brittle from being frozen...", defender_is_player)
		_damage = _damage * 2
	return _damage

func calc_heal(action: MonsterAction, user: Monster) -> int:
	return (((float(2.0 * user.level) / 5.0) * action.power * (float(user.MATK) / user.level)) / 50.0) * stat_multiplier.get(user.MATK_STAGE) * randf_range(0.85, 1.15) + 1

func calc_armor(action: MonsterAction, user: Monster) -> int:
	return ((float(2.0 * user.level) / 5.0) * action.power * (float(user.DEF + user.MDEF) / (user.level * 2.0))) / 50.0 + 1

const stat_multiplier : Dictionary = {
	-3:0.4, -2:0.5, -1:0.67, 0:1.0, 1:1.5, 2:2.0, 3:2.5
}
#===============================================================================
# Local Effect Manager
#-------------------------------------------------------------------------------
func check_local_action_effects(action:Action) -> void:
	var user_is_player: bool = false
	if action.user == active_player_monster:
		user_is_player = true
	
	check_wish(action, user_is_player)

func check_wish(action:Action, user_is_player:bool = false) -> void:
	if action.action.action_effect == action.action.EFFECTS.WISH:
		if user_is_player:
			if player_wish_counter <= 0:
				_append_message(active_player_monster.data.monster_name + " wished upon a star...", true)
				player_wish_counter = 3
			else:
				_append_message(active_player_monster.data.monster_name + "'s wish failed...", true)
		elif !user_is_player:
			if enemy_wish_counter <= 0:
				_append_message(active_enemy_monster.data.monster_name + " wished upon a star...")
				enemy_wish_counter = 3
			else:
				_append_message(active_enemy_monster.data.monster_name + "'s wish failed...")
#===============================================================================
# Start of Turn Effects
#-------------------------------------------------------------------------------
func start_of_turn_effects() -> void:
	handle_wish_effect()
	handle_sigil_sphere()

func handle_wish_effect() -> void:
	if player_wish_counter > 1:
		player_wish_counter -= 1
	elif player_wish_counter == 1:
		player_wish_counter = 0
		_append_message(active_player_monster.data.monster_name + " healed from the Wish!", true)
		active_player_monster.heal(active_player_monster.HP / 4)
	if enemy_wish_counter > 1:
		enemy_wish_counter -= 1
	elif enemy_wish_counter == 1:
		enemy_wish_counter = 0
		_append_message(active_enemy_monster.data.monster_name + " healed from the Wish!")
		active_enemy_monster.heal(active_enemy_monster.HP / 4)
	update_hp_bars()

func handle_sigil_sphere() -> void:
	if active_player_monster.has_sigil_sphere:
		active_player_monster.has_sigil_sphere = false
	if active_enemy_monster.has_sigil_sphere:
		active_enemy_monster.has_sigil_sphere = false
#===============================================================================
# End of Turn Effects
#-------------------------------------------------------------------------------
func end_of_turn_effects() -> void:
	check_poison()

func check_poison() -> void:
	if active_player_monster.SPD > active_enemy_monster.SPD:
		if active_player_monster.active_statuses.has(active_player_monster.STATUSES.POISON):
			_append_message(active_player_monster.data.monster_name + " took damage from the poison...", true)
			active_player_monster.take_damage(active_player_monster.HP / 10)
			check_force_switch()
		if active_enemy_monster.active_statuses.has(active_enemy_monster.STATUSES.POISON) and !end_of_game:
			_append_message(active_enemy_monster.data.monster_name + " took damage from the poison...")
			active_enemy_monster.take_damage(active_enemy_monster.HP / 10)
			check_force_switch()
	else:
		if active_enemy_monster.active_statuses.has(active_enemy_monster.STATUSES.POISON):
			_append_message(active_enemy_monster.data.monster_name + " took damage from the poison...")
			active_enemy_monster.take_damage(active_enemy_monster.HP / 10)
			check_force_switch()
		if active_player_monster.active_statuses.has(active_player_monster.STATUSES.POISON) and !end_of_game:
			_append_message(active_player_monster.data.monster_name + " took damage from the poison...", true)
			active_player_monster.take_damage(active_player_monster.HP / 10)
			check_force_switch()
#===============================================================================
# Battle Message Log
#-------------------------------------------------------------------------------
@onready var battle_message_log : VBoxContainer = $BattlePanel/BattleMessageLog/ScrollContainer/MessageLogList

func _append_action_message(action: MonsterAction, user: Monster) -> void:
	var log : Label = Label.new()
	log.add_theme_color_override("font_outline_color", Color("BLACK"))
	log.add_theme_constant_override("outline_size", 3)
	if user == active_player_monster:
		log.add_theme_color_override("font_color", Color("CYAN"))
	elif user == active_enemy_monster:
		log.add_theme_color_override("font_color", Color("ORANGE"))
	log.text = user.data.monster_name + " used " + action.action_name + "!"
	battle_message_log.add_child(log)

func _append_switch_message(user: Monster, target: Monster) -> void:
	var log : Label = Label.new()
	log.add_theme_color_override("font_outline_color", Color("BLACK"))
	log.add_theme_constant_override("outline_size", 3)
	if target == active_player_monster:
		log.add_theme_color_override("font_color", Color("CYAN"))
	elif target == active_enemy_monster:
		log.add_theme_color_override("font_color", Color("ORANGE"))
	log.text = user.data.monster_name + " switched with " + target.data.monster_name + "!"
	battle_message_log.add_child(log)

func _append_wait_message(user: Monster) -> void:
	var log : Label = Label.new()
	log.add_theme_color_override("font_outline_color", Color("BLACK"))
	log.add_theme_constant_override("outline_size", 3)
	if user == active_player_monster:
		log.add_theme_color_override("font_color", Color("CYAN"))
	elif user == active_enemy_monster:
		log.add_theme_color_override("font_color", Color("ORANGE"))
	log.text = user.data.monster_name + " is waiting around..."
	battle_message_log.add_child(log)

func _append_ko_message(ko: Monster) -> void:
	# Only append ko message first time... Before switch
	var log : Label = Label.new()
	log.add_theme_color_override("font_outline_color", Color("BLACK"))
	log.add_theme_constant_override("outline_size", 3)
	if ko == active_player_monster:
		log.add_theme_color_override("font_color", Color("CYAN"))
	elif ko == active_enemy_monster:
		log.add_theme_color_override("font_color", Color("ORANGE"))
	log.text = ko.data.monster_name + " was knocked out..."
	battle_message_log.add_child(log)

func _append_winner_message(winner: String) -> void:
	if !displayed_winner_message:
		displayed_winner_message = true
		var log : Label = Label.new()
		log.add_theme_color_override("font_outline_color", Color("BLACK"))
		log.add_theme_constant_override("outline_size", 3)
		if "PLAYER" == winner:
			log.add_theme_color_override("font_color", Color("CYAN"))
			log.text = "You win!"
		elif "NPC" == winner:
			log.add_theme_color_override("font_color", Color("ORANGE"))
			log.text = "You lost..."
		battle_message_log.add_child(log)

func _append_message(msg: String, is_player_monster:bool = false) -> void:
	var log : Label = Label.new()
	log.add_theme_color_override("font_outline_color", Color("BLACK"))
	log.add_theme_constant_override("outline_size", 3)
	if is_player_monster:
		log.add_theme_color_override("font_color", Color("CYAN"))
	else:
		log.add_theme_color_override("font_color", Color("ORANGE"))
	log.text = msg
	battle_message_log.add_child(log)
#===============================================================================
# Unhandled Input Handling and DEBUG
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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://game/scenes/battle_setup.tscn")
