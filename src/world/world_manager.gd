## WorldManager.gd
## Handles world/level generation and zone management

extends Node

signal zone_entered(zone_id: String)
signal level_generated(level_id: String)
signal entity_spawned(entity)

# Tile types
enum TileType {
    FLOOR = 0,
    WALL = 1,
    DOOR = 2,
    STAIRS_UP = 3,
    STAIRS_DOWN = 4,
    WATER = 5,
    LAVA = 6,
    TELEPORT = 7,
    EXIT = 8,
    CHEST = 9,
    PROP = 10
}

# Biome types
enum Biome {
    TOWN = 0,
    FOREST = 1,
    DESERT = 2,
    JUNGLE = 3,
    CAVE = 4,
    DUNGEON = 5,
    HELL = 6,
    CRYPT = 7
}

# Zone types
enum ZoneType {
    TOWN,
    WILDERNESS,
    DUNGEON,
    BOSS_LAIR
}

class ZoneData:
    var zone_id: String
    var name: String
    var biome: Biome
    var zone_type: ZoneType
    var level: int
    var width: int
    var height: int
    var tiles: Array = []  # 2D array of TileType
    var entities: Array = []  # Spawned entities
    var connected_zones: Array = []  # Adjacent zone IDs
    var is_indoor: bool
    
    func _init(zid: String, n: String, b: Biome, zt: ZoneType, lvl: int, w: int, h: int):
        zone_id = zid
        name = n
        biome = b
        zone_type = zt
        level = lvl
        width = w
        height = h
        tiles.resize(w * h)
        tiles.fill(TileType.FLOOR)

class LevelTile:
    var type: TileType
    var x: int
    var y: int
    var walkable: bool = true
    var blocks_sight: bool = false
    var decoration: int = 0
    var variant: int = 0
    
    func _init(tx: int, ty: int, ttype: TileType):
        x = tx
        y = ty
        type = ttype
        _update_properties()
    
    func _update_properties():
        match type:
            TileType.FLOOR, TileType.WATER:
                walkable = type == TileType.FLOOR
                blocks_sight = false
            TileType.WALL:
                walkable = false
                blocks_sight = true
            TileType.DOOR:
                walkable = true
                blocks_sight = false
            TileType.STAIRS_UP, TileType.STAIRS_DOWN:
                walkable = true
                blocks_sight = false
            TileType.LAVA:
                walkable = false
                blocks_sight = false

var current_zone: ZoneData = null
var zones: Dictionary = {}  # zone_id -> ZoneData
var world_seed: int = 0
var current_act: int = 1

# Generation parameters
const TILE_SIZE: int = 64
const MIN_ROOM_SIZE: int = 4
const MAX_ROOM_SIZE: int = 10
const ROOM_ATTEMPTS: int = 50

func _ready() -> void:
    randomize()
    world_seed = randi()

func generate_world(act: int) -> void:
    current_act = act
    world_seed = randi()
    seed(world_seed)
    
    zones.clear()
    
    match act:
        1:
            _generate_act_1()
        2:
            _generate_act_2()
        3:
            _generate_act_3()
        4:
            _generate_act_4()
        5:
            _generate_act_5()

func _generate_act_1() -> void:
    # Act 1: Wilderness -> Town -> Cave -> Crypt -> Boss
    var town = _create_zone("town", "Rogue Encampment", Biome.TOWN, ZoneType.TOWN, 1, 30, 30)
    var wilderness = _create_zone("wilderness_1", "Blood Moor", Biome.FOREST, ZoneType.WILDERNESS, 1, 40, 40)
    var cave = _create_zone("cave_1", "Cold Plains", Biome.CAVE, ZoneType.DUNGEON, 2, 30, 30)
    var crypt = _create_zone("crypt_1", "Burial Grounds", Biome.CRYPT, ZoneType.DUNGEON, 3, 25, 25)
    var boss = _create_zone("boss_1", "The Pit", Biome.CRYPT, ZoneType.BOSS_LAIR, 4, 20, 20)
    
    _connect_zones(town, wilderness)
    _connect_zones(wilderness, cave)
    _connect_zones(cave, crypt)
    _connect_zones(crypt, boss)
    
    _spawn_monsters_for_zone(wilderness, 1)
    _spawn_monsters_for_zone(cave, 2)
    _spawn_monsters_for_zone(crypt, 3)
    _spawn_boss(boss, "den_of_evil")

