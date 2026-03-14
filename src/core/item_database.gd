## ItemDatabase.gd
## Database for all items, loot generation, and item definitions

extends Node

enum ItemType {
    SWORD, AXE, MACE, STAFF, DAGGER, BOW,
    HELM, CHEST, SHIELD, GLOVES, BOOTS, BELT,
    RING, AMULET, CHARM, POTION, SCROLL, GEM
}

enum Rarity {
    NORMAL = 0
    MAGIC = 1
    RARE = 2
    SET = 3
    UNIQUE = 4
    RUNE = 5
}

class ItemDefinition:
    var id: String
    var name: String
    var type: ItemType
    var rarity_levels: Array = []
    var base_defense: int = 0
    var base_damage_min: int = 0
    var base_damage_max: int = 0
    var speed: int = 0
    var required_level: int = 1
    var required_strength: int = 0
    var required_dexterity: int = 0
    var possible_sockets: Array = [0]
    var two_handed: bool = false
    var width: int = 1
    var height: int = 1

var item_definitions: Dictionary = {}
var affix_pool: Dictionary = {}
var set_items: Dictionary = {}
var unique_items: Dictionary = {}

func _ready() -> void:
    _load_item_definitions()
    _load_affixes()
    _load_set_items()
    _load_unique_items()

