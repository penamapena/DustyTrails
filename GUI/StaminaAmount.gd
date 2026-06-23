### StaminaAmount.gd
extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func _ready():
	value.text = str(player.stamina_pickup)

func update_stamina_pickup_ui(stamina_pickup):
	value.text = str(stamina_pickup)
