class_name MainMenu
extends Node

@onready var main_menu := $Main
@onready var options_menu : OptionsMenu = $OptionsMenu
@onready var music_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	GlobalSettings.load_settings()
	connect_signals()
	setup_music_player()

func connect_signals() -> void:
	if options_menu:
		options_menu.volume_updated.connect(setup_music_player)
		options_menu.pressed_back_button.connect(_close_options)

func _start_game() -> void:
	get_tree().change_scene_to_file("res://game/scenes/battle_setup.tscn")

func _open_options() -> void:
	main_menu.hide()
	options_menu._refresh()
	options_menu.show()

func _exit_game() -> void:
	get_tree().quit()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if options_menu.visible:
				_close_options()
			else:
				_exit_game()

func setup_music_player() -> void:
	if music_player:
		music_player.volume_db = GlobalSettings.get_global_volume()

func _close_options() -> void:
	GlobalSettings.save_settings()
	options_menu.hide()
	main_menu.show()
