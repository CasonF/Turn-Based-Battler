class_name EffectHandler
extends Node

const self_stat_effect: Array[MonsterAction.EFFECTS] = [
MonsterAction.EFFECTS._BULKUP, MonsterAction.EFFECTS._MEDITATE,
MonsterAction.EFFECTS._AGILITY, MonsterAction.EFFECTS._LOCKON,
MonsterAction.EFFECTS._SHOOTINGSTAR, MonsterAction.EFFECTS._SIGILSPHERE,
MonsterAction.EFFECTS._ARCANEEXPLOSION, MonsterAction.EFFECTS._SYNTHESIS]

const target_stat_effect: Array[MonsterAction.EFFECTS] = [
MonsterAction.EFFECTS._GROWL, MonsterAction.EFFECTS._SNARL,
MonsterAction.EFFECTS._LEER, MonsterAction.EFFECTS._GLARE,
MonsterAction.EFFECTS._MUDBALL, MonsterAction.EFFECTS._WEBSLING,
MonsterAction.EFFECTS._MINDSEAL, MonsterAction.EFFECTS._HURRICANE]

const stat_exchange_effect: Array[MonsterAction.EFFECTS] = [
	MonsterAction.EFFECTS._THEFT
]

const health_effect: Array[MonsterAction.EFFECTS] = [
	MonsterAction.EFFECTS._BOMB, MonsterAction.EFFECTS._SOULSIPHON,
	MonsterAction.EFFECTS._DRAININGTENDRILS
]

const status_effect: Array[MonsterAction.EFFECTS] = [
	MonsterAction.EFFECTS._TOXIN, MonsterAction.EFFECTS._FROSTBURN,
	MonsterAction.EFFECTS._EMBERS, MonsterAction.EFFECTS._FIREWORKS,
	MonsterAction.EFFECTS._ANTIDOTE, MonsterAction.EFFECTS._OINTMENT,
	MonsterAction.EFFECTS._CLEANSE, MonsterAction.EFFECTS._SNOWSTORM
]

const team_effect: Array[MonsterAction.EFFECTS] = [
	MonsterAction.EFFECTS._SUPERNOVA, MonsterAction.EFFECTS._TSUNAMI
]

#===============================================================================
# Effect Routing
#-------------------------------------------------------------------------------
func pre_battle_effect(action:BattleManager.Action) -> void:
	pass

func post_battle_effect(action:BattleManager.Action) -> void:
	if action.action.action_effect:
		if self_stat_effect.has(action.action.action_effect):
			self_stat_modifying_effect(action.action.action_effect, action.user)
		elif target_stat_effect.has(action.action.action_effect):
			target_stat_modifying_effect(action.action.action_effect, action.target)
		elif stat_exchange_effect.has(action.action.action_effect):
			stat_exchange_modifying_effect(action.action.action_effect, action.user, action.target)
		elif health_effect.has(action.action.action_effect):
			health_modifying_effect(action.action, action.user, action.target)
		elif status_effect.has(action.action.action_effect):
			status_modifying_effect(action.action, action.user, action.target)
		elif team_effect.has(action.action.action_effect):
			team_modifying_effect(action.action, action.user, action.target, action.user_party, action.enemy_party)
#===============================================================================
# Used in some effects
#-------------------------------------------------------------------------------
func calc_damage(attack: MonsterAction, attacker: Monster, defender: Monster) -> int:
	var damage : int = 1
	if attack.action_type == attack.ACTION_TYPE.PHYSICAL:
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.ATK * stat_multiplier.get(attacker.ATK_STAGE)) / (defender.DEF * stat_multiplier.get(defender.DEF_STAGE)))) / 50) * randf_range(0.85, 1.15) + 1
	elif attack.action_type == attack.ACTION_TYPE.MAGICAL:
		damage = ((((2 * attacker.level) / 5) * attack.power * ((attacker.MATK * stat_multiplier.get(attacker.MATK_STAGE)) / (defender.MDEF * stat_multiplier.get(defender.MDEF_STAGE)))) / 50) * randf_range(0.85, 1.15) + 1
	return damage

func calc_heal(action: MonsterAction, user: Monster) -> int:
	return (((float(2.0 * user.level) / 5.0) * action.power * (float(user.MATK) / user.level)) / 50.0) * stat_multiplier.get(user.MATK_STAGE) * randf_range(0.85, 1.15) + 1

func calc_armor(action: MonsterAction, user: Monster) -> int:
	return ((float(2.0 * user.level) / 5.0) * action.power * (float(user.DEF + user.MDEF) / (user.level * 2.0))) / 50.0 + 1

