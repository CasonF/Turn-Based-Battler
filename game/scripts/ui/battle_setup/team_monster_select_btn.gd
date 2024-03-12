class_name TeamMonsterSelBtn
extends Button

@export var test_monster: MonsterStats

#@onready var select_btn : Button = $TeamMonsterSelectBtn
@onready var red_x : Sprite2D = $RemoveFromPartySprite
@onready var remove_from_party_button : Button = $RemoveFromPartySprite/RemoveFromPartyBtn
@onready var monster_label : Label = $MonsterLabel

var self_ref: TeamMonsterSelBtn

var orig_position: Vector2
var mouse_is_hovering: bool = false
var is_dragging: bool = false

signal remove_from_party
signal team_monster(monster: Monster)
signal dropped_team_monster

var monster: Monster :
	set(mon):
		monster = mon
		if mon != null:
			monster_backup = mon
		setup_monster_sprite()
		setup_red_x()
# Used in case of illegal drag and drop...
var monster_backup: Monster

func _ready() -> void:
	orig_position = global_position
	if GlobalVariables.debug_mode:
		if test_monster:
			var mon: Monster = Monster.create(test_monster)
			monster = mon
	setup_monster_sprite()
	setup_red_x()
	if remove_from_party_button:
		remove_from_party_button.pressed.connect(remove_from_party_emitter)

func setup_monster_sprite() -> void:
	if monster:
		var btn_icon: Sprite2D = Sprite2D.new()
		btn_icon.texture = monster.data.sprite
		if monster_label:
			monster_label.show()
			monster_label.text = monster.data.monster_name + " - " + str(monster.level)
		if btn_icon.texture.get_height() > 64 or btn_icon.texture.get_width() > 64:
			expand_icon = true
		else:
			expand_icon = false
		icon = btn_icon.texture
	else:
		icon = null
		if monster_label:
			monster_label.hide()

func setup_red_x() -> void:
	if monster:
		if red_x:
			red_x.show()
			remove_from_party_button.disabled = false
	else:
		if red_x:
			red_x.hide()
			remove_from_party_button.disabled = true

func remove_from_party_emitter() -> void:
	monster = null
	monster_backup = null
	remove_from_party.emit()

func _get_drag_data(at_position: Vector2) -> TeamMonsterSelBtn:
	var preview = TeamMonsterSelBtn.new()
	preview.icon = icon
	preview.expand_icon = true
	preview.size = Vector2(80, 80)
	preview.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.monster = monster
	preview.self_ref = self
	preview.top_level = true
	preview.z_index = 90
	
	set_drag_preview(preview)
	monster = null
	
	return preview

func _can_drop_data(at_position: Vector2, data) -> bool:
	return data is TeamMonsterSelBtn

func _drop_data(at_position: Vector2, data) -> void:
	data.self_ref.monster = monster
	monster = data.monster
	dropped_team_monster.emit()

func _notification(what:int) -> void:
	if what==NOTIFICATION_DRAG_END and not is_drag_successful():
		if monster_backup:
			monster = monster_backup

func _pressed() -> void:
	if monster:
		team_monster.emit(monster)