func _load_item_definitions() -> void:
    # Weapons (id, name, type, rarities, defense, dmg_min, dmg_max, speed, req_lvl, req_str, req_dex, sockets, two_hand, width, height)
    _add_weapon("gladius", "Gladius", ItemType.SWORD, [0,1,2], 0, 3, 6, -10, 1, 0, 0, [1,3], false, 2, 3)
    _add_weapon("short_sword", "Short Sword", ItemType.SWORD, [0], 0, 4, 8, -5, 1, 0, 0, [1,3], false, 2, 2)
    _add_weapon("scimitar", "Scimitar", ItemType.SWORD, [0,1], 0, 5, 10, 0, 3, 0, 0, [1,4], false, 2, 3)
    _add_weapon("cutlass", "Cutlass", ItemType.SWORD, [0], 0, 6, 11, 5, 5, 0, 0, [1,4], false, 2, 3)
    _add_weapon("saber", "Saber", ItemType.SWORD, [0,1], 0, 7, 13, 10, 7, 0, 0, [1,4], false, 2, 3)
    _add_weapon("crystal_sword", "Crystal Sword", ItemType.SWORD, [0,1,2], 0, 8, 15, -5, 11, 0, 0, [2,4], false, 2, 3)
    _add_weapon("bastard_sword", "Bastard Sword", ItemType.SWORD, [0,1], 0, 12, 22, 10, 17, 0, 0, [2,4], true, 2, 3)
    _add_weapon("two_handed_sword", "Two-Handed Sword", ItemType.SWORD, [0,1,2], 0, 18, 30, 20, 21, 0, 0, [3,5], true, 2, 4)
    
    _add_weapon("hand_axe", "Hand Axe", ItemType.AXE, [0], 0, 3, 7, -10, 1, 0, 0, [1,2], false, 2, 2)
    _add_weapon("axe", "Axe", ItemType.AXE, [0,1], 0, 5, 10, 0, 5, 0, 0, [1,3], false, 2, 3)
    _add_weapon("double_axe", "Double Axe", ItemType.AXE, [0], 0, 7, 14, 5, 11, 0, 0, [2,4], true, 2, 4)
    _add_weapon("great_axe", "Great Axe", ItemType.AXE, [0,1,2], 0, 15, 25, 15, 20, 0, 0, [3,5], true, 2, 4)
    
    _add_weapon("club", "Club", ItemType.MACE, [0], 0, 3, 5, -20, 1, 0, 0, [1,2], false, 2, 2)
    _add_weapon("spiked_club", "Spiked Club", ItemType.MACE, [0], 0, 4, 7, -10, 1, 0, 0, [1,2], false, 2, 2)
    _add_weapon("mace", "Mace", ItemType.MACE, [0,1], 0, 5, 9, 0, 5, 0, 0, [1,3], false, 2, 3)
    _add_weapon("morning_star", "Morning Star", ItemType.MACE, [0,1], 0, 8, 13, 5, 11, 0, 0, [2,3], false, 2, 3)
    _add_weapon("war_hammer", "War Hammer", ItemType.MACE, [0,1], 0, 12, 20, 20, 17, 0, 0, [2,4], true, 2, 4)
    
    _add_weapon("short_staff", "Short Staff", ItemType.STAFF, [0], 2, 2, 5, -20, 1, 0, 0, [1,2], true, 2, 3)
    _add_weapon("long_staff", "Long Staff", ItemType.STAFF, [0,1], 3, 3, 7, -10, 6, 0, 0, [1,3], true, 2, 4)
    _add_weapon("war_staff", "War Staff", ItemType.STAFF, [0,1,2], 5, 6, 12, 0, 18, 0, 0, [2,4], true, 2, 4)
    
    _add_weapon("dagger", "Dagger", ItemType.DAGGER, [0,1], 0, 1, 4, -30, 1, 0, 0, [1,2], false, 1, 2)
    _add_weapon("knife", "Knife", ItemType.DAGGER, [0], 0, 2, 5, -20, 1, 0, 0, [1,2], false, 1, 2)
    _add_weapon("stiletto", "Stiletto", ItemType.DAGGER, [0,1], 0, 3, 6, -10, 6, 0, 0, [1,3], false, 1, 2)
    
    _add_weapon("short_bow", "Short Bow", ItemType.BOW, [0], 0, 2, 6, -10, 1, 0, 0, [1,2], false, 2, 3)
    _add_weapon("long_bow", "Long Bow", ItemType.BOW, [0], 0, 3, 8, 0, 4, 0, 0, [1,3], true, 2, 4)
    _add_weapon("composite_bow", "Composite Bow", ItemType.BOW, [0,1], 0, 4, 10, 5, 7, 0, 0, [1,3], true, 2, 4)
    _add_weapon("hunter's_bow", "Hunter's Bow", ItemType.BOW, [0,1,2], 0, 6, 14, -5, 11, 0, 0, [2,4], true, 2, 4)
    
    # Armor
    _add_armor("helm", "Helm", ItemType.HELM, [0,1,2], 3, 0, 0, 0, 1, 0, 0, [0,1], 2, 2)
    _add_armor("great_helm", "Great Helm", ItemType.HELM, [0,1], 6, 0, 0, 0, 7, 0, 0, [0,1], 2, 2)
    _add_armor("mask", "Mask", ItemType.HELM, [0,1], 4, 0, 0, 0, 3, 0, 0, [0,1], 2, 2)
    
    _add_armor("leather_armor", "Leather Armor", ItemType.CHEST, [0], 4, 0, 0, 0, 1, 0, 0, [0,1], 2, 3)
    _add_armor("hard_leather", "Hard Leather", ItemType.CHEST, [0], 8, 0, 0, 0, 3, 0, 0, [0,1], 2, 3)
    _add_armor("studded_leather", "Studded Leather", ItemType.CHEST, [0,1], 12, 0, 0, 0, 5, 0, 0, [0,2], 2, 3)
    _add_armor("ring_mail", "Ring Mail", ItemType.CHEST, [0], 16, 0, 0, 0, 7, 0, 0, [0,2], 2, 3)
    _add_armor("chain_mail", "Chain Mail", ItemType.CHEST, [0,1], 22, 0, 0, 0, 11, 0, 0, [0,2], 2, 3)
    _add_armor("breast_plate", "Breast Plate", ItemType.CHEST, [0,1], 30, 0, 0, 0, 14, 0, 0, [0,3], 2, 3)
    _add_armor("splint_mail", "Splint Mail", ItemType.CHEST, [0,1], 40, 0, 0, 0, 20, 0, 0, [0,3], 2, 4)
    _add_armor("plate_mail", "Plate Mail", ItemType.CHEST, [0,1,2], 55, 0, 0, 0, 27, 0, 0, [0,3], 2, 4)
    _add_armor("field_plate", "Field Plate", ItemType.CHEST, [0,1], 70, 0, 0, 0, 32, 0, 0, [0,4], 2, 4)
    _add_armor("gothic_plate", "Gothic Plate", ItemType.CHEST, [0,1,2], 90, 0, 0, 0, 39, 0, 0, [0,4], 2, 4)
    
    _add_armor("small_shield", "Small Shield", ItemType.SHIELD, [0], 3, 0, 0, 0, 1, 0, 0, [0,1], 2, 2)
    _add_armor("large_shield", "Large Shield", ItemType.SHIELD, [0], 5, 0, 0, 0, 3, 0, 0, [0,1], 2, 3)
    _add_armor("kite_shield", "Kite Shield", ItemType.SHIELD, [0,1], 8, 0, 0, 0, 6, 0, 0, [0,2], 2, 3)
    _add_armor("tower_shield", "Tower Shield", ItemType.SHIELD, [0,1], 12, 0, 0, 0, 10, 0, 0, [0,2], 2, 4)
    _add_armor("spiked_shield", "Spiked Shield", ItemType.SHIELD, [0,1], 10, 4, 8, 5, 8, 0, 0, [0,2], 2, 3)
    
    _add_armor("leather_gloves", "Leather Gloves", ItemType.GLOVES, [0], 2, 0, 0, 0, 1, 0, 0, [0,1], 2, 2)
    _add_armor("heavy_gloves", "Heavy Gloves", ItemType.GLOVES, [0,1], 4, 0, 0, 0, 4, 0, 0, [0,1], 2, 2)
    _add_armor("chain_gloves", "Chain Gloves", ItemType.GLOVES, [0,1], 6, 0, 0, 0, 8, 0, 0, [0,1], 2, 2)
    _add_armor("light_gauntlets", "Light Gauntlets", ItemType.GLOVES, [0,1], 8, 0, 0, 0, 12, 0, 0, [0,1], 2, 2)
    _add_armor("gauntlets", "Gauntlets", ItemType.GLOVES, [0,1,2], 10, 0, 0, 0, 16, 0, 0, [0,1], 2, 2)
    
    _add_armor("boots", "Boots", ItemType.BOOTS, [0], 2, 0, 0, 0, 1, 0, 0, [0,1], 2, 2)
    _add_armor("heavy_boots", "Heavy Boots", ItemType.BOOTS, [0,1], 4, 0, 0, 0, 4, 0, 0, [0,1], 2, 2)
    _add_armor("chain_boots", "Chain Boots", ItemType.BOOTS, [0,1], 6, 0, 0, 0, 8, 0, 0, [0,1], 2, 2)
    _add_armor("light_plated_boots", "Light Plated Boots", ItemType.BOOTS, [0,1], 8, 0, 0, 0, 12, 0, 0, [0,1], 2, 2)
    _add_armor("boots", "Heavy Boots", ItemType.BOOTS, [0,1,2], 10, 0, 0, 0, 16, 0, 0, [0,1], 2, 2)
    
    _add_armor("sash", "Sash", ItemType.BELT, [0], 1, 0, 0, 0, 1, 0, 0, [0,1], 2, 1)
    _add_armor("leather_belt", "Leather Belt", ItemType.BELT, [0], 2, 0, 0, 0, 3, 0, 0, [0,1], 2, 1)
    _add_armor("heavy_belt", "Heavy Belt", ItemType.BELT, [0,1], 4, 0, 0, 0, 7, 0, 0, [0,1], 2, 1)
    _add_armor("plated_belt", "Plated Belt", ItemType.BELT, [0,1], 6, 0, 0, 0, 11, 0, 0, [0,1], 2, 1)
    _add_armor("war_belt", "War Belt", ItemType.BELT, [0,1,2], 8, 0, 0, 0, 15, 0, 0, [0,1], 2, 1)
    
    # Rings & Amulets
    _add_ring_amulet("gold_ring", "Gold Ring", ItemType.RING, [0,1], 3, 0, 10)
    _add_ring_amulet("silver_ring", "Silver Ring", ItemType.RING, [0], 2, 0, 5)
    _add_ring_amulet("ring", "Ring", ItemType.RING, [0], 1, 0, 0)
    _add_ring_amulet("amulet", "Amulet", ItemType.AMULET, [0], 2, 0, 0)

