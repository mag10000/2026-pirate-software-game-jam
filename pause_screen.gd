extends CanvasLayer

@export var pc: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	$settings.show()


func _on_visibility_changed():
	$settings.hide()
	if visible:
		$Back.grab_focus()


func _on_tutorial_button_pressed():
	$Tutorial.show()
	await get_tree().create_timer($Tutorial.total_time).timeout


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_back_pressed():
	pc.pause()
