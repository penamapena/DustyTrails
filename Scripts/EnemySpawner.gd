########## EnemySpawner.gd
extends Node2D

# Node refs
@onready var spawned_enemies = $SpawnedEnemies
@onready var tilemap: TileMapLayer = get_tree().root.get_node("Main/Map")

# Enemy stats
@export var max_enemies = 20 # to spawn
var enemy_count = 0 
var rng = RandomNumberGenerator.new()

# Define your Source IDs based on what you set up in your TileSet
const EXTERIOR_SOURCE_ID = 0
const INTERIOR_SOURCE_ID = 1
const WATER_SOURCE_ID = 2

# --------------------------------- Spawning -------------------------------------
func spawn_enemy():
	var used_rect = tilemap.get_used_rect()
	
	# Safety Check: Prevent modulo by zero if the map isn't loaded
	if used_rect.size.x == 0 or used_rect.size.y == 0:
		print("Warning: Map is empty or not loaded yet!")
		return

	var attempts = 0
	var max_attempts = 100  
	var spawned = false

	while not spawned and attempts < max_attempts:
		attempts += 1
		
		# Correctly pick a random coordinate within the map bounds
		var random_x = used_rect.position.x + (randi() % int(used_rect.size.x))
		var random_y = used_rect.position.y + (randi() % int(used_rect.size.y))
		var random_position = Vector2i(random_x, random_y) # Vector2i for cell coords
		
		# Check if the position is a valid spawn location
		if is_valid_spawn_location(random_position):
			var enemy = Global.enemy_scene.instantiate()
			enemy.death.connect(_on_enemy_death)
			# Convert grid cell to local pixel coordinates
			# Note: map_to_local automatically centers the position inside the tile!
			enemy.position = tilemap.map_to_local(random_position)
			
			spawned_enemies.add_child(enemy)
			spawned = true
			enemy_count += 1
		else:
			attempts += 1
			
	if attempts == max_attempts and not spawned:
		print("Warning: Could not find a valid spawn location after ", max_attempts, " attempts.")

# Valid spawn location helper
func is_valid_spawn_location(position: Vector2i) -> bool:
	# Look up what tile source is placed at this grid coordinate (1 argument only!)
	var source_id = tilemap.get_cell_source_id(position)
	
	# Rule 1: If there's no tile painted there at all (-1), don't spawn
	if source_id == -1:
		return false
	
	# Rule 2: Block spawning if it's water or inside a building
	if source_id == WATER_SOURCE_ID or source_id == INTERIOR_SOURCE_ID:
		return false
	
	# Rule 3: Allow spawning if it's an exterior tile (grass, sand, etc.)
	if source_id == EXTERIOR_SOURCE_ID:
		return true
		
	return false

# Spawn enemy via timer
func _on_timer_timeout():
	if enemy_count < max_enemies:
		spawn_enemy()

func _on_enemy_death():
	enemy_count = enemy_count - 1
