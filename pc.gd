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

@export var depositButton: Button

@export var scrollAlertTextAnimation: AnimationPlayer

@export_group("store")

@export var item1: Button
@export var item1Label: Label

@export var item2: Button
@export var item2Label: Label

@export var item3: Button
@export var item3Label: Label

var item1Price = 0
var item2Price = 0
var item3Price = 0
var item1Discription = 0
var item2Discription = 0
var item3Discription = 0

# The Amount of Money the Player Has
var money = 0

# Time Remaining in a Counter
var time = 0

# Amount Deposited in current Round
var deposited_in_round = 0

func _ready():
	InventoryManager.grant_item("res://inventory/items/item.tres")
	InventoryManager.grant_item("res://inventory/items/item.tres")

# Runs every frame
func _process(delta):
	earningsAmountDisplay.text = "$" + str(money)
	debtAmountDisplay.text = "$" + str(Global.debt)
	debtMinimumPayDisplay.text = "Minimum Debt Due: $" + str(Global.minimumPay)
	
	if Global.phase == 0:
		Global.minimumPay = 7
		if not Global.work_time_started:
			Global.break_time_started = false
			Global.work_time_started = true
			time = Global.times[Global.current_time_id] + randi_range(1,5)
			workTimer.start()
			breakTimer.stop()
			scrollAlertText.text = "It's Work Time!!!"
			scrollAlertTextAnimation.play()
		bankWindow.title = "Bank Account"
		depositButton.hide()
		debtMinimumPayDisplay.hide()
		if time == 0:
			workTimer.stop()
			Global.work_time_started = false
			if Global.times.size() - 1 == Global.current_time_id:
				Global.current_time_id = 0
			Global.current_time_id += 1
			Global.phase = 1
			workWindow.title = "Work - Time Up!"
			await get_tree().create_timer(0.5).timeout
			workWindow.hide()
			storeWindow.show()
			depositButton.show()
			debtMinimumPayDisplay.show()
		else:
			workWindow.title = "Work - " + str(time)
			
	if Global.phase == 1:
		if not Global.break_time_started:
			Global.break_time_started = true
			time = Global.times[Global.current_time_id] + randi_range(1,5)
			deposited_in_round = 0
			breakTimer.start()
			var item1Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
			var item2Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
			var item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
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
			scrollAlertText.text = "It's Break Time!!!"
			scrollAlertTextAnimation.play()

		depositButton.show()
		debtMinimumPayDisplay.show()
		item1Label.text = item1Discription + " - Price $" + str(item1Price)
		item2Label.text = item2Discription + " - Price $" + str(item2Price)
		item3Label.text = item3Discription + " - Price $" + str(item3Price)
		if time == 0:
			if deposited_in_round < Global.minimumPayStatic:
				get_tree().change_scene_to_file("res://game_over.tscn")
			else:
				Global.work_time_started = false
				Global.phase = 0
				breakTimer.stop()
				storeWindow.hide()
				workWindow.show()
		else:
			bankWindow.title = "Bank Account - " + str(time)



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
		pass #TODO


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
	if money > 0:
		print("TEST")
		item1Price -= 1
		money -= 1


func _on_item_2_pressed():
	if money > 0:
		print("TEST")
		item2Price -= 1
		money -= 1


func _on_item_3_pressed():
	if money > 0:
		print("TEST")
		item3Price -= 1
		money -= 1
