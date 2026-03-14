## QuestManager.gd
## Handles quests, objectives, and rewards

extends Node

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, objective_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)

enum QuestState {
    LOCKED,
    AVAILABLE,
    IN_PROGRESS,
    COMPLETED,
    FAILED
}

enum QuestType {
    MAIN_STORY,
    SIDE,
    REPEATABLE
}

enum ObjectiveType {
    KILL_MONSTER,
    COLLECT_ITEM,
    VISIT_ZONE,
    TALK_TO_NPC,
    USE_ITEM,
    REACH_LEVEL,
    USE_SKILL
}

class QuestObjective:
    var objective_id: String
    var description: String
    var objective_type: ObjectiveType
    var target_id: String  # monster_id, item_id, zone_id, etc.
    var target_count: int
    var current_count: int = 0
    var optional: bool = false
    
    func is_complete() -> bool:
        return current_count >= target_count

class Quest:
    var quest_id: String
    var name: String
    var description: String
    var quest_type: QuestType
    var state: QuestState = QuestState.LOCKED
    
    var objectives: Array = []  # Array of QuestObjective
    var rewards: Dictionary = {}  # xp, gold, items
    
    var required_level: int = 1
    var required_quest: String = ""  # Quest ID that must be completed first
    var required_act: int = 1
    
    var NPC_giver: String = ""
    var NPC_complete: String = ""
    
    var completion_dialog: String = ""
    var failure_dialog: String = ""

var active_quests: Dictionary = {}  # quest_id -> Quest
var completed_quests: Array = []
var available_quests: Array = []

func _ready() -> void:
    _load_quests()

func _load_quests() -> void:
    # Act 1 Quests
    _add_quest("q_sisters", "Sisters of the Sightless", QuestType.MAIN_STORY, 1, 
        "Andariel has taken the sisters of the Sightless. Save them from her grasp.",
        {"den_of_evil": "Rescue kashya"}, {"den_of_evil": "Rescue kashya"}, 
        {"xp": 500, "gold": 100})
    
    _add_quest("q_den_of_evil", "Den of Evil", QuestType.MAIN_STORY, 1,
        "Clear the Den of Evil from the cold plains.",
        {"den_of_evil": "Kill all monsters in Den of Evil"}, {},
        {"xp": 200, "gold": 50})
    
    _add_quest("q_sisters_2", "The Sisters' Burial", QuestType.SIDE, 2,
        "Find the burial site of the sisters in the Burial Grounds.",
        {"crypt_1": "Find the burial site"}, {},
        {"xp": 300, "gold": 75})
    
    _add_quest("q_countess", "The Countess", QuestType.MAIN_STORY, 3,
        "Defeat the Countess in the Dark Wood tower.",
        {"tower": "Kill the Countess"}, {},
        {"xp": 800, "gold": 200})
    
    # Act 2 Quests
    _add_quest("q_radament", "Radament", QuestType.MAIN_STORY, 5,
        "Find and defeat the evil caster Radament in the Sewers.",
        {"sewers_1": "Find Radament"}, {"sewers_1": "Kill Radament"},
        {"xp": 1000, "gold": 300})
    
    _add_quest("q_horadric", "Horadric Staff", QuestType.MAIN_STORY, 6,
        "Find the Horadric Staff and deliver it to Deckard Cain in town.",
        {"desert_1": "Find the Horadric Staff"}, {"desert_2": "Deliver to Cain"},
        {"xp": 1200, "gold": 400})
    
    _add_quest("q_tome", "The Lost Tome", QuestType.SIDE, 7,
        "Find the Tome of Identify in the Far Oasis.",
        {"ruins_1": "Find the Tome"}, {},
        {"xp": 600, "gold": 150})
    
    # Act 3 Quests
    _add_quest("q_travincal", "Travincal", QuestType.MAIN_STORY, 10,
        "Stop the Prime Evils from completing the Dark Exile.",
        {"temple_2": "Kill Council Members"}, {},
        {"xp": 2000, "gold": 500})
    
    _add_quest("q_mephisto", "The Black Soulstone", QuestType.MAIN_STORY, 12,
        "Mephisto must be trapped in the Black Soulstone.",
        {"boss_3": "Defeat Mephisto"}, {},
        {"xp": 3000, "gold": 750})
    
    # Act 4 Quests
    _add_quest("q_terrors", "Terrors' Domain", QuestType.MAIN_STORY, 20,
        "Find and defeat the Terrors in the Plains of Destruction.",
        {"fortress_1": "Find the Terrors"}, {"fortress_1": "Kill Izual"},
        {"xp": 2500, "gold": 600})
    
    _add_quest("q_diablo", "The Fall of Diablo", QuestType.MAIN_STORY, 21,
        "Descend into the Chaos Sanctuary and defeat Diablo.",
        {"boss_4": "Defeat Diablo"}, {},
        {"xp": 5000, "gold": 1000})
    
    # Act 5 Quests
    _add_quest("q_free_clan", "Free the Clans", QuestType.MAIN_STORY, 30,
        "Rescue the captured clansmen from the Barbarian camps.",
        {"mountains_1": "Rescue 5 clansmen"}, {},
        {"xp": 3000, "gold": 800})
    
    _add_quest("q_baal", "The Worldstone", QuestType.MAIN_STORY, 31,
        "Defeat Baal at the Worldstone Keep.",
        {"baal_1": "Defeat Baal"}, {},
        {"xp": 10000, "gold": 2000})

