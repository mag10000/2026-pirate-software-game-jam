extends Node

var current_work_time_id = 0

var current_break_time_id = 0

var work_time_started = false

var break_time_started = false

var work_times = [23,25,21,22]

var break_times = [9]

var phase = 0

var money = 0

var money_earned = 0

var debt = 10000

var debt_paid = 0

var minimumPay = 500

var crt_on = false

var clock_hand_pos = [Vector2(7.0,19.0),Vector2(9.0,14.0),Vector2(11.0,11.0),Vector2(19.0,8.0),Vector2(26.0,10.0),Vector2(29.0,14.0),Vector2(30.0,25.0),Vector2(27.0,26.0)]

var day = 1

var hour = 1

var story_beat = 1

var item_pool = ["res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]

var iconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6, 7],[1, 2, 3, 4, 5, 8, 9],[1, 2, 3, 4, 5, 10, 11],[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]]

var regularIconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6],[1, 2, 3, 4, 5, 8],[1, 2, 3, 4, 5, 10],[1, 2, 3, 4, 5, 6, 8, 10]]

var newIconsForRound = [[],[1,2,3,4,5],[6,7],[8,9],[10,11],[]]

var newItemsForRound = [[], [["res://inventory/items/time_add_item.tres"],["res://inventory/items/refresh_item.tres"],["res://inventory/items/bomb_item.tres"]],
[["res://inventory/items/money_multiplier_item.tres"]],[["res://inventory/items/lightning_item.tres"]],[["res://inventory/items/missle_item.tres"]],[]]

var evilIconsForRound = [[],[],[7],[9],[11],[7,9,11]]

var debt_payments = [0,500,1000,1500,3000,4000]

var amt_earned_combos = 6

var amt_earned_icon = 2

var money_multiplier = 1




func _ready():
	
	SilentWolf.configure({
	"api_key": "dVj5hDbhnL7eQuo7VDpR58hryt4hF2d02sW82n8A",
	"game_id": "hyperdebtswap",
	"log_level": 1
	})

	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
	})
	
	
func clear_data():
	#TODO - Update this as we change things
	# Logic to reset all amounts to default
	InventoryManager.clear_inventory()
	Global.current_work_time_id = 0
	Global.current_break_time_id = 0
	Global.work_time_started = false
	Global.break_time_started = false
	Global.work_times = [23,25,21,22]
	Global.break_times = [10]
	Global.phase = 0
	Global.money_earned = 0
	Global.debt = 10000
	Global.minimumPay = 500
	Global.day = 1
	Global.hour = 1
	Global.story_beat = "start_cutscene"
	Global.item_pool = ["res://inventory/items/lightning_item.tres","res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
	Global.iconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6, 7],[1, 2, 3, 4, 5, 8, 9],[1, 2, 3, 4, 5, 10, 11],[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]]
	Global.regularIconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6],[1, 2, 3, 4, 5, 8],[1, 2, 3, 4, 5, 10],[1, 2, 3, 4, 5, 6, 8, 10]]
	Global.evilIconsForRound = [[],[],[7],[9],[11],[7,9,11]]
	Global.amt_earned_combos = 4
	Global.amt_earned_icon = 1
	Global.money_multiplier = 1
