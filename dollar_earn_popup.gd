extends Node2D

var amount = 1
var good = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if good:
		$text.add_theme_color_override("default_color","4dbf32")
		$text.text = "[wave]+$" + str(amount)
	else:
		$text.add_theme_color_override("default_color","f60023")
		$text.text = "[wave]-$" + str(amount)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	queue_free()
