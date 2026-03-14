## PlayerManager.gd
## Manages player characters and their data

extends Node

signal player_created(player_id: int, class_type: String)
signal player_level_up(player_id: int, new_level: int)
signal player_stats_changed(player_id: int)

enum CharacterClass {
    MARAUDER,
    SORCERESS,
    SHADOW,
    NECROMANCER,
    PALADIN
}

const MAX_LEVEL: int = 99

var players: Dictionary = {}
var current_player_id: int = 0

# Base stat growth per class
const CLASS_BASE_STATS = {
    CharacterClass.MARAUDER: {
        "str": 30, "dex": 20, "vit": 25, "ene": 10,
        "hp": 120, "mp": 60, "stamina": 100
    },
    CharacterClass.SORCERESS: {
        "str": 10, "dex": 25, "vit": 15, "ene": 35,
        "hp": 80, "mp": 140, "stamina": 80
    },
    CharacterClass.SHADOW: {
        "str": 20, "dex": 30, "vit": 20, "ene": 20,
        "hp": 100, "mp": 100, "stamina": 90
    },
    CharacterClass.NECROMANCER: {
        "str": 15, "dex": 15, "vit": 20, "ene": 30,
        "hp": 90, "mp": 120, "stamina": 85
    },
    CharacterClass.PALADIN: {
        "str": 25, "dex": 20, "vit": 25, "ene": 25,
        "hp": 110, "mp": 100, "stamina": 95
    }
}

class PlayerData:
    var player_id: int
    var name: String
    var char_class: CharacterClass
    var level: int = 1
    var experience: int = 0
    var gold: int = 0
    
    # Core stats
    var strength: int
    var dexterity: int
    var vitality: int
    var energy: int
    
    # Current values
    var current_hp: int
    var current_mp: int
    var current_stamina: int
    
    # Derived stats (calculated from base + gear + skills)
    var max_hp: int
    var max_mp: int
    var max_stamina: int
    var defense: int = 0
    var attack_rating: int = 0
    var enhanced_damage: int = 0
    
    # Resistances
    var fire_resist: int = 0
    var cold_resist: int = 0
    var lightning_resist: int = 0
    var poison_resist: int = 0
    
    # Combat
    var critical_hit_chance: float = 0.0
    var life_leech: float = 0.0
    var mana_leech: float = 0.0
    
    # Skill points
    var skill_points: int = 0
    
    # Inventory reference
    var inventory: Inventory
    var stash: Inventory
    var equipped: Dictionary = {}  # slot -> ItemData
    
    func _init(class_type: CharacterClass, player_name: String):
        player_id = GlobalUniqueId.next()
        name = player_name
        char_class = class_type
        inventory = Inventory.new(16, 6)  # 16 cols, 6 rows
        stash = Inventory.new(16, 6)
        _initialize_stats()
    
    func _initialize_stats() -> void:
        var base = PlayerManager.CLASS_BASE_STATS[char_class]
        strength = base["str"]
        dexterity = base["dex"]
        vitality = base["vit"]
        energy = base["ene"]
        
        current_hp = base["hp"]
        current_mp = base["mp"]
        current_stamina = base["stamina"]
        
        max_hp = current_hp
        max_mp = current_mp
        max_stamina = current_stamina
        
        skill_points = 0
    
    func add_experience(amount: int) -> bool:
        if level >= PlayerManager.MAX_LEVEL:
            return false
        
        experience += amount
        var exp_needed = get_experience_for_next_level()
        
        while experience >= exp_needed and level < PlayerManager.MAX_LEVEL:
            experience -= exp_needed
            level_up()
            exp_needed = get_experience_for_next_level()
        
        return true
    
    func level_up() -> void:
        level += 1
        skill_points += 1
        
        # Apply stat growth
        var hp_growth = 0
        var mp_growth = 0
        
        match char_class:
            CharacterClass.MARAUDER:
                hp_growth = 12
                mp_growth = 3
            CharacterClass.SORCERESS:
                hp_growth = 5
                mp_growth = 15
            CharacterClass.SHADOW:
                hp_growth = 8
                mp_growth = 8
            CharacterClass.NECROMANCER:
                hp_growth = 7
                mp_growth = 10
            CharacterClass.PALADIN:
                hp_growth = 10
                mp_growth = 8
        
        max_hp += hp_growth
        max_mp += mp_growth
        current_hp = max_hp
        current_mp = max_mp
        
        PlayerManager.player_level_up.emit(player_id, level)
    
    func get_experience_for_next_level() -> int:
        # D2-style exp curve
        return int(pow(level, 3) * 0.5) + 500

