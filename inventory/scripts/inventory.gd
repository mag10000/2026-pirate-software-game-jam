extends Control

@export var inventory_slots : int
@export var inventory_group : String
var slot_scene = preload("res://inventory/scenes/inventory_slot.tscn")
var slots

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in inventory_slots:
		var slot_to_create = slot_scene.instantiate()
		$Control/slots.add_child(slot_to_create)
	slots = $Control/slots.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_items()

func set_items():
	var items = InventoryManager.get_inventory(InventoryManager.get_inventory_enums.DICTONARY_PATH_AMOUNT)
	var size = items.size()
	var on = 0
	if size < inventory_slots:
		for item in items:
			var slot = slots[on]
			slot.item = load(item)
			slot.amount = items[item]
			on += 1
	else:
		print("not enough slots for the amount of items")
