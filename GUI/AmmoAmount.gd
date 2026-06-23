### AmmoAmount.gd
extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func _ready():
	value.text = str(player.ammo_pickup)

func update_ammo_pickup_ui(ammo_pickup):
	value.text = str(ammo_pickup)