func _add_weapon(id: String, name: String, type: ItemType, rarities: Array, def: int, dmin: int, dmax: int, spd: int, rlvl: int, rstr: int, rdex: int, soc: Array, th: bool, w: int, h: int):
    var item = ItemDefinition.new()
    item.id = id
    item.name = name
    item.type = type
    item.rarity_levels = rarities
    item.base_defense = def
    item.base_damage_min = dmin
    item.base_damage_max = dmax
    item.speed = spd
    item.required_level = rlvl
    item.required_strength = rstr
    item.required_dexterity = rdex
    item.possible_sockets = soc
    item.two_handed = th
    item.width = w
    item.height = h
    item_definitions[id] = item

func _add_armor(id: String, name: String, type: ItemType, rarities: Array, def: int, dmin: int, dmax: int, spd: int, rlvl: int, rstr: int, rdex: int, soc: Array, w: int, h: int):
    _add_weapon(id, name, type, rarities, def, dmin, dmax, spd, rlvl, rstr, rdex, soc, false, w, h)

func _add_ring_amulet(id: String, name: String, type: ItemType, rarities: Array, rlvl: int, rstr: int, rdex: int):
    _add_weapon(id, name, type, rarities, 0, 0, 0, 0, rlvl, rstr, rdex, [0], false, 1, 1)

