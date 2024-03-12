class_name GlobalSettings
extends Node

static var save_path = "res://user/settings.save"

static var VOLUME_PERCENTAGE: float = 100.0

static func get_global_volume() -> float:
	if GlobalSettings.VOLUME_PERCENTAGE >= 1.0:
		return -35.0 + (25.0 * (GlobalSettings.VOLUME_PERCENTAGE / 100.0))
	else:
		return -80.0

# Try again but with ResourceSaver and ResourceLoader??
# Apparently they only update exported resource variables??
static func save_settings() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(VOLUME_PERCENTAGE)

static func load_settings() -> void:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		setup_settings(file)

static func setup_settings(file: FileAccess) -> void:
	VOLUME_PERCENTAGE = file.get_var(VOLUME_PERCENTAGE)
