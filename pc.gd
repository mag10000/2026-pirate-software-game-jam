extends Control

# Export Variables
@export var earningsAmountDisplay: Label
@export var debtAmountDisplay: Label
@export var debtMinimumPayDisplay: Label
@export var scrollAlertText: Label
@export var dayHourText: Label

@export var workTimer: Timer
@export var breakTimer: Timer

@export var workWindow: Panel
@export var bankWindow: Panel
@export var itemWindow: Panel
@export var storeWindow: Panel
@export var topWindow: Window
@export var timerWindow: Panel
@export var dayHourWindow: Panel

@export var progressBar: ProgressBar

@export var depositButton: Button

@export var scrollAlertTextAnimation: AnimationPlayer

@export var tileGameReference: Node2D

@export var MusicPlayer: AudioStreamPlayer

@export var pauseScreen: CanvasLayer

@export var debugScreen: CanvasLayer

@export_group("store")

@export var item1: Button
@export var item1Label: Label

@export var item2: Button
@export var item2Label: Label

@export var item3: Button
@export var item3Label: Label

@export var itemSoldOutArt: Texture
@export var crtFilerOn = true

# Pause variable...
var topWindowVisible = false

# Color Variables for ProgressBar
var redTime = 4.5
var yellowTime = 8.5
var greenTime = 24

# For Shop Items
var item1Random
var item2Random
var item3Random
var item1Price = 0
var item2Price = 0
var item3Price = 0
var item1Discription
var item2Discription
var item3Discription
var item1SoldOut = false
var item2SoldOut = false
var item3SoldOut = false

# The Amount of Money the Player Has
var money = 0

# Time Remaining in a Counter
var time = 0

# Amount Deposited in current Round
var deposited_in_round = 0

# Variables for the color in the progress bar
var r = 0
var g = 0
var b = 0

# Phase setup booleans
var phase0Setup = true
var phase1Setup = false

func _ready():
	crtFilerOn = Global.crt_on
	if crtFilerOn:
		$CRTScreen.show()
	create_new_store()
	workWindow.hide()
	storeWindow.hide()
	topWindow.hide()
	update_day_hour_text()
	InventoryManager.grant_item("res://inventory/items/time_add_item.tres", 1)
	InventoryManager.grant_item("res://inventory/items/bomb_item.tres", 1)
	InventoryManager.grant_item("res://inventory/items/refresh_item.tres", 1)