func _generate_act_2() -> void:
    var town = _create_zone("town_2", "Lut Gholein", Biome.TOWN, ZoneType.TOWN, 1, 30, 30)
    var desert = _create_zone("desert_1", "Sewers", Biome.DESERT, ZoneType.WILDERNESS, 5, 40, 40)
    var temple = _create_zone("temple_1", "Dry Hills", Biome.DESERT, ZoneType.DUNGEON, 6, 30, 30)
    var ruins = _create_zone("ruins_1", "Far Oasis", Biome.DESERT, ZoneType.DUNGEON, 7, 25, 25)
    var boss = _create_zone("boss_2", "Arcane Sanctuary", Biome.DESERT, ZoneType.BOSS_LAIR, 8, 20, 20)
    
    _connect_zones(town, desert)
    _connect_zones(desert, temple)
    _connect_zones(temple, ruins)
    _connect_zones(ruins, boss)
    
    _spawn_monsters_for_zone(desert, 5)
    _spawn_monsters_for_zone(temple, 6)
    _spawn_monsters_for_zone(ruins, 7)
    _spawn_boss(boss, "summoner")

func _generate_act_3() -> void:
    var town = _create_zone("town_3", "Kurast", Biome.JUNGLE, ZoneType.TOWN, 1, 30, 30)
    var jungle = _create_zone("jungle_1", "Spider Forest", Biome.JUNGLE, ZoneType.WILDERNESS, 10, 40, 40)
    var temple = _create_zone("temple_2", "Spider Cave", Biome.JUNGLE, ZoneType.DUNGEON, 11, 30, 30)
    var ruins = _create_zone("ruins_2", "Flayer Dungeon", Biome.JUNGLE, ZoneType.DUNGEON, 12, 25, 25)
    var boss = _create_zone("boss_3", "Durance of Hate", Biome.JUNGLE, ZoneType.BOSS_LAIR, 13, 20, 20)
    
    _connect_zones(town, jungle)
    _connect_zones(jungle, temple)
    _connect_zones(temple, ruins)
    _connect_zones(ruins, boss)
    
    _spawn_monsters_for_zone(jungle, 10)
    _spawn_monsters_for_zone(temple, 11)
    _spawn_monsters_for_zone(ruins, 12)
    _spawn_boss(boss, "mephisto")

func _generate_act_4() -> void:
    var town = _create_zone("town_4", "Pandemonium Fortress", Biome.HELL, ZoneType.TOWN, 1, 30, 30)
    var fortress = _create_zone("fortress_1", "Outer Steppes", Biome.HELL, ZoneType.WILDERNESS, 20, 40, 40)
    var city = _create_zone("city_1", "City of the Damned", Biome.HELL, ZoneType.DUNGEON, 21, 35, 35)
    var chaos = _create_zone("chaos_1", "River of Flame", Biome.HELL, ZoneType.BOSS_LAIR, 22, 25, 25)
    
    _connect_zones(town, fortress)
    _connect_zones(fortress, city)
    _connect_zones(city, chaos)
    
    _spawn_monsters_for_zone(fortress, 20)
    _spawn_monsters_for_zone(city, 21)
    _spawn_boss(chaos, "diablo")

func _generate_act_5() -> void:
    var town = _create_zone("town_5", "Harrogath", Biome.HELL, ZoneType.TOWN, 1, 30, 30)
    var mountains = _create_zone("mountains_1", "Bloody Foothills", Biome.HELL, ZoneType.WILDERNESS, 30, 40, 40)
    var baal = _create_zone("baal_1", "Arreat Summit", Biome.HELL, ZoneType.BOSS_LAIR, 31, 30, 30)
    var chaos = _create_zone("chaos_2", "Worldstone Keep", Biome.HELL, ZoneType.BOSS_LAIR, 32, 25, 25)
    
    _connect_zones(town, mountains)
    _connect_zones(mountains, baal)
    _connect_zones(baal, chaos)
    
    _spawn_monsters_for_zone(mountains, 30)
    _spawn_boss(baal, "baal")

func _create_zone(zid: String, name: String, biome: Biome, ztype: ZoneType, lvl: int, w: int, h: int) -> ZoneData:
    var zone = ZoneData.new(zid, name, biome, ztype, lvl, w, h)
    zone.is_indoor = ztype != ZoneType.WILDERNESS
    
    # Generate tiles based on type
    if ztype == ZoneType.TOWN:
        _generate_town_tiles(zone)
    elif ztype == ZoneType.WILDERNESS:
        _generate_wilderness_tiles(zone)
    else:
        _generate_dungeon_tiles(zone)
    
    zones[zid] = zone
    return zone

