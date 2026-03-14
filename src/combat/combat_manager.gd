## CombatManager.gd
## Handles all combat calculations and damage processing

extends Node

signal damage_dealt(target, damage, damage_type)
signal player_damaged(damage, damage_type)
signal enemy_killed(enemy)
signal critical_hit(target, damage)

# Damage types
enum DamageType {
    PHYSICAL = 0,
    FIRE = 1,
    COLD = 2,
    LIGHTNING = 3,
    POISON = 4,
    HOLY = 5,
    MAGIC = 6
}

# Status effects
enum StatusEffect {
    NONE = 0,
    FROZEN = 1,
    STUNNED = 2,
    CHILLED = 3,
    BURNING = 4,
    POISONED = 5,
    BLEEDING = 6,
    ENFEEBLED = 7,
    FRIGHTENED = 8
}

# Combat calculation constants
const HIT_CHANCE_MIN: float = 0.05
const HIT_CHANCE_MAX: float = 0.95
const CRITICAL_MULTIPLIER: float = 1.5
const BLOCK_CHANCE_MAX: float = 0.75
const DODGE_CHANCE_MAX: float = 0.50

# Leeches
const LEECH_CAP_PER_HIT: float = 0.40  # Max % of damage returned per hit

class DamageResult:
    var total_damage: int
    var physical: int
    var fire: int
    var cold: int
    var lightning: int
    var poison: int
    var holy: int
    var critical: bool
    var blocked: bool
    var missed: bool
    var life_stolen: int
    var mana_stolen: int
    
    func _init():
        total_damage = 0
        physical = 0
        fire = 0
        cold = 0
        lightning = 0
        poison = 0
        holy = 0
        critical = false
        blocked = false
        missed = false
        life_stolen = 0
        mana_stolen = 0

class CombatEntity:
    var entity_id: int
    var is_player: bool
    var position: Vector2
    var level: int
    
    # Stats
    var max_hp: int
    var current_hp: int
    var max_mp: int
    var current_mp: int
    var max_stamina: int
    var current_stamina: int
    
    # Combat stats
    var attack_rating: int = 0
    var defense: int = 0
    var enhanced_damage: int = 0
    var damage_min: int = 0
    var damage_max: int = 0
    var attack_speed: float = 1.0
    var cast_speed: float = 1.0
    
    # Critical
    var critical_chance: float = 0.0
    var critical_multiplier: float = 1.5
    
    # Resists (0-100, can go negative)
    var fire_resist: int = 0
    var cold_resist: int = 0
    var lightning_resist: int = 0
    var poison_resist: int = 0
    var physical_resist: int = 0
    
    # Leeches
    var life_leech: float = 0.0
    var mana_leech: float = 0.0
    
    # Status
    var current_status: StatusEffect = StatusEffect.NONE
    var status_duration: float = 0.0
    
    # Skills
    var active_skills: Dictionary = {}  # skill_id -> level
    
    func _init():
        entity_id = GlobalUniqueId.next()
    
    func is_alive() -> bool:
        return current_hp > 0
    
    func take_damage(dmg: DamageResult) -> void:
        current_hp -= dmg.total_damage
        if current_hp < 0:
            current_hp = 0
    
    func heal(amount: int) -> void:
        current_hp = min(current_hp + amount, max_hp)
    
    func restore_mana(amount: int) -> void:
        current_mp = min(current_mp + amount, max_mp)
    
    func apply_status(effect: StatusEffect, duration: float) -> void:
        # Don't overwrite worse effects
        if current_status == StatusEffect.NONE or current_status < effect:
            current_status = effect
            status_duration = duration
    
    func update_status(delta: float) -> void:
        if status_duration > 0:
            status_duration -= delta
            if status_duration <= 0:
                current_status = StatusEffect.NONE
                status_duration = 0.0

class GlobalUniqueId:
    static var _counter: int = 0
    static func next() -> int:
        _counter += 1
        return _counter

# Main combat functions
func calculate_hit(attacker: CombatEntity, defender: CombatEntity) -> bool:
    # Base chance
    var base_chance: float = 0.5
    
    # Attack rating vs defense
    var ar_vs_def = float(attacker.attack_rating - defender.defense)
    var chance_mod = ar_vs_def / (ar_vs_def + float(defender.level * 50))
    
    var hit_chance = clamp(base_chance + chance_mod, HIT_CHANCE_MIN, HIT_CHANCE_MAX)
    
    # Apply status modifiers
    if defender.current_status == StatusEffect.FROZEN:
        hit_chance += 0.25  # Easier to hit frozen targets
    elif defender.current_status == StatusEffect.ENFEEBLED:
        hit_chance += 0.20
    
    return randf() < hit_chance

