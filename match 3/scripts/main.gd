extends Node2D

@export_subgroup("Properties")
@export var width: int = 6
@export var height: int = 6
@export var offset: int = 68
@export var day: int = 1

@export_subgroup("Scenes")
@export var tile_scene: PackedScene 
@export var sparkles_scene: PackedScene
@export var bomb_fire_scene: PackedScene
@export var lightning_sparkles_scene: PackedScene

@export_subgroup("Tiles")
@export var textures: Array[Texture2D] 

@export_subgroup("Cursors")
@export var open_hand_cursor: Texture2D
@export var closed_hand_cursor: Texture2D

@export_subgroup("Other Textures")
@export var bomb_texture: Texture2D

@onready var container = $Board

@export var pc_ref: Control

# State

var grid = []
var first_touch = Vector2i(-1, -1)
var is_swapping = false
var combo_count: int = 0
# Depending on which round, we'll get the right amount of icons
var iconArray = [1, 2, 3, 4, 5, 6]
var evilIcons = [7, 9, 11]
var evil_match = 0
var matches 
var amount_tile
var amount_combo
var evil_block_count = 0
var is_dpad_attempt = false
var spawn_count = 0
# Functions

func _ready():
	iconArray = Global.iconsForRound[Global.day].duplicate(true)
	randomize()
	
	setup_grid_array() 
	process_board_state()
	
	center_grid_on_screen() 
	
	get_viewport().size_changed.connect(center_grid_on_screen)
	amount_tile = Global.amt_earned_icon
	amount_combo = Global.amt_earned_combos
	
# Centers the board on-screen, the above conection ensures the board is centered after resizing the window

func center_grid_on_screen():
	
	container.position = get_viewport_rect().size / 2.0 - Vector2(width - 1, height - 1) * offset / 2.0

# Initialize grid

func setup_grid_array():
	
	grid = []
	for x in width:
		grid.append([])
		grid[x].resize(height)
		grid[x].fill(null)
		
	# Spawn initial pieces
	
	for x in width:
		for y in height:
			#print(x, y)
			initial_spawn(x, y, false)
	
	evil_block_count = 0
	spawn_count = 0

# Spawn a new tile at a certain grid position

func initial_spawn(x, y, blanks: bool):
	var created_piece = tile_scene.instantiate()
	var random_index = iconArray.pick_random() 
	spawn_count += 1
	while (check_neighbors(x, y, random_index) == true): 
		random_index = iconArray.pick_random()
	if is_evil_block(random_index):
		evil_block_count += 1

	if Global.day > 1 && spawn_count > 24 && evil_block_count < 3:
			while (check_neighbors(x, y, random_index) == true): 
				random_index = iconArray.pick_random()
				if is_evil_block(random_index):
					evil_block_count += 1
			if spawn_count > 30:
				while (!is_evil_block(random_index) && check_neighbors(x, y, random_index) == true): 
					random_index = iconArray.pick_random()

	# Allow an evil block only if there aren't too many for how far into the day you are
	if evil_block_count > 3:
		if Global.hour <= 2:
			while is_evil_block(random_index) || check_neighbors(x, y, random_index) == true:
				random_index = iconArray.pick_random()
		if evil_block_count > 4:
			if Global.hour <= 4:
				while is_evil_block(random_index) || check_neighbors(x, y, random_index) == true:
						random_index = iconArray.pick_random()
			if evil_block_count > 5:
				if Global.hour <= 6:
					while is_evil_block(random_index) || check_neighbors(x, y, random_index) == true:
						random_index = iconArray.pick_random()
				elif evil_block_count >= 6:
					while is_evil_block(random_index) || check_neighbors(x, y, random_index) == true:
						random_index = iconArray.pick_random()
	if blanks:
		random_index = 0 

	# This is default code for just using the amount of icons in the array
	#var random_index = randi_range(0, textures.size() - 1)
	
	container.add_child(created_piece) 
	
	created_piece.set_tile_type(str(random_index), textures[random_index]) 
	created_piece.tile_pressed.connect(_on_tile_pressed)
	#created_piece.tile_dpad_swap.connect(_on_tile_dpad_swap)
	created_piece.grid_position = Vector2i(x, y) 
	created_piece.position = grid_to_pixel(x, y) 
	
	grid[x][y] = created_piece
			
