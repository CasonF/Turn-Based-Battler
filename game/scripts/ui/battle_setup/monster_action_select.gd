class_name MonsterActionSelect
extends Button

var action: MonsterAction
signal action_selected(ma: MonsterAction, btn: MonsterActionSelect)

func _ready() -> void:
	if action:
		text = action.action_name

func _pressed() -> void:
	action_selected.emit(action, self)
