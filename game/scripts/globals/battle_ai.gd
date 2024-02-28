extends Node

# Closer avg team level is to this number, smarter it should be
var difficulty_threshold : int = 100

enum INTENT {ATTACK, HEAL, DEFEND, SWITCH, STAT}

func get_next_action(ai: Monster, player: Monster, ai_team: Array[Monster]) -> BattleManager.Action:
	var avg_team_level : int = ai.level
	for t:Monster in ai_team:
		avg_team_level += t.level
	avg_team_level = avg_team_level / (ai_team.size() + 1)
	
	var ai_intended_action: INTENT = get_ai_intention(ai, player, ai_team, avg_team_level)
	var action : BattleManager.Action = get_ai_next_action(ai_intended_action, ai, player, ai_team, avg_team_level)
	# If no action.action, then we are switching... and already selected our target in get_ai_next_action
	if action.action:
		action.priority = action.action.priority
		action.target = player
		action.user = ai
	return action

func get_ai_intention(ai: Monster, player: Monster, ai_team: Array[Monster], avg_team_level:int) -> INTENT:
	var legal : LegalActions = get_legal_actions(ai, ai_team)
	var intent : INTENT = INTENT.ATTACK
	if (float(avg_team_level) / float(difficulty_threshold)) >= 0.7:
		intent = get_smart_intent(ai, player, ai_team, legal)
	elif (float(avg_team_level) / float(difficulty_threshold)) >= 0.5:
		intent = get_avg_intent(ai, player, legal)
	else:
		intent = get_random_intent(ai, legal)
	
	return intent

func get_ai_next_action(intent: INTENT, ai:Monster, player:Monster, ai_team:Array[Monster], avg_team_level:int) -> BattleManager.Action:
	var action: BattleManager.Action = BattleManager.Action.new()
	if (float(avg_team_level) / float(difficulty_threshold)) >= 0.7:
		action = get_smart_action(intent, ai, player, ai_team)
	elif (float(avg_team_level) / float(difficulty_threshold)) >= 0.5:
		action = get_avg_action(intent, ai, player, ai_team)
	else:
		action = get_random_action(intent, ai, ai_team)
	return action

func get_legal_actions(ai:Monster, ai_team:Array[Monster]) -> LegalActions:
	var legal : LegalActions = LegalActions.new()
	if ai.current_hp > 0:
		legal.has_hp = true
	for move:MonsterAction in ai.data.actions:
		if move.action_type == move.ACTION_TYPE.PHYSICAL:
			legal.can_attack = true
			legal.can_attack_phys = true
		if move.action_type == move.ACTION_TYPE.MAGICAL:
			legal.can_attack = true
			legal.can_attack_magic = true
		if move.action_type == move.ACTION_TYPE.OTHER:
			if move.attack_type == move.ATTACK_TYPE.DEFEND:
				legal.can_defend = true
			else:
				# Only other OTHER types are stat buffs, currently...
				legal.can_raise_stat = true
		if move.action_type == move.ACTION_TYPE.STATUS:
			if move.attack_type == move.ATTACK_TYPE.HEAL:
				legal.can_heal = true
	for mem:Monster in ai_team:
		if mem.current_hp > 0:
			legal.can_switch = true
	return legal

func get_smart_intent(ai:Monster, player:Monster, ai_team:Array[Monster], legal: LegalActions) -> INTENT:
	var intent: INTENT = INTENT.ATTACK
	return intent

func get_smart_action(intent: INTENT, ai:Monster, player:Monster, ai_team:Array[Monster]) -> BattleManager.Action:
	var action: BattleManager.Action = BattleManager.Action.new()
	return action

func get_avg_intent(ai:Monster, player:Monster, legal: LegalActions) -> INTENT:
	var intent: INTENT = INTENT.ATTACK
	return intent

func get_avg_action(intent: INTENT, ai:Monster, player:Monster, ai_team:Array[Monster]) -> BattleManager.Action:
	var action: BattleManager.Action = BattleManager.Action.new()
	return action

