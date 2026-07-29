extends Control


func _on_button_pressed():
	SilentWolf.Scores.wipe_leaderboard()


func _on_button_2_pressed():
	get_tree().quit()


func _on_button_3_pressed():
	var sw_result = await SilentWolf.Scores.get_scores(0, "DailyBoard").sw_get_scores_complete
	var scores = sw_result.scores
	$Label.text = str(scores)
