class_name MonsterActionButton
extends Button

@onready var action_info_panel : Panel = $ActionInfoPanel
@onready var action_scroll_container: ScrollContainer = $ActionInfoPanel/ScrollContainer
@onready var action_info_divider: VBoxContainer = $ActionInfoPanel/ScrollContainer/InfoDivider
@onready var action_description : Label = $ActionInfoPanel/ScrollContainer/InfoDivider/Description
@onready var action_type : Label = $ActionInfoPanel/ScrollContainer/InfoDivider/ActionType
@onready var action_power : Label = $ActionInfoPanel/ScrollContainer/InfoDivider/Power

@onready var ap_cost : Label = $APCost

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

var mouse_hovering: bool = false
var info_fully_visible: bool = false
var info_hover: bool = false

const DELAY_TIME: float = 0.5
var show_delay: float = 0.5
var hide_delay: float = 0.5

func _ready() -> void:
	setup_info_panel()

func _process(delta) -> void:
	if mouse_hovering:
		show_info_panel(delta)
	else:
		hide_info_panel(delta)

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

func setup_info_panel() -> void:
	if action:
		text = action.action_name
		ap_cost.text = "Cost: " + action.AP
		if action.description.size() > 0:
			action_description.text = "Description: " + action.description[0]
		if action.power > 0:
			action_power.text = "Power - " + str(action.power)
		elif action.power == -1:
			# Negative 1 means variable power...
			action_power.text = "Power - X"
		else:
			action_power.hide()
		action_type.text = "Action Type - " + str(MonsterAction.ACTION_TYPE.keys()[action.action_type]).to_pascal_case()
		icon = get_action_icon(action)

func show_info_panel(delta) -> void:
	if !action:
		setup_info_panel()
	if hide_delay < DELAY_TIME:
		hide_delay += delta
	
	if show_delay > 0:
		show_delay -= delta
	else:
		if action_info_panel.modulate.a < 1:
			action_info_panel.modulate.a += delta
			info_fully_visible = false
			action_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			action_scroll_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
			action_info_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			info_fully_visible = true
			action_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
			action_scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS
			action_info_divider.mouse_filter = Control.MOUSE_FILTER_PASS

func hide_info_panel(delta) -> void:
	if show_delay < DELAY_TIME:
		show_delay += delta
	
	if hide_delay > 0:
		hide_delay -= delta
	elif !info_fully_visible or !info_hover:
		if action_info_panel.modulate.a > 0:
			action_info_panel.modulate.a -= delta
			info_fully_visible = false
			action_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			action_scroll_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
			action_info_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _mouse_entered() -> void:
	mouse_hovering = true

func _mouse_exited() -> void:
	mouse_hovering = false

func info_mouse_entered() -> void:
	info_hover = true

func info_mouse_exited() -> void:
	info_hover = false

func _pressed() -> void:
	use_action.emit(action)