# Spawn a new tile at a certain grid position
func spawn_at(x, y, blanks: bool):
	
	var created_piece = tile_scene.instantiate()
	var random_index = iconArray.pick_random() 
	#while (check_neighbors(x, y, random_index) == true): 
		#random_index = iconArray.pick_random()
		#pass
	
	if blanks:
		random_index = 0 

	# This is default code for just using the amount of icons in the array
	#var random_index = randi_range(0, textures.size() - 1)
	
	container.add_child(created_piece) 
	
	created_piece.set_tile_type(str(random_index), textures[random_index]) 
	created_piece.tile_pressed.connect(_on_tile_pressed)
	#created_piece.tile_dpad_swap.connect(_on_tile_dpad_swap)
	created_piece.grid_position = Vector2i(x, y) 
	created_piece.position = grid_to_pixel(x, y) 
	
	grid[x][y] = created_piece
	
func spawn_specific_at(x, y, type: String):
	
	var created_piece = tile_scene.instantiate()
	
	container.add_child(created_piece) 
	
	created_piece.set_tile_type(type, textures[int(type)])
	created_piece.tile_pressed.connect(_on_tile_pressed)
	#created_piece.tile_dpad_swap.connect(_on_tile_dpad_swap)
	created_piece.grid_position = Vector2i(x, y) 
	created_piece.position = grid_to_pixel(x, y) 
	
	grid[x][y] = created_piece

func check_neighbors(x, y, random_index) -> bool:
	#TODO - This sin't right, we can't just flag as false if either is true, have to check
	#specifically within that function
	#print(x, y)
	if x == 0:
		if y == 0:
			return false
		elif random_index == grid[x][y - 1].icon_no:
			return true
		else:
			return false
	elif y == 0:
		if random_index == grid[x - 1][y].icon_no:
			return true
		else: 
			return false
	elif random_index == grid[x - 1][y].icon_no:
		return true
	elif random_index == grid[x][y - 1].icon_no:
		return true
	else:
		return false

# Spawn a virus at a position
func spawn_virus_at(x, y):
	
	var created_piece = tile_scene.instantiate()
	var virus_index = 11
	
	container.add_child(created_piece) 
	
	created_piece.set_tile_type(str(virus_index), textures[virus_index]) 
	created_piece.tile_pressed.connect(_on_tile_pressed) 
	created_piece.grid_position = Vector2i(x, y) 
	created_piece.position = grid_to_pixel(x, y) 
	
	grid[x][y] = created_piece

# Interaction

func _on_tile_pressed(grid_position: Vector2i):
	#print(grid[grid_position.x][grid_position.y].type)
	print(grid_position)
	if not is_swapping:
		if grid[grid_position.x][grid_position.y].type == "7":
			Audio.play("res://sfx/Error 3.wav")
		else:
			Audio.play("res://sfx/Click_Select.wav")
			#TODO - If blank can't grab as first
		first_touch = grid_position


#func _on_tile_dpad_swap(direction_to_swap : String, grid_position: Vector2):
#
	#print (grid_position)
	#first_touch = grid_position
	#var difference = grid_position - grid_to_pixel(first_touch.x, first_touch.y)
	#print(difference)
	#if (grid[first_touch.x][first_touch.y].type == "0"):
		#return
	#
	#if difference.length() > 32:
		#var other_position = grid_position
		#if abs(difference.x) > abs(difference.y): # Horizontal dragging
			#other_position.x += 1 if difference.x > 0 else -1
		#else: # Vertical dragging
			#other_position.y += 1 if difference.y > 0 else -1
	#
		#match direction_to_swap:
			#"up":
				#other_position.y += 1
			#"down":
				#other_position.y -= 1
			#"left":
				#other_position.x -= 1
			#"right":
				#other_position.x += 1
		##TODO - Logic to figure out the grid position
		#
		#print(other_position)
		#if is_within_grid(other_position):
			##print (grid_position)
			##print (other_position)
			## If one of the blocks is an Error block that can't move then return
			#if (grid[grid_position.x][grid_position.y].type == "7" || grid[other_position.x][other_position.y].type == "7"):
				#return
			#handle_swap_logic(grid_position, other_position)
			#Audio.play("res://match 3/sounds/tile-swap.ogg", false, randf_range(0.8, 1.2), 0.3)
			#
	#first_touch = Vector2i(-1, -1)

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if first_touch != Vector2i(-1, -1):
				var local_mouse_pos = container.get_local_mouse_position()
				calculate_swipe(local_mouse_pos)

