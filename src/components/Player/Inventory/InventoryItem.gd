extends ColorRect

@onready 
var label := $Info 

var _item : Item = null

func bind(item: Item) -> void:
	assert(_item == null, "Item wrapper is already bound.")
	if item == null:
		return

	_item = item
	label.text = item.get_name()
	
func unbind() -> void:
	_item = null
	label.text = ""
	
func bound() -> bool:
	return _item != null
	
func get_item() -> Item:
	return _item

var _hover = null
var _dragged := false
var _lock_position: Vector2

func _swap(other):
	var tmp = other.get_item()
	other.unbind()
	other.bind(self.get_item())
	
	self.unbind()
	self.bind(tmp)
	
var _active = []

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
		
			if event.button_mask == 1:
				_dragged = true
				_lock_position = position
		
			elif event.button_mask == 0:
				if _hover:
					_swap(_hover)

				_dragged = false
				position = _lock_position

	if _dragged and event is InputEventMouseMotion:
		position += event.relative

# This will need some trickery to work.
# A stack sounds reasonable.

func _on_area_entered(area):
	if _dragged:
		_active.append(area.get_parent())

		# Deselect previous head
		if _hover:
			_hover.color[3] = 1.0
		
		# Select new head
		_hover = _active[_active.size() - 1]	# peek
		_hover.color[3] = 0.5

func _on_area_exited(area):
	if _dragged:
		_active.pop_at(_active.find(area))
		color[3] = 1.0
		
		if _active.size() > 0:
			_hover = _active[_active.size() - 1]
			_hover.color[3] = 0.5
			
