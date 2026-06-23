### HealthAmount.gd
extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func _ready():
	value.text = str(player.health_pickup)

func update_health_pickup_ui(health_pickup):
	value.text = str(health_pickup)