const stat_multiplier : Dictionary = {
	-3:0.4, -2:0.5, -1:0.67, 0:1.0, 1:1.5, 2:2.0, 3:2.5
}
#*******************************************************************************
#*******************************************************************************
#===============================================================================
# Self Stat Modifying Effects
#-------------------------------------------------------------------------------
func self_stat_modifying_effect(effect:MonsterAction.EFFECTS, user:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[effect])
	call.call(user)

# Raises user ATK 1 stage
func effect_BULKUP(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.ATK, 1)
# Raises user MATK 1 stage
func effect_MEDITATE(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.MATK, 1)
# Raises user SPD 1 stage
func effect_AGILITY(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.SPD, 1)
# Raise user ATK and MATK by 1, lower user DEF and MDEF by 1
func effect_LOCKON(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.ATK, 1)
	user.update_stat_stage(Monster.STAT_STAGE.MATK, 1)
	user.update_stat_stage(Monster.STAT_STAGE.DEF, -1)
	user.update_stat_stage(Monster.STAT_STAGE.MDEF, -1)
# Raises user random stat 1 stage
func effect_SHOOTINGSTAR(user:Monster) -> void:
	var rand : float = randf_range(0, 100)
	if rand < 20:
		user.update_stat_stage(Monster.STAT_STAGE.ATK, 1)
	elif rand < 40:
		user.update_stat_stage(Monster.STAT_STAGE.DEF, 1)
	elif rand < 60:
		user.update_stat_stage(Monster.STAT_STAGE.MATK, 1)
	elif rand < 80:
		user.update_stat_stage(Monster.STAT_STAGE.MDEF, 1)
	else:
		user.update_stat_stage(Monster.STAT_STAGE.SPD, 1)
# Gives self Sigil Sphere, which reduces magic damage from opponent by 90%
# reduces physical damage from opponent by 30% this turn only
func effect_SIGILSPHERE(user:Monster) -> void:
	user.has_sigil_sphere = true
# Lowers user MATK 2 stages
func effect_ARCANEEXPLOSION(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.MATK, -2)
# Raises user MDEF by 1 stage
func effect_SYNTHESIS(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.MDEF, 1)
#===============================================================================
# Target Stat Modifying Effects
#-------------------------------------------------------------------------------
func target_stat_modifying_effect(effect:MonsterAction.EFFECTS, target:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[effect])
	call.call(target)

# Lower target DEF 1 stage
func effect_LEER(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.DEF, -1)
# Lower target MDEF 1 stage
func effect_GLARE(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.MDEF, -1)
# Lower target ATK 1 stage
func effect_GROWL(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.ATK, -1)
# Lower target MATK 1 stage
func effect_SNARL(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.MATK, -1)
# Lower target SPD 1 stage
func effect_MUDBALL(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.SPD, -1)
# Lower target SPD 2 stages
func effect_WEBSLING(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.SPD, -2)
# Lowers target MATK 3 stages
func effect_MINDSEAL(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.MATK, -3)
# Jumbles target stat changes
func effect_HURRICANE(target:Monster) -> void:
	var stat_changes := [target.ATK_STAGE, target.DEF_STAGE, target.MATK_STAGE, target.MDEF_STAGE, target.SPD_STAGE]
	stat_changes.shuffle()
	target.ATK_STAGE = stat_changes[0]
	target.DEF_STAGE = stat_changes[1]
	target.MATK_STAGE = stat_changes[2]
	target.MDEF_STAGE = stat_changes[3]
	target.SPD_STAGE = stat_changes[4]
#===============================================================================
# Stat Exchange Modifying Effects
#-------------------------------------------------------------------------------
func stat_exchange_modifying_effect(effect:MonsterAction.EFFECTS, user:Monster, target:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[effect])
	call.call(user, target)

# Steal 1 AP from target (if greater than 0) and add it to self
func effect_THEFT(user:Monster, target:Monster) -> void:
	# This move has -10 priority, so should never put target in "illegal move use" situation
	if target.AP > 0:
		target.AP -= 1
		user.gain_AP()
#===============================================================================
# Health Modifying Effects
#-------------------------------------------------------------------------------
func health_modifying_effect(action:MonsterAction, user:Monster, target:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[action.action_effect])
	call.call(action, user, target)

func effect_BOMB(action:MonsterAction, user:Monster, target:Monster) -> void:
	var damage = calc_damage(action, user, user) / 2
	user.take_damage(damage)

