extends Control

@export var slots_Box_Container: Control
@export var inventory_slots : int
@export var inventory_group : String
var slot_scene = preload("res://inventory/scenes/inventory_slot.tscn")
var slots

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in inventory_slots:
		var slot_to_create = slot_scene.instantiate()
		slots_Box_Container.add_child(slot_to_create)
	slots = slots_Box_Container.get_children()
	
	raise_items_update()
	
func raise_items_update():
	match Global.day:
		1:
			InventoryManager.grant_item("res://inventory/items/time_add_item.tres", 3)
			InventoryManager.grant_item("res://inventory/items/bomb_item.tres", 3)
			InventoryManager.grant_item("res://inventory/items/refresh_item.tres", 3)
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



#		$Control/slots.add_child(slot_to_create)
#	slots = $Control/slots.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_items()

func set_items():
	var items = InventoryManager.get_inventory(InventoryManager.get_inventory_enums.DICTONARY_PATH_AMOUNT)
	var sizeSet = items.size()
	var on = 0
	if sizeSet < inventory_slots:
		for item in items:
			var slot = slots[on]
			slot.item = load(item)
			slot.amount = items[item]
			on += 1
	else:
		print("not enough slots for the amount of items")
		
	if sizeSet != inventory_slots:
		for n in range(0, 7):
			if n < on:
				pass
			else:
				slots[n].amount = 0
				slots[n].item = null	

func item_clicked(node):
	if InventoryManager.using_item == true:
		#TODO - Play ITEM ERROR sfx
		return
	else:
		InventoryManager.using_item = true
		$"../..".item_clicked(node)
