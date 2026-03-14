## Game.gd
## Main game scene

extends Node2D

@onready var player: CharacterBody2D
@onready var camera: Camera2D
@onready var world_tilemap: TileMapLayer

var input_enabled: bool = true

func _ready() -> void:
    GameManager.set_game_state(GameManager.GameState.PLAYING)
    
    # Initialize world
    WorldManager.generate_world(1)
    WorldManager.enter_zone("town")
    
    # Create player
    var player_data = PlayerManager.create_player(PlayerManager.CharacterClass.MARAUDER, "Hero")
    _create_player_character(player_data)
    
    # Connect signals
    GameManager.game_paused.connect(_on_game_paused)
    
    # Update UI
    UIManager.update_hud()

func _create_player_character(player_data) -> void:
    player = CharacterBody2D.new()
    player.name = "Player"
    player.position = Vector2(300, 300)  # Start in town
    
    # Add sprite
    var sprite = Sprite2D.new()
    sprite.name = "Sprite"
    # sprite.texture = load("res://assets/sprites/player.png")  # Placeholder
    sprite.modulate = Color(0.3, 0.8, 0.3)  # Green tint for now
    player.add_child(sprite)
    
    # Add collision
    var collision = CollisionShape2D.new()
    collision.shape = CircleShape2D.new()
    collision.shape.radius = 16
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
