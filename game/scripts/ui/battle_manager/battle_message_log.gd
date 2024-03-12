class_name BattleMessageLog
extends Panel

@onready var expand_button : Button = $ExpandButton
@onready var scroll_container : ScrollContainer = $ScrollContainer
var scroll_bar: VScrollBar
var max_scroll_length = 0

@export var scale_speed : float = 600.0
@export var max_size: float = 420.0
@export var min_size: float = 30.0

var expand_contents : bool = false
var finished_translation: bool = true

func _ready() -> void:
	if scroll_container:
		scroll_bar = scroll_container.get_v_scroll_bar()
		scroll_bar.changed.connect(handle_scrollbar_changed)
		max_scroll_length = scroll_bar.max_value

func _process(delta) -> void:
	if !finished_translation:
		if expand_contents:
			if size.y < max_size:
				size.y += scale_speed * delta
				global_position.y -= scale_speed * delta
			else:
				expand_button.text = "v v v v v"
				finished_translation = true
		else:
			if size.y > min_size:
				size.y -= scale_speed * delta
				global_position.y += scale_speed * delta
			else:
				expand_button.text = "^ ^ ^ ^ ^"
				finished_translation = true

func _expand_contents() -> void:
	expand_contents = !expand_contents
	finished_translation = false
   
func handle_scrollbar_changed():
	if max_scroll_length != scroll_bar.max_value:
		max_scroll_length = scroll_bar.max_value
		scroll_container.scroll_vertical = max_scroll_length
