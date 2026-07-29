extends Control

@export var close_to_home = true

func _ready():
	$CheckBox.button_pressed = Global.crt_on

func _on_button_pressed():
	if close_to_home:
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		Global.crt_on = $CheckBox.button_pressed
		hide()


func _on_check_box_pressed():
	Global.crt_on = $CheckBox.button_pressed
