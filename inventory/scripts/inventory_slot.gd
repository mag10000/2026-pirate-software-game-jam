extends Panel

@export var item : InventoryItem
@export var amount : int
signal show_discription(discription : String)

func _process(delta):
	if item:
		$border/item.texture = item.item_icon
		if amount > 1:
			$border/item/Label.text = str(amount)
	else:
		$border/item.texture = load("res://assets/art/blank.tres")
		$border/item/Label.text = ""


func _on_button_pressed():
	if item:
		show_discription.emit(item.discription)
