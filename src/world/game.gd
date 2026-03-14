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
var player_moving: bool = false
var player_attacking: bool = false
var attack_cooldown: float = 0.0
var enemy_ai_timer: float = 0.0

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

func _process(delta: float) -> void:
    if not input_enabled:
        return
    
    _handle_input(delta)
    _update_game(delta)
    _update_animations(delta)

func _handle_input(delta: float) -> void:
    var direction = Vector2.ZERO
    player_moving = false
    
    if Input.is_action_pressed("move_up"):
        direction.y -= 1
        player_moving = true
    if Input.is_action_pressed("move_down"):
        direction.y += 1
        player_moving = true
    if Input.is_action_pressed("move_left"):
        direction.x -= 1
        player_moving = true
    if Input.is_action_pressed("move_right"):
        direction.x += 1
        player_moving = true
    
    # Attack cooldown
    if attack_cooldown > 0:
        attack_cooldown -= delta
    
    if direction.length() > 0:
        direction = direction.normalized()
        
        # Isometric movement
        var move_dir = _to_isometric(direction)
        player.velocity = move_dir * 150
        player.move_and_slide()
        
        # Face movement direction
        _set_player_facing(direction)
        
        # Update player entity in combat
        _update_player_entity()
    
    # Handle primary action (attack)
    if Input.is_action_just_pressed("primary_action") and attack_cooldown <= 0:
        _perform_attack()
    
    # Handle skill keys 1-8
    for i in range(8):
        if Input.is_action_just_pressed("skill_" + str(i + 1)):
            _use_skill(i)

func _update_animations(delta: float) -> void:
    # Player walking animation
    if player_moving:
        _animate_player_walk(delta)
    else:
        _animate_player_idle(delta)
    
    # Player attack animation
    if player_attacking:
        _animate_player_attack(delta)
    
    # Enemy AI and animations
    _update_enemy_ai(delta)

func _animate_player_walk(delta: float) -> void:
    # Bob up and down while walking
    var bob_amount = sin(Time.get_ticks_msec() * 0.015) * 3
    player.position.y += bob_amount * delta * 10

func _animate_player_idle(delta: float) -> void:
    # Gentle breathing animation
    var breath = sin(Time.get_ticks_msec() * 0.003) * 1
    player.scale = Vector2(1.0 + breath * 0.02, 1.0 - breath * 0.02)

func _animate_player_attack(delta: float) -> void:
    # Attack swing animation
    var swing = sin(Time.get_ticks_msec() * 0.05) * 0.3
    player.rotation = swing

func _set_player_facing(direction: Vector2) -> void:
    # Flip sprite based on movement direction
    if direction.x < 0:
        player.scale = Vector2(-1, 1)
    elif direction.x > 0:
        player.scale = Vector2(1, 1)

func _update_enemy_ai(delta: float) -> void:
    enemy_ai_timer += delta
    
    if enemy_ai_timer > 0.5:  # Update every 0.5 seconds
        enemy_ai_timer = 0
        
        for enemy in enemies.get_children():
            if not is_instance_valid(enemy):
                continue
                
            var dist = player.global_position.distance_to(enemy.global_position)
            
            # Enemy is close - attack player
            if dist < 60:
                _enemy_attack(enemy, delta)
            # Enemy is far - move towards player
            elif dist < 300:
                _enemy_move_towards_player(enemy, delta)
            
            # Animate enemy
            _animate_enemy(enemy, delta)

func _enemy_move_towards_player(enemy: Node2D, delta: float) -> void:
    var direction = (player.global_position - enemy.global_position).normalized()
    enemy.velocity = direction * 40  # Slower than player
    enemy.global_position += enemy.velocity * delta
    
    # Face player
    if direction.x < 0:
        enemy.scale = Vector2(-1, 1)
    else:
        enemy.scale = Vector2(1, 1)

func _enemy_attack(enemy: Node2D, delta: float) -> void:
    # Simple attack animation
    var attack_timer = enemy.get_meta("attack_timer", 0.0)
    attack_timer += delta
    enemy.set_meta("attack_timer", attack_timer)
    
    # Attack every 1 second
    if attack_timer > 1.0:
        enemy.set_meta("attack_timer", 0.0)
        
        # Get player data and damage
        var player_data = PlayerManager.get_current_player()
        if player_data:
            var damage = enemy.get_meta("damage", 5)
            player_data.current_hp -= damage
            
            # Flash player red
            player.modulate = Color(1.5, 0.3, 0.3)
            await get_tree().create_timer(0.2).timeout
            player.modulate = Color(1, 1, 1)
            
            # Update UI
            UIManager.update_hud()