func calculate_swipe(final_pos: Vector2):
	if (grid[first_touch.x][first_touch.y].type == "0"):
		return
		
	var difference = final_pos - grid_to_pixel(first_touch.x, first_touch.y)
	
	if difference.length() > 32:
		var other_touch = first_touch
		if abs(difference.x) > abs(difference.y): # Horizontal dragging
			other_touch.x += 1 if difference.x > 0 else -1
		else: # Vertical dragging
			other_touch.y += 1 if difference.y > 0 else -1
				
		#if (Global.day == 2 || Global.day == 5):
			#if (grid[first_touch.x][first_touch.y].type == "7" || grid[other_touch.x][other_touch.y].type == "7"):
				#return
		
		if is_within_grid(other_touch):
			# If one of the blocks is an Error block that can't move then return
			if ((Global.day == 2 || Global.day == 5) && (grid[first_touch.x][first_touch.y].type == "7" || grid[other_touch.x][other_touch.y].type == "7")):
				Audio.play("res://sfx/Error 3.wav")
				return
			handle_swap_logic(first_touch, other_touch)

	first_touch = Vector2i(-1, -1)

# Game loop

func handle_swap_logic(pos_a: Vector2i, pos_b: Vector2i):
	
	is_swapping = true
	swap_pieces(pos_a, pos_b)
	
	await get_tree().create_timer(0.3).timeout
	
	process_board_state()
	
	#if find_matches().size() > 0:
	#	process_board_state()
	#else:
		#swap_pieces(pos_a, pos_b)
		#Audio.play("res://sounds/tile-swap.ogg", false, 2, 0.3)
	#	await get_tree().create_timer(0.3).timeout
	#	is_swapping = false

func swap_pieces(a: Vector2i, b: Vector2i):
	var piece_a = grid[a.x][a.y]
	var piece_b = grid[b.x][b.y]
	
	if piece_a and piece_b:
		grid[a.x][a.y] = piece_b
		grid[b.x][b.y] = piece_a
		
		piece_a.grid_position = b
		piece_b.grid_position = a
				
		piece_a.move_to(grid_to_pixel(b.x, b.y), false)
		piece_b.move_to(grid_to_pixel(a.x, a.y), false)
		
		if (piece_a.type == "11") && (piece_b.type != "0"):
			piece_b.set_tile_type("11", textures[11])
			Audio.play("res://sfx/Glitchy Block Swap.wav", false, randf_range(0.8, 1.2), 0.3) 
		elif (piece_b.type == "11") && (piece_a.type != "0"):
			piece_a.set_tile_type("11", textures[11]) 
			Audio.play("res://sfx/Glitchy Block Swap.wav", false, randf_range(0.8, 1.2), 0.3) 
		elif (piece_a.type == "9") && (piece_b.type != "0"):
			Global.money -= round((amount_tile*3))
			pc_ref.show_money_popup(round((amount_tile*3)/2), false)
			Audio.play("res://sfx/Anti Cha Ching.wav", true, 1.0 + (combo_count * 0.1))
		elif (piece_b.type == "9") && (piece_a.type != "0"):
			Global.money -= round((amount_tile*3)/2)
			pc_ref.show_money_popup(round((amount_tile*3)/2), false)
			Audio.play("res://sfx/Anti Cha Ching.wav", true, 1.0 + (combo_count * 0.1))
		else:
			Audio.play("res://sfx/Block Swap.wav", false, randf_range(0.8, 1.2), 0.3)

		#SFX for Virus?
		
	await get_tree().create_timer(0.3).timeout
	await collapse_columns()
	await refill_board(true)

