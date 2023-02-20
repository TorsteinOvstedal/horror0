extends Item

var on_energy := 1.0
var on := false

func  _ready() -> void:
	if $SpotLight3D.light_energy > 0:
		on_energy = $SpotLight3D.light_energy
		on = true

func toggle() -> void:
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	
	$AudioStreamPlayer.play(0.0)
	
	if on:
		$SpotLight3D.light_energy = 0
		on = false
	else:
		$SpotLight3D.light_energy = on_energy
		on = true

func use() -> void:
	toggle()