func _animate_enemy(enemy: Node2D, delta: float) -> void:
    var dist = player.global_position.distance_to(enemy.global_position)
    
    if dist < 60:
        # Attack animation - shake
        var shake = sin(Time.get_ticks_msec() * 0.03) * 4
        enemy.position.y += shake * delta * 20
    elif dist < 300:
        # Walking animation - bob
        var bob = sin(Time.get_ticks_msec() * 0.01) * 2
        enemy.position.y += bob * delta * 10

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
    # Spawn different enemy types
    var enemy_types = [
        {"type": "orc", "pos": Vector2(400, 300)},
        {"type": "orc", "pos": Vector2(500, 200)},
        {"type": "skeleton", "pos": Vector2(350, 450)},
        {"type": "skeleton", "pos": Vector2(600, 400)},
        {"type": "zombie", "pos": Vector2(200, 500)},
        {"type": "zombie", "pos": Vector2(550, 350)},
    ]
    
    for e in enemy_types:
        var enemy = _create_enemy(e["type"], e["pos"])
        enemies.add_child(enemy)

func _create_enemy(enemy_type: String, position: Vector2) -> Node2D:
    var enemy = CharacterBody2D.new()
    enemy.position = position
    enemy.name = "Enemy"
    enemy.set_meta("type", enemy_type)
    
    # Create visual based on enemy type
    _create_enemy_visual(enemy, enemy_type)
    
    # Collision
    var collision = CollisionShape2D.new()
    collision.shape = CircleShape2D.new()
    collision.shape.radius = 14
    enemy.add_child(collision)
    
    # Enemy stats based on type
    match enemy_type:
        "orc":
            enemy.set_meta("hp", 80)
            enemy.set_meta("max_hp", 80)
            enemy.set_meta("damage", 15)
            enemy.set_meta("name", "Orc")
        "skeleton":
            enemy.set_meta("hp", 40)
            enemy.set_meta("max_hp", 40)
            enemy.set_meta("damage", 10)
            enemy.set_meta("name", "Skeleton")
        "zombie":
            enemy.set_meta("hp", 60)
            enemy.set_meta("max_hp", 60)
            enemy.set_meta("damage", 8)
            enemy.set_meta("name", "Zombie")
    
    return enemy

