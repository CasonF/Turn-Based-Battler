class_name OptionsMenu
extends Node

@onready var back_button: Button = $OptionsBack
signal pressed_back_button

@onready var volume_bar: HSlider = $Header/ScrollContainer/VBoxContainer/HBoxContainer/VolumeSlider
@onready var volume_level: Label = $Header/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/VolumeLevel

signal volume_updated

func _ready() -> void:
	volume_bar.value = GlobalSettings.VOLUME_PERCENTAGE
	volume_level.text = str(volume_bar.value) + "%"

func _refresh() -> void:
	volume_bar.value = GlobalSettings.VOLUME_PERCENTAGE
	volume_level.text = str(volume_bar.value) + "%"

func _update_volume_level(value: float) -> void:
	GlobalSettings.VOLUME_PERCENTAGE = value
	volume_level.text = str(value) + "%"
	volume_updated.emit()

func _back_button_echo() -> void:
	pressed_back_button.emit()
