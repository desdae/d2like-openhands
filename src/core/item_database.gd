## ItemDatabase.gd
## Central database for all item definitions and generation

extends Node

# Rarity tiers
enum Rarity {
    NORMAL = 0,   # White - base items
    MAGIC = 1,    # Blue - 1-2 affixes
    RARE = 2,     # Yellow - 3-6 affixes
    SET = 3,      # Green - set items
    UNIQUE = 4,   # Gold - fixed properties
    RUNE = 5      # Orange - socketable
}

# Item types
enum ItemType {
    SWORD,
    AXE,
    MACE,
    DAGGER,
    STAFF,
    BOW,
    CROSSBOW,
    POLEARM,
    SPEAR,
    HELM,
    CHEST,
    SHIELD,
    BELT,
    GLOVES,
    BOOTS,
    RING,
    AMULET,
    CHARM,
    POTION,
    GEM,
    RUNE,
    JEWEL,
    SCROLL
}

# Affix types
enum AffixType {
    PREFIX,
    SUFFIX
}

# Item definition template
class ItemDefinition:
    var id: String
    var name: String
    var type: ItemType
    var rarity_levels: Array = []  # Which rarities can spawn this
    var base_defense: int = 0
    var base_damage_min: int = 0
    var base_damage_max: int = 0
    var speed: int = 0  # -20 = fast, 0 = normal, +20 = slow
    var required_level: int = 1
    var required_strength: int = 0
    var required_dexterity: int = 0
    var possible_sockets: Array = [0]  # [min, max] or fixed
    var two_handed: bool = false
    var weapon_type: bool = false
    var width: int = 1
    var height: int = 1
    
    func init(i: String, n: String, t: ItemType, rl: Array, bd: int, dmin: int, dmax: int, spd: int, rlvl: int, rstr: int, rdex: int, soc: Array, th: bool, wt: bool) -> ItemDefinition:
        id = i
        name = n
        type = t
        rarity_levels = rl
        base_defense = bd
        base_damage_min = dmin
        base_damage_max = dmax
        speed = spd
        required_level = rlvl
        required_strength = rstr
        required_dexterity = rdex
        possible_sockets = soc
        two_handed = th
        weapon_type = wt
        # Set dimensions based on type
        match t:
            ItemType.SWORD, ItemType.AXE, ItemType.MACE, ItemType.STAFF, ItemType.BOW:
                width = 2
                height = 3 if two_handed else 2
            ItemType.DAGGER:
                width = 1
                height = 2
            ItemType.HELM:
                width = 2
                height = 2
            ItemType.CHEST:
                width = 2
                height = 3
            ItemType.SHIELD:
                width = 2
                height = 2
            ItemType.GLOVES:
                width = 2
                height = 2
            ItemType.BOOTS:
                width = 2
                height = 2
            ItemType.BELT:
                width = 2
                height = 1
            ItemType.RING:
                width = 1
                height = 1
            ItemType.AMULET:
                width = 1
                height = 1
            ItemType.CHARM:
                width = 1
                height = 1
        return self

var item_definitions: Dictionary = {}
var affix_pool: Dictionary = {}  # prefix/suffix by item_level
var set_items: Dictionary = {}
var unique_items: Dictionary = {}

func _ready() -> void:
    _load_item_definitions()
    _load_affixes()
    _load_set_items()
    _load_unique_items()