func _create_enemy_visual(enemy: Node2D, enemy_type: String) -> void:
    match enemy_type:
        "orc":
            # Body
            var body = ColorRect.new()
            body.size = Vector2(28, 32)
            body.position = Vector2(-14, -20)
            body.color = Color(0.2, 0.5, 0.2)  # Dark green
            enemy.add_child(body)
            
            # Head
            var head = ColorRect.new()
            head.size = Vector2(18, 18)
            head.position = Vector2(-9, -38)
            head.color = Color(0.3, 0.6, 0.3)  # Lighter green
            enemy.add_child(head)
            
            # Tusks
            var tusk_l = ColorRect.new()
            tusk_l.size = Vector2(4, 8)
            tusk_l.position = Vector2(-10, -22)
            tusk_l.color = Color(0.9, 0.8, 0.6)
            enemy.add_child(tusk_l)
            
            var tusk_r = ColorRect.new()
            tusk_r.size = Vector2(4, 8)
            tusk_r.position = Vector2(6, -22)
            tusk_r.color = Color(0.9, 0.8, 0.6)
            enemy.add_child(tusk_r)
            
            # Club
            var club = ColorRect.new()
            club.size = Vector2(6, 24)
            club.position = Vector2(14, -10)
            club.color = Color(0.4, 0.25, 0.1)  # Brown
            enemy.add_child(club)
            
            # Eyes
            var eye_l = ColorRect.new()
            eye_l.size = Vector2(4, 4)
            eye_l.position = Vector2(-7, -34)
            eye_l.color = Color(1, 0.2, 0.2)  # Red eyes
            enemy.add_child(eye_l)
            
            var eye_r = ColorRect.new()
            eye_r.size = Vector2(4, 4)
            eye_r.position = Vector2(3, -34)
            eye_r.color = Color(1, 0.2, 0.2)
            enemy.add_child(eye_r)
            
        "skeleton":
            # Ribcage body
            var body = ColorRect.new()
            body.size = Vector2(20, 28)
            body.position = Vector2(-10, -18)
            body.color = Color(0.85, 0.82, 0.75)  # Bone white
            enemy.add_child(body)
            
            # Ribs (dark lines)
            for i in range(4):
                var rib = ColorRect.new()
                rib.size = Vector2(18, 2)
                rib.position = Vector2(-9, -14 + i * 6)
                rib.color = Color(0.3, 0.3, 0.3)
                enemy.add_child(rib)
            
            # Skull
            var skull = ColorRect.new()
            skull.size = Vector2(20, 20)
            skull.position = Vector2(-10, -40)
            skull.color = Color(0.9, 0.87, 0.8)
            enemy.add_child(skull)
            
            # Eye sockets (dark)
            var socket_l = ColorRect.new()
            socket_l.size = Vector2(5, 6)
            socket_l.position = Vector2(-7, -36)
            socket_l.color = Color(0.1, 0.1, 0.1)
            enemy.add_child(socket_l)
            
            var socket_r = ColorRect.new()
            socket_r.size = Vector2(5, 6)
            socket_r.position = Vector2(2, -36)
            socket_r.color = Color(0.1, 0.1, 0.1)
            enemy.add_child(socket_r)
            
            # Jaw
            var jaw = ColorRect.new()
            jaw.size = Vector2(14, 6)
            jaw.position = Vector2(-7, -22)
            jaw.color = Color(0.8, 0.77, 0.7)
            enemy.add_child(jaw)
            
            # Teeth
            for i in range(3):
                var tooth = ColorRect.new()
                tooth.size = Vector2(3, 4)
                tooth.position = Vector2(-5 + i * 4, -22)
                tooth.color = Color(0.95, 0.92, 0.85)
                enemy.add_child(tooth)
            
        "zombie":
            # Body (tattered)
            var body = ColorRect.new()
            body.size = Vector2(24, 30)
            body.position = Vector2(-12, -18)
            body.color = Color(0.25, 0.35, 0.2)  # Rotten green
            enemy.add_child(body)
            
            # Torn clothes effect
            var clothes = ColorRect.new()
            clothes.size = Vector2(22, 20)
            clothes.position = Vector2(-11, -8)
            clothes.color = Color(0.2, 0.15, 0.15)  # Dark brown tatters
            enemy.add_child(clothes)
            
            # Head
            var head = ColorRect.new()
            head.size = Vector2(18, 18)
            head.position = Vector2(-9, -36)
            head.color = Color(0.3, 0.45, 0.25)  # Sickly green
            enemy.add_child(head)
            
            # Missing eye
            var missing_eye = ColorRect.new()
            missing_eye.size = Vector2(5, 5)
            missing_eye.position = Vector2(-6, -32)
            missing_eye.color = Color(0.1, 0.05, 0.05)  # Dark hole
            enemy.add_child(missing_eye)
            
            # Bulging eye
            var eye = ColorRect.new()
            eye.size = Vector2(5, 5)
            eye.position = Vector2(2, -33)
            eye.color = Color(0.9, 0.9, 0.3)  # Yellow eye
            enemy.add_child(eye)
            
            # Drooling mouth
            var mouth = ColorRect.new()
            mouth.size = Vector2(8, 3)
            mouth.position = Vector2(-4, -24)
            mouth.color = Color(0.4, 0.2, 0.2)
            enemy.add_child(mouth)
            
            var drool = ColorRect.new()
            drool.size = Vector2(3, 6)
            drool.position = Vector2(0, -21)
            drool.color = Color(0.6, 0.8, 0.5)
            enemy.add_child(drool)
            
            # Arms sticking out
            var arm_l = ColorRect.new()
            arm_l.size = Vector2(16, 6)
            arm_l.position = Vector2(-20, -12)
            arm_l.color = Color(0.28, 0.4, 0.22)
            enemy.add_child(arm_l)
            
            var arm_r = ColorRect.new()
            arm_r.size = Vector2(16, 6)
            arm_r.position = Vector2(4, -10)
            arm_r.color = Color(0.28, 0.4, 0.22)
            enemy.add_child(arm_r)

func _create_player_character(player_data) -> void:
    player = CharacterBody2D.new()
    player.name = "Player"
    player.position = Vector2(300, 300)  # Start in town
    player.set_meta("class", GameManager.selected_class)
    
    # Create visual based on selected class
    _create_player_visual(player, GameManager.selected_class)
    
    # Collision
    var collision = CollisionShape2D.new()
    collision.shape = CircleShape2D.new()
    collision.shape.radius = 14
    player.add_child(collision)
    
    # Add camera
    camera = Camera2D.new()
    camera.name = "Camera"
    camera.zoom = Vector2(1.5, 1.5)
    player.add_child(camera)
    
    add_child(player)

