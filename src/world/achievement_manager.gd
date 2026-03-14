## AchievementManager.gd
## Handles achievements, stats tracking, and rewards

extends Node

signal achievement_unlocked(achievement_id: String)
signal achievement_progress_updated(achievement_id: String, current: int, target: int)
signal stat_updated(stat_name: String, value: float)

enum AchievementCategory {
    COMBAT,
    EXPLORATION,
    ITEM,
    QUEST,
    SKILL,
    SOCIAL,
    SEASON,
}

class Achievement:
    var achievement_id: String
    var name: String
    var description: String
    var category: AchievementCategory
    var icon: String = ""
    
    var target_value: int = 1
    var current_value: int = 0
    var unlocked: bool = false
    var unlocked_time: int = 0
    
    var reward_xp: int = 0
    var reward_gold: int = 0
    var reward_item: String = ""
    
    var is_secret: bool = false

var achievements: Dictionary = {}
var player_stats: Dictionary = {}
var unlocked_achievements: Array = []

func _ready() -> void:
    _load_achievements()
    _initialize_stats()

func _load_achievements() -> void:
    # Combat achievements
    _add_achievement("first_blood", "First Blood", "Kill your first monster", AchievementCategory.COMBAT, 1, 50, 0)
    _add_achievement("monster_slayer", "Monster Slayer", "Kill 100 monsters", AchievementCategory.COMBAT, 100, 100, 500)
    _add_achievement("mass_murderer", "Mass Murderer", "Kill 1,000 monsters", AchievementCategory.COMBAT, 1000, 500, 2000)
    _add_achievement("serial_killer", "Serial Killer", "Kill 10,000 monsters", AchievementCategory.COMBAT, 10000, 1000, 5000)
    
    _add_achievement("boss_killer", "Boss Killer", "Kill your first boss", AchievementCategory.COMBAT, 1, 100, 200)
    _add_achievement("boss_slayer", "Boss Slayer", "Kill 10 bosses", AchievementCategory.COMBAT, 10, 300, 1000)
    _add_achievement("demon_hunter", "Demon Hunter", "Kill all Act bosses", AchievementCategory.COMBAT, 5, 1000, 5000)
    
    _add_achievement("deathless", "Deathless", "Complete a difficulty without dying", AchievementCategory.COMBAT, 1, 500, 2000)
    _add_achievement("survivor", "Survivor", "Complete all difficulties without dying", AchievementCategory.COMBAT, 3, 2000, 10000)
    
    _add_achievement("critical_master", "Critical Master", "Land 100 critical hits", AchievementCategory.COMBAT, 100, 100, 500)
    _add_achievement("critical_god", "Critical God", "Land 1,000 critical hits", AchievementCategory.COMBAT, 1000, 500, 2500)
    
    # Exploration achievements
    _add_achievement("explorer", "Explorer", "Visit all zones in Act 1", AchievementCategory.EXPLORATION, 1, 200, 500)
    _add_achievement("world_traveler", "World Traveler", "Visit all zones in all acts", AchievementCategory.EXPLORATION, 1, 1000, 5000)
    _add_achievement("cartographer", "Cartographer", "Discover all areas in the game", AchievementCategory.EXPLORATION, 1, 2000, 10000)
    
    # Item achievements
    _add_achievement("first_loot", "First Loot", "Pick up your first item", AchievementCategory.ITEM, 1, 10, 0)
    _add_achievement("collector", "Collector", "Collect 100 items", AchievementCategory.ITEM, 100, 50, 100)
    _add_achievement("treasure_hunter", "Treasure Hunter", "Collect 1,000 items", AchievementCategory.ITEM, 1000, 200, 500)
    
    _add_achievement("rich", "Rich", "Accumulate 100,000 gold", AchievementCategory.ITEM, 100000, 200, 500)
    _add_achievement("tycoon", "Tycoon", "Accumulate 1,000,000 gold", AchievementCategory.ITEM, 1000000, 1000, 2500)
    _add_achievement("millionaire", "Millionaire", "Accumulate 10,000,000 gold", AchievementCategory.ITEM, 10000000, 5000, 10000)
    
    _add_achievement("unique_hunter", "Unique Hunter", "Find 10 unique items", AchievementCategory.ITEM, 10, 300, 1000)
    _add_achievement("set_collector", "Set Collector", "Complete 5 item sets", AchievementCategory.ITEM, 5, 500, 2000)
    _add_achievement("rune_word", "Rune Word", "Create your first Rune Word", AchievementCategory.ITEM, 1, 300, 1000)
    
    _add_achievement("perfect_gear", "Perfect Gear", "Equip all items with 90%+ resistances", AchievementCategory.ITEM, 1, 1000, 5000)
    
    # Quest achievements
    _add_achievement("quester", "Quester", "Complete 10 quests", AchievementCategory.QUEST, 10, 100, 300)
    _add_achievement("quest_master", "Quest Master", "Complete 30 quests", AchievementCategory.QUEST, 30, 500, 1500)
    _add_achievement("hero_of_tristram", "Hero of Tristram", "Complete all quests in the game", AchievementCategory.QUEST, 1, 5000, 25000)
    
    # Skill achievements
    _add_achievement("skillful", "Skillful", "Unlock 10 skills", AchievementCategory.SKILL, 10, 100, 300)
    _add_achievement("master_of_arts", "Master of Arts", "Unlock 30 skills", AchievementCategory.SKILL, 30, 500, 2000)
    _add_achievement("skill_god", "Skill God", "Unlock all skills", AchievementCategory.SKILL, 1, 5000, 25000)
    
    _add_achievement("level_10", "Level 10", "Reach level 10", AchievementCategory.SKILL, 10, 100, 200)
    _add_achievement("level_25", "Level 25", "Reach level 25", AchievementCategory.SKILL, 25, 300, 750)
    _add_achievement("level_50", "Level 50", "Reach level 50", AchievementCategory.SKILL, 50, 1000, 2500)
    _add_achievement("level_99", "Level 99", "Reach the maximum level", AchievementCategory.SKILL, 99, 10000, 50000)
    
    _add_achievement("hardcore", "Hardcore", "Reach level 10 in Hardcore mode", AchievementCategory.SKILL, 10, 1000, 5000)
    
    # Multiplayer achievements
    _add_achievement("social_butterfly", "Social Butterfly", "Play with 5 different players", AchievementCategory.SOCIAL, 5, 200, 500)
    _add_achievement("party_animal", "Party Animal", "Play with 20 different players", AchievementCategory.SOCIAL, 20, 1000, 2500)
    
    _add_achievement("pvp_1", "First Blood (PvP)", "Kill another player", AchievementCategory.SOCIAL, 1, 200, 500)
    _add_achievement("pvp_10", "Arena Champion", "Kill 10 players", AchievementCategory.SOCIAL, 10, 1000, 2500)
    
    # Secret achievements
    _add_achievement("lucky", "Lucky", "Find an item with 6 sockets (secret)", AchievementCategory.ITEM, 1, 0, 1000, true)
    _add_achievement("unlucky", "Unlucky", "Die 100 times (secret)", AchievementCategory.COMBAT, 100, 0, 500, true)
    _add_achievement("speedrunner", "Speedrunner", "Complete the game in under 4 hours (secret)", AchievementCategory.EXPLORATION, 1, 0, 10000, true)
    _add_achievement("pacifist", "Pacifist", "Complete a difficulty without killing anything (secret)", AchievementCategory.COMBAT, 1, 0, 5000, true)

