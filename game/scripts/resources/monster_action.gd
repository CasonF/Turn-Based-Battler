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

enum EFFECTS {
	_NONE,
	_000, # Raise self ATK 1 stage
	_001, # Raise self MATK 1 stage
	_002, # Raise self SPD 1 stage
	_003, # Raise self ATK and MATK by 1, lower self DEF and MDEF by 1
	_004, # Lower target DEF by 1
	_005, # Lower target MDEF by 1
	_006 # Lower target SPD by 1
}

@export var action_name : String
@export var priority : int = 0

@export_category("Monster Action Stats")
@export_range(0, 200, 1) var power : int
@export_range(0, 5, 1) var ap_cost : int

@export_category("Monster Action Types")
@export var action_type : ACTION_TYPE
@export var attack_type : ATTACK_TYPE

@export_category("Monster Effects")
@export var action_effect : EFFECTS
