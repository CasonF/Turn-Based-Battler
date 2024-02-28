class_name MonsterActionButton
extends Button

enum ICONS {
	PHYSICAL, MAGICAL, HEAL, DEFEND, STAT
}
var action_icons : Dictionary = {
	ICONS.PHYSICAL : "res://game/assets/icons/i_physical.png",
	ICONS.MAGICAL : "res://game/assets/icons/i_magical.png",
	ICONS.HEAL : "res://game/assets/icons/i_heal.png",
	ICONS.DEFEND : "res://game/assets/icons/i_defend.png",
	ICONS.STAT : "res://game/assets/icons/i_stat.png"
}

signal use_action(action: MonsterAction)
var action: MonsterAction

func _ready() -> void:
	if action:
		if action.power > 0:
			text = action.action_name + " - " + str(action.power)
		else:
			text = action.action_name
		if action.priority != 0:
			if action.priority > 0:
				text += "\nPriority: +" + str(action.priority)
			else:
				text += "\nPriority: " + str(action.priority)
		icon = get_action_icon(action)

func get_action_icon(ma: MonsterAction) -> Texture:
	var i : Texture
	var i_path : String
	if ma.action_type == ma.ACTION_TYPE.PHYSICAL:
		i_path = action_icons.get(ICONS.PHYSICAL)
	elif ma.action_type == ma.ACTION_TYPE.MAGICAL:
		i_path = action_icons.get(ICONS.MAGICAL)
	elif ma.action_type == ma.ACTION_TYPE.STATUS:
		# If adding other statuses, will need to abstract this...
		i_path = action_icons.get(ICONS.HEAL)
	elif ma.action_type == ma.ACTION_TYPE.OTHER:
		i_path = set_action_icon_OTHER(ma)
	
	if i_path:
		i = load(i_path)
	return i

func set_action_icon_OTHER(ma:MonsterAction) -> String:
	var i_path : String
	if ma.attack_type == ma.ATTACK_TYPE.DEFEND:
		i_path = action_icons.get(ICONS.DEFEND)
	else:
		i_path = action_icons.get(ICONS.STAT)
	return i_path

func _pressed() -> void:
	use_action.emit(action)