func _add_achievement(aid: String, name: String, desc: String, cat: AchievementCategory, target: int, xp: int, gold: int, secret: bool = false) -> void:
    var ach = Achievement.new()
    ach.achievement_id = aid
    ach.name = name
    ach.description = desc
    ach.category = cat
    ach.target_value = target
    ach.reward_xp = xp
    ach.reward_gold = gold
    ach.is_secret = secret
    achievements[aid] = ach

func _initialize_stats() -> void:
    player_stats = {
        "monsters_killed": 0,
        "bosses_killed": 0,
        "deaths": 0,
        "critical_hits": 0,
        "gold_collected": 0,
        "items_collected": 0,
        "unique_items": 0,
        "set_items": 0,
        "quests_completed": 0,
        "skills_unlocked": 0,
        "zones_visited": 0,
        "players_met": 0,
        "pvp_kills": 0,
        "play_time": 0.0,
        "distance_traveled": 0.0,
    }

func update_stat(stat_name: String, amount: float = 1.0) -> void:
    if not player_stats.has(stat_name):
        player_stats[stat_name] = 0.0
    
    var old_value = player_stats[stat_name]
    player_stats[stat_name] += amount
    
    stat_updated.emit(stat_name, player_stats[stat_name])
    
    # Check achievements that depend on this stat
    _check_stat_achievements(stat_name, player_stats[stat_name])

func set_stat(stat_name: String, value: float) -> void:
    var old_value = player_stats.get(stat_name, 0.0)
    player_stats[stat_name] = value
    stat_updated.emit(stat_name, value)
    _check_stat_achievements(stat_name, value)

func get_stat(stat_name: String) -> float:
    return player_stats.get(stat_name, 0.0)

