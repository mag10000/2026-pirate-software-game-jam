extends Control

# Export Variables
@export var earningsAmountDisplay: Label
@export var debtAmountDisplay: Label
@export var debtMinimumPayDisplay: Label
@export var scrollAlertText: Label

@export var workTimer: Timer
@export var breakTimer: Timer
@export var depositFlickerTimer: Timer

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

@export_group("store")

@export var item1: Button
@export var item1Label: Label

@export var item2: Button
@export var item2Label: Label

@export var item3: Button
@export var item3Label: Label

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

func _ready():
	create_new_store()
	workWindow.hide()
	storeWindow.hide()
	topWindow.hide()
	InventoryManager.grant_item("res://inventory/items/bomb_item.tres")
	#InventoryManager.grant_item("res://inventory/items/refresh_item.tres")
	#InventoryManager.revoke_item("res://inventory/items/bomb_item.tres")

# Runs every frame
func _process(delta):
	earningsAmountDisplay.text = "$" + str(money)
	debtAmountDisplay.text = "$" + str(Global.debt)
	debtMinimumPayDisplay.text = "Minimum Debt Due: $" + str(Global.minimumPay)
	progressBar.value = time
	if (time > yellowTime && time <= greenTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color(0.0, 1.0, 0.0, 1.0)
	elif (time > redTime && time <= yellowTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color(1.0, 0.871, 0.129, 1.0)
	elif (time <= redTime):
		progressBar.get("theme_override_styles/fill").bg_color = Color(1.0, 0.0, 0.0, 1.0)
	
	
	if Global.phase == 0:
		phase_0_setup()
		
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
			Global.phase = 1

			
	if Global.phase == 1:
		phase_1_setup()
		
		if not Global.break_time_started:
			create_new_store()
			change_phase_display(1)
			time = Global.break_times[Global.current_break_time_id]
			progressBar.max_value = time
			deposited_in_round = 0
			depositButton.show()
			debtMinimumPayDisplay.show()
			storeWindow.show()
			breakTimer.start()
			Global.break_time_started = true

		if time == 0:
			if deposited_in_round < Global.minimumPayStatic:
				get_tree().change_scene_to_file("res://game_over.tscn")
			else:
				breakTimer.stop()
				Global.break_time_started = false
				Global.current_break_time_id = randi_range(0, 3)
				await get_tree().create_timer(0.5).timeout
				storeWindow.hide()
				depositButton.hide()
				debtMinimumPayDisplay.hide()
				Global.phase = 0

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
		if Global.minimumPay != 0:
			Global.minimumPay -= 1


func _on_deposit_flicker_timer_timeout():
	if depositButton.disabled:
		depositButton.disabled = false
	else:
		depositButton.disabled = true


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
	if item1.disabled:
		item1.disabled = false
	else:
		item1.disabled = true
	
	if item2.disabled:
		item2.disabled = false
	else:
		item2.disabled = true
	
	if item3.disabled:
		item3.disabled = false
	else:
		item3.disabled = true


func _on_item_1_pressed():
	if money > 0 && item1Price > 0:
		print("TEST")
		item1Price -= 1
		money -= 1
		if item1Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item1Random.get_path())
			print("Item3Price is Zero")
			item1.hide()
			item1Label.hide()


func _on_item_2_pressed():
	if money > 0 && item2Price > 0:
		print("TEST")
		item2Price -= 1
		money -= 1
		if item2Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item2Random.get_path())
			print("Item2Price is Zero")
			item2.hide()
			item2Label.hide()

func _on_item_3_pressed():
	if money > 0 && item3Price > 0:
		print("TEST")
		item3Price -= 1
		money -= 1
		if item3Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item3Random.get_path())
			print("Item3Price is Zero")
			item3.hide()
			item3Label.hide()
			
			
func phase_0_setup():
	Global.break_time_started = false
	breakTimer.stop()
	Global.minimumPay = 7

	depositButton.hide()
	debtMinimumPayDisplay.hide()
	storeWindow.hide()

func phase_1_setup():
	Global.work_time_started = false
	workTimer.stop()
	workWindow.hide()

	item1Label.text = item1Discription + " - Price $" + str(item1Price)
	item2Label.text = item2Discription + " - Price $" + str(item2Price)
	item3Label.text = item3Discription + " - Price $" + str(item3Price)
	
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
	item1.show()
	item2Label.show()
	item2.show()
	item2Label.show()
	item3.show()
	item3Label.show()	
	
	item1Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item2Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item1.text = item1Random.item_name
	item2.text = item2Random.item_name
	item3.text = item3Random.item_name
	item1.icon = item1Random.item_icon
	item2.icon = item2Random.item_icon
	item3.icon = item3Random.item_icon
	item1Discription = item1Random.discription
	item2Discription = item2Random.discription
	item3Discription = item3Random.discription
	item1Price = item1Random.cost
	item2Price = item2Random.cost
	item3Price = item3Random.cost