func find_matches() -> Array:
	
	var matched_dict = {}

	for y in height:
		for x in range(width - 2):
			var p1 = grid[x][y]; var p2 = grid[x+1][y]; var p3 = grid[x+2][y]
			if p1 == null || p2 == null || p3 == null || p1.type == "0" || p2.type == "0" || p3.type == "0" || p1.type == "11" || p2.type == "11" || p3.type == "11":
				pass
			elif p1 and p2 and p3 and p1.type == p2.type and p1.type == p3.type:
				if p1.type == "9" && p2.type == "9" && p3.type == "9":
					evil_match += 3
				for p in [p1, p2, p3]: matched_dict[p] = true

	for x in width:
		for y in range(height - 2):
			var p1 = grid[x][y]; var p2 = grid[x][y+1]; var p3 = grid[x][y+2]
			if p1 == null || p2 == null || p3 == null || p1.type == "0" || p2.type == "0" || p3.type == "0" || p1.type == "11" || p2.type == "11" || p3.type == "11":
				pass
			elif p1 and p2 and p3 and p1.type == p2.type and p1.type == p3.type:
				if p1.type == "9" && p2.type == "9" && p3.type == "9":
					evil_match += 3
				for p in [p1, p2, p3]: matched_dict[p] = true

	return matched_dict.keys()

func process_board_state():
	combo_count = 0 
	matches = find_matches()
	var money_lost = false
	var earned_this_round = 0
	while matches.size() > 0:
		#print("Evil Match Count: " + str(evil_match))
		
		if evil_match < 1:
			combo_count += 1
		
		if combo_count > 1:
			Audio.play("res://sfx/Combo.wav", true, 1.0 + (combo_count * 0.1))
			Global.money += round(((combo_count-1) * amount_combo * Global.money_multiplier))
			Global.money_earned += round(((combo_count-1) * amount_combo * Global.money_multiplier))
			earned_this_round += round(((combo_count-1) * amount_combo * Global.money_multiplier))
		for piece in matches:
			var effect = sparkles_scene.instantiate()
			effect.position = piece.position
			container.add_child(effect)
			
			grid[piece.grid_position.x][piece.grid_position.y] = null
			
			var tween = piece.create_tween()
			tween.tween_property(piece, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece.queue_free)
			
			if evil_match == 0:
				Global.money += round((amount_tile * Global.money_multiplier))
				Global.money_earned += round((amount_tile * Global.money_multiplier))
				earned_this_round += round(amount_tile * Global.money_multiplier)
			#await collapse_columns()
			elif evil_match >= 1:
				Global.money -= round(amount_tile * Global.money_multiplier)
				Global.money_earned -= round(amount_tile * Global.money_multiplier)
				earned_this_round -= round(amount_tile * Global.money_multiplier)
				evil_match -= 1
		if earned_this_round > 0:
			pc_ref.show_money_popup(earned_this_round)
			Audio.play("res://sfx/Cha Ching.wav", true, 1.0 + (combo_count * 0.1))
		elif earned_this_round < 0:
			pc_ref.show_money_popup(earned_this_round, false)
			Audio.play("res://sfx/Anti Cha Ching.wav", true, 1.0 + (combo_count * 0.1))
		await get_tree().create_timer(0.3).timeout
		await collapse_columns()
		await refill_board(true)
		
		matches = find_matches()
		await collapse_columns()

	
	#await collapse_columns()
	#matches = find_matches()
	#process_board_state()
	is_swapping = false

