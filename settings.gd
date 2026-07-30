extends Control

@export var close_to_home = true

func _ready():
	$music.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$sfx.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	if FileAccess.file_exists("user://settings.conf"):
		var file = FileAccess.open("user://settings.conf", FileAccess.READ)
		var new_json = JSON.new()
		var content = new_json.parse(file.get_as_text())
		var data = new_json.get_data()
		print(data)
		Global.crt_on = data.crt
		$music.value = data.music
		$sfx.value = data.sfx
	$CheckBox.button_pressed = Global.crt_on
	print("hi")

func _on_button_pressed():
	_on_hidden()
	if close_to_home:
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		Global.crt_on = $CheckBox.button_pressed
		hide()


func _on_check_box_pressed():
	Global.crt_on = $CheckBox.button_pressed


func _on_hidden():
	var file = FileAccess.open("user://settings.conf", FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"crt" : $CheckBox.button_pressed,
		"music" : $music.value,
		"sfx" : $music.value
	}))
	file.close()
	file = null
	print("dhfjus")
	Global.crt_on = $CheckBox.button_pressed


func _on_music_mouse_exited():
	release_focus()


func _on_sfx_mouse_exited():
	release_focus()


func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(1,linear_to_db($music.value))


func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(2,linear_to_db($sfx.value))