func calculate_damage(attacker: CombatEntity, defender: CombatEntity, skill_damage: Dictionary = {}) -> DamageResult:
    var result = DamageResult.new()
    
    # Get base damage
    var base_min = attacker.damage_min
    var base_max = attacker.damage_max
    
    # Apply skill damage overrides
    if skill_damage.has("min"):
        base_min = skill_damage["min"]
    if skill_damage.has("max"):
        base_max = skill_damage["max"]
    
    # Random damage in range
    var base_damage = randi_range(base_min, base_max)
    
    # Apply enhanced damage
    var damage_mult = 1.0 + (attacker.enhanced_damage / 100.0)
    base_damage = int(base_damage * damage_mult)
    
    # Check for critical
    var is_critical = randf() < attacker.critical_chance
    if is_critical:
        result.critical = true
        base_damage = int(base_damage * attacker.critical_multiplier)
        critical_hit.emit(defender.entity_id, base_damage)
    
    # Determine damage types and apply resistances
    var damage_types = _get_damage_types(attacker, skill_damage)
    
    for dmg_type in damage_types:
        var dmg = 0
        match dmg_type:
            DamageType.PHYSICAL:
                dmg = base_damage
                result.physical = _apply_resist(dmg, defender.physical_resist)
            DamageType.FIRE:
                dmg = base_damage
                result.fire = _apply_resist(dmg, defender.fire_resist)
            DamageType.COLD:
                dmg = base_damage
                result.cold = _apply_resist(dmg, defender.cold_resist)
                # Cold also has chance to freeze
                if randf() < 0.1 and result.cold > 0:
                    defender.apply_status(StatusEffect.CHILLED, 2.0)
            DamageType.LIGHTNING:
                dmg = base_damage
                result.lightning = _apply_resist(dmg, defender.lightning_resist)
            DamageType.POISON:
                dmg = base_damage
                result.poison = _apply_resist(dmg, defender.poison_resist)
                # Poison applies DoT
                if result.poison > 0:
                    _apply_poison_damage(defender, result.poison)
            DamageType.HOLY:
                dmg = base_damage
                result.holy = dmg  # Holy doesn't get resisted by most
    
    result.total_damage = result.physical + result.fire + result.cold + result.lightning + result.poison + result.holy
    
    # Apply leech (capped)
    if result.total_damage > 0:
        var leech_amount = min(result.total_damage * LEECH_CAP_PER_HIT, attacker.max_hp * 0.1)
        result.life_stolen = int(attacker.life_leech * leech_amount)
        result.mana_stolen = int(attacker.mana_leech * leech_amount)
    
    # Apply difficulty penalty to player
    if defender.is_player:
        var penalty = GameManager.get_resistance_penalty()
        result.total_damage = int(result.total_damage * (1.0 + penalty))
    
    return result

func _get_damage_types(attacker: CombatEntity, skill_damage: Dictionary) -> Array:
    # Default physical, can be overridden by skill
    if skill_damage.has("type"):
        return [skill_damage["type"]]
    return [DamageType.PHYSICAL]

func _apply_resist(damage: int, resist: int) -> int:
    # Resistance reduces damage
    # Negative resist = extra damage
    var reduction = clamp(resist, -100, 95)  # Cap at -100 (double damage) to +95%
    return int(damage * (1.0 - (reduction / 100.0)))

func _apply_poison_damage(defender: CombatEntity, damage: int) -> void:
    # Poison does damage over time
    defender.apply_status(StatusEffect.POISONED, 3.0)

func perform_attack(attacker: CombatEntity, defender: CombatEntity, skill: Dictionary = {}) -> DamageResult:
    if not attacker.is_alive():
        return null
    if not defender.is_alive():
        return null
    
    # Check if hit lands
    if not calculate_hit(attacker, defender):
        var result = DamageResult.new()
        result.missed = true
        return result
    
    # Calculate damage
    var damage = calculate_damage(attacker, defender, skill)
    
    # Apply damage
    defender.take_damage(damage)
    
    # Apply leech
    if damage.life_stolen > 0:
        attacker.heal(damage.life_stolen)
    if damage.mana_stolen > 0:
        attacker.restore_mana(damage.mana_stolen)
    
    # Emit signals
    damage_dealt.emit(defender.entity_id, damage.total_damage, DamageType.PHYSICAL)
    if not defender.is_alive():
        enemy_killed.emit(defender)
    
    return damage