func collapse_columns():
	
	for x in width:
		for y in height:
			if not is_instance_valid(grid[x][y]):
				return
			if grid[x][y].type == "0":
				grid[x][y] = null
	
	for x in width:
		for y in range(height - 1, -1, -1):
			if grid[x][y] == null:
				for k in range(y - 1, -1, -1):
					if grid[x][k] != null:
						grid[x][y] = grid[x][k]
						# I had this next line commented out at one point but trying to bug fix and...?
						spawn_at(x, k, true)
						grid[x][k] = null
						grid[x][y].grid_position = Vector2i(x, y)
						grid[x][y].move_to(grid_to_pixel(x, y))
						break
	for x in width:
		for y in height:
			if grid[x][y] == null:
				spawn_at(x, y, true)
				
	await get_tree().create_timer(0.1).timeout
	matches = find_matches()

func refill_board(blanks: bool):
	
	for x in width:
		for y in height:
			if grid[x][y] == null:
				if blanks:
					spawn_at(x, y, true)
				else:
					initial_spawn(x, y, false)
				grid[x][y].position.y -= offset * 2 
				grid[x][y].move_to(grid_to_pixel(x, y))
	evil_block_count = 0
	spawn_count = 0
	await get_tree().create_timer(0.3).timeout

# Utilities for coordinates

func grid_to_pixel(column: int, row: int) -> Vector2:
	
	return Vector2(offset * column, offset * row)

func is_within_grid(pos: Vector2i) -> bool:
	
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

# Utilities

func set_cursor(cursor):
	
	Input.set_default_cursor_shape(cursor)

# Item related functions

func get_whole_board()-> Array:
	
	var board_dict = {}

	for x in width:
		for y in height:
			board_dict[grid[x][y]] = true
	return board_dict.keys()
	

func simplify_board():
	var randomToDestroy = iconArray.pick_random()
	while randomToDestroy == 0 || randomToDestroy == 7 || randomToDestroy == 9 || randomToDestroy == 11:
		randomToDestroy = iconArray.pick_random()
	var objectsDestroyed = false
	var whole_board = get_whole_board()
	var other_types = false
	var get_new_type = true
	var type_to_swap 
	var earned_this_round = 0
	
	for piece in whole_board:
		if not is_instance_valid(piece):
			return
		if piece.type != str(randomToDestroy):
			other_types = true	
			if get_new_type == true:
				get_new_type = false
				type_to_swap = piece.type
		elif piece.type == str(randomToDestroy):
			#print("Objects Destroyed: " + str(objectsDestroyed))
			objectsDestroyed = true
			var effect = sparkles_scene.instantiate()
			effect.position = piece.position
			container.add_child(effect)
			grid[piece.grid_position.x][piece.grid_position.y] = null
	
			var tween = piece.create_tween()
			tween.tween_property(piece, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece.queue_free)
						
			Global.money += round((amount_tile * Global.money_multiplier))
			Global.money_earned += round((amount_tile * Global.money_multiplier))
			earned_this_round += round((amount_tile * Global.money_multiplier))
			spawn_specific_at(piece.grid_position.x,piece.grid_position.y, type_to_swap)
			
		# TODO - Make this work so that one type in the whole board is 
		# now changed
	if objectsDestroyed == false:
		#TODO - play a failed to use item SFX
		#TODO - DONT REVOKE THE ITEM
		pass
	
	
	elif objectsDestroyed == true:
		Audio.play("res://sfx/Simplify Board.wav",true)
		#print("Got to objectsDestroyed == true")
		#iconArray.erase(randomToDestroy)
		if earned_this_round > 0:
			pc_ref.show_money_popup(earned_this_round)
		elif earned_this_round < 0:
			pc_ref.show_money_popup(earned_this_round, false)
		await get_tree().create_timer(0.15).timeout
		await collapse_columns()
		await refill_board(true)
	await get_tree().create_timer(0.15).timeout
	await collapse_columns()
	await refill_board(true)
	process_board_state()

