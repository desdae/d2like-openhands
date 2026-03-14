## Game.gd
## Main game scene

extends Node2D

@onready var player: CharacterBody2D
@onready var camera: Camera2D
@onready var world_tilemap: TileMapLayer
@onready var enemies: Node2D
@onready var ground: Node2D

var input_enabled: bool = true
var selected_class: int = 0

func _ready() -> void:
    GameManager.set_game_state(GameManager.GameState.PLAYING)
    
    # Create ground layer
    ground = Node2D.new()
    ground.name = "Ground"
    add_child(ground)
    _create_ground()
    
    # Create enemies container
    enemies = Node2D.new()
    enemies.name = "Enemies"
    add_child(enemies)
    _spawn_enemies()
    
    # Initialize world
    WorldManager.generate_world(1)
    WorldManager.enter_zone("town")
    
    # Create player with selected class
    var player_data = PlayerManager.create_player(GameManager.selected_class, "Hero")
    _create_player_character(player_data)
    
    # Connect signals
    GameManager.game_paused.connect(_on_game_paused)
    
    # Update UI
    UIManager.update_hud()

func _create_ground() -> void:
    # Create a simple floor pattern
    for x in range(30):
        for y in range(30):
            var tile = ColorRect.new()
            tile.position = Vector2(x * 32, y * 32)
            tile.size = Vector2(32, 32)
            # Checkerboard pattern
            if (x + y) % 2 == 0:
                tile.color = Color(0.15, 0.15, 0.12)
            else:
                tile.color = Color(0.12, 0.12, 0.1)
            ground.add_child(tile)
    
    # Add some decoration (town center)
    var town_center = ColorRect.new()
    town_center.position = Vector2(250, 250)
    town_center.size = Vector2(100, 80)
    town_center.color = Color(0.3, 0.25, 0.2)
    ground.add_child(town_center)

func _spawn_enemies() -> void:
    # Spawn some test enemies
    var enemy_positions = [
        Vector2(400, 300),
        Vector2(500, 200),
        Vector2(350, 450),
        Vector2(600, 400),
        Vector2(200, 500),
    ]
    
    for pos in enemy_positions:
        var enemy = _create_enemy(pos)
        enemies.add_child(enemy)

func _create_enemy(position: Vector2) -> Node2D:
    var enemy = CharacterBody2D.new()
    enemy.position = position
    enemy.name = "Enemy"
    
    # Sprite (using ColorRect for visibility)
    var sprite = ColorRect.new()
    sprite.name = "Sprite"
    sprite.size = Vector2(24, 24)
    sprite.position = Vector2(-12, -12)
    sprite.color = Color(0.8, 0.2, 0.2)  # Red
    enemy.add_child(sprite)
    
    # Collision
    var collision = CollisionShape2D.new()
    collision.shape = CircleShape2D.new()
    collision.shape.radius = 12
    enemy.add_child(collision)
    
    # Enemy stats
    enemy.set_meta("hp", 50)
    enemy.set_meta("max_hp", 50)
    enemy.set_meta("damage", 5)
    
    return enemy

func _create_player_character(player_data) -> void:
    player = CharacterBody2D.new()
    player.name = "Player"
    player.position = Vector2(300, 300)  # Start in town
    
    # Add sprite (using ColorRect for visibility)
    var sprite = ColorRect.new()
    sprite.name = "Sprite"
    sprite.size = Vector2(24, 24)
    sprite.position = Vector2(-12, -12)  # Center it
    sprite.color = Color(0.3, 0.8, 0.3)  # Green
    player.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    collision.shape = CircleShape2D.new()
    collision.shape.radius = 12
    player.add_child(collision)
    
    # Add camera
    camera = Camera2D.new()
    camera.name = "Camera"
    camera.zoom = Vector2(1.5, 1.5)
    player.add_child(camera)
    
    add_child(player)

func _process(delta: float) -> void:
    if not input_enabled:
        return
    
    _handle_input(delta)
    _update_game(delta)

func _handle_input(delta: float) -> void:
    var direction = Vector2.ZERO
    
    if Input.is_action_pressed("move_up"):
        direction.y -= 1
    if Input.is_action_pressed("move_down"):
        direction.y += 1
    if Input.is_action_pressed("move_left"):
        direction.x -= 1
    if Input.is_action_pressed("move_right"):
        direction.x += 1
    
    if direction.length() > 0:
        direction = direction.normalized()
        
        # Isometric movement
        var move_dir = _to_isometric(direction)
        player.velocity = move_dir * 200
        player.move_and_slide()
        
        # Update player entity in combat
        _update_player_entity()
    
    # Handle primary action (attack)
    if Input.is_action_just_pressed("primary_action"):
        _perform_attack()
    
    # Handle skill keys 1-8
    for i in range(8):
        if Input.is_action_just_pressed("skill_" + str(i + 1)):
            _use_skill(i)

func _perform_attack() -> void:
    # Simple attack - damage nearby enemies
    if not player:
        return
    
    var attack_range = 50.0
    var attack_damage = 10
    
    for enemy in enemies.get_children():
        var dist = player.global_position.distance_to(enemy.global_position)
        if dist < attack_range:
            var hp = enemy.get_meta("hp", 50)
            hp -= attack_damage
            enemy.set_meta("hp", hp)
            
            # Knockback
            var knockback_dir = (enemy.global_position - player.global_position).normalized()
            enemy.global_position += knockback_dir * 20
            
            # Check if enemy died
            if hp <= 0:
                enemy.queue_free()

func _use_skill(slot: int) -> void:
    # Placeholder - skills would use the SkillDatabase
    print("Skill slot ", slot, " pressed")

func _to_isometric(direction: Vector2) -> Vector2:
    # Convert screen direction to isometric
    var iso = Vector2(
        direction.x - direction.y,
        (direction.x + direction.y) * 0.5
    )
    return iso

func _update_game(delta: float) -> void:
    # Update UI bars
    UIManager.update_hud()
    
    # Check for player death
    var player_data = PlayerManager.get_current_player()
    if player_data and player_data.current_hp <= 0:
        _handle_player_death()

func _update_player_entity() -> void:
    # Sync player position with world
    pass

func _on_game_paused(paused: bool) -> void:
    input_enabled = not paused

func _handle_player_death() -> void:
    var player_data = PlayerManager.get_current_player()
    
    # Drop gold (half)
    var gold_loss = player_data.gold / 2
    player_data.gold -= gold_loss
    
    # Respawn in town
    player_data.current_hp = player_data.max_hp
    player_data.current_mp = player_data.max_mp
    player.position = Vector2(300, 300)
    
    # Show death message
    GameManager.set_game_state(GameManager.GameState.GAME_OVER)