# Runs every frame
func _process(delta):
	if Global.debt < 0:
		Global.debt = 0
	
	crtFilerOn = Global.crt_on
	if crtFilerOn:
		$CRTScreen.show()
	else:
		$CRTScreen.hide()
	
	earningsAmountDisplay.text = "$" + str(money)
	debtAmountDisplay.text = "$" + str(Global.debt)
	debtMinimumPayDisplay.text = "Minimum Debt Due Today\n$" + str(Global.minimumPay)
	progressBar.value = time
	
	if item1SoldOut == false:
		item1Label.text = item1Discription + " - Price $" + str(item1Price)
	if item2SoldOut == false:
		item2Label.text = item2Discription + " - Price $" + str(item2Price)
	if item3SoldOut == false:
		item3Label.text = item3Discription + " - Price $" + str(item3Price)
	
	if (time > yellowTime && time <= greenTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color("6abe30")
	elif (time > redTime && time <= yellowTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color("e39712")
	elif (time <= redTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color("a54a34")
	
	if Global.phase == 0:
		if phase0Setup == true:
			await phase_0_setup()
		
		if not Global.work_time_started:
			change_phase_display(0)
			time = Global.work_times[Global.current_work_time_id]
			progressBar.max_value = time
			workWindow.show()
			workTimer.start()
			Global.work_time_started = true

		if time == 0:
			workTimer.stop()
			Global.work_time_started = false
			Global.current_work_time_id = randi_range(0,3)
			await get_tree().create_timer(0.5).timeout
			workWindow.hide()
			phase1Setup = true
			Global.phase = 1
			
	if Global.phase == 1:
		if phase1Setup == true:
			await phase_1_setup()
		
		if not Global.break_time_started:
			change_phase_display(1)
			time = Global.break_times[Global.current_break_time_id]
			progressBar.max_value = time
			deposited_in_round = 0
			debtMinimumPayDisplay.show()
			storeWindow.show()
			breakTimer.start()
			Global.break_time_started = true

		if time == 0:
			breakTimer.stop()
			# We have removed Simplify item so we don't need this anymore
			#tileGameReference.refresh_icons()
			#tileGameReference.queue_free()
			
			print(str(tileGameReference.iconArray))
			Global.break_time_started = false
			await get_tree().create_timer(0.5).timeout
			storeWindow.hide()
			phase0Setup = true
			Global.phase = 0
			Global.hour += 1
			if Global.hour > 8:
				# TODO - Check Minimum
				if deposited_in_round < Global.minimumPay:
					get_tree().change_scene_to_file("res://game_over.tscn")
				elif Global.day == 5:
					get_tree().change_scene_to_file("res://you_win_credits.tscn")
				else:
					Global.day += 1
					Global.hour = 1
					raise_items_update()
					update_minimum_debt_payment()
					# TODO - Create scene for new_day
					get_tree().change_scene_to_file("res://story_beat.tscn")
			update_day_hour_text()


func seconds2hhmmss(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hours:  int   =  int(total_seconds / 3600.0)
	var hhmmss_string:String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	return hhmmss_string.replace(".00","")

func _on_work_timer_timeout():
	time -= 1


func _on_deposit_pressed():
	if money != 0:
		money -= 1
		Global.debt -= 1
		deposited_in_round += 1
		# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 1

func _on_deposit_10_pressed():
	if money >= 10:
		money -= 10
		Global.debt -= 10
		deposited_in_round += 10
				# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 10

func _on_deposit_100_pressed():
	if money >= 100:
		money -= 100
		Global.debt -= 100
		deposited_in_round += 100
				# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 100


func _on_break_timer_timeout():
	time -= 1


func raise_items_update():
	match Global.day:
		2:
			Global.amt_earned_combos += 6
			Global.amt_earned_icon +=2
			Global.item_pool = ["res://inventory/items/money_multiplier_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
			InventoryManager.grant_item("res://inventory/items/money_multiplier_item.tres", 1)
		3:	
			Global.amt_earned_combos += 6
			Global.amt_earned_icon +=2
			Global.item_pool = ["res://inventory/items/lightning_item.tres","res://inventory/items/money_multiplier_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
			InventoryManager.grant_item("res://inventory/items/lightning_item.tres", 1)
		4: 
			Global.amt_earned_combos += 6
			Global.amt_earned_icon +=2
			Global.item_pool = ["res://inventory/items/missle_item.tres","res://inventory/items/money_multiplier_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
			InventoryManager.grant_item("res://inventory/items/missle_item.tres", 1)	
		5: 
			Global.amt_earned_combos += 6
			Global.amt_earned_icon +=2
			Global.item_pool = ["res://inventory/items/missle_item.tres","res://inventory/items/money_multiplier_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
		_:
			pass
func item_clicked(node):
	print("Clicked on item: ",node.item.item_name)
	match node.item.item_name:
		"Add Time":
			time = time + 5
			InventoryManager.revoke_item("res://inventory/items/time_add_item.tres")
			Audio.play("res://sfx/Time Add.wav",true)
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Bomb":
			await tileGameReference.bomb_random_icon()
			#TODO - Make sure to grant a missle if it can't fire and play SFX, maybe put revoking in other code
			InventoryManager.revoke_item("res://inventory/items/bomb_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Refresh Board":
			Audio.play("res://sfx/Time Add.wav",true)
			await tileGameReference.reset_board()
			InventoryManager.revoke_item("res://inventory/items/refresh_item.tres")			
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"$ Multiplier":
			Global.money_multiplier += 1
			InventoryManager.revoke_item("res://inventory/items/money_multiplier_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Simplify Board":
			await tileGameReference.simplify_board()
			#TODO - Make sure to grant a missle if it can't fire and play SFX
			InventoryManager.revoke_item("res://inventory/items/simplify_board_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Missle":
			await tileGameReference.missle_evil_icons()
			#TODO - Make sure to grant a missle if it can't fire and play SFX
			InventoryManager.revoke_item("res://inventory/items/missle_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Lightning":
			await tileGameReference.lightning()
			InventoryManager.revoke_item("res://inventory/items/lightning_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		_: 
			pass
			

func _on_item_1_pressed():
	if money > 0 && item1Price > 0:
		print("TEST")
		item1Price -= 1
		money -= 1
		if item1Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item1Random.get_path())
			print("Item3Price is Zero")
			
			item1SoldOut = true
			item1.icon = itemSoldOutArt
			item1Label.text = "ITEM NOT AVAILABLE!"
			item1.text = "SOLD OUT!"
			item1.disabled = true


func _on_item_2_pressed():
	if money > 0 && item2Price > 0:
		print("TEST")
		item2Price -= 1
		money -= 1
		if item2Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item2Random.get_path())
			print("Item2Price is Zero")
			
			item2SoldOut = true
			item2.icon = itemSoldOutArt
			item2Label.text = "ITEM NOT AVAILABLE!"
			item2.text = "SOLD OUT!"
			item2.disabled = true

func _on_item_3_pressed():
	if money > 0 && item3Price > 0:
		print("TEST")
		item3Price -= 1
		money -= 1
		if item3Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item3Random.get_path())
			print("Item3Price is Zero")
			
			item3SoldOut = true
			item3.icon = itemSoldOutArt
			item3Label.text = "ITEM NOT AVAILABLE!"
			item3.text = "SOLD OUT!"
			item3.disabled = true
			
func phase_0_setup():
	MusicPlayer.stop()
	phase0Setup = false
	Global.break_time_started = false
	MusicPlayer.stream = load("res://music/money on the line [puzzle theme].wav")
	MusicPlayer.play()
	breakTimer.stop()
	create_new_store()
	storeWindow.hide()
	if (Global.day == 1 && Global.hour == 1):
		return
	# We have removed SIMPLIFY item so we don't need this any more
	#tileGameReference.refresh_icons()
	Global.money_multiplier = 1
	tileGameReference.reset_board()
	

func phase_1_setup():
	MusicPlayer.stop()
	phase1Setup = false
	Global.work_time_started = false
	MusicPlayer.stream = load("res://music/money to spend [shortened break theme].wav")
	MusicPlayer.play()
	workTimer.stop()
	workWindow.hide()
	Global.money_multiplier = 1
	
func change_phase_display(phase: int):
	if phase == 0:
		scrollAlertText.text = "It's Work Time!!!"
	elif phase == 1:
		scrollAlertText.text = "It's Break Time!!!"	

	await get_tree().create_timer(0.5).timeout
	topWindow.show()
	scrollAlertTextAnimation.play()
	await get_tree().create_timer(1.25).timeout
	topWindow.hide()
	
func create_new_store():
	
	if item1SoldOut == true:
		item1SoldOut = false
	item1.disabled = false
	item1Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item1.text = item1Random.item_name + " - " + "Pay $1"
	item1.icon = item1Random.item_icon
	item1Price = item1Random.cost
	item1Discription = item1Random.discription

	if item2SoldOut == true:
		item2SoldOut = false
	item2.disabled = false
	item2Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item2.text = item2Random.item_name + " - " + "Pay $1"
	item2.icon = item2Random.item_icon
	item2Price = item2Random.cost
	item2Discription = item2Random.discription

	if item3SoldOut == true:
		item3SoldOut = false
	item3.disabled = false
	item3SoldOut = false

	item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	while (item3Random == item1Random && item3Random == item2Random):
		item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item3.text = item3Random.item_name + " - " + "Pay $1"
	item3.icon = item3Random.item_icon
	item3Price = item3Random.cost
	item3Discription = item3Random.discription

func update_minimum_debt_payment():
	match Global.day:
		1:
			Global.minimumPay = 500
		2:
			Global.minimumPay = 1000
		3:
			Global.minimumPay = 1500
		4:
			Global.minimumPay = 3000
		5:
			Global.minimumPay = 4000
		_:
			Global.minimumPay = 500

func update_day_hour_text():
	dayHourText.text = "Day: " + str(Global.day) + "/5 \nHour: " + str(Global.hour) + "/8 \nPhase: " + str(Global.phase + 1) +"/2"

func pause():
		if not pauseScreen.visible:
			MusicPlayer.volume_db = -40
			topWindow.hide()
			workWindow.hide()
			bankWindow.hide()
			timerWindow.hide()
			dayHourWindow.hide()
			itemWindow.hide()
			storeWindow.hide()
			Engine.time_scale = 0
			pauseScreen.show()

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		if not pauseScreen.visible:
			MusicPlayer.volume_db = -40
			if topWindow.visible:
				topWindowVisible = true
				topWindow.hide()
			else:
				topWindowVisible = false
			workWindow.hide()
			bankWindow.hide()
			timerWindow.hide()
			dayHourWindow.hide()
			itemWindow.hide()
			storeWindow.hide()
			Engine.time_scale = 0
			pauseScreen.show()
		else:
			MusicPlayer.volume_db = 0
			if topWindowVisible:
				topWindow.show()
			bankWindow.show()
			timerWindow.show()
			dayHourWindow.show()
			itemWindow.show()
			if Global.phase == 1:
				storeWindow.show()
			else:
				workWindow.show()
			Engine.time_scale = 1
			pauseScreen.hide()
	if Input.is_action_just_pressed("debug"):
		if not debugScreen.visible:
			MusicPlayer.volume_db = -40
			workWindow.hide()
			bankWindow.hide()
			timerWindow.hide()
			dayHourWindow.hide()
			itemWindow.hide()
			storeWindow.hide()
			Engine.time_scale = 0
			debugScreen.show()
		else:
			MusicPlayer.volume_db = 0
			bankWindow.show()
			timerWindow.show()
			dayHourWindow.show()
			itemWindow.show()
			if Global.phase == 1:
				storeWindow.show()
			else:
				workWindow.show()
			Engine.time_scale = 1
			debugScreen.hide()
			bankWindow.grab_focus()

func debug():
		if not debugScreen.visible:
			MusicPlayer.volume_db = -40
			topWindow.hide()
			workWindow.hide()
			bankWindow.hide()
			timerWindow.hide()
			dayHourWindow.hide()
			itemWindow.hide()
			storeWindow.hide()
			Engine.time_scale = 0
			debugScreen.show()


func _on_x_button_pressed():
	if Global.phase == 0:
		$"not allow/text".text = "YOUR BOSS IS NOT
ALLOWING YOU 
TO CLOSE THE WINDOW"
	else:
		$"not allow/text".text = "INTERNAL ERROR
		CODE: HDS2026PSGJ"
	$"not allow".show()
	await get_tree().create_timer(2).timeout
	$"not allow".hide()

func show_money_popup(money_amount : int,good = true):
	var popup = preload("res://dollar_earn_popup.tscn").instantiate()
	popup.amount = abs(money_amount)
	popup.good = good
	var randi_type = randi_range(1,2)
	var randi = 0
	if randi_type == 1:
		randi = randi_range(145,200)
	if randi_type == 2:
		randi = randi_range(15,65)
	popup.global_position = Vector2(randi,165)
	add_child(popup)


func _on_skip_pressed():
	time = 0