func perform_skill(attacker: CombatEntity, target: CombatEntity, skill_id: String, skill_level: int) -> DamageResult:
    var skill = SkillDatabase.get_skill(skill_id)
    if not skill:
        return null
    
    var player = PlayerManager.get_current_player()
    if not player:
        return null
    
    # Check mana
    var mana_cost = skill.mana_cost * (1.0 - (skill_level * 0.05))  # 5% cheaper per level
    if attacker.current_mp < mana_cost:
        return null
    
    attacker.current_mp -= int(mana_cost)
    
    # Build skill damage dict
    var skill_damage = {
        "min": skill.damage_min * (1.0 + skill_level * 0.1),
        "max": skill.damage_max * (1.0 + skill_level * 0.1),
        "type": skill.damage_type
    }
    
    # Perform attack
    var result = perform_attack(attacker, target, skill_damage)
    
    # Handle area effects
    if skill.effect_radius > 0:
        _handle_aoe_damage(attacker, target.position, skill.effect_radius, skill_damage)
    
    return result

func _handle_aoe_damage(attacker: CombatEntity, center: Vector2, radius: float, damage: Dictionary) -> void:
    # Get all entities in radius
    # This would query the game world for nearby enemies
    pass

# Helper functions for creating combat entities
func create_player_entity(player: PlayerManager.PlayerData) -> CombatEntity:
    var entity = CombatEntity.new()
    entity.is_player = true
    entity.level = player.level
    
    entity.max_hp = player.max_hp
    entity.current_hp = player.current_hp
    entity.max_mp = player.max_mp
    entity.current_mp = player.current_mp
    
    entity.attack_rating = player.attack_rating + (player.dexterity * 2)
    entity.defense = player.defense + (player.dexterity / 2)
    entity.enhanced_damage = player.enhanced_damage
    
    entity.fire_resist = player.fire_resist
    entity.cold_resist = player.cold_resist
    entity.lightning_resist = player.lightning_resist
    entity.poison_resist = player.poison_resist
    
    entity.life_leech = player.life_leech
    entity.mana_leech = player.mana_leech
    entity.critical_chance = player.critical_hit_chance
    
    return entity

func create_enemy_entity(monster_data: Dictionary, level: int) -> CombatEntity:
    var entity = CombatEntity.new()
    entity.is_player = false
    entity.level = level
    
    # Scale with level and difficulty
    var diff_mod = GameManager.get_difficulty_modifier()
    
    entity.max_hp = int(monster_data.get("hp", 50) * diff_mod * (1.0 + level * 0.1))
    entity.current_hp = entity.max_hp
    entity.max_mp = monster_data.get("mp", 10)
    entity.current_mp = entity.max_mp
    
    entity.attack_rating = int(monster_data.get("ar", 20) * diff_mod)
    entity.defense = int(monster_data.get("def", 5) * diff_mod)
    entity.damage_min = int(monster_data.get("dmg_min", 3) * diff_mod)
    entity.damage_max = int(monster_data.get("dmg_max", 6) * diff_mod)
    
    entity.fire_resist = monster_data.get("fire_resist", 0)
    entity.cold_resist = monster_data.get("cold_resist", 0)
    entity.lightning_resist = monster_data.get("lightning_resist", 0)
    entity.poison_resist = monster_data.get("poison_resist", 0)
    
    # Hell difficulty adds immunities
    if GameManager.current_difficulty == GameManager.Difficulty.HELL:
        _apply_hell_immunities(entity, monster_data)
    
    return entity

func _apply_hell_immunities(entity: CombatEntity, monster_data: Dictionary) -> void:
    # In Hell, some monsters get full immunities
    var roll = randi() % 4
    match roll:
        0:
            entity.fire_resist = 100
        1:
            entity.cold_resist = 100
        2:
            entity.lightning_resist = 100
        3:
            entity.poison_resist = 100

# Status effect utilities
func get_status_effect_name(effect: StatusEffect) -> String:
    match effect:
        StatusEffect.NONE: return ""
        StatusEffect.FROZEN: return "Frozen"
        StatusEffect.STUNNED: return "Stunned"
        StatusEffect.CHILLED: return "Chilled"
        StatusEffect.BURNING: return "Burning"
        StatusEffect.POISONED: return "Poisoned"
        StatusEffect.BLEEDING: return "Bleeding"
        StatusEffect.ENFEEBLED: return "Enfeebled"
        StatusEffect.FRIGHTENED: return "Frightened"
    return ""

func get_damage_type_name(dmg_type: int) -> String:
    match dmg_type:
        DamageType.PHYSICAL: return "Physical"
        DamageType.FIRE: return "Fire"
        DamageType.COLD: return "Cold"
        DamageType.LIGHTNING: return "Lightning"
        DamageType.POISON: return "Poison"
        DamageType.HOLY: return "Holy"
        DamageType.MAGIC: return "Magic"
    return "Unknown"
