extends Control


func _on_button_pressed():
	Global.clear_data()
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_leaderboard_pressed():
	$LeaderBoard.show()


func _on_animation_player_animation_finished(anim_name):
	$LeaderBoard.get_scores()
