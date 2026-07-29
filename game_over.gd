extends Control


func _on_button_pressed():
	Global.clear_data()
	get_tree().change_scene_to_file("res://main_menu.tscn")
