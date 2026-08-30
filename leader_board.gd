extends Control

func _ready():
	if not FileAccess.file_exists("user://leaderboard.csv"):
		var file = FileAccess.open("user://leaderboard.csv", FileAccess.WRITE)
		file.store_string("name:,score:")
		file.close()
		file = null
	print(Time.get_datetime_string_from_system())
	if (Global.debt <= 0):
		$score.text += "$" + format_number(Global.money)
	else: 
		$score.text += "$" + format_number(Global.money- Global.debt)
	get_scores()

func sort_ascending(a, b):
	if a.score < b.score:
		return false
	return true

func get_scores():
	#var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	#print("Scores: " + str(sw_result.scores))
	for child in $ScrollContainer/ScoresContainer.get_children():
		child.queue_free()
	#for score in sw_result.scores:
	
	var csv_data = get_dict_from_csv()
	
	for score in csv_data:
		var label = Label.new()
		label.text = " Name: " + score.player_name + ", Score: " + format_number(score.score)
		label.add_theme_font_size_override("font_size",32)
		label.add_theme_font_override("font",load("res://Match 8h.ttf"))
		label.add_theme_constant_override("outline_size",8)
		label.name = score.player_name + str(score.score)
		$ScrollContainer/ScoresContainer.add_child(label)

func get_dict_from_csv():
	var plain_csv_data = FileAccess.get_file_as_string("user://leaderboard.csv")
	var formatted_csv = []
	
	var format1 = plain_csv_data.split("
")
	format1.remove_at(0)
	for line in format1:
		if line == "":
			return formatted_csv
		var formatted_line = line.split(",")
		print(formatted_line.size())
		formatted_csv.append({"player_name" : formatted_line[0],"score" : int(formatted_line[1])})
	return formatted_csv



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
	var csv_data = get_dict_from_csv()
	csv_data.append({"player_name" : $LineEdit.text.to_upper(),"score" : Global.money-Global.debt})
	#SilentWolf.Scores.save_score($LineEdit.text.to_upper(), Global.money-Global.debt)
	csv_data.sort_custom(sort_ascending)
	var final_text = "name:,score:"
	for value in csv_data:
		var line = value.player_name + "," + str(value.score)
		final_text += "
" + str(line)
	var file = FileAccess.open("user://leaderboard.csv", FileAccess.WRITE)
	file.store_string(final_text)
	file.close()
	file = null
	$submit.disabled = true
	get_scores()


func _on_to_main_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func wipe():
	DirAccess.remove_absolute("user://leaderboard.csv")