func _load_item_definitions() -> void:
    # Weapons - Swords
    item_definitions["gladius"] = ItemDefinition.new().init("gladius", "Gladius", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC, Rarity.RARE], 0, 3, 6, -10, 1, 0, 0, [1, 3], false, true)
    item_definitions["short_sword"] = ItemDefinition.new().init("short_sword", "Short Sword", ItemType.SWORD, [Rarity.NORMAL], 0, 4, 8, -5, 1, 0, 0, [1, 3], false, true)
    item_definitions["scimitar"] = ItemDefinition.new().init("scimitar", "Scimitar", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC], 0, 5, 10, 0, 3, 0, 0, [1, 4], false, true)
    item_definitions["cutlass"] = ItemDefinition.new().init("cutlass", "Cutlass", ItemType.SWORD, [Rarity.NORMAL], 0, 6, 11, 5, 5, 0, 0, [1, 4], false, true)
    item_definitions["saber"] = ItemDefinition.new().init("saber", "Saber", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC], 0, 7, 13, 10, 7, 0, 0, [1, 4], false, true)
    item_definitions["crystal_sword"] = ItemDefinition.new().init("crystal_sword", "Crystal Sword", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC, Rarity.RARE], 0, 8, 15, -5, 11, 0, 0, [2, 4], false, true)
    item_definitions["broad_sword"] = ItemDefinition.new().init("broad_sword", "Broad Sword", ItemType.SWORD, [Rarity.NORMAL], 0, 10, 18, 5, 13, 0, 0, [2, 4], false, true)
    item_definitions["bastard_sword"] = ItemDefinition.new().init("bastard_sword", "Bastard Sword", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC], 0, 12, 22, 10, 17, 0, 0, [2, 4], true, true)
    item_definitions["two_handed_sword"] = ItemDefinition.new().init("two_handed_sword", "Two-Handed Sword", ItemType.SWORD, [Rarity.NORMAL, Rarity.MAGIC, Rarity.RARE], 0, 18, 30, 20, 21, 0, 0, [3, 5], true, true)
    
    # Weapons - Axes
    item_definitions["hand_axe"] = ItemDefinition.new().init("hand_axe", "Hand Axe", ItemType.AXE, [Rarity.NORMAL], 0, 3, 7, -10, 1, 0, 0, [1, 2], false, true)
    item_definitions["axe"] = ItemDefinition.new().init("axe", "Axe", ItemType.AXE, [Rarity.NORMAL, Rarity.MAGIC], 0, 5, 10, 0, 5, 0, 0, [1, 3], false, true)
    item_definitions["double_axe"] = ItemDefinition.new().init("double_axe", "Double Axe", ItemType.AXE, [Rarity.NORMAL], 0, 7, 14, 5, 11, 0, 0, [2, 4], true, true)
    item_definitions["great_axe"] = ItemDefinition.new().init("great_axe", "Great Axe", ItemType.AXE, [Rarity.NORMAL, Rarity.MAGIC, Rarity.RARE], 0, 15, 25, 15, 20, 0, 0, [3, 5], true, true)
    
    # Weapons - Maces
    item_definitions["club"] = ItemDefinition.new().init("club", "Club", ItemType.MACE, [Rarity.NORMAL], 0, 3, 5, -20, 1, 0, 0, [1, 2], false, true)
    item_definitions["spiked_club"] = ItemDefinition.new().init("spiked_club", "Spiked Club", ItemType.MACE, [Rarity.NORMAL], 0, 4, 7, -10, 1, 0, 0, [1, 2], false, true)
    item_definitions["mace"] = ItemDefinition.new().init("mace", "Mace", ItemType.MACE, [Rarity.NORMAL, Rarity.MAGIC], 0, 5, 9, 0, 5, 0, 0, [1, 3], false, true)
    item_definitions["morning_star"] = ItemDefinition.new().init("morning_star", "Morning Star", ItemType.MACE, [Rarity.NORMAL, Rarity.MAGIC], 0, 8, 13, 5, 11, 0, 0, [2, 3], false, true)
    item_definitions["war_hammer"] = ItemDefinition.new().init("war_hammer", "War Hammer", ItemType.MACE, [Rarity.NORMAL, Rarity.MAGIC], 0, 12, 20, 20, 17, 0, 0, [2, 4], true, true)
    
    # Weapons - Staves
    item_definitions["short_staff"] = ItemDefinition.new().init("short_staff", "Short Staff", ItemType.STAFF, [Rarity.NORMAL], 2, 2, 5, -20, 1, 0, 0, [1, 2], true, true)
    item_definitions["long_staff"] = ItemDefinition.new().init("long_staff", "Long Staff", ItemType.STAFF, [Rarity.NORMAL, Rarity.MAGIC], 3, 3, 7, -10, 6, 0, 0, [1, 3], true, true)
    item_definitions["battle_staff"] = ItemDefinition.new().init("battle_staff", "Battle Staff", ItemType.STAFF, [Rarity.NORMAL, Rarity.MAGIC, Rarity.RARE], 4, 4, 10, 0, 12, 0, 0, [2, 4], true, true)
    item_definitions["war_staff"] = ItemDefinition.new().init("war_staff", "War Staff", ItemType.STAFF, [Rarity.RARE, Rarity.UNIQUE], 6, 6, 14, 10, 24, 0, 0, [2, 5], true, true)
    
    # Weapons - Bows
    item_definitions["short_bow"] = ItemDefinition.new().init("short_bow", "Short Bow", ItemType.BOW, [Rarity.NORMAL], 0, 2, 6, -20, 1, 0, 0, [1, 2], true, true)
    item_definitions["long_bow"] = ItemDefinition.new().init("long_bow", "Long Bow", ItemType.BOW, [Rarity.NORMAL, Rarity.MAGIC], 0, 3, 8, -10, 6, 0, 0, [1, 3], true, true)
    item_definitions["composite_bow"] = ItemDefinition.new().init("composite_bow", "Composite Bow", ItemType.BOW, [Rarity.NORMAL, Rarity.MAGIC], 0, 4, 10, 0, 11, 0, 0, [1, 3], true, true)
    item_definitions["short_battle_bow"] = ItemDefinition.new().init("short_battle_bow", "Short Battle Bow", ItemType.BOW, [Rarity.NORMAL, Rarity.MAGIC], 0, 5, 12, 5, 15, 0, 0, [2, 4], true, true)
    item_definitions["long_battle_bow"] = ItemDefinition.new().init("long_battle_bow", "Long Battle Bow", ItemType.BOW, [Rarity.RARE], 0, 7, 15, 10, 21, 0, 0, [2, 4], true, true)
    
    # Armor - Helmets
    item_definitions["helm"] = ItemDefinition.new().init("helm", "Helm", ItemType.HELM, [Rarity.NORMAL], 3, 0, 0, 0, 1, 0, 0, [0, 1])
    item_definitions["great_helm"] = ItemDefinition.new().init("great_helm", "Great Helm", ItemType.HELM, [Rarity.NORMAL, Rarity.MAGIC], 5, 0, 0, 0, 7, 0, 0, [0, 2])
    item_definitions["mask"] = ItemDefinition.new().init("mask", "Mask", ItemType.HELM, [Rarity.NORMAL, Rarity.MAGIC], 4, 0, 0, 0, 5, 0, 0, [0, 1])
    item_definitions["bone_helm"] = ItemDefinition.new().init("bone_helm", "Bone Helm", ItemType.HELM, [Rarity.MAGIC, Rarity.RARE], 6, 0, 0, 0, 11, 0, 0, [1, 2])
    
    # Armor - Chest
    item_definitions["leather_armor"] = ItemDefinition.new().init("leather_armor", "Leather Armor", ItemType.CHEST, [Rarity.NORMAL], 8, 0, 0, 0, 1, 0, 0, [0, 1])
    item_definitions["hard_leather_armor"] = ItemDefinition.new().init("hard_leather_armor", "Hard Leather Armor", ItemType.CHEST, [Rarity.NORMAL], 12, 0, 0, 0, 3, 0, 0, [0, 2])
    item_definitions["studded_leather"] = ItemDefinition.new().init("studded_leather", "Studded Leather", ItemType.CHEST, [Rarity.NORMAL, Rarity.MAGIC], 16, 0, 0, 0, 5, 0, 0, [0, 2])
    item_definitions["ring_mail"] = ItemDefinition.new().init("ring_mail", "Ring Mail", ItemType.CHEST, [Rarity.NORMAL], 20, 0, 0, 0, 7, 0, 0, [0, 2])
    item_definitions["scale_mail"] = ItemDefinition.new().init("scale_mail", "Scale Mail", ItemType.CHEST, [Rarity.NORMAL, Rarity.MAGIC], 26, 0, 0, 0, 10, 0, 0, [0, 3])
    item_definitions["breast_plate"] = ItemDefinition.new().init("breast_plate", "Breast Plate", ItemType.CHEST, [Rarity.NORMAL, Rarity.MAGIC], 32, 0, 0, 0, 13, 0, 0, [0, 3])
    item_definitions["chain_mail"] = ItemDefinition.new().init("chain_mail", "Chain Mail", ItemType.CHEST, [Rarity.NORMAL, Rarity.MAGIC], 38, 0, 0, 0, 16, 0, 0, [0, 3])
    item_definitions["splint_mail"] = ItemDefinition.new().init("splint_mail", "Splint Mail", ItemType.CHEST, [Rarity.MAGIC, Rarity.RARE], 44, 0, 0, 0, 20, 0, 0, [0, 4])
    item_definitions["plate_mail"] = ItemDefinition.new().init("plate_mail", "Plate Mail", ItemType.CHEST, [Rarity.MAGIC, Rarity.RARE], 52, 0, 0, 0, 25, 0, 0, [1, 4])
    item_definitions["field_plate"] = ItemDefinition.new().init("field_plate", "Field Plate", ItemType.CHEST, [Rarity.RARE], 60, 0, 0, 0, 30, 0, 0, [1, 5])
    item_definitions["ghost_armor"] = ItemDefinition.new().init("ghost_armor", "Ghost Armor", ItemType.CHEST, [Rarity.RARE, Rarity.UNIQUE], 55, 0, 0, 0, 28, 0, 0, [2, 5])
    
    # Shields
    item_definitions["small_shield"] = ItemDefinition.new().init("small_shield", "Small Shield", ItemType.SHIELD, [Rarity.NORMAL], 8, 0, 0, 0, 1, 0, 0, [0, 1])
    item_definitions["large_shield"] = ItemDefinition.new().init("large_shield", "Large Shield", ItemType.SHIELD, [Rarity.NORMAL, Rarity.MAGIC], 14, 0, 0, 0, 5, 0, 0, [0, 2])
    item_definitions["kite_shield"] = ItemDefinition.new().init("kite_shield", "Kite Shield", ItemType.SHIELD, [Rarity.NORMAL, Rarity.MAGIC], 18, 0, 0, 0, 10, 0, 0, [0, 3])
    item_definitions["tower_shield"] = ItemDefinition.new().init("tower_shield", "Tower Shield", ItemType.SHIELD, [Rarity.MAGIC, Rarity.RARE], 24, 0, 0, 0, 16, 0, 0, [1, 3])
    
    # Accessories
    item_definitions["gold_ring"] = ItemDefinition.new().init("gold_ring", "Gold Ring", ItemType.RING, [Rarity.NORMAL], 0, 0, 0, 0, 1, 0, 0, [0])
    item_definitions["silver_ring"] = ItemDefinition.new().init("silver_ring", "Silver Ring", ItemType.RING, [Rarity.NORMAL], 0, 0, 0, 0, 1, 0, 0, [0])
    item_definitions["amulet"] = ItemDefinition.new().init("amulet", "Amulet", ItemType.AMULET, [Rarity.NORMAL], 0, 0, 0, 0, 1, 0, 0, [0])

