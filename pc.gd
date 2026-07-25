extends Control

# Export Variables
@export var earningsAmountDisplay: Label
@export var debtAmountDisplay: Label
@export var debtMinimumPayDisplay: Label
@export var scrollAlertText: Label
@export var dayHourText: Label

@export var workTimer: Timer
@export var breakTimer: Timer

@export var workWindow: Window
@export var bankWindow: Window
@export var itemWindow: Window
@export var storeWindow: Window
@export var topWindow: Window
@export var timerWindow: Window

@export var progressBar: ProgressBar

@export var depositButton: Button

@export var scrollAlertTextAnimation: AnimationPlayer

@export var tileGameReference: Node2D

@export var MusicPlayer: AudioStreamPlayer

@export_group("store")

@export var item1: Button
@export var item1Label: Label

@export var item2: Button
@export var item2Label: Label

@export var item3: Button
@export var item3Label: Label

@export var itemSoldOutArt: Texture

# Color Variables for ProgressBar
var redTime = 5
var yellowTime = 10
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
	create_new_store()
	workWindow.hide()
	storeWindow.hide()
	topWindow.hide()
	update_day_hour_text()
	InventoryManager.grant_item("res://inventory/items/bomb_item.tres")
	InventoryManager.grant_item("res://inventory/items/refresh_item.tres")
	#InventoryManager.revoke_item("res://inventory/items/bomb_item.tres")

# Runs every frame
func _process(delta):
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
		progressBar.get("theme_override_styles/fill").bg_color = Color(0.0, 1.0, 0.0, 1.0)
	elif (time > redTime && time <= yellowTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color(1.0, 0.871, 0.129, 1.0)
	elif (time <= redTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color(1.0, 0.0, 0.0, 1.0)
	
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
			Global.break_time_started = false
			Global.current_break_time_id = randi_range(0, 3)
			await get_tree().create_timer(0.5).timeout
			storeWindow.hide()
			debtMinimumPayDisplay.hide()
			phase0Setup = true
			Global.phase = 0
			Global.hour += 1
			if Global.hour > 8:
				# TODO - Check Minimum
				if deposited_in_round < Global.minimumPay:
					get_tree().change_scene_to_file("res://game_over.tscn")
				else:
					Global.day += 1
					Global.hour = 1
					update_minimum_debt_payment()
					# TODO - Create scene for new_day
					# get_tree().change_scene_to_file("res://new_day.tscn")
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

func item_clicked(node):
	print("Clicked on item: ",node.item.item_name)
	match node.item.item_name:
		"Add Time":
			time = time + 5
			InventoryManager.revoke_item("res://inventory/items/time_add_item.tres")
		"Bomb":
			tileGameReference.remove_random_icon()
			InventoryManager.revoke_item("res://inventory/items/bomb_item.tres")
		"Refresh Board":
			tileGameReference.reset_board()
			InventoryManager.revoke_item("res://inventory/items/refresh_item.tres")			
			
func _on_store_flicker_timer_timeout():
	#if item1.disabled && item1SoldOut == false:
		#item1.disabled = false
	#else:
		#item1.disabled = true
	#
	#if item2.disabled && item2SoldOut == false:
		#item2.disabled = false
	#else:
		#item2.disabled = true
	#
	#if item3.disabled && item3SoldOut == false:
		#item3.disabled = false
	#else:
		#item3.disabled = true
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
	debtMinimumPayDisplay.hide()
	create_new_store()
	storeWindow.hide()
	if (Global.day == 1 && Global.hour == 1):
		return
	tileGameReference.reset_board()
	

func phase_1_setup():
	MusicPlayer.stop()
	phase1Setup = false
	Global.work_time_started = false
	MusicPlayer.stream = load("res://music/money to spend [shortened break theme].wav")
	MusicPlayer.play()
	workTimer.stop()
	workWindow.hide()
	
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
	
	if item1SoldOut == true || Global.hour == 1:
		item1SoldOut = false
		item1.disabled = false
		item1Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
		item1.text = "Make $1 Item Payment"
		item1.icon = item1Random.item_icon
		item1Price = item1Random.cost
		item1Discription = item1Random.item_name + " - " + item1Random.discription

	if item2SoldOut == true || Global.hour == 1:
		item2SoldOut = false
		item2.disabled = false
		item2Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
		item2.text = "Make $1 Item Payment"
		item2.icon = item2Random.item_icon
		item2Price = item2Random.cost
		item2Discription = item2Random.item_name + " - " + item2Random.discription

	if item3SoldOut == true || Global.hour == 1:
		item3SoldOut = false
		item3.disabled = false
		item3SoldOut = false
		item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
		item3.text = "Make $1 Item Payment"
		item3.icon = item3Random.item_icon
		item3Price = item3Random.cost
		item3Discription = item3Random.item_name + " - " + item3Random.discription

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
	dayHourText.text = "Day: " + str(Global.day) + "/5 \nHour: " + str(Global.hour) + "/8"
	
	