func effect_SOULSIPHON(action:MonsterAction, user:Monster, target:Monster) -> void:
	var damage = calc_damage(action, user, target) / 2
	user.heal(damage)

func effect_DRAININGTENDRILS(action:MonsterAction, user:Monster, target:Monster) -> void:
	var damage = calc_damage(action, user, target) / 2
	user.heal(damage)
	target.update_stat_stage(Monster.STAT_STAGE.SPD, -1)
#===============================================================================
# Status Modifying Effects
#-------------------------------------------------------------------------------
func status_modifying_effect(action:MonsterAction, user:Monster, target:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[action.action_effect])
	call.call(action, user, target)
# Applies poison status to target
func effect_TOXIN(action:MonsterAction, user:Monster, target:Monster) -> void:
	if !target.active_statuses.has(target.STATUSES.POISON):
		target.active_statuses.append(target.STATUSES.POISON)
# Applies Freeze and Burn statuses to target
func effect_FROSTBURN(action:MonsterAction, user:Monster, target:Monster) -> void:
	if !target.active_statuses.has(target.STATUSES.FREEZE):
		target.active_statuses.append(target.STATUSES.FREEZE)
	if !target.active_statuses.has(target.STATUSES.BURN):
		target.active_statuses.append(target.STATUSES.BURN)
# Applies Burn status to target
func effect_EMBERS(action:MonsterAction, user:Monster, target:Monster) -> void:
	if !target.active_statuses.has(target.STATUSES.BURN):
		target.active_statuses.append(target.STATUSES.BURN)
# Has a 25% chance to Burn target
func effect_FIREWORKS(action:MonsterAction, user:Monster, target:Monster) -> void:
	if !target.active_statuses.has(target.STATUSES.BURN) and randf_range(0, 100.0) <= 25.0:
		target.active_statuses.append(target.STATUSES.BURN)
# Cures self of Poison status
func effect_ANTIDOTE(action:MonsterAction, user:Monster, target:Monster) -> void:
	if user.active_statuses.has(user.STATUSES.POISON):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.POISON))
# Cures self of Burn and Freeze status
func effect_OINTMENT(action:MonsterAction, user:Monster, target:Monster) -> void:
	if user.active_statuses.has(user.STATUSES.BURN):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.BURN))
	if user.active_statuses.has(user.STATUSES.FREEZE):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.FREEZE))
# Cures self of Burn, Poison, and Freeze status
func effect_CLEANSE(action:MonsterAction, user:Monster, target:Monster) -> void:
	if user.active_statuses.has(user.STATUSES.BURN):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.BURN))
	if user.active_statuses.has(user.STATUSES.FREEZE):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.FREEZE))
	if user.active_statuses.has(user.STATUSES.POISON):
		user.active_statuses.remove_at(user.active_statuses.find(user.STATUSES.POISON))
# Reduces target SPD by 1 stage and applies Freeze to target
func effect_SNOWSTORM(action:MonsterAction, user:Monster, target:Monster) -> void:
	if !target.active_statuses.has(target.STATUSES.FREEZE):
		target.active_statuses.append(target.STATUSES.FREEZE)
	target.update_stat_stage(target.STAT_STAGE.SPD, -1)
#===============================================================================
# Team Modifying Effects
#-------------------------------------------------------------------------------
func team_modifying_effect(action:MonsterAction, user:Monster, target:Monster, user_party:Array[Monster], target_party:Array[Monster]) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[action.action_effect])
	call.call(action, user, target, user_party, target_party)
# KOs user and burns all other living mons
func effect_SUPERNOVA(action:MonsterAction, user:Monster, target:Monster, user_party:Array[Monster], target_party:Array[Monster]) -> void:
	user.current_hp = 0
	if target.current_hp > 0 and !target.active_statuses.has(target.STATUSES.BURN):
		target.active_statuses.append(target.STATUSES.BURN)
	for um:Monster in user_party:
		if um.current_hp > 0 and !um.active_statuses.has(um.STATUSES.BURN):
			um.active_statuses.append(um.STATUSES.BURN)
	for tm:Monster in target_party:
		if tm.current_hp > 0 and !tm.active_statuses.has(tm.STATUSES.BURN):
			tm.active_statuses.append(tm.STATUSES.BURN)
# Inflicts 10% max hp damage to each living opponent party mon
func effect_TSUNAMI(action:MonsterAction, user:Monster, target:Monster, user_party:Array[Monster], target_party:Array[Monster]) -> void:
	for mon:Monster in target_party:
		if mon.current_hp > 0:
			mon.current_hp -= mon.HP / 10