func _load_affixes() -> void:
    # Prefixes by item level groups
    affix_pool["prefixes"] = {
        1: [
            {"name": "Rusty", "stats": {"defense": 1}},
            {"name": "Cracked", "stats": {"defense": 2}},
            {"name": "Rough", "stats": {"damage_min": 1, "damage_max": 2}},
            {"name": "Damaged", "stats": {"hp_bonus": 5}},
        ],
        5: [
            {"name": "Strong", "stats": {"str_bonus": 2}},
            {"name": "Agile", "stats": {"dex_bonus": 2}},
            {"name": "Vital", "stats": {"vit_bonus": 2}},
            {"name": "Arcane", "stats": {"ene_bonus": 2}},
            {"name": "Fiery", "stats": {"fire_resist": 5}},
            {"name": "Icy", "stats": {"cold_resist": 5}},
            {"name": "Shocking", "stats": {"lightning_resist": 5}},
            {"name": "Toxic", "stats": {"poison_resist": 5}},
        ],
        10: [
            {"name": "Savage", "stats": {"str_bonus": 5, "damage_min": 2, "damage_max": 4}},
            {"name": "Deadly", "stats": {"critical_chance": 3}},
            {"name": "Vampiric", "stats": {"life_leech": 2}},
            {"name": "Enchanted", "stats": {"enhanced_damage": 10}},
            {"name": "Protective", "stats": {"defense": 10}},
        ],
        20: [
            {"name": "Furious", "stats": {"str_bonus": 10, "enhanced_damage": 15}},
            {"name": "Blazing", "stats": {"fire_resist": 15, "damage_min": 5}},
            {"name": "Frozen", "stats": {"cold_resist": 15, "damage_min": 5}},
            {"name": "Voltaic", "stats": {"lightning_resist": 15, "damage_min": 5}},
        ],
        30: [
            {"name": "Ethereal", "stats": {"all_stats": 5}},
            {"name": "Luminous", "stats": {"fire_resist": 25, "mp_bonus": 20}},
            {"name": "Sanguine", "stats": {"life_leech": 5, "hp_bonus": 30}},
        ],
        40: [
            {"name": "Mythical", "stats": {"all_stats": 10, "enhanced_damage": 25}},
            {"name": "Celestial", "stats": {"all_resists": 10}},
        ]
    }
    
    # Suffixes by item level groups
    affix_pool["suffixes"] = {
        1: [
            {"name": "of Minor Gl保", "stats": {"defense": 1}},
            {"name": "of Easy Use", "stats": {"required_level": -1}},
        ],
        5: [
            {"name": "of Strength", "stats": {"str_bonus": 3}},
            {"name": "of Dexterity", "stats": {"dex_bonus": 3}},
            {"name": "of Vitality", "stats": {"vit_bonus": 3}},
            {"name": "of Energy", "stats": {"ene_bonus": 3}},
        ],
        10: [
            {"name": "of the Bear", "stats": {"hp_bonus": 15}},
            {"name": "of the Eagle", "stats": {"mp_bonus": 15}},
            {"name": "of Fire", "stats": {"fire_resist": 8}},
            {"name": "of Frost", "stats": {"cold_resist": 8}},
            {"name": "of Lightning", "stats": {"lightning_resist": 8}},
            {"name": "of Poison", "stats": {"poison_resist": 8}},
        ],
        15: [
            {"name": "of Piercing", "stats": {"attack_rating": 20}},
            {"name": "of Smiting", "stats": {"enhanced_damage": 15}},
            {"name": "of Balance", "stats": {"dex_bonus": 5, "vit_bonus": 5}},
        ],
        25: [
            {"name": "of Might", "stats": {"str_bonus": 10, "enhanced_damage": 20}},
            {"name": "of Craft", "stats": {"skill_bonuses": {"all_skills": 1}}},
            {"name": "of Absorption", "stats": {"life_leech": 3}},
            {"name": "of the Phoenix", "stats": {"fire_resist": 20, "max_fire": 5}},
        ]
    }