func _check_stat_achievements(stat_name: String, value: float) -> void:
    # Map stats to achievements
    var stat_to_achievements = {
        "monsters_killed": ["first_blood", "monster_slayer", "mass_murderer", "serial_killer"],
        "bosses_killed": ["boss_killer", "boss_slayer", "demon_hunter"],
        "critical_hits": ["critical_master", "critical_god"],
        "deaths": ["deathless", "survivor", "unlucky"],
        "gold_collected": ["rich", "tycoon", "millionaire"],
        "items_collected": ["first_loot", "collector", "treasure_hunter"],
        "unique_items": ["unique_hunter"],
        "set_items": ["set_collector"],
        "quests_completed": ["quester", "quest_master", "hero_of_tristram"],
        "skills_unlocked": ["skillful", "master_of_arts", "skill_god"],
        "zones_visited": ["explorer", "world_traveler", "cartographer"],
        "players_met": ["social_butterfly", "party_animal"],
        "pvp_kills": ["pvp_1", "pvp_10"],
    }
    
    var relevant_achievements = stat_to_achievements.get(stat_name, [])
    for ach_id in relevant_achievements:
        if achievements.has(ach_id):
            var ach = achievements[ach_id]
            if not ach.unlocked:
                _update_achievement_progress(ach_id, int(value))

func _update_achievement_progress(achievement_id: String, new_value: int) -> void:
    if not achievements.has(achievement_id):
        return
    
    var ach = achievements[achievement_id]
    var old_value = ach.current_value
    ach.current_value = new_value
    
    if new_value != old_value:
        achievement_progress_updated.emit(achievement_id, new_value, ach.target_value)
    
    # Check if completed
    if ach.current_value >= ach.target_value and not ach.unlocked:
        _unlock_achievement(achievement_id)

func _unlock_achievement(achievement_id: String) -> void:
    if not achievements.has(achievement_id):
        return
    
    var ach = achievements[achievement_id]
    
    if ach.unlocked:
        return
    
    ach.unlocked = true
    ach.unlocked_time = Time.get_unix_time_from_system()
    unlocked_achievements.append(achievement_id)
    
    # Grant rewards
    var player = PlayerManager.get_current_player()
    if player:
        if ach.reward_xp > 0:
            player.add_experience(ach.reward_xp)
        if ach.reward_gold > 0:
            player.gold += ach.reward_gold
    
    achievement_unlocked.emit(achievement_id)

func unlock_achievement(achievement_id: String) -> void:
    _unlock_achievement(achievement_id)

func get_achievement(achievement_id: String) -> Achievement:
    return achievements.get(achievement_id)

func get_all_achievements() -> Array:
    return achievements.values()

func get_unlocked_achievements() -> Array:
    var result = []
    for ach in achievements.values():
        if ach.unlocked:
            result.append(ach)
    return result

func get_locked_achievements() -> Array:
    var result = []
    for ach in achievements.values():
        if not ach.unlocked:
            result.append(ach)
    return result

func get_achievements_by_category(category: AchievementCategory) -> Array:
    var result = []
    for ach in achievements.values():
        if ach.category == category:
            result.append(ach)
    return result

func get_achievement_progress(achievement_id: String) -> Dictionary:
    if not achievements.has(achievement_id):
        return {}
    
    var ach = achievements[achievement_id]
    return {
        "current": ach.current_value,
        "target": ach.target_value,
        "percent": float(ach.current_value) / float(ach.target_value) if ach.target_value > 0 else 0,
        "unlocked": ach.unlocked,
    }

func get_total_progress() -> float:
    var unlocked = unlocked_achievements.size()
    var total = achievements.size()
    return float(unlocked) / float(total) if total > 0 else 0

func reset_progress() -> void:
    for ach in achievements.values():
        ach.current_value = 0
        ach.unlocked = false
        ach.unlocked_time = 0
    
    unlocked_achievements.clear()
    _initialize_stats()

func has_achievement(achievement_id: String) -> bool:
    return achievement_id in unlocked_achievements

func get_player_stats() -> Dictionary:
    return player_stats.duplicate()

func save_progress() -> Dictionary:
    return {
        "achievements": unlocked_achievements,
        "achievement_values": {},
        "stats": player_stats,
    }

func load_progress(data: Dictionary) -> void:
    if data.has("achievements"):
        unlocked_achievements = data["achievements"]
        
        for ach_id in unlocked_achievements:
            if achievements.has(ach_id):
                achievements[ach_id].unlocked = true
    
    if data.has("achievement_values"):
        var values = data["achievement_values"]
        for ach_id in values:
            if achievements.has(ach_id):
                achievements[ach_id].current_value = values[ach_id]
    
    if data.has("stats"):
        player_stats = data["stats"]

func get_achievement_count() -> Dictionary:
    var total = achievements.size()
    var unlocked = unlocked_achievements.size()
    return {
        "total": total,
        "unlocked": unlocked,
        "locked": total - unlocked,
    }
