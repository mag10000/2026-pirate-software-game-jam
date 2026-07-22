extends Node

var current_work_time_id = 0

var current_break_time_id = 0

var work_time_started = false

var break_time_started = false

var work_times = [20,24,18,22]

var break_times = [10,12,8,14]

var phase = 0

var debt = 1000

var minimumPay = 7

var minimumPayStatic = 7

var item_pool = ["res://inventory/items/time_add_item.tres","res://inventory/items/refresh_item.tres","res://inventory/items/bomb_item.tres"]