func _connect_zones(zone_a: ZoneData, zone_b: ZoneData) -> void:
    zone_a.connected_zones.append(zone_b.zone_id)
    zone_b.connected_zones.append(zone_a.zone_id)

func _generate_town_tiles(zone: ZoneData) -> void:
    # Towns have a simple grid layout with walls around edges
    for y in range(zone.height):
        for x in range(zone.width):
            if x == 0 or x == zone.width - 1 or y == 0 or y == zone.height - 1:
                zone.tiles[y * zone.width + x] = TileType.WALL
            else:
                zone.tiles[y * zone.width + x] = TileType.FLOOR
    
    # Add some building footprints (walls)
    _add_town_buildings(zone)

func _add_town_buildings(zone: ZoneData) -> void:
    # Add NPC area in center
    var cx = zone.width / 2
    var cy = zone.height / 2
    
    # Create a building footprint
    for y in range(cy - 3, cy + 3):
        for x in range(cx - 4, cx + 5):
            if x == cx - 4 or x == cx + 4 or y == cy - 3 or y == cy + 2:
                zone.tiles[y * zone.width + x] = TileType.WALL

func _generate_wilderness_tiles(zone: ZoneData) -> void:
    # Wilderness uses cellular automata for natural-looking areas
    _initialize_random_tiles(zone, 0.45)
    _run_cellular_automata(zone, 4)
    _ensure_connectivity(zone)
    
    # Add some paths
    _add_wilderness_paths(zone)

func _generate_dungeon_tiles(zone: ZoneData) -> void:
    # Dungeons use room-and-corridor generation
    _generate_room_dungeon(zone)

func _initialize_random_tiles(zone: ZoneData, fill_prob: float) -> void:
    for i in range(zone.tiles.size()):
        zone.tiles[i] = TileType.FLOOR if randf() < fill_prob else TileType.WALL

func _run_cellular_automata(zone: ZoneData, iterations: int) -> void:
    for _iter in range(iterations):
        var new_tiles = zone.tiles.duplicate()
        
        for y in range(1, zone.height - 1):
            for x in range(1, zone.width - 1):
                var neighbors = _count_wall_neighbors(zone, x, y)
                var idx = y * zone.width + x
                
                if neighbors > 4:
                    new_tiles[idx] = TileType.WALL
                elif neighbors < 4:
                    new_tiles[idx] = TileType.FLOOR
        
        zone.tiles = new_tiles

func _count_wall_neighbors(zone: ZoneData, x: int, y: int) -> int:
    var count = 0
    for dy in range(-1, 2):
        for dx in range(-1, 2):
            if dx == 0 and dy == 0:
                continue
            var nx = x + dx
            var ny = y + dy
            if nx < 0 or nx >= zone.width or ny < 0 or ny >= zone.height:
                count += 1
            elif zone.tiles[ny * zone.width + nx] == TileType.WALL:
                count += 1
    return count

func _generate_room_dungeon(zone: ZoneData) -> void:
    # Start with all walls
    zone.tiles.fill(TileType.WALL)
    
    var rooms: Array = []
    var corridors: Array = []
    
    # Try to place rooms
    for _i in range(ROOM_ATTEMPTS):
        var w = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
        var h = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
        var x = randi_range(1, zone.width - w - 1)
        var y = randi_range(1, zone.height - h - 1)
        
        var new_room = Rect2i(x, y, w, h)
        
        # Check overlap
        var overlaps = false
        for room in rooms:
            if new_room.grow(1).intersects(room):
                overlaps = true
                break
        
        if not overlaps:
            rooms.append(new_room)
            _carve_room(zone, new_room)
            
            # Connect to previous room
            if rooms.size() > 1:
                var prev_room = rooms[rooms.size() - 2]
                _carve_corridor(zone, prev_room.get_center(), new_room.get_center())
    
    # Add stairs
    if rooms.size() >= 2:
        _add_stairs(zone, rooms[0], true)  # Up
        _add_stairs(zone, rooms[rooms.size() - 1], false)  # Down

func _carve_room(zone: ZoneData, room: Rect2i) -> void:
    for y in range(room.position.y, room.position.y + room.size.y):
        for x in range(room.position.x, room.position.x + room.size.x):
            zone.tiles[y * zone.width + x] = TileType.FLOOR