func _load_set_items() -> void:
    # Set items with bonus properties
    set_items["sarak_nash"] = {
        "name": "Sarak's Nash",
        "helm": {"defense": 35, "str_bonus": 15, "vit_bonus": 10},
        "chest": {"defense": 65, "str_bonus": 20, "hp_bonus": 50},
        "boots": {"defense": 30, "dex_bonus": 10, "vit_bonus": 10},
        "2_bonus": {"life_leech": 3},
        "3_bonus": {"enhanced_damage": 10},
    }

func _load_unique_items() -> void:
    # Unique items with fixed properties
    unique_items["wirts_leg"] = {
        "name": "Wirt's Leg",
        "type": ItemType.MACE,
        "damage_min": 8,
        "damage_max": 20,
        "speed": -5,
        "required_level": 7,
        "defense": 4,
        "all_stats": 3,
    }
    unique_items["horizons_torch"] = {
        "name": "Horizon's Torch",
        "type": ItemType.AMULET,
        "required_level": 30,
        "all_stats": 10,
        "all_resists": 10,
    }

# Item generation functions
func get_random_item(item_level: int, rarity: int = -1) -> ItemData:
    # Determine rarity if not specified
    if rarity < 0:
        rarity = _roll_rarity()
    
    # Get valid item definitions for this rarity
    var valid_items = []
    for id in item_definitions:
        var def = item_definitions[id]
        if rarity in def.rarity_levels:
            valid_items.append(id)
    
    if valid_items.is_empty():
        return null
    
    var item_id = valid_items.pick_random()
    var def = item_definitions[item_id]
    
    var item = ItemData.new(item_id, def.name)
    item.rarity = rarity
    item.item_level = item_level
    item.width = def.width if def.width > 0 else 1
    item.height = def.height if def.height > 0 else 1
    item.base_type = ItemType.keys()[def.type]
    item.defense = def.base_defense
    item.damage_min = def.base_damage_min
    item.damage_max = def.base_damage_max
    item.required_level = def.required_level
    item.required_strength = def.required_strength
    item.required_dexterity = def.required_dexterity
    
    # Roll sockets
    if def.possible_sockets.size() > 0:
        var socket_count = randi_range(def.possible_sockets[0], def.possible_sockets[1])
        item.sockets = socket_count
    
    # Apply rarity-specific generation
    match rarity:
        Rarity.NORMAL:
            pass  # Base item only
        Rarity.MAGIC:
            _add_affixes(item, item_level, randi_range(1, 2))
        Rarity.RARE:
            _add_affixes(item, item_level, randi_range(3, 6))
        Rarity.SET, Rarity.UNIQUE:
            _apply_unique_or_set(item, rarity)
    
    return item

