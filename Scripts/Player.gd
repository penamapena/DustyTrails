########## Player.gd
extends CharacterBody2D

# Node references
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar
@onready var ammo_amount = $UI/AmmoAmount
@onready var stamina_amount = $UI/StaminaAmount2
@onready var health_amount = $UI/HealthAmount

@export var speed = 50
const JUMP_VELOCITY = -400.0
var is_attacking = false

#direction and animation to be updated throughout game state
var new_direction = Vector2(0,1) #only move one spaces
var animation

# UI variables
var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 1

# Custom signals
signal health_updated
signal stamina_updated
signal ammo_pickups_updated
signal health_pickups_updated
signal stamina_pickups_updated

# Bullet & attack variables
var bullet_damage = 30
var bullet_reload_time = 1000
var bullet_fired_time = 0.5

enum Pickups {AMMO, STAMINA, HEALTH}
var ammo_pickup = 0
var health_pickup = 0
var stamina_pickup = 0
# ----------- UI -----------
func _process(delta):
	#regenerates health
	var updated_health = min(health + regen_health * delta, max_health)
	if updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)
	#regenerates stamina
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)

func _ready():
	# Connect the signals to the UI components' function
	health_updated.connect(health_bar.update_health_ui)
	stamina_updated.connect(stamina_bar.update_stamina_ui)
	ammo_pickups_updated.connect(ammo_amount.update_ammo_pickup_ui)
	health_pickups_updated.connect(health_amount.update_health_pickup_ui)
	stamina_pickups_updated.connect(stamina_amount.update_stamina_pickup_ui)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
			direction = direction.normalized()
	# Sprinting
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 25:
			speed = 100
			stamina = stamina - 5
			stamina_updated.emit(stamina, max_stamina)
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50
	# Apply movement
	var movement = speed * direction * delta
	
	if is_attacking == false:
	# Moves our player around, whilst enforcing collision so that they come to a stop when colliding with another object.
		move_and_collide(movement)
		player_animations(direction)
	
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation  = "idle_" + returned_direction(new_direction)
# Animations
func player_animations(direction : Vector2):
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation because we are moving
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		animation = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)

func returned_direction(direction : Vector2):
	#it normalizes the direction vector 
	var normalized_direction = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "side"
		
	return default_return

func _input(event):
	#input event for our attacking, i.e. our shooting
	if event.is_action_pressed("ui_attack"):
	#checks the current time as the amount of time passed in milliseconds since the engine started
		var now = Time.get_ticks_msec()
		#check if player can shoot if the reload time has passed and we have ammo
		if now >= bullet_fired_time and ammo_pickup > 0:
			#shooting anim
			is_attacking = true
			var animation  = "attack_" + returned_direction(new_direction)
			animation_sprite.play(animation)
			#bullet fired time to current time
			bullet_fired_time = now + bullet_reload_time
			#reduce and signal ammo change
			ammo_pickup = ammo_pickup - 1
			ammo_pickups_updated.emit(ammo_pickup)
			
	elif event.is_action_pressed("ui_consume_health"):
		if health > 0 && health_pickup > 0:
			health_pickup = health_pickup - 1
			health = min(health + 50, max_health)
			health_pickups_updated.emit(health_pickup)
	elif event.is_action_pressed("ui_consume_stamina"):
		if stamina > 0 && stamina_pickup > 0:
			stamina_pickup = stamina_pickup - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_pickups_updated.emit(stamina_pickup)

func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
	
	# Instantiate Bullet
	if animation_sprite.animation.begins_with("attack_"):
		var bullet = Global.bullet_scene.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		# Place it 4-5 pixels away in front of the player to simulate it coming from the guns barrel
		bullet.position = position + new_direction.normalized() * 4
		get_tree().root.get_node("Main").add_child(bullet)

func add_pickup(item):
	if item == Global.Pickups.AMMO:
		ammo_pickup = ammo_pickup + 3
		ammo_pickups_updated.emit(ammo_pickup)
		print("ammo val:" + str(ammo_pickup))
	if item == Global.Pickups.HEALTH:
		health_pickup = health_pickup + 1
		health_pickups_updated.emit(health_pickup)
		print("health val:" + str(health_pickup))
	if item == Global.Pickups.STAMINA:
		stamina_pickup = stamina_pickup + 1
		stamina_pickups_updated.emit(stamina_pickup)
		print("stamina val:" + str(stamina_pickup))