func _carve_corridor(zone: ZoneData, from: Vector2i, to: Vector2i) -> void:
    # L-shaped corridor
    var x = from.x
    var y = from.y
    
    # Horizontal first
    var dx = sign(to.x - x)
    while x != to.x:
        zone.tiles[y * zone.width + x] = TileType.FLOOR
        x += dx
    
    # Then vertical
    var dy = sign(to.y - y)
    while y != to.y:
        zone.tiles[y * zone.width + x] = TileType.FLOOR
        y += dy

func _add_stairs(zone: ZoneData, room: Rect2i, up: bool) -> void:
    var center = room.get_center()
    var stair_type = TileType.STAIRS_UP if up else TileType.STAIRS_DOWN
    zone.tiles[center.y * zone.width + center.x] = stair_type

func _ensure_connectivity(zone: ZoneData) -> void:
    # Simple flood fill to find unconnected areas
    var visited: Array = []
    visited.resize(zone.tiles.size())
    visited.fill(false)
    
    var queue: Array = []
    
    # Find first floor tile
    var start_idx = -1
    for i in range(zone.tiles.size()):
        if zone.tiles[i] == TileType.FLOOR:
            start_idx = i
            break
    
    if start_idx == -1:
        return
    
    queue.append(start_idx)
    visited[start_idx] = true
    
    # Flood fill
    while queue.size() > 0:
        var idx = queue.pop_front()
        var x = idx % zone.width
        var y = idx / zone.width
        
        # Check neighbors
        for dx in [-1, 0, 1]:
            for dy in [-1, 0, 1]:
                if dx == 0 and dy == 0:
                    continue
                var nx = x + dx
                var ny = y + dy
                if nx >= 0 and nx < zone.width and ny >= 0 and ny < zone.height:
                    var nidx = ny * zone.width + nx
                    if not visited[nidx] and zone.tiles[nidx] == TileType.FLOOR:
                        visited[nidx] = true
                        queue.append(nidx)
    
    # Convert unconnected floors to walls (creates islands)
    for i in range(zone.tiles.size()):
        if zone.tiles[i] == TileType.FLOOR and not visited[i]:
            zone.tiles[i] = TileType.WALL

func _add_wilderness_paths(zone: ZoneData) -> void:
    # Add winding paths through the wilderness
    var num_paths = randi_range(2, 4)
    
    for _i in range(num_paths):
        var x = randi_range(2, zone.width - 3)
        var y = 2
        
        while y < zone.height - 2:
            zone.tiles[y * zone.width + x] = TileType.FLOOR
            zone.tiles[y * zone.width + x + 1] = TileType.FLOOR
            
            # Random walk
            x += randi_range(-1, 1)
            x = clamp(x, 2, zone.width - 3)
            y += randi_range(0, 2)

# Zone management
func enter_zone(zone_id: String) -> bool:
    if not zones.has(zone_id):
        return false
    
    current_zone = zones[zone_id]
    zone_entered.emit(zone_id)
    return true

func get_tile(x: int, y: int) -> TileType:
    if not current_zone:
        return TileType.WALL
    if x < 0 or x >= current_zone.width or y < 0 or y >= current_zone.height:
        return TileType.WALL
    return current_zone.tiles[y * current_zone.width + x]

func is_walkable(x: int, y: int) -> bool:
    var tile = get_tile(x, y)
    match tile:
        TileType.FLOOR, TileType.STAIRS_UP, TileType.STAIRS_DOWN, TileType.DOOR:
            return true
        TileType.WATER:
            return false  # Could add swimming later
    return false

func is_sight_blocked(x: int, y: int) -> bool:
    var tile = get_tile(x, y)
    return tile == TileType.WALL

# Pathfinding (A*)
func find_path(start: Vector2i, end: Vector2i) -> Array:
    if not current_zone:
        return []
    
    var open_set: Array = [start]
    var came_from: Dictionary = {}
    var g_score: Dictionary = {start: 0}
    var f_score: Dictionary = {start: _heuristic(start, end)}
    
    while open_set.size() > 0:
        # Get node with lowest f_score
        var current = open_set[0]
        var current_f = f_score.get(current, 999999)
        for node in open_set:
            var f = f_score.get(node, 999999)
            if f < current_f:
                current = node
                current_f = f
        
        if current == end:
            return _reconstruct_path(came_from, current)
        
        open_set.erase(current)
        
        # Check neighbors
        for neighbor in _get_neighbors(current):
            var tentative_g = g_score.get(current, 999999) + 1
            
            if tentative_g < g_score.get(neighbor, 999999):
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + _heuristic(neighbor, end)
                
                if not neighbor in open_set:
                    open_set.append(neighbor)
    
    return []  # No path found

