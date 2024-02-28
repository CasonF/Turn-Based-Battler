class_name TeamManager
extends Node

static var PLAYER_TEAM : Array[Monster] = []
static var ENEMY_TEAM : Array[Monster] = []

static func add_player_leader(leader: MonsterStats, level: int = 1) -> bool:
	var add_success := true
	var current_leader : Monster
	for member in PLAYER_TEAM:
		if member.data.is_monster_leader:
			current_leader = member
			break
	
	if current_leader:
		var team_leader : Monster = Monster.create(leader.monster_name, level)
		remove_player_monster(current_leader)
		team_leader.current_hp = team_leader.HP
		team_leader.armor = 0
		PLAYER_TEAM.append(team_leader)
	else:
		if PLAYER_TEAM.size() == 4:
			# Team cannot exceed 4 members
			add_success = false
		else:
			var team_leader : Monster = Monster.create(leader.monster_name, level)
			team_leader.current_hp = team_leader.HP
			team_leader.armor = 0
			PLAYER_TEAM.append(team_leader)
	return add_success

static func add_player_monster(monster: MonsterStats, level: int = 1) -> bool:
	var add_success := true
	if PLAYER_TEAM.size() == 4:
		# Team cannot exceed 4 members
		add_success = false
	else:
		var team_member: Monster = Monster.create(monster.monster_name, level)
		team_member.current_hp = team_member.HP
		team_member.armor = 0
		PLAYER_TEAM.append(team_member)
	return add_success

static func remove_player_monster(monster: Monster) -> void:
	if PLAYER_TEAM.has(monster):
		PLAYER_TEAM.remove_at(PLAYER_TEAM.find(monster))

static func set_enemy_team(team: Array[MonsterStats], team_level: int = 20) -> void:
	ENEMY_TEAM.clear()
	if team:
		for mon: MonsterStats in team:
			var team_member: Monster = Monster.create(mon.monster_name, team_level)
			team_member.current_hp = team_member.HP
			team_member.armor = 0
			ENEMY_TEAM.append(team_member)

static func clear_enemy_team() -> void:
	ENEMY_TEAM.clear()
