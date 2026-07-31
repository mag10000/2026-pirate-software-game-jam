extends Control

# Export Variables
@export var earningsAmountDisplay: Label
@export var debtTitleDisplay: Label
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
@export var item1TextureRect: TextureRect

@export var item2: Button
@export var item2Label: Label
@export var item2TextureRect: TextureRect

@export var item3: Button
@export var item3Label: Label
@export var item3TextureRect: TextureRect

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

var bombInRound = 0
var lightningInRound = 0
var refreshInRound = 0
var moneyUpInRound = 0
var timeUpInRound = 0
var missleInRound = 0

var celebrate = false

# The Amount of Money the Player Has

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
var day1hour1Setup = false

func _ready():
	crtFilerOn = Global.crt_on
	if crtFilerOn:
		$CRTScreen.show()
	create_new_store()
	storeWindow.hide()
	topWindow.hide()
	update_day_hour_text()
	Global.phase = 0

# Runs every frame
func _process(delta):
	if day1hour1Setup == false:
		day1hour1Setup = true
		InventoryManager.grant_item("res://inventory/items/time_add_item.tres", 3)
		InventoryManager.grant_item("res://inventory/items/bomb_item.tres", 3)
		InventoryManager.grant_item("res://inventory/items/refresh_item.tres", 3)
	
	crtFilerOn = Global.crt_on
	if crtFilerOn:
		$CRTScreen.show()
	else:
		$CRTScreen.hide()
	
	earningsAmountDisplay.text = "$" + str(Global.money)
	debtAmountDisplay.text = "$-" + str(Global.debt)
	var debt_due
	if Global.minimumPay <= 0:
		debt_due = 0
	else:
		debt_due = Global.minimumPay
	
	if (debt_due == 0 && celebrate == false):
		celebrate = true
		Audio.play("res://sfx/MinimumMet.wav",true)
		debtMinimumPayDisplay.text = "Minimum Payment Made!"
	elif Global.debt <= 0:
		debtAmountDisplay.text = "NO MORE DEBT!\nGO FOR PROFIT!"
		debtMinimumPayDisplay.text = ""
	elif (debt_due) > 0:
		debtMinimumPayDisplay.text = "Minimum Payment Due Today\n$" + str(debt_due)
		
	progressBar.value = time
	update_day_hour_text()
	
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
			$"work window/Title".show()
			workTimer.start()
			Global.work_time_started = true
			reset_item_limit_on_round()

		if time == 0:
			workTimer.stop()
			Global.work_time_started = false
			Global.current_work_time_id = randi_range(0,3)
			await get_tree().create_timer(0.5).timeout
			$"work window/Title".hide()
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
			if Global.hour >= 8:
				Global.day += 1
				Global.hour = 1
				# TODO - Check Minimum
				if deposited_in_round < Global.minimumPay:
					get_tree().change_scene_to_file("res://game_over.tscn")
				elif Global.day == 5:
					get_tree().change_scene_to_file("res://you_win_credits.tscn")
				else:
					raise_items_update()
					update_minimum_debt_payment()
					# TODO - Create scene for new_day
					get_tree().change_scene_to_file("res://day_win.tscn")
			else:
				await get_tree().create_timer(0.5).timeout
				storeWindow.hide()
				phase0Setup = true
				Global.phase = 0
				Global.hour += 1


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
	if Global.money > 0:
		if Global.debt <= 0:
			Audio.play("res://sfx/Error 2.wav",true)
			return
		Global.money -= 1
		Global.debt -= 1
		Global.debt_paid += 1
		deposited_in_round += 1
		# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 1
		show_money_popup(1, false)
		Audio.play("res://sfx/money_paid.wav",true)
	else:
		Audio.play("res://sfx/Error 2.wav",true)
		
func _on_deposit_10_pressed():
	if Global.money >= 10:
		if Global.debt <= 0:
			Audio.play("res://sfx/Error 2.wav",true)
			return
		Global.money -= 10
		Global.debt -= 10
		Global.debt_paid += 10
		deposited_in_round += 10
				# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 10
		show_money_popup(10, false)
		Audio.play("res://sfx/money_paid.wav",true, 1.2)
	else:
		Audio.play("res://sfx/Error 2.wav",true)
		
