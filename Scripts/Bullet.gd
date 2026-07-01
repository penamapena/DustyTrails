### Bullet.gd
extends Area2D

# Bullet variables
#@onready var tilemap = get_tree().root.get_node("Main/Map")
@onready var animated_sprite = $AnimatedSprite2D

@export var speed = 200
var direction : Vector2 = Vector2.RIGHT
var damage

# ---------------- Bullet -------------------------
# Position
func _process(delta):
	if direction != Vector2.ZERO:
		position += + speed * delta * direction

func _on_body_entered(body: Node2D) -> void:
	# Ignore collision with Player
	if body.name == "Player":
		return

	# Ignore collision with Water
	if body is TileMapLayer:
		return
		
	# If the bullets hit an enemy, damage them
	if body.is_in_group("enemy"):
		body.hit(damage)
	# Stop the movement and explode
	direction = Vector2.ZERO
	animated_sprite.play("impact")

	# If the bullets hit an enemy, damage them
	if body.name.find("Enemy") >= 0:
		#todo: add damage/hit function to enemy scene
		pass


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "impact":
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
