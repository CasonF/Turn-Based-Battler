class_name StatChart
extends Polygon2D

var points : PackedVector2Array = []

func _draw() -> void:
	if points.size() > 0:
		draw_polygon(points, PackedColorArray(["00c2cfd3"]))