func _roll_rarity() -> int:
    var roll = randi() % 100
    if roll < 1:
        return Rarity.UNIQUE  # 1%
    elif roll < 3:
        return Rarity.SET    # 2%
    elif roll < 10:
        return Rarity.RARE   # 7%
    elif roll < 30:
        return Rarity.MAGIC  # 20%
    else:
        return Rarity.NORMAL  # 70%

func _add_affixes(item: ItemData, item_level: int, count: int) -> void:
    var prefix_count = count / 2 + (1 if randi() % 2 == 0 else 0)
    var suffix_count = count - prefix_count
    
    for i in range(prefix_count):
        var affix = _get_random_affix("prefixes", item_level)
        if affix:
            _apply_affix(item, affix)
    
    for i in range(suffix_count):
        var affix = _get_random_affix("suffixes", item_level)
        if affix:
            _apply_affix(item, affix)

func _get_random_affix(pool_name: String, item_level: int) -> Dictionary:
    var pool = affix_pool.get(pool_name, {})
    var available = []
    
    for level in pool:
        if level <= item_level:
            available.append_array(pool[level])
    
    if available.is_empty():
        return {}
    
    return available.pick_random()

func _apply_affix(item: ItemData, affix: Dictionary) -> void:
    item.affixes.append(affix["name"])
    var stats = affix.get("stats", {})
    
    for stat in stats:
        match stat:
            "str_bonus":
                item.str_bonus += stats[stat]
            "dex_bonus":
                item.dex_bonus += stats[stat]
            "vit_bonus":
                item.vit_bonus += stats[stat]
            "ene_bonus":
                item.ene_bonus += stats[stat]
            "hp_bonus":
                item.hp_bonus += stats[stat]
            "mp_bonus":
                item.mp_bonus += stats[stat]
            "defense":
                item.defense += stats[stat]
            "damage_min":
                item.damage_min += stats[stat]
            "damage_max":
                item.damage_max += stats[stat]
            "enhanced_damage":
                item.enhanced_damage += stats[stat]
            "attack_rating":
                item.attack_rating += stats[stat]
            "critical_chance":
                item.critical_chance += stats[stat]
            "life_leech":
                item.life_leech += stats[stat]
            "mana_leech":
                item.mana_leech += stats[stat]
            "fire_resist":
                item.fire_resist += stats[stat]
            "cold_resist":
                item.cold_resist += stats[stat]
            "lightning_resist":
                item.lightning_resist += stats[stat]
            "poison_resist":
                item.poison_resist += stats[stat]
            "all_stats":
                item.str_bonus += stats[stat]
                item.dex_bonus += stats[stat]
                item.vit_bonus += stats[stat]
                item.ene_bonus += stats[stat]
            "all_resists":
                item.fire_resist += stats[stat]
                item.cold_resist += stats[stat]
                item.lightning_resist += stats[stat]
                item.poison_resist += stats[stat]