func lightning():
	var randomToDestroy = iconArray.pick_random()
	while randomToDestroy == 0 || randomToDestroy == 7 || randomToDestroy == 9 || randomToDestroy == 11:
		randomToDestroy = iconArray.pick_random()
	var objectsDestroyed = false
	var whole_board = get_whole_board()
	var earned_this_round = 0
	
	for piece in whole_board:
		if not is_instance_valid(piece):
			return
		if piece.type == str(randomToDestroy):
			#print("Objects Destroyed: " + str(objectsDestroyed))
			objectsDestroyed = true
			var effect = lightning_sparkles_scene.instantiate()
			effect.position = piece.position
			container.add_child(effect)
			grid[piece.grid_position.x][piece.grid_position.y] = null
	
			var tween = piece.create_tween()
			tween.tween_property(piece, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece.queue_free)
						
			Global.money += round((amount_tile * Global.money_multiplier))
			Global.money_earned += round((amount_tile * Global.money_multiplier))
			earned_this_round += round((amount_tile * Global.money_multiplier))
	if objectsDestroyed == true:
		Audio.play("res://sfx/Lightning.wav",true)
		if earned_this_round > 0:
			pc_ref.show_money_popup(earned_this_round)
		elif earned_this_round < 0:
			pc_ref.show_money_popup(earned_this_round, false)
		await get_tree().create_timer(0.15).timeout
		await collapse_columns()
		await refill_board(true)
	await get_tree().create_timer(0.15).timeout
	await collapse_columns()
	await refill_board(true)
	process_board_state()

func bomb_random_icon():
	var earned_this_round = 0
	var randomToDestroy = iconArray.pick_random()
	while randomToDestroy == 0:
		randomToDestroy = iconArray.pick_random()
	var objectsInIdealArray = false
	var objectsInOtherArray = false
	var objectsDestroyed = false
	var whole_board = get_whole_board()
	var array_random_ideal_icons = []
	var array_random_other_icons = []
	var random_index
	var piece_to_destroy 
	var array_to_destroy = []
	#TODO - If there are ONLY pieces on edges, we should bomb an edge. If board is empty no big deal.
	for piece in whole_board:
		if not is_instance_valid(piece):
			return
		if piece.type != "0" && piece.grid_position.x != 0 && piece.grid_position.x != 5 && piece.grid_position.y != 0 && piece.grid_position.y != 5:
			array_random_ideal_icons.append(piece)
			objectsInIdealArray = true
		elif piece.type != "0":
			array_random_other_icons.append(piece)
			objectsInOtherArray = true
		
	if objectsInIdealArray:
		random_index = randi_range(0,array_random_ideal_icons.size() - 1)
		piece_to_destroy = array_random_ideal_icons[random_index]
		array_to_destroy = [piece_to_destroy, 
		grid[piece_to_destroy.grid_position.x + 1][piece_to_destroy.grid_position.y],
		grid[piece_to_destroy.grid_position.x - 1][piece_to_destroy.grid_position.y],
		grid[piece_to_destroy.grid_position.x][piece_to_destroy.grid_position.y + 1],
		grid[piece_to_destroy.grid_position.x][piece_to_destroy.grid_position.y - 1],
		grid[piece_to_destroy.grid_position.x + 1][piece_to_destroy.grid_position.y + 1],
		grid[piece_to_destroy.grid_position.x + 1][piece_to_destroy.grid_position.y - 1],
		grid[piece_to_destroy.grid_position.x - 1][piece_to_destroy.grid_position.y + 1],
		grid[piece_to_destroy.grid_position.x - 1][piece_to_destroy.grid_position.y - 1]]	
		
	elif objectsInOtherArray:
		random_index = randi_range(0,array_random_other_icons.size() - 1)
		piece_to_destroy = array_random_other_icons[random_index]
		array_to_destroy.append(piece_to_destroy)
		var x = piece_to_destroy.grid_position.x
		var y = piece_to_destroy.grid_position.y
			
		if is_position_in_grid(x + 1, y) && grid[x + 1][y] != null:
			array_to_destroy.append(grid[x + 1][y])
		if is_position_in_grid(x - 1, y) && grid[x - 1][y] != null:
			array_to_destroy.append(grid[x - 1][y])
		if is_position_in_grid(x + 1, y + 1) && grid[x + 1][y + 1] != null:
			array_to_destroy.append(grid[x + 1][y + 1])
		if is_position_in_grid(x + 1, y - 1) && grid[x + 1][y - 1] != null:
			array_to_destroy.append(grid[x + 1][y - 1])
		if is_position_in_grid(x - 1, y + 1) && grid[x - 1][y + 1] != null:
			array_to_destroy.append(grid[x - 1][y + 1])
		if is_position_in_grid(x - 1, y - 1) && grid[x - 1][y - 1] != null:
			array_to_destroy.append(grid[x - 1][y - 1])
		if is_position_in_grid(x, y + 1) && grid[x][y + 1] != null:
			array_to_destroy.append(grid[x][y + 1])
		if is_position_in_grid(x, y - 1) && grid[x][y - 1] != null:
			array_to_destroy.append(grid[x][y - 1])
	
			
	if objectsInIdealArray || objectsInOtherArray:

			#print("Objects Destroyed: " + str(objectsDestroyed))
		for piece_to_bomb in array_to_destroy:
			var grant_money = false
			objectsDestroyed = true
			if piece_to_bomb.type != "0":
				grant_money = true
			if piece_to_bomb == piece_to_destroy:
				piece_to_bomb.sprite_texture = bomb_texture
			var effect = bomb_fire_scene.instantiate()
			effect.position = piece_to_bomb.position
			container.add_child(effect)
			grid[piece_to_bomb.grid_position.x][piece_to_bomb.grid_position.y] = null
	
			var tween = piece_to_bomb.create_tween()
			tween.tween_property(piece_to_bomb, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece_to_bomb.queue_free)
			
			if grant_money == true:
				Global.money += round((amount_tile * Global.money_multiplier))
				Global.money_earned += round((amount_tile * Global.money_multiplier))
				earned_this_round += round((amount_tile * Global.money_multiplier))
				
	if objectsDestroyed == true:
		InventoryManager.revoke_item("res://inventory/items/bomb_item.tres")
		Audio.play("res://sfx/Bomb.wav",true)
		if earned_this_round > 0:
			pc_ref.show_money_popup(earned_this_round)
		elif earned_this_round < 0:
			pc_ref.show_money_popup(earned_this_round, false)
		await get_tree().create_timer(0.15).timeout
		await collapse_columns()
		await refill_board(true)
	await get_tree().create_timer(0.15).timeout
	await collapse_columns()
	await refill_board(true)
	process_board_state()

