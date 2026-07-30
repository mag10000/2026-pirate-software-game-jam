extends Control

func _ready():
	$score.text += "$" + format_number(0-Global.debt)
	get_scores()

func get_scores():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))
	for child in $ScrollContainer/ScoresContainer.get_children():
		child.queue_free()
	for score in sw_result.scores:
		var label = Label.new()
		label.text = " Name: " + score.player_name + ", Score: " + format_number(score.score)
		label.add_theme_font_size_override("font_size",32)
		label.add_theme_font_override("font",load("res://Match 8h.ttf"))
		label.add_theme_constant_override("outline_size",8)
		label.name = score.player_name + str(score.score)
		$ScrollContainer/ScoresContainer.add_child(label)




func format_number(number: int) -> String:
	# Handle negative numbers by adding the "minus" sign in advance, as we discard it
	# when looping over the number.
	var formatted_number := "-" if sign(number) == -1 else ""
	var index := 0
	var number_string := str(abs(number))
	
	for digit in number_string:
		formatted_number += digit
		
		var counter := number_string.length() - index
		
		# Don't add a comma at the end of the number, but add a comma every 3 digits
		# (taking into account the number's length).
		if counter >= 2 and counter % 3 == 1:
			formatted_number += ","
			
		index += 1
	
	return formatted_number


func _on_submit_pressed():
	SilentWolf.Scores.save_score($LineEdit.text.to_upper(), 0-Global.money_earned)
	$submit.disabled = true
	get_scores()


func _on_to_main_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
