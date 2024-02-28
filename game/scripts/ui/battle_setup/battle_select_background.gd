extends ParallaxLayer

@export var BACKGROUND_SPEED:float = 15

func _process(delta) -> void:
	motion_offset.x += BACKGROUND_SPEED * delta
