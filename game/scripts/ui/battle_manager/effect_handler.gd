class_name EffectHandler
extends Node

const self_stat_effect: Array[MonsterAction.EFFECTS] = [
MonsterAction.EFFECTS._000, MonsterAction.EFFECTS._001,
MonsterAction.EFFECTS._002, MonsterAction.EFFECTS._003]

const target_stat_effect: Array[MonsterAction.EFFECTS] = [
MonsterAction.EFFECTS._004, MonsterAction.EFFECTS._005,
MonsterAction.EFFECTS._006]

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
#===============================================================================
# Used in some effects
#-------------------------------------------------------------------------------
func calc_heal(action: MonsterAction, user: Monster) -> int:
	return ((((2 * user.level) / 5) * action.power * (user.MATK / user.level)) / 50) * BattleManager.stat_multiplier.get(user.MATK_STAGE) + 1

func calc_armor(action: MonsterAction, user: Monster) -> int:
	return (((2 * user.level) / 5) * action.power * ((user.DEF + user.MDEF) / (user.level * 2))) / 50 + 1
#*******************************************************************************
#*******************************************************************************
#===============================================================================
# Self Stat Modifying Effects
#-------------------------------------------------------------------------------
func self_stat_modifying_effect(effect:MonsterAction.EFFECTS, user:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[effect])
	call.call(user)

# Raises user ATK 1 stage
func effect_000(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.ATK, 1)
# Raises user MATK 1 stage
func effect_001(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.MATK, 1)
# Raises user SPD 1 stage
func effect_002(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.SPD, 1)
# Raise user ATK and MATK by 1, lower user DEF and MDEF by 1
func effect_003(user:Monster) -> void:
	user.update_stat_stage(Monster.STAT_STAGE.ATK, 1)
	user.update_stat_stage(Monster.STAT_STAGE.MATK, 1)
	user.update_stat_stage(Monster.STAT_STAGE.DEF, -1)
	user.update_stat_stage(Monster.STAT_STAGE.MDEF, -1)
#===============================================================================
# Target Stat Modifying Effects
#-------------------------------------------------------------------------------
func target_stat_modifying_effect(effect:MonsterAction.EFFECTS, target:Monster) -> void:
	var call := Callable(self, "effect" + MonsterAction.EFFECTS.keys()[effect])
	call.call(target)

# Lower target DEF 1 stage
func effect_004(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.DEF, -1)
# Lower target MDEF 1 stage
func effect_005(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.MDEF, -1)
# Lower target SPD 1 stage
func effect_006(target:Monster) -> void:
	target.update_stat_stage(Monster.STAT_STAGE.SPD, -1)
