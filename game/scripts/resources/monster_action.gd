class_name MonsterAction
extends Resource

enum ACTION_TYPE {
	PHYSICAL, MAGICAL, STATUS, OTHER
}

enum ATTACK_TYPE {
	NONE,
	SLASHING, BLUDGEONING, PIERCING,
	ARCANE, FIRE, WATER, ICE, WIND, EARTH, LIGHT, DARK,
	HEAL,
	DEFEND
}

# No underscore means it's handled in LOCAL effect handler of battle manager
enum EFFECTS {
	_NONE,
	_BULKUP, # Raise self ATK 1 stage
	_MEDITATE, # Raise self MATK 1 stage
	_AGILITY, # Raise self SPD 1 stage
	_LOCKON, # Raise self ATK and MATK by 1, lower self DEF and MDEF by 1
	_GROWL, # Lower target ATK by 1
	_SNARL, # Lower target MATK by 1
	_LEER, # Lower target DEF by 1
	_GLARE, # Lower target MDEF by 1
	_MUDBALL, # Lower target SPD by 1
	_THEFT, # Steal 1 AP from target
	_SHOOTINGSTAR, # Randomly raise 1 stat by 1
	_BOMB, # User does half Bomb damage to themselves
	WISH, # At end of 2 turns, heals current active mon
	_SIGILSPHERE, # Reduces incoming Magic damage by 90%, reduces incoming Physical damage by 30%
	REVERSAL, # Power depends on remaining HP
	_WEBSLING, # Lowers target SPD by 2
	CHAINLIGHTNING, # Increases in power each time the attack is used in succession
	_ARCANEEXPLOSION, # Lowers self MATK by 2 stages
	_SOULSIPHON, # Heal by ~50% of damage inflicted
	_MINDSEAL, # Lowers target MATK by 3 stages
	_DRAININGTENDRILS, # Lowers target SPD by 1 stage and heals user by ~50% of damage inflicted
	_SYNTHESIS, # Raises user MDEF by 1 stage
	CHARGEBEAM, # Uses all AP. This attack's power is equal to the AP used to cast it x40
	BODYSPLASH, # This attack's power is equal to the user's base HP stat
	_HURRICANE, # Jumbles target stat changes
	_EMBERS, # Burns target
	_FIREWORKS, # 25% to burn target
	_ANTIDOTE, # Cures poison
	_OINTMENT, # Cures freeze and burn
	_CLEANSE, # Cures all status
	_SNOWSTORM, # Freezes target an lowers target SPD by 1 stage
	_TOXIN, # Poisons target
	_FROSTBURN, # Freezes and burns target
	_SUPERNOVA, # KOs the user and inflicts burn to all living mons
	_TSUNAMI # Inflicts 10% max HP to each opponent party mon
}

@export var action_name : String
@export var priority : int = 0
@export_multiline var description : PackedStringArray

@export_category("Monster Action Stats")
@export_range(-1, 200, 1) var power : int
@export_range(-1, 5, 1) var ap_cost : int
var AP: String :
	get: return str(ap_cost) if ap_cost>=0 else "X"

@export_category("Monster Action Types")
@export var action_type : ACTION_TYPE
@export var attack_type : ATTACK_TYPE

@export_category("Monster Effects")
@export var action_effect : EFFECTS

@export_category("Multi-Attack Action")
@export var multi_attack : bool = false
@export var multi_attack_action: MonsterAction
@export var range : Array[int] = [2, 2, 2, 2, 2, 2, 2, 3, 3, 3]