func _on_deposit_100_pressed():
	if Global.money >= 100:
		if Global.debt <= 0:
			Audio.play("res://sfx/Error 2.wav",true)
			return
		Global.money -= 100
		Global.debt -= 100
		Global.debt_paid += 100
		deposited_in_round += 100
		
				# TODO - Need to change this logic but not sure how because now you can pay more and see it
		if Global.minimumPay != 0:
			Global.minimumPay -= 100
		show_money_popup(100, false)
		Audio.play("res://sfx/money_paid.wav",true, 1.5)
	else:
		Audio.play("res://sfx/Error 2.wav",true)

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
			InventoryManager.grant_item("res://inventory/items/missle_item.tres", 1)
			InventoryManager.grant_item("res://inventory/items/lightning_item.tres", 1)
			InventoryManager.grant_item("res://inventory/items/money_multiplier_item.tres", 1)
			InventoryManager.grant_item("res://inventory/items/time_add_item.tres", 1)
			InventoryManager.grant_item("res://inventory/items/bomb_item.tres", 1)
			InventoryManager.grant_item("res://inventory/items/refresh_item.tres", 1)
		_:
			pass
func item_clicked(node):
	match node.item.item_name:
		"Add Time":
			print("Got to Add Time in Match")
			if timeUpInRound < 3 && Global.phase == 0:
				print("Got USING Add Time in Match")
				print(timeUpInRound)
				time = time + 5
				InventoryManager.revoke_item("res://inventory/items/time_add_item.tres")
				Audio.play("res://sfx/Time Add.wav",true)
				await get_tree().create_timer(0.15).timeout
				InventoryManager.using_item = false
				timeUpInRound += 1
			else:
				print("Got UNABLE TO USE Add Time in Match")
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		"Bomb":
			if bombInRound < 3 && Global.phase == 0:
				await tileGameReference.bomb_random_icon()
				InventoryManager.using_item = false
				bombInRound += 1
			else:
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		"Refresh Board":
			if refreshInRound < 3 && Global.phase == 0:
				Audio.play("res://sfx/Refresh.wav",true)
				await tileGameReference.reset_board()
				InventoryManager.revoke_item("res://inventory/items/refresh_item.tres")
				await get_tree().create_timer(0.15).timeout
				InventoryManager.using_item = false
				refreshInRound += 1
			else:
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		"$ Multiplier":
			if moneyUpInRound < 3 && Global.phase == 0:
				Global.money_multiplier += 1
				Audio.play("res://sfx/MoneyMult.wav",true)
				InventoryManager.revoke_item("res://inventory/items/money_multiplier_item.tres")
				await get_tree().create_timer(0.15).timeout
				InventoryManager.using_item = false
				moneyUpInRound += 1
			else:
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		"Simplify Board":
			await tileGameReference.simplify_board()
			#TODO - Make sure to grant a missle if it can't fire and play SFX
			InventoryManager.revoke_item("res://inventory/items/simplify_board_item.tres")
			await get_tree().create_timer(0.15).timeout
			InventoryManager.using_item = false
		"Missle":
			if missleInRound < 3 && Global.phase == 0:
				await tileGameReference.missle_evil_icons()
				#TODO - Make sure to grant a missle if it can't fire and play SFX
				InventoryManager.revoke_item("res://inventory/items/missle_item.tres")
				await get_tree().create_timer(0.15).timeout
				InventoryManager.using_item = false
				missleInRound += 1
			else:
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		"Lightning":
			if lightningInRound < 3 && Global.phase == 0:
				await tileGameReference.lightning()
				InventoryManager.revoke_item("res://inventory/items/lightning_item.tres")
				await get_tree().create_timer(0.15).timeout
				InventoryManager.using_item = false
				lightningInRound += 1
			else:
				Audio.play("res://sfx/Error 2.wav",true)
				InventoryManager.using_item = false
		_: 
			pass
			

func _on_item_1_pressed():
	if Global.money > 0 && item1Price > 0:
		print("TEST")
		item1Price -= 1
		Global.money -= 1
		show_money_popup(1, false)
		Audio.play("res://sfx/money_paid.wav",true)
		if item1Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item1Random.get_path())
			print("Item3Price is Zero")
			
			item1SoldOut = true
			item1TextureRect.texture = itemSoldOutArt
			item1Label.text = "ITEM NOT AVAILABLE!"
			item1.text = "SOLD OUT!"
			item1.disabled = true


func _on_item_2_pressed():
	if Global.money > 0 && item2Price > 0:
		print("TEST")
		item2Price -= 1
		Global.money -= 1
		show_money_popup(1, false)
		Audio.play("res://sfx/money_paid.wav",true)
		if item2Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item2Random.get_path())
			print("Item2Price is Zero")
			
			item2SoldOut = true
			item2TextureRect.texture = itemSoldOutArt
			item2Label.text = "ITEM NOT AVAILABLE!"
			item2.text = "SOLD OUT!"
			item2.disabled = true

