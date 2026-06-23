extends ColorRect

# Node refs
@onready var value = $Value

# Updates UI
func update_health_ui(health, max_health):
	value.size.x = 98 * health / max_health
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