class GlobalUniqueId:
    static var _counter: int = 0
    
    static func next() -> int:
        _counter += 1
        return _counter

class Inventory:
    var cols: int
    var rows: int
    var slots: Array = []  # 2D array of ItemData or null
    
    func _init(c: int, r: int):
        cols = c
        rows = r
        slots.resize(cols * rows)
        slots.fill(null)
    
    func get_item(x: int, y: int) -> ItemData:
        if x < 0 or x >= cols or y < 0 or y >= rows:
            return null
        return slots[y * cols + x]
    
    func set_item(x: int, y: int, item: ItemData) -> bool:
        if x < 0 or x >= cols or y < 0 or y >= rows:
            return false
        slots[y * cols + x] = item
        return true
    
    func find_free_space(width: int, height: int) -> Vector2i:
        for y in range(rows - height + 1):
            for x in range(cols - width + 1):
                if _can_place(x, y, width, height):
                    return Vector2i(x, y)
        return Vector2i(-1, -1)
    
    func _can_place(x: int, y: int, w: int, h: int) -> bool:
        for dy in range(h):
            for dx in range(w):
                if get_item(x + dx, y + dy) != null:
                    return false
        return true

class ItemData:
    var item_id: String
    var name: String
    var rarity: int  # 0=white, 1=blue, 2=yellow, 3=green, 4=gold, 5=orange
    var item_level: int = 1
    var width: int = 1
    var height: int = 1
    var sockets: int = 0
    var socketed_items: Array = []
    var affixes: Array = []
    var base_type: String = ""
    var damage_min: int = 0
    var damage_max: int = 0
    var defense: int = 0
    var required_level: int = 1
    var required_strength: int = 0
    var required_dexterity: int = 0
    
    # Stats
    var str_bonus: int = 0
    var dex_bonus: int = 0
    var vit_bonus: int = 0
    var ene_bonus: int = 0
    var hp_bonus: int = 0
    var mp_bonus: int = 0
    
    var fire_resist: int = 0
    var cold_resist: int = 0
    var lightning_resist: int = 0
    var poison_resist: int = 0
    
    var enhanced_damage: int = 0
    var attack_rating: int = 0
    var critical_chance: float = 0.0
    var life_leech: float = 0.0
    var mana_leech: float = 0.0
    
    var skill_bonuses: Dictionary = {}  # skill_name -> +level
    
    func _init(id: String, item_name: String):
        item_id = id
        name = item_name

func create_player(class_type: CharacterClass, player_name: String = "Hero") -> PlayerData:
    var player = PlayerData.new(class_type, player_name)
    players[player.player_id] = player
    
    if current_player_id == 0:
        current_player_id = player.player_id
    
    player_created.emit(player.player_id, CharacterClass.keys()[class_type])
    return player

func get_current_player() -> PlayerData:
    return players.get(current_player_id)

func get_player(id: int) -> PlayerData:
    return players.get(id)

func set_current_player(id: int) -> void:
    if players.has(id):
        current_player_id = id

func delete_player(id: int) -> void:
    players.erase(id)
    if current_player_id == id:
        current_player_id = players.keys()[0] if players.size() > 0 else 0
