extends Control

@export var close_to_home = true

func _ready():
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
	

func _on_button_pressed():
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
	Global.crt_on = $CheckBox.button_pressed