func missle_evil_icons():
	var objectsDestroyed = false
	var whole_board = get_whole_board()
	
	for piece in whole_board:
		if not is_instance_valid(piece):
			return
		if is_evil_block(int(piece.type)):
			objectsDestroyed = true
			var effect = bomb_fire_scene.instantiate()
			effect.position = piece.position
			container.add_child(effect)
			grid[piece.grid_position.x][piece.grid_position.y] = null
	
			var tween = piece.create_tween()
			tween.tween_property(piece, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece.queue_free)
	if objectsDestroyed == true:
		Audio.play("res://sfx/Missile.wav",true)
		await get_tree().create_timer(0.3).timeout
		await collapse_columns()
		await refill_board(true)
	await get_tree().create_timer(0.1).timeout
	await collapse_columns()
	await refill_board(true)
	process_board_state()

func reset_board():
	var whole_board = get_whole_board()
	
	while whole_board.size() > 0:

		for piece in whole_board:
			if not is_instance_valid(piece):
				return
			
			grid[piece.grid_position.x][piece.grid_position.y] = null
			
			var tween = piece.create_tween()
			tween.tween_property(piece, "scale", Vector2.ZERO, 0.2)
			tween.finished.connect(piece.queue_free)
		
		await get_tree().create_timer(0.3).timeout
		await collapse_columns()
		await refill_board(false)
	
		process_board_state()

func refresh_icons():
	iconArray = Global.iconsForRound[Global.day].duplicate(true)
	
func is_evil_block(type: int)-> bool: 
	if (type == 7 || type == 9 || type == 11):
		return true
	else:
		return false
		
func is_position_in_grid(x: int, y: int)->bool:
	if (x >= 0 && x <=5 && y >=0 && y<= 5):
		return true
	else:
		return false
