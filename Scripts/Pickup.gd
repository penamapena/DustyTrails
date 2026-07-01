########## Pickup.gd
@tool

extends Area2D

# Node refs
@onready var sprite = $Sprite2D

# Pickups to choose from
enum Pickups { AMMO, STAMINA, HEALTH}
@export var item : Pickups

var ammo_texture = preload("res://Assets/Icons/shard_01i.png")
var stamina_texture = preload("res://Assets/Icons/potion_02b.png")
var health_texture = preload("res://Assets/Icons/potion_02c.png")

# --------- Icon --------- 
func _process(_delta):
	if Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Global.Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Global.Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Global.Pickups.STAMINA:
			sprite.set_texture(stamina_texture)

func _ready():
	if not Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Global.Pickups.AMMO:
			sprite.set_texture(ammo_texture)
		elif item == Global.Pickups.HEALTH:
			sprite.set_texture(health_texture)
		elif item == Global.Pickups.STAMINA:
			sprite.set_texture(stamina_texture)
			


func _on_body_entered(body):
	if body.name == "Player":
		body.add_pickup(item)
		get_tree().queue_delete(self)
