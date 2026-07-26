extends Control

const Ballon = preload("res://dialogue/balloon.tscn")

var text = "DAY 1
REMAINING DEBT: 10,000"

func _ready():
	text = "DAY " + str(Global.day) + "
REMAINING DEBT: " + str(Global.debt)
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
	get_tree().change_scene_to_file("res://pc.tscn")
	match Global.story_beat:
		_:
			var ballon: Node = Ballon.instantiate()
			get_tree().current_scene.add_child(ballon)
			ballon.start(preload("res://dialogue/test.dialogue"),"start")
