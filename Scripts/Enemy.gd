extends CharacterBody2D

# Node refs
@onready var player = get_tree().root.get_node("Main/Player")
@onready var animation_sprite = $AnimatedSprite2D

# Enemy stats
@export var speed = 50
var direction : Vector2 = Vector2.ZERO # Start idle
var new_direction = Vector2(0,1) 
var animation
var is_attacking = false

# RandomNumberGenerator to generate timer countdown value 
var rng = RandomNumberGenerator.new()
var change_direction_timer = 0.0

func _ready():
	rng.randomize()
	# Give the enemy a random starting direction so they aren't frozen
	pick_random_direction()

func _physics_process(delta):
	if not player:
		return

	var player_distance = player.global_position - global_position
	var distance_length = player_distance.length()

	# ---- AI STATE MACHINE ----
	if distance_length <= 20:
		# State 1: Close enough to attack, stop moving and face player
		direction = Vector2.ZERO
		new_direction = player_distance.normalized()
	elif distance_length <= 150:
		# State 2: Within detection radius (150px), active chase!
		direction = player_distance.normalized()
		new_direction = direction
	else:
		# State 3: Player is far away, randomly roam around
		change_direction_timer -= delta
		if change_direction_timer <= 0:
			pick_random_direction()

	# ---- MOVEMENT EXECUTION ----
	# Using CharacterBody2D standard movement (smoother, handles collisions perfectly)
	velocity = direction * speed
	move_and_slide()

	# If we bumped into something that isn't the player, bounce away
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision.get_collider().name != "Player":
			direction = direction.rotated(rng.randf_range(PI/4, PI/2))
			new_direction = direction
			change_direction_timer = rng.randf_range(2, 4) # Don't change again for a bit

	if not is_attacking:
		enemy_animations(new_direction)

func pick_random_direction():
	# Pick between stopping or walking in a random direction
	if rng.randf() < 0.3:
		direction = Vector2.ZERO
	else:
		direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI).normalized()
	
	new_direction = direction
	change_direction_timer = rng.randf_range(1.5, 3.5) # Seconds until next wander choice

func enemy_animations(anim_direction : Vector2):
	if direction != Vector2.ZERO:
		animation = "walk_" + returned_direction(anim_direction)
	else:
		animation = "idle_" + returned_direction(anim_direction)
	animation_sprite.play(animation)

func returned_direction(look_direction : Vector2):
	var normalized_direction = look_direction.normalized()
	
	if abs(normalized_direction.x) > abs(normalized_direction.y):
		$AnimatedSprite2D.flip_h = normalized_direction.x < 0
		return "side"
	elif normalized_direction.y < 0:
		return "up"
	else:
		return "down"