func _apply_unique_or_set(item: ItemData, rarity: int) -> void:
    var pool = unique_items if rarity == Rarity.UNIQUE else set_items
    
    if pool.is_empty():
        return
    
    var item_pool = []
    for id in pool:
        if rarity == Rarity.UNIQUE:
            if pool[id].get("type") == _get_item_type_enum(item.base_type):
                item_pool.append(id)
        else:
            item_pool.append(id)
    
    if item_pool.is_empty():
        return
    
    var unique_id = item_pool.pick_random()
    var unique_data = pool[unique_id]
    
    item.name = unique_data["name"]
    item.item_id = unique_id
    
    # Apply fixed properties
    for prop in unique_data:
        if prop == "name":
            continue
        match prop:
            "defense":
                item.defense = unique_data[prop]
            "damage_min":
                item.damage_min = unique_data[prop]
            "damage_max":
                item.damage_max = unique_data[prop]
            "enhanced_damage":
                item.enhanced_damage = unique_data[prop]
            "all_stats":
                item.str_bonus = unique_data[prop]
                item.dex_bonus = unique_data[prop]
                item.vit_bonus = unique_data[prop]
                item.ene_bonus = unique_data[prop]
            "all_resists":
                item.fire_resist = unique_data[prop]
                item.cold_resist = unique_data[prop]
                item.lightning_resist = unique_data[prop]
                item.poison_resist = unique_data[prop]
            "str_bonus", "vit_bonus", "ene_bonus", "hp_bonus", "mp_bonus":
                # Direct assignment for simplicity
                pass

func _get_item_type_enum(type_name: String) -> int:
    for i in ItemType.keys():
        if ItemType.keys()[i] == type_name:
            return i
    return 0

func get_item_definition(item_id: String) -> ItemDefinition:
    return item_definitions.get(item_id)

func get_unique_item(unique_id: String) -> Dictionary:
    return unique_items.get(unique_id, {})

func get_set_item(set_id: String) -> Dictionary:
    return set_items.get(set_id, {})
