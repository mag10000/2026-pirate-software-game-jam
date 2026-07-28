extends Node

var _inventory : Dictionary = {}
enum get_inventory_enums {
	DICTONARY_NAME_AMOUNT,
	DICTONARY_PATH_AMOUNT,
	ARRAY_PATH,
	ARRAY_AMOUNT,
	ARRAY_NAME
}
enum get_group_enums {
	DICTONARY_NAME_AMOUNT,
	DICTONARY_PATH_AMOUNT,
}

## blah
func get_inventory(mode : get_inventory_enums):
	if mode == get_inventory_enums.DICTONARY_NAME_AMOUNT:
		var new_inventory : Dictionary
		for item in _inventory:
			new_inventory[load(item).item_name] = _inventory[item]
		return new_inventory
	if mode == get_inventory_enums.DICTONARY_PATH_AMOUNT:
		return _inventory
	if mode == get_inventory_enums.ARRAY_PATH:
		var array : Array
		for item in _inventory:
			array.insert(array.size(),item)
		return array
	if mode == get_inventory_enums.ARRAY_AMOUNT:
		var array : Array
		for item in _inventory:
			array.insert(array.size(),_inventory[item])
		return array
	if mode == get_inventory_enums.ARRAY_NAME:
		var array : Array
		for item in _inventory:
			array.insert(array.size(),load(item).item_name)
		return array

func clear_inventory():
		for item in _inventory:
			revoke_item(item.item_name)
		

func get_group(group : String, mode : get_group_enums):
	if group.to_lower() != "all":
		if mode == get_group_enums.DICTONARY_NAME_AMOUNT:
			var dictionary : Dictionary
			for item in _inventory:
				if load(item).item_group == group:
					dictionary[load(item).item_name] = _inventory[item]
			return dictionary
		if mode == get_group_enums.DICTONARY_PATH_AMOUNT:
			var dictionary : Dictionary
			for item in _inventory:
				if load(item).item_group == group:
					dictionary[item] = _inventory[item]
			return dictionary
	else:
		if mode == get_group_enums.DICTONARY_NAME_AMOUNT:
			var new_inventory : Dictionary
			for item in _inventory:
				new_inventory[load(item).item_name] = _inventory[item]
			return new_inventory
		if mode == get_group_enums.DICTONARY_PATH_AMOUNT:
			return _inventory

func grant_item(item_path : String, amount : int = 1):
	if _inventory.has(item_path):
		_inventory[item_path] += amount
		print("granted, ", amount, " ", load(item_path).item_name)
		print("player now has, ", _inventory[item_path], " " , load(item_path).item_name)
	else:
		_inventory[item_path] = amount
		print("granted, ", amount, " ", load(item_path).item_name)

func revoke_item(item_path : String, amount : int = 1):
	if amount > 0:
		if _inventory[item_path] > 1:
			_inventory[item_path] -= amount
			print("revoked, ", amount, " ", load(item_path).item_name)
			if _inventory[item_path] > 0:
				print("player now has, ", _inventory[item_path], " " , load(item_path).item_name)
			else:
				_inventory.erase(item_path)
				print("player now has, ", 0, " " , load(item_path).item_name)
		else:
			_inventory.erase(item_path)
			print("revoked, ", amount, " ", load(item_path).item_name)
			print("player now has, ", 0, " " , load(item_path).item_name)
	else:
		print("Can't revoke less than 1!")
