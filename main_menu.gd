extends Control


func _on_button_pressed():
	get_tree().change_scene_to_file("res://story_beat.tscn")


func _on_setttings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")
