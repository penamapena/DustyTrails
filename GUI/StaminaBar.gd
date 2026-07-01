########## StaminaBar.gd
extends ColorRect

# Node refs
@onready var value = $Value

# Updates UI
func update_stamina_ui(stamina, max_stamina):
	value.size.x = 98 * stamina / max_stamina
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
