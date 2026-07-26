extends Node

var current_work_time_id = 0

var current_break_time_id = 0

var work_time_started = false

var break_time_started = false

var work_times = [23,25,27,29]

var break_times = [8,10,12,14]

var phase = 0

var debt = 10000

var minimumPay = 500

var day = 1

var hour = 1

var item_pool = ["res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]

var iconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6, 7],[1, 2, 3, 4, 5, 8, 9],[1, 2, 3, 4, 5, 10, 11],[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]]

var bombIconsForRound = [[],[1, 2, 3, 4, 5],[1, 2, 3, 4, 5, 6],[1, 2, 3, 4, 5, 8],[1, 2, 3, 4, 5, 10],[1, 2, 3, 4, 5, 6, 8, 10]]

var amt_earned_combos = 4

var amt_earned_icon = 1

var money_multiplier = 1
