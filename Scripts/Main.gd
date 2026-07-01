########## Main.gd
extends Node2D

@onready var map: TileMapLayer = $Map
@onready var spawned_pickups = $SpawnedPickups

# 1. Update these to match your Source IDs instead of old layers!
const EXTERIOR_SOURCE_ID = 0
const INTERIOR_SOURCE_ID = 1
const WATER_SOURCE_ID = 2

var rng = RandomNumberGenerator.new()

func _ready():
	# rng.randf_range returns a float (e.g., 7.43). 
	# Wrap it in int() to get a whole number of items to spawn.
	var spawn_pickup_amount = int(rng.randf_range(5, 10))
	spawn_pickups(spawn_pickup_amount)

# Valid pickup spawn location helper
func is_valid_spawn_location(position: Vector2i) -> bool:
	# Look up what tile source is placed at this grid coordinate
	var source_id = map.get_cell_source_id(position)
	
	# If there's no tile painted there at all, don't spawn anything
	if source_id == -1:
		return false
	
	# Block spawning if it's water or inside a building
	if source_id == WATER_SOURCE_ID or source_id == INTERIOR_SOURCE_ID:
		return false
	
	# Allow spawning if it's an exterior tile (grass, sand, etc.)
	if source_id == EXTERIOR_SOURCE_ID:
		return true
	
	return false

func spawn_pickups(amount):
	var used_rect = map.get_used_rect()
	
	# Safety check to prevent modulo by zero if map isn't ready
	if used_rect.size.x == 0 or used_rect.size.y == 0:
		print("Warning: TileMapLayer is empty or not loaded yet!")
		return

	var spawned = 0
	var attempts = 0
	var max_attempts = 1000  

	while spawned < amount and attempts < max_attempts:
		attempts += 1
		
		# Pick a random cell within the map's boundary box
		var random_x = used_rect.position.x + (randi() % int(used_rect.size.x))
		var random_y = used_rect.position.y + (randi() % int(used_rect.size.y))
		var random_position = Vector2i(random_x, random_y) 
		
		# Check our rules using the source IDs
		if is_valid_spawn_location(random_position):
			var pickup_instance = Global.pickups_scene.instantiate()
			
			# Selects a random pickup type from your global list
			pickup_instance.item = Global.Pickups.values()[randi() % Global.Pickups.size()]
			
			# Translate grid coordinates (e.g., 5, 4) into actual screen pixels
			pickup_instance.position = map.map_to_local(random_position)
			
			spawned_pickups.add_child(pickup_instance)
			spawned += 1