func _load_affixes() -> void:
    affix_pool = {
        "prefixes": {
            1: [{"name": "of Strength", "stats": {"str_bonus": 3}}],
            5: [{"name": "of Dexterity", "stats": {"dex_bonus": 3}}],
            8: [{"name": "of Vitality", "stats": {"vit_bonus": 3}}],
            10: [{"name": "of Energy", "stats": {"ene_bonus": 3}}],
            15: [{"name": "of the Bear", "stats": {"str_bonus": 5, "hp_bonus": 10}}],
            20: [{"name": "of the Eagle", "stats": {"dex_bonus": 5, "attack_rating": 20}}],
            25: [{"name": "of the Whale", "stats": {"vit_bonus": 10, "hp_bonus": 30}}],
        },
        "suffixes": {
            1: [{"name": "of Defense", "stats": {"defense": 3}}],
            5: [{"name": "of Protection", "stats": {"fire_resist": 5}}],
            8: [{"name": "of Warmth", "stats": {"fire_resist": 5, "cold_resist": 5}}],
            12: [{"name": "of Blocking", "stats": {"block_chance": 5}}],
            18: [{"name": "of Absorption", "stats": {"damage_reduce": 3}}],
            25: [{"name": "of Balance", "stats": {"dex_bonus": 5, "vit_bonus": 5}}],
        }
    }

func _load_set_items() -> void:
    set_items = {}

func _load_unique_items() -> void:
    unique_items = {}

func get_random_item(item_level: int, rarity: int = -1):
    if rarity < 0:
        rarity = _roll_rarity()
    
    var valid_items = []
    for id in item_definitions:
        var def = item_definitions[id]
        if rarity in def.rarity_levels:
            valid_items.append(def)
    
    if valid_items.size() == 0:
        return null
    
    var def = valid_items.pick_random()
    var item = _create_item_from_def(def, item_level, rarity)
    return item

func _create_item_from_def(def: ItemDefinition, item_level: int, rarity: int):
    var item = {}
    item["item_id"] = def.id
    item["name"] = def.name
    item["base_type"] = ItemType.keys()[def.type]
    item["rarity"] = rarity
    item["item_level"] = item_level
    item["width"] = def.width
    item["height"] = def.height
    item["defense"] = def.base_defense
    item["damage_min"] = def.base_damage_min
    item["damage_max"] = def.base_damage_max
    item["required_level"] = def.required_level
    item["required_strength"] = def.required_strength
    item["required_dexterity"] = def.required_dexterity
    item["sockets"] = 0
    item["socketed_items"] = []
    item["affixes"] = []
    item["str_bonus"] = 0
    item["dex_bonus"] = 0
    item["vit_bonus"] = 0
    item["ene_bonus"] = 0
    item["fire_resist"] = 0
    item["cold_resist"] = 0
    item["lightning_resist"] = 0
    item["poison_resist"] = 0
    item["enhanced_damage"] = 0
    
    if rarity >= Rarity.MAGIC:
        _add_random_affixes(item, item_level, rarity)
    
    return item

func _roll_rarity() -> int:
    var roll = randi() % 100
    if roll < 70: return Rarity.NORMAL
    if roll < 95: return Rarity.MAGIC
    if roll < 99: return Rarity.RARE
    return Rarity.UNIQUE

func _add_random_affixes(item: Dictionary, item_level: int, rarity: int) -> void:
    var affix_count = 1 if rarity == Rarity.MAGIC else 2
    
    for i in range(affix_count):
        var prefix_pool = affix_pool.get("prefixes", {})
        var keys = prefix_pool.keys()
        keys.sort()
        
        for lvl in keys:
            if lvl <= item_level and randi() % 100 < 30:
                var affixes = prefix_pool[lvl]
                var affix = affixes.pick_random()
                item["affixes"].append(affix["name"])
                var stats = affix.get("stats", {})
                for stat in stats:
                    item[stat] = item.get(stat, 0) + stats[stat]
                break

func get_item_definition(item_id: String) -> ItemDefinition:
    return item_definitions.get(item_id)