func get_random_intent(ai:Monster, legal: LegalActions) -> INTENT:
	var intent: INTENT = INTENT.ATTACK
	var rand : float = randf_range(0, 1.0)
	if !legal.has_hp: # Force switch
		intent = INTENT.SWITCH
	elif legal.can_attack and legal.can_defend and legal.can_heal and legal.can_raise_stat:
		if (float(ai.current_hp) / float(ai.HP)) < 1.0:
			if rand < 0.15:
				intent = INTENT.HEAL
		elif rand < 0.30:
			intent = INTENT.DEFEND
		elif rand < 0.45:
			intent = INTENT.STAT
	elif legal.can_attack and legal.can_defend and legal.can_heal:
		if (float(ai.current_hp) / float(ai.HP)) < 1.0:
			if rand < 0.2:
				intent = INTENT.HEAL
		elif rand < 0.4:
			intent = INTENT.DEFEND
	elif legal.can_attack and legal.can_heal and legal.can_raise_stat:
		if (float(ai.current_hp) / float(ai.HP)) < 1.0:
			if rand < 0.2:
				intent = INTENT.HEAL
		elif rand < 0.4:
			intent = INTENT.STAT
	elif legal.can_attack and legal.can_defend and legal.can_raise_stat:
		if rand < 0.2:
			intent = INTENT.DEFEND
		elif rand < 0.4:
			intent = INTENT.STAT
	elif legal.can_attack and legal.can_defend:
		if rand < 0.3:
			intent = INTENT.DEFEND
	elif legal.can_attack and legal.can_heal:
		if (float(ai.current_hp) / float(ai.HP)) < 1.0:
			if rand < 0.3:
				intent = INTENT.HEAL
	elif legal.can_attack and legal.can_raise_stat:
		if rand < 0.3:
			intent = INTENT.STAT
	elif legal.can_defend or legal.can_heal or legal.can_raise_stat:
		if legal.can_defend and legal.can_heal and legal.can_raise_stat:
			if (float(ai.current_hp) / float(ai.HP)) < 1.0:
				if rand < 0.3:
					intent = INTENT.HEAL
				elif rand < 0.6:
					intent = INTENT.DEFEND
				else:
					intent = INTENT.STAT
		elif legal.can_defend and legal.can_heal:
			if (float(ai.current_hp) / float(ai.HP)) < 1.0:
				if rand < 0.4:
					intent = INTENT.HEAL
				else:
					intent = INTENT.DEFEND
		elif legal.can_raise_stat and legal.can_heal:
			if (float(ai.current_hp) / float(ai.HP)) < 1.0:
				if rand < 0.4:
					intent = INTENT.HEAL
				else:
					intent = INTENT.STAT
		elif legal.can_defend and legal.can_raise_stat:
			if rand < 0.4:
				intent = INTENT.STAT
			else:
				intent = INTENT.DEFEND
		elif legal.can_defend:
			intent = INTENT.DEFEND
		elif legal.can_raise_stat:
			intent = INTENT.STAT
		else:
			intent = INTENT.HEAL
	return intent

func get_random_action(intent: INTENT, ai:Monster, ai_team:Array[Monster]) -> BattleManager.Action:
	var action: BattleManager.Action = BattleManager.Action.new()
	if intent == INTENT.SWITCH:
		for mon:Monster in ai_team:
			if !action.target and mon.current_hp > 0:
				action.priority = 100
				action.target = mon
				action.user = ai
			elif mon.current_hp > 0 and randf_range(0, 1.0) > 0.8:
				action.priority = 100
				action.target = mon
				action.user = ai
	else:
		for move:MonsterAction in ai.data.actions:
			if intent == INTENT.ATTACK and (move.action_type == move.ACTION_TYPE.PHYSICAL or move.action_type == move.ACTION_TYPE.MAGICAL):
				if !action.action or randf_range(0, 1.0) > 0.5:
					action.action = move
			elif intent == INTENT.DEFEND and move.action_type == move.ACTION_TYPE.OTHER and move.attack_type == move.ATTACK_TYPE.DEFEND:
				if !action.action or randf_range(0, 1.0) > 0.5:
					action.action = move
			elif intent == INTENT.HEAL and move.action_type == move.ACTION_TYPE.STATUS and move.attack_type == move.ATTACK_TYPE.HEAL:
				if !action.action or randf_range(0, 1.0) > 0.5:
					action.action = move
			elif intent == INTENT.STAT and move.action_type == move.ACTION_TYPE.OTHER and !move.attack_type:
				if !action.action or randf_range(0, 1.0) > 0.5:
					action.action = move
	return action

class LegalActions:
	var has_hp: bool = false
	var can_attack: bool = false
	var can_attack_phys: bool = false
	var can_attack_magic: bool = false
	var can_defend: bool = false
	var can_heal: bool = false
	var can_switch: bool = false
	var can_raise_stat: bool = false
