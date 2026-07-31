extends Node2D

@export var image1: TextureRect
@export var image2: TextureRect
@export var image3: TextureRect
@export var image4: TextureRect
@export var image5: TextureRect
@export var image6: TextureRect
@export var image7: TextureRect
@export var image8: TextureRect
@export var image9: TextureRect
@export var cycle_time = 1.0
var total_time = cycle_time * 9 + 10

func cycle():
	break_cycle()
	image1.show()
	await get_tree().create_timer(cycle_time).timeout
	image1.hide()
	image2.show()
	await get_tree().create_timer(cycle_time).timeout
	image2.hide()
	image3.show()
	await get_tree().create_timer(cycle_time).timeout
	image3.hide()
	image4.show()
	await get_tree().create_timer(cycle_time + 5).timeout
	image4.hide()
	image5.show()
	await get_tree().create_timer(cycle_time).timeout
	image5.hide()
	image6.show()
	await get_tree().create_timer(cycle_time).timeout
	image6.hide()
	image7.show()
	await get_tree().create_timer(cycle_time).timeout
	image7.hide()
	image8.show()
	await get_tree().create_timer(cycle_time).timeout
	image8.hide()
	image9.show()
	await get_tree().create_timer(cycle_time + 5).timeout
	image9.hide()
	hide()

func break_cycle():
	image1.hide()
	image2.hide()
	image3.hide()
	image4.hide()
	image5.hide()
	image6.hide()
	image7.hide()
	image8.hide()
	image9.hide()
	
func _on_visibility_changed():
	if visible:
		cycle()