func _on_item_3_pressed():
	if Global.money > 0 && item3Price > 0:
		print("TEST")
		item3Price -= 1
		Global.money -= 1
		show_money_popup(1, false)
		Audio.play("res://sfx/money_paid.wav",true)
		if item3Price == 0:
			# Grant Item and Remove Item from Store
			InventoryManager.grant_item(item3Random.get_path())
			print("Item3Price is Zero")
			
			item3SoldOut = true
			item3TextureRect.texture = itemSoldOutArt
			item3Label.text = "ITEM NOT AVAILABLE!"
			item3.text = "SOLD OUT!"
			item3.disabled = true
			
func phase_0_setup():
	MusicPlayer.stop()
	phase0Setup = false
	Global.break_time_started = false
	change_music_track()
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
	change_music_track()
	MusicPlayer.play()
	workTimer.stop()
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
	item1.text = "     " + item1Random.item_name + " - " + "Pay $1"
	item1TextureRect.texture = item1Random.item_icon
	item1Price = item1Random.cost
	item1Discription = item1Random.discription

	if item2SoldOut == true:
		item2SoldOut = false
	item2.disabled = false
	item2Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item2.text = "     " + item2Random.item_name + " - " + "Pay $1"
	item2TextureRect.texture = item2Random.item_icon
	item2Price = item2Random.cost
	item2Discription = item2Random.discription

	if item3SoldOut == true:
		item3SoldOut = false
	item3.disabled = false
	item3SoldOut = false

	item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	while (item3Random == item1Random && item3Random == item2Random):
		item3Random = load(Global.item_pool[randi_range(0,Global.item_pool.size() - 1)])
	item3.text = "     " + item3Random.item_name + " - " + "Pay $1"
	item3TextureRect.texture = item3Random.item_icon
	item3Price = item3Random.cost
	item3Discription = item3Random.discription

func update_minimum_debt_payment():
	match Global.day:
		1:
			Global.minimumPay = 500
		2:
			Global.minimumPay = 1500 - Global.debt_paid
		3:
			Global.minimumPay = 3000 - Global.debt_paid
		4:
			Global.minimumPay = 6000 - Global.debt_paid
		5:
			Global.minimumPay = 10000 - Global.debt_paid
		_:
			Global.minimumPay = 500

func update_day_hour_text():
	dayHourText.text = "Day: " + str(Global.day) + "/5 \nHour: " + str(Global.hour) + "/8 \nPhase: " + str(Global.phase + 1) +"/2"

func pause():
		if not pauseScreen.visible:
			MusicPlayer.volume_db = -40
			topWindow.hide()
			$"work window/Title".show()
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
				$"work window/Title".show()
			Engine.time_scale = 1
			pauseScreen.hide()

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		if not pauseScreen.visible:
			MusicPlayer.volume_db = -40
			if topWindow.visible:
				topWindowVisible = true
				topWindow.hide()
			else:
				topWindowVisible = false
			$"work window/Title".hide()
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
				$"work window/Title".show()
			Engine.time_scale = 1
			pauseScreen.hide()
	if Input.is_action_just_pressed("debug"):
		if not debugScreen.visible:
			MusicPlayer.volume_db = -40
			$"work window/Title".hide()
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
				$"work window/Title".show()
			Engine.time_scale = 1
			debugScreen.hide()
			bankWindow.grab_focus()

func debug():
	if not debugScreen.visible:
		MusicPlayer.volume_db = -40
		topWindow.hide()
		$"work window/Title".hide()
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
	if good == false:
		pass
		# For now I think we're handling this elsewhere
#		Audio.play("res://sfx/Anti Cha Ching.wav",true)
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

func change_music_track():
	match Global.hour:
		1:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_12.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_12.wav")
			else:
				print("Error with Global.phase and Music playing")
		2:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_12.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_12.wav")
			else:
				print("Error with Global.phase and Music playing")
		3:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_34.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_34.wav")
			else:
				print("Error with Global.phase and Music playing")
		4:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_34.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_34.wav")
			else:
				print("Error with Global.phase and Music playing")
		5:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_56.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_56.wav")
			else:
				print("Error with Global.phase and Music playing")
		6:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_56.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_56.wav")
			else:
				print("Error with Global.phase and Music playing")
		7:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_78.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_78.wav")
			else:
				print("Error with Global.phase and Music playing")
		8:
			if Global.phase == 0:
				if Global.day == 5:
					MusicPlayer.stream = load("res://music/Rave.wav")
				else:
					MusicPlayer.stream = load("res://music/MoneyOnTheLine_78.wav")
			elif Global.phase == 1:
				MusicPlayer.stream = load("res://music/MoneyToSpend_78.wav")
			else:
				print("Error with Global.phase and Music playing")
		_:
			print("Error with Global.day and Music playing")

func reset_item_limit_on_round():
	bombInRound = 0
	lightningInRound = 0
	refreshInRound = 0
	moneyUpInRound = 0
	timeUpInRound = 0
	missleInRound = 0

func _on_skip_pressed():
	time = 0
