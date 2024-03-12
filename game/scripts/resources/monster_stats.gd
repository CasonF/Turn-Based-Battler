class_name MonsterStats
extends Resource

enum level_rate {
	SLOW,
	MEDIUM,
	FAST
}

@export var monster_name : String
@export var is_monster_leader : bool = false
@export var default_direction_left : bool = false

@export_category("Monster Sprite")
@export var sprite : Texture2D

@export_category("Monster Base Stats")
@export_range(5, 200, 1) var hp : int
@export_range(5, 200, 1) var atk : int
@export_range(5, 200, 1) var def : int
@export_range(5, 200, 1) var matk : int
@export_range(5, 200, 1) var mdef : int
@export_range(5, 200, 1) var spd : int

@export_category("Monster Misc. Stats")
@export_range(10, 300, 1) var xp_yield : int
@export var growth_rate : level_rate

@export_category("Monster Actions")
@export var actions : Array[MonsterAction] = []
@export var knowable_actions : Array[MonsterAction] = []

@export_category("Position Offsets")
@export var y_offset : float = 0.0
