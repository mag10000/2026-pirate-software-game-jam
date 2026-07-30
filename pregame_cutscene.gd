extends Node2D

@export var label: RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	play_cutscene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_cutscene():
	await get_tree().create_timer(0.25).timeout
	$AudioStreamPlayer.play()
	type_text("Hello")
	$Image1.show()
	await get_tree().create_timer(2).timeout
	$Image2.show()
	await get_tree().create_timer(2).timeout
	$Image3.show()
	await get_tree().create_timer(2).timeout
	$Image4.show()
	await get_tree().create_timer(2).timeout
	type_text("")
	await get_tree().create_timer(2).timeout
	$Image5.show()
	await get_tree().create_timer(2).timeout
	$Image6.show()
	await get_tree().create_timer(2).timeout
	type_text("")
	await get_tree().create_timer(2).timeout
	$Image7.show()
	await get_tree().create_timer(2).timeout
	$Image8.show()
	type_text("")
	load_main_menu()
	

func type_text(str: String):
	for letter in str:
		print("hi")
		await get_tree().create_timer(0.075).timeout
		label.text += letter
		if letter == ":" or letter == " ":
			await get_tree().create_timer(0.2).timeout

func show_image(numb: int)
	match numb:
		1:
			$Image1.show()
		2:
			$Image1.hide()
			$Image2.show()
			$Image3.show()
			$Image4.show()
			$Image5.show()
			$Image6.show()
			$Image7.show()
			$Image8.show()
		_:
			pass
func load_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