func _add_quest(qid: String, name: String, qtype: QuestType, lvl: int, desc: String, 
    objectives: Dictionary, alt_objectives: Dictionary, rewards: Dictionary) -> void:
    
    var quest = Quest.new()
    quest.quest_id = qid
    quest.name = name
    quest.description = desc
    quest.quest_type = qtype
    quest.required_level = lvl
    quest.rewards = rewards
    
    # Parse objectives
    for i in range(objectives.size()):
        var obj = QuestObjective.new()
        obj.objective_id = qid + "_obj_" + str(i)
        obj.target_id = objectives.keys()[i]
        obj.description = objectives.values()[i]
        obj.target_count = 1
        quest.objectives.append(obj)
    
    # Store quest (locked by default)
    active_quests[qid] = quest

func _check_quest_availability() -> void:
    var current_act = 1  # Would get from WorldManager
    var player = PlayerManager.get_current_player()
    if not player:
        return
    
    var player_level = player.level
    
    for qid in active_quests:
        var quest = active_quests[qid]
        
        if quest.state != QuestState.LOCKED:
            continue
        
        # Check requirements
        if quest.required_level > player_level:
            continue
        if quest.required_act > current_act:
            continue
        if quest.required_quest != "" and not quest.required_quest in completed_quests:
            continue
        
        # Quest is now available
        quest.state = QuestState.AVAILABLE
        if not qid in available_quests:
            available_quests.append(qid)

func start_quest(quest_id: String) -> bool:
    if not active_quests.has(quest_id):
        return false
    
    var quest = active_quests[quest_id]
    
    if quest.state != QuestState.AVAILABLE:
        return false
    
    quest.state = QuestState.IN_PROGRESS
    quest_started.emit(quest_id)
    
    # Reset objective progress
    for obj in quest.objectives:
        obj.current_count = 0
    
    return true

func update_objective(target_id: String, amount: int = 1) -> void:
    # Check all in-progress quests
    for qid in active_quests:
        var quest = active_quests[qid]
        
        if quest.state != QuestState.IN_PROGRESS:
            continue
        
        for obj in quest.objectives:
            if obj.target_id == target_id and not obj.is_complete():
                obj.current_count += amount
                quest_updated.emit(qid, obj.objective_id)
                
                # Check if all required objectives complete
                _check_quest_completion(qid)

func _check_quest_completion(quest_id: String) -> void:
    var quest = active_quests[quest_id]
    
    # Check all non-optional objectives
    var all_complete = true
    for obj in quest.objectives:
        if not obj.optional and not obj.is_complete():
            all_complete = false
            break
    
    if all_complete:
        complete_quest(quest_id)

func complete_quest(quest_id: String) -> bool:
    if not active_quests.has(quest_id):
        return false
    
    var quest = active_quests[quest_id]
    
    if quest.state != QuestState.IN_PROGRESS:
        return false
    
    # Grant rewards
    var player = PlayerManager.get_current_player()
    if player:
        if quest.rewards.has("xp"):
            player.add_experience(quest.rewards["xp"])
        if quest.rewards.has("gold"):
            player.gold += quest.rewards["gold"]
        
        # TODO: Add reward items to inventory
    
    quest.state = QuestState.COMPLETED
    completed_quests.append(quest_id)
    quest_completed.emit(quest_id)
    
    # Remove from active
    active_quests.erase(quest_id)
    available_quests.erase(quest_id)
    
    return true

func fail_quest(quest_id: String) -> bool:
    if not active_quests.has(quest_id):
        return false
    
    var quest = active_quests[quest_id]
    
    quest.state = QuestState.FAILED
    quest_failed.emit(quest_id)
    
    active_quests.erase(quest_id)
    available_quests.erase(quest_id)
    
    return true

func abandon_quest(quest_id: String) -> bool:
    if not active_quests.has(quest_id):
        return false
    
    var quest = active_quests[quest_id]
    
    if quest.state != QuestState.IN_PROGRESS:
        return false
    
    active_quests.erase(quest_id)
    available_quests.erase(quest_id)
    
    return true

func get_quest(quest_id: String) -> Quest:
    return active_quests.get(quest_id)

func get_active_quests() -> Array:
    var result = []
    for qid in active_quests:
        if active_quests[qid].state == QuestState.IN_PROGRESS:
            result.append(active_quests[qid])
    return result

func get_available_quests() -> Array:
    var result = []
    for qid in available_quests:
        result.append(active_quests[qid])
    return result

func get_completed_quests() -> Array:
    return completed_quests

func is_quest_completed(quest_id: String) -> bool:
    return quest_id in completed_quests

func has_quest_in_progress() -> bool:
    for qid in active_quests:
        if active_quests[qid].state == QuestState.IN_PROGRESS:
            return true
    return false

# Quest UI helpers
func get_quest_progress_text(quest_id: String) -> String:
    if not active_quests.has(quest_id):
        return ""
    
    var quest = active_quests[quest_id]
    var text = quest.name + "\n\n"
    
    for obj in quest.objectives:
        var status = "☐"
        if obj.is_complete():
            status = "☒"
        text += status + " " + obj.description
        
        if obj.target_count > 1:
            text += " (" + str(obj.current_count) + "/" + str(obj.target_count) + ")"
        
        text += "\n"
    
    return text