func _heuristic(a: Vector2i, b: Vector2i) -> int:
    return abs(a.x - b.x) + abs(a.y - b.y)

func _get_neighbors(pos: Vector2i) -> Array:
    var result: Array = []
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue
            var nx = pos.x + dx
            var ny = pos.y + dy
            if is_walkable(nx, ny):
                result.append(Vector2i(nx, ny))
    return result

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
    var path: Array = [current]
    while current in came_from:
        current = came_from[current]
        path.push_front(current)
    return path

# Monster spawning
func _spawn_monsters_for_zone(zone: ZoneData, level: int) -> void:
    var num_packs = randi_range(3, 8)
    
    for _i in range(num_packs):
        var pos = _find_random_floor(zone)
        if pos.x >= 0:
            var monster_data = _get_random_monster(level)
            zone.entities.append({
                "type": "monster",
                "data": monster_data,
                "position": pos,
                "level": level
            })

func _spawn_boss(zone: ZoneData, boss_id: String) -> void:
    var pos = _find_random_floor(zone)
    if pos.x >= 0:
        var boss_data = _get_boss_data(boss_id)
        zone.entities.append({
            "type": "boss",
            "data": boss_data,
            "position": pos,
            "level": zone.level
        })

func _find_random_floor(zone: ZoneData) -> Vector2i:
    var attempts = 0
    while attempts < 100:
        var x = randi_range(1, zone.width - 2)
        var y = randi_range(1, zone.height - 2)
        if zone.tiles[y * zone.width + x] == TileType.FLOOR:
            return Vector2i(x, y)
        attempts += 1
    return Vector2i(-1, -1)

func _get_random_monster(level: int) -> Dictionary:
    var monsters = [
        {"name": "Fallen", "hp": 8, "ar": 5, "def": 0, "dmg_min": 2, "dmg_max": 4, "exp": 5},
        {"name": "Carver", "hp": 12, "ar": 8, "def": 2, "dmg_min": 3, "dmg_max": 6, "exp": 8},
        {"name": "Dark Ranger", "hp": 15, "ar": 12, "def": 0, "dmg_min": 4, "dmg_max": 8, "exp": 12},
        {"name": "Dark Spear", "hp": 18, "ar": 10, "def": 4, "dmg_min": 5, "dmg_max": 10, "exp": 15},
        {"name": "Hill Rat", "hp": 20, "ar": 8, "def": 2, "dmg_min": 4, "dmg_max": 9, "exp": 10},
        {"name": "Gorilla", "hp": 25, "ar": 15, "def": 5, "dmg_min": 6, "dmg_max": 12, "exp": 18},
    ]
    var monster = monsters[randi() % monsters.size()].duplicate()
    monster["level"] = level
    return monster

func _get_boss_data(boss_id: String) -> Dictionary:
    var bosses = {
        "den_of_evil": {"name": "Andariel", "hp": 400, "ar": 80, "def": 20, "dmg_min": 15, "dmg_max": 30, "skills": ["poison_nova", "constrict"]},
        "summoner": {"name": "Duriel", "hp": 800, "ar": 100, "def": 30, "dmg_min": 20, "dmg_max": 40, "skills": ["cold_nova", "charge"]},
        "mephisto": {"name": "Mephisto", "hp": 1200, "ar": 120, "def": 40, "dmg_min": 25, "dmg_max": 50, "skills": ["hydra", "lightning_nova"]},
        "diablo": {"name": "Diablo", "hp": 2000, "ar": 150, "def": 50, "dmg_min": 35, "dmg_max": 70, "skills": ["fire_nova", "lightning", "teleporter"]},
        "baal": {"name": "Baal", "hp": 3000, "ar": 180, "def": 60, "dmg_min": 40, "dmg_max": 80, "skills": ["cold_wave", "summon", "curse"]},
    }
    var boss = bosses.get(boss_id, bosses["den_of_evil"]).duplicate()
    return boss

func get_zone(zone_id: String) -> ZoneData:
    return zones.get(zone_id)

func get_current_zone() -> ZoneData:
    return current_zone
