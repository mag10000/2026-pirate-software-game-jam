extends Control

@export var main_node: Node

const Balloon = preload("res://dialogue/balloon.tscn")

var text = "DAY 1
REMAINING DEBT: 10,000"

func _ready():
	text = "DAY " + str(Global.day) + "
REMAINING DEBT: " + "$" + format_number(Global.debt)
	type_text()

func type_text():
	$text.text = ""
	for letter in text:
		print("hi")
		await get_tree().create_timer(0.1).timeout
		$text.text += letter
		if letter == ":" or letter == " ":
			await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play("fade")
	await get_tree().create_timer(1).timeout

	match Global.story_beat:
		_:
			var balloon: Node = Balloon.instantiate()
			main_node.add_child(balloon)
			balloon.start(preload("res://dialogue/test.dialogue"),"start")
			#TODO - Will want this to be a conditional, only if something happens in the dialogue that triggers it
			get_tree().change_scene_to_file("res://pc.tscn")
			
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
