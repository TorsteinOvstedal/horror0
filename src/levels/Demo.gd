extends Node

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	flash_light.connect("tree_entered", _on_flashlight_tree_entered)
			
var _flag0 := false
@onready var flash_light := $Game/FlashLight

func _on_flashlight_tree_entered() -> void:
	# Start playing music on first pickup of the flash light.
	if not _flag0 and flash_light.get_parent() != self:
		_flag0 = true
		$MusicPlayer.play("MusicStart")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit(0)
	if Input.is_action_just_pressed("ui_paste"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
