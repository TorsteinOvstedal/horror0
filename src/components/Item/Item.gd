extends RigidBody3D

class_name Item

@export_category("Equip transform")
@export var equip_position := Vector3.ZERO
@export var equip_rotation := Vector3.ZERO
	
# Abstract methods

func use() -> void:
	pass

func _ready():
	connect("sleeping_state_changed", _on_sleeping_state_changed)

func _on_sleeping_state_changed() -> void:
	if EngineDebugger.is_active() and sleeping:
		print(name, ": Sleeping.")
	else:
		print(name, ": Ragdoll.")

var _equipped := false

func equip() -> void:
	_equipped = true

func unequip() -> void:
	_equipped = false