func _create_player_visual(player: Node2D, char_class: int) -> void:
    # Body armor
    var body = ColorRect.new()
    body.size = Vector2(22, 26)
    body.position = Vector2(-11, -16)
    
    match char_class:
        0:  # Marauder
            body.color = Color(0.6, 0.3, 0.2)  # Brown leather
        1:  # Sorceress
            body.color = Color(0.3, 0.3, 0.6)  # Blue robes
        2:  # Shadow
            body.color = Color(0.2, 0.2, 0.3)  # Dark leather
        3:  # Necromancer
            body.color = Color(0.3, 0.25, 0.3)  # Dark purple robes
        4:  # Paladin
            body.color = Color(0.7, 0.6, 0.2)  # Golden armor
    player.add_child(body)
    
    # Head
    var head = ColorRect.new()
    head.size = Vector2(16, 16)
    head.position = Vector2(-8, -32)
    head.color = Color(0.9, 0.75, 0.6)  # Skin tone
    player.add_child(head)
    
    # Hair/Helm
    var hair = ColorRect.new()
    hair.size = Vector2(18, 8)
    hair.position = Vector2(-9, -40)
    match char_class:
        0: hair.color = Color(0.3, 0.2, 0.1)  # Brown hair
        1: hair.color = Color(0.8, 0.8, 0.9)  # White wizard hat area
        2: hair.color = Color(0.1, 0.1, 0.1)  # Black
        3: hair.color = Color(0.2, 0.1, 0.2)  # Dark purple
        4: hair.color = Color(0.8, 0.7, 0.3)  # Golden
    player.add_child(hair)
    
    # Eyes
    var eye_l = ColorRect.new()
    eye_l.size = Vector2(3, 3)
    eye_l.position = Vector2(-5, -29)
    eye_l.color = Color(0.2, 0.4, 0.8)  # Blue eyes
    player.add_child(eye_l)
    
    var eye_r = ColorRect.new()
    eye_r.size = Vector2(3, 3)
    eye_r.position = Vector2(2, -29)
    eye_r.color = Color(0.2, 0.4, 0.8)
    player.add_child(eye_r)
    
    # Weapon based on class
    match char_class:
        0:  # Marauder - sword
            var sword = ColorRect.new()
            sword.size = Vector2(4, 28)
            sword.position = Vector2(12, -12)
            sword.color = Color(0.7, 0.7, 0.75)  # Steel
            player.add_child(sword)
            
            var hilt = ColorRect.new()
            hilt.size = Vector2(8, 4)
            hilt.position = Vector2(10, 14)
            hilt.color = Color(0.5, 0.3, 0.1)  # Brown
            player.add_child(hilt)
            
        1:  # Sorceress - staff
            var staff = ColorRect.new()
            staff.size = Vector2(4, 50)
            staff.position = Vector2(14, -30)
            staff.color = Color(0.4, 0.25, 0.1)  # Wood
            player.add_child(staff)
            
            var orb = ColorRect.new()
            orb.size = Vector2(8, 8)
            orb.position = Vector2(12, -38)
            orb.color = Color(0.3, 0.5, 0.9)  # Magic orb
            player.add_child(orb)
            
        2:  # Shadow - dual daggers
            var dagger_l = ColorRect.new()
            dagger_l.size = Vector2(3, 16)
            dagger_l.position = Vector2(-16, -8)
            dagger_l.color = Color(0.5, 0.5, 0.55)
            player.add_child(dagger_l)
            
            var dagger_r = ColorRect.new()
            dagger_r.size = Vector2(3, 16)
            dagger_r.position = Vector2(13, -8)
            dagger_r.color = Color(0.5, 0.5, 0.55)
            player.add_child(dagger_r)
            
        3:  # Necromancer - staff with skull
            var staff = ColorRect.new()
            staff.size = Vector2(4, 50)
            staff.position = Vector2(14, -30)
            staff.color = Color(0.25, 0.2, 0.15)
            player.add_child(staff)
            
            var skull = ColorRect.new()
            skull.size = Vector2(8, 8)
            skull.position = Vector2(12, -38)
            skull.color = Color(0.85, 0.82, 0.75)
            player.add_child(skull)
            
        4:  # Paladin - shield + mace
            var shield = ColorRect.new()
            shield.size = Vector2(14, 18)
            shield.position = Vector2(-20, -12)
            shield.color = Color(0.7, 0.6, 0.2)  # Gold shield
            player.add_child(shield)
            
            var mace = ColorRect.new()
            mace.size = Vector2(4, 24)
            mace.position = Vector2(12, -10)
            mace.color = Color(0.6, 0.6, 0.65)
            player.add_child(mace)

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
