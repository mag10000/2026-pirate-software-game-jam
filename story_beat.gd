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
	var balloon: Node = Balloon.instantiate()
	main_node.add_child(balloon)
	match Global.day:
		1:
			BankerMusicPlayer.play()
			balloon.start(preload("res://dialogue/day1intro.dialogue"),"start")
		2:
			BankerMusicPlayer.play()
			balloon.start(preload("res://dialogue/day2intro.dialogue"),"start")
		3:
			BankerMusicPlayer.play()
			balloon.start(preload("res://dialogue/day3intro.dialogue"),"start")
		4:
			BankerMusicPlayer.play()
			balloon.start(preload("res://dialogue/day4intro.dialogue"),"start")
		5:
			BankerMusicPlayer.play()
			balloon.start(preload("res://dialogue/day5intro.dialogue"),"start")
		_:
			balloon.start(preload("res://dialogue/test.dialogue"),"start")
			#TODO - Will want this to be a conditional, only if something happens in the dialogue that triggers it
			#get_tree().change_scene_to_file("res://pc.tscn")

func new_day_text():
	data_text = "DAY " + str(Global.day) + "
REMAINING DEBT: " + "$" + format_number(Global.debt) + "
DAILY GOAL: " + "$" + format_number(Global.debt_payments[Global.day])
	type_text()
	


func type_text():
	BankerMusicPlayer.stop()
	DayMusicPlayer.play()
	for letter in data_text:
		print("hi")
		await get_tree().create_timer(0.075).timeout
		data_text_label.text += letter
		if letter == ":" or letter == " ":
			await get_tree().create_timer(0.2).timeout
	show_text()


func show_text():
	var iconstext = ""
	var itemstext = ""
	match Global.day:
		1:
			info_text_label.text = "Match ICONS for $$$   COMBOS payout HIGHER!!"
		2:
			info_text_label.text = "You got a RAISE!   COMBOS payout EVEN HIGHER!!"
		3:
			info_text_label.text = "You got another RAISE!  You're a GOOD WORKER!!"
		4:
			info_text_label.text = "You got another RAISE!  LOOK OUT for VIRUSES!!"
		5:
			info_text_label.text = "You got your last RAISE!!   BRING IT HOME!!!"
	#for icon in Global.newIconsForRound[Global.day]:
		#match icon:
			#1:
				#iconstext += "\n[img=32x32]res://art/Email_Icon.png[/img]"
			#2:
				#iconstext += "\n[img=32x32]res://art/Folder_Icon.png[/img]"
			#3:
				#iconstext += "\n[img=32x32]res://art/Printer_Icon.png[/img]"
			#4:
				#iconstext += "\n[img=32x32]res://art/Spreadsheet_Icon.png[/img]"
			#5:
				#iconstext += "\n[img=32x32]res://art/Document_Icon.png[/img]"
			#6:
				#iconstext += "\n[img=32x32]res://art/Message_Icon.png[/img]"
			#7:
				#iconstext += "\n[img=32x32]res://art/Error_Icon.png[/img]"
			#8:
				#iconstext += "\n[img=32x32]res://art/Phone_Icon.png[/img]"
			#9:
				#iconstext += "\n[img=32x32]res://art/Virus_Icon.png[/img]"
			#10:
				#iconstext += "\n[img=32x32]res://art/Bar_Chart_Icon.png[/img]"
			#11:
				#iconstext += "\n[img=32x32]res://art/SociL_Media_Icon.png[/img]"
	#for array in Global.newItemsForRound[Global.day]:
		#for item in array:
			#print(load(item).item_name)
			#itemstext += "\n" + str(load(item).item_name) + " [img=32x32]" + load(item).item_icon.resource_path + "[/img]"
	#print("New Tiles: " + iconstext)
	#$"new tile text".text = "New Tiles: " + iconstext
	#$"new item text".text = "New Items: " + itemstext
	
	match Global.day:
		1:
			$Screen.texture = load("res://screens/DAYONE_SCREEN_3.png")
		2:
			$Screen.texture = load("res://screens/DAYTWO_SCREEN_2.png")
		3:
			$Screen.texture = load("res://screens/DAYTHREE_SCREEN_2.png")
		4:
			$Screen.texture = load("res://screens/DAYFOUR_SCREEN_2.png")
		5:
			$Screen.texture = load("res://screens/DAYFIVE_SCREEN_3.png")
	

	$"CanvasLayer/Continue Button".show()
	$"CanvasLayer/Skip Button".hide()
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

func load_scene(sceneToLoad: String):
	get_tree().change_scene_to_file(sceneToLoad)


func _on_button_pressed():
	load_scene("res://pc.tscn")


func _on_continue_button_pressed():
	#$AnimationPlayer.play("fade")
	#await get_tree().create_timer(1).timeout
	load_scene("res://pc.tscn")
