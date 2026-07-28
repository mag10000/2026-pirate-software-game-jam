extends Control

@export var main_node: Node
@export var data_text_label: Label
@export var info_text_label: Label 

@export var BankerMusicPlayer: AudioStreamPlayer
@export var DayMusicPlayer: AudioStreamPlayer

const Balloon = preload("res://dialogue/balloon.tscn")

var data_text = ""
var info_text = ""

var dayTileText = [[],["Base Tiles: "],["New Tile: "],["New Tile: "],["New Tile: "],["New Tile: "]]
var dayItemText = [[],["Base Items: "]]
var dayEvilText = [[],[],[],[],[]]






func _ready():
	BankerMusicPlayer.play()
	match Global.story_beat:
		1:
			var balloon: Node = Balloon.instantiate()
			main_node.add_child(balloon)
			balloon.start(preload("res://dialogue/day1intro.dialogue"),"start")
		_:
			var balloon: Node = Balloon.instantiate()
			main_node.add_child(balloon)
			balloon.start(preload("res://dialogue/test.dialogue"),"start")
			#TODO - Will want this to be a conditional, only if something happens in the dialogue that triggers it
			#get_tree().change_scene_to_file("res://pc.tscn")

func new_day_text():
	data_text = "DAY " + str(Global.day) + "
REMAINING DEBT: " + "$" + format_number(Global.debt)
	type_text()
	


func type_text():
	DayMusicPlayer.play()
	for letter in data_text:
		print("hi")
		await get_tree().create_timer(0.075).timeout
		data_text_label.text += letter
		if letter == ":" or letter == " ":
			await get_tree().create_timer(0.2).timeout
	show_text()
	await get_tree().create_timer(2.5).timeout
	$AnimationPlayer.play("fade")
	await get_tree().create_timer(1).timeout
	finish_story_beat()

func show_text():
	info_text_label.text = "Match 3 for $5, Combos payout higher!!!"
	
	pass	
	#"
#Match 3 for $5" + "
#Combos payout higher!!!"

			
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

func finish_story_beat():
	get_tree().change_scene_to_file("res://pc.tscn")
