extends Node2D

@export var label: RichTextLabel
@export var time_between_pics: float

# Called when the node enters the scene tree for the first time.
func _ready():
	play_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_cutscene():
	await get_tree().create_timer(0.25).timeout
	$AudioStreamPlayer.play()
	type_text("Ziggy returns home after another long, wild night out on the town.")
	show_image(1)
	await get_tree().create_timer(time_between_pics).timeout
	show_image(2)
	await get_tree().create_timer(time_between_pics).timeout
	label.text = ""
	type_text("Checking his bank account he sees his life catching up with him.")
	show_image(3)
	await get_tree().create_timer(time_between_pics).timeout
	show_image(4)
	await get_tree().create_timer(time_between_pics).timeout
	label.text = ""
	type_text("“Oh man…. I’m gonna have to work so hard to pay this off... WHAT THE HELL!?”")
	show_image(5)
	await get_tree().create_timer(time_between_pics).timeout
	show_image(6)
	await get_tree().create_timer(time_between_pics).timeout
	label.text = ""
	type_text("“You have FIVE DAYS to pay off your debt... Or it’s LIGHTS OUT! Muahaha!!”")
	show_image(7)
	await get_tree().create_timer(time_between_pics).timeout
	show_image(8)
	await get_tree().create_timer(time_between_pics).timeout	
	label.text = ""
	$Image8.hide()
	await get_tree().create_timer(1.5).timeout	
	load_main_menu()
	
func type_text(str: String):
	for letter in str:
		print("hi")
		await get_tree().create_timer(0.0375).timeout
		label.text += letter
#		if letter == ":" or letter == " ":
#			await get_tree().create_timer(0.1).timeout

func show_image(numb: int):
	match numb:
		1:
			$Image1.show()
		2:
			$Image1.hide()
			$Image2.show()
		3:
			$Image2.hide()
			$Image3.show()
		4:
			$Image3.hide()
			$Image4.show()
		5:
			$Image4.hide()
			$Image5.show()
		6:
			$Image5.hide()
			$Image6.show()
		7:
			$Image6.hide()
			$Image7.show()
		8:
			$Image7.hide()
			$Image8.show()

func load_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_skip_button_pressed():
	load_main_menu()
