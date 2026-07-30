extends Area2D

signal tile_pressed(pos)
signal tile_dpad_swap(dir,pos)

var type:String
var icon_no:int
var grid_position:Vector2i
var mouse_hovering = false
var sprite_texture
var dpad_pressing = false

# Set piece them when initializing

func set_tile_type(id: String, texture: Texture2D):
	
	type = id
	icon_no = int(id)
	$Sprite2D.texture = texture
	sprite_texture = $Sprite2D.texture

# Letting the main code know when a tile has been pressed

func _input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_pressed.emit(grid_position)

# Animations when tile is moving

func move_to(target_position: Vector2, play_sound: bool = true):
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "position", target_position, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	$Sprite2D.scale = Vector2(1.2, 0.8)
	tween.tween_property($Sprite2D, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	if play_sound:
		tween.finished.connect(_on_move_finished)

# Audio that plays after the tile lands on the board

func _on_move_finished():
	if type != "0":
		Audio.play("res://sfx/Block Drop.wav")


func _on_button_pressed():
	tile_pressed.emit(grid_position)


func _on_button_mouse_entered():
	mouse_hovering = true
	#print(grid_position)
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Sprite2D, "scale", Vector2(1.025, 1.025), 0.1)
	tween.tween_property($Sprite2D, "modulate", Color(1.2, 1.2, 1.2), 0.1) # Brighten
	if dpad_pressing == true:
		pass


func _on_button_mouse_exited():
	mouse_hovering = false
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.1)


func _unhandled_input(event):
	if Input.is_action_just_pressed("up"):
		print(grid_position)
		if dpad_pressing == false:
			dpad_pressing = true
			tile_dpad_swap.emit("up",grid_position)
			await get_tree().create_timer(1).timeout
			dpad_pressing = false
	if Input.is_action_just_pressed("down"):
		if dpad_pressing == false:
			dpad_pressing = true
			dpad_pressing = true
			tile_dpad_swap.emit("down",grid_position)
			await get_tree().create_timer(0.3).timeout
			dpad_pressing = false
	if Input.is_action_just_pressed("left"):
		if dpad_pressing == false:
			dpad_pressing = true
			tile_dpad_swap.emit("left",grid_position)
			await get_tree().create_timer(0.3).timeout
			dpad_pressing = false
	if Input.is_action_just_pressed("right"):
		if dpad_pressing == false:
			dpad_pressing = true
			tile_dpad_swap.emit("right",grid_position)
			await get_tree().create_timer(0.3).timeout
			dpad_pressing = false
