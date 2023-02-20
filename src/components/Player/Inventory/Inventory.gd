extends Control

# Controller

@export_node_path("CharacterBody3D")
var player

func _ready() -> void:
	for i in range(4):
		var item = InventoryItem.instantiate()
		
		grid.add_child(item)

const InventoryItem = preload("res://components/Player/Inventory/InventoryItem.tscn")

@onready
var grid = $PanelContainer/GridContainer

func add(item: Item, index: int = -1) -> bool:
	assert(index >= -1 and index < capacity(), "Illegal index: %d" % index)
	
	var item_wrapper = null
	
	if index == -1:
		item_wrapper = _first_free()

	elif index >= 0 and index < capacity():
		item_wrapper = grid.get_child(index)
	
	if not item_wrapper or item_wrapper.bound():
		return false
	
	item_wrapper.bind(item)
	return true

func _first_free():
	for item in grid.get_children():
		if not item.bound():
			return item

	return null

func capacity() -> int:
	return grid.get_children().size()

func remove(index: int = 0) -> void:
	assert(index >= 0 and index < capacity(), "Illegal index")
	
	var item_wrapper = grid.get_child(index)
	if item_wrapper.bound():
		item_wrapper.unbind()

func get_at(index: int) -> Item:
	return grid.get_child(index).item()
