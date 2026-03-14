## SkillDatabase.gd
## Database for all skills and skill trees

extends Node

enum SkillTree {
    BERSERKER,
    DEFENDER,
    WARRIOR,
    FIRE,
    COLD,
    LIGHTNING,
    MARTIAL,
    TRICKERY,
    SHADOW,
    SUMMONING,
    POISON_BONE,
    CURSE,
    AURA_DEFENSE,
    AURA_OFFENSE,
    HOLY,
}

class SkillDefinition:
    var id: String
    var name: String
    var description: String
    var tree: SkillTree
    var required_level: int = 1
    var mana_cost: int = 0
    var damage_min: int = 0
    var damage_max: int = 0
    var damage_type: int = 0
    var effect_radius: float = 0.0
    var duration: float = 0.0

var skills: Dictionary = {}

const CLASS_TREES = {
    0: [SkillTree.BERSERKER, SkillTree.DEFENDER, SkillTree.WARRIOR],
    1: [SkillTree.FIRE, SkillTree.COLD, SkillTree.LIGHTNING],
    2: [SkillTree.MARTIAL, SkillTree.TRICKERY, SkillTree.SHADOW],
    3: [SkillTree.SUMMONING, SkillTree.POISON_BONE, SkillTree.CURSE],
    4: [SkillTree.AURA_DEFENSE, SkillTree.AURA_OFFENSE, SkillTree.HOLY],
}

func _ready() -> void:
    _load_skills()

func _load_skills() -> void:
    # Marauder - Berserker
    _add_skill("bash", "Bash", "A powerful melee strike.", SkillTree.BERSERKER, 1, 5, 6, 10, 0, 0.0, 0.0)
    _add_skill("berserker_rage", "Berserker Rage", "Enter a rage, increasing damage.", SkillTree.BERSERKER, 6, 15, 0, 30, 0, 0.0, 30.0)
    _add_skill("whirlwind", "Whirlwind", "Spin and damage nearby enemies.", SkillTree.BERSERKER, 12, 25, 15, 25, 0, 2.0, 0.0)
    _add_skill("frenzy", "Frenzy", "Dual wield attack speed boost.", SkillTree.BERSERKER, 18, 10, 10, 18, 0, 0.0, 0.0)
    _add_skill("maul", "Maul", "Heavy damage with chance to stun.", SkillTree.BERSERKER, 24, 20, 20, 35, 0, 0.0, 0.0)
    _add_skill("consumption", "Consumption", "Life steal on hit.", SkillTree.BERSERKER, 30, 0, 0, 0, 0, 0.0, 0.0)
    
    # Marauder - Defender
    _add_skill("iron_skin", "Iron Skin", "Passively increases defense.", SkillTree.DEFENDER, 1, 0, 0, 0, 0, 0.0, 0.0)
    _add_skill("war_cry", "War Cry", "Shout that weakens enemy defense.", SkillTree.DEFENDER, 6, 8, 5, 10, 0, 0.0, 0.0)
    _add_skill("defiance", "Defiance", "Increases block chance.", SkillTree.DEFENDER, 12, 0, 0, 0, 0, 0.0, 0.0)
    _add_skill("wall", "Wall", "Become immune to knockback.", SkillTree.DEFENDER, 18, 0, 0, 0, 0, 12.0, 0.0)
    _add_skill("fervor", "Fervor", "Reduce non-physical damage taken.", SkillTree.DEFENDER, 24, 0, 0, 0, 0, 0.0, 0.0)
    
    # Marauder - Warrior
    _add_skill("battle_cry", "Battle Cry", "Shout that weakens enemies.", SkillTree.WARRIOR, 1, 3, 3, 6, 0, 0.0, 0.0)
    _add_skill("shout", "Shout", "Buff allies damage.", SkillTree.WARRIOR, 6, 5, 5, 10, 0, 0.0, 0.0)
    _add_skill("battle_orders", "Battle Orders", "Grant bonus life/mana.", SkillTree.WARRIOR, 12, 10, 0, 0, 0, 0.0, 60.0)
    _add_skill("grim_ward", "Grim Ward", "Aura that terrorizes enemies.", SkillTree.WARRIOR, 18, 8, 8, 15, 0, 0.0, 0.0)
    _add_skill("battle_command", "Battle Command", "Ready all skills.", SkillTree.WARRIOR, 24, 25, 0, 0, 0, 0.0, 180.0)
    
    # Sorceress - Fire
    _add_skill("fire_bolt", "Fire Bolt", "Hurl a bolt of fire.", SkillTree.FIRE, 1, 4, 4, 8, 1, 0.0, 0.0)
    _add_skill("inferno", "Inferno", "Channel fire at enemies.", SkillTree.FIRE, 6, 8, 8, 15, 1, 0.0, 0.0)
    _add_skill("fire_ball", "Fire Ball", "Hurl an explosive fireball.", SkillTree.FIRE, 12, 12, 15, 30, 1, 0.0, 0.0)
    _add_skill("fire_mastery", "Fire Mastery", "Passive fire damage boost.", SkillTree.FIRE, 18, 0, 0, 0, 0, 0.0, 0.0)
    _add_skill("meteor", "Meteor", "Summon a meteor.", SkillTree.FIRE, 24, 50, 40, 80, 1, 3.0, 0.0)
    _add_skill("hydra", "Hydra", "Summon a fire serpent.", SkillTree.FIRE, 30, 35, 20, 40, 1, 0.0, 0.0)
    
    # Sorceress - Cold
    _add_skill("ice_bolt", "Ice Bolt", "Hurl a bolt of ice.", SkillTree.COLD, 1, 3, 3, 6, 2, 0.0, 0.0)
    _add_skill("frost_nova", "Frost Nova", "Freeze enemies around.", SkillTree.COLD, 6, 10, 8, 15, 2, 15.0, 0.0)
    _add_skill("ice_blast", "Ice Blast", "Blast enemies with cold.", SkillTree.COLD, 12, 15, 10, 20, 2, 0.0, 0.0)
    _add_skill("cold_mastery", "Cold Mastery", "Passive cold damage boost.", SkillTree.COLD, 18, 0, 0, 0, 0, 0.0, 0.0)
    _add_skill("blizzard", "Blizzard", "Call down an ice storm.", SkillTree.COLD, 24, 50, 30, 60, 2, 2.0, 0.0)
    _add_skill("frozen_orb", "Frozen Orb", "Launch piercing cold.", SkillTree.COLD, 30, 40, 25, 50, 2, 0.5, 0.0)
    
    # Sorceress - Lightning
    _add_skill("charged_bolt", "Charged Bolt", "Hurl bolts of lightning.", SkillTree.LIGHTNING, 1, 2, 1, 4, 3, 0.0, 0.0)
    _add_skill("static_field", "Static Field", "Damage based on life.", SkillTree.LIGHTNING, 6, 5, 0, 0, 3, 2.5, 0.0)
    _add_skill("lightning", "Lightning", "Chain lightning attack.", SkillTree.LIGHTNING, 12, 12, 8, 16, 3, 0.0, 0.0)
    _add_skill("lightning_mastery", "Lightning Mastery", "Passive lightning boost.", SkillTree.LIGHTNING, 18, 0, 0, 0, 0, 0.0, 0.0)
    _add_skill("chain_lightning", "Chain Lightning", "Powerful chaining.", SkillTree.LIGHTNING, 24, 30, 25, 45, 3, 1.0, 0.0)
    _add_skill("thunder_storm", "Thunder Storm", "Storm strikes enemies.", SkillTree.LIGHTNING, 30, 40, 40, 70, 3, 3.0, 0.0)
    
    # Necromancer - Summoning
    _add_skill("skeleton", "Skeleton", "Raise a skeleton.", SkillTree.SUMMONING, 1, 10, 8, 15, 0, 0.0, 0.0)
    _add_skill("golem", "Golem", "Summon a golem.", SkillTree.SUMMONING, 6, 25, 20, 35, 0, 0.0, 60.0)
    _add_skill("skeleton_mage", "Skeleton Mage", "Raise skeleton mage.", SkillTree.SUMMONING, 12, 20, 12, 22, 0, 0.0, 0.0)
    _add_skill("revive", "Revive", "Revive a fallen enemy.", SkillTree.SUMMONING, 18, 50, 30, 50, 0, 0.0, 30.0)
    _add_skill("summon_mastery", "Summon Mastery", "Boost to all minions.", SkillTree.SUMMONING, 24, 0, 0, 0, 0, 0.0, 0.0)
    
    # Necromancer - Poison/Bone
    _add_skill("poison_dagger", "Poison Dagger", "Coat weapon in poison.", SkillTree.POISON_BONE, 1, 4, 3, 6, 4, 0.0, 0.0)
    _add_skill("bone_spear", "Bone Spear", "Fire a spear of bone.", SkillTree.POISON_BONE, 6, 10, 10, 20, 0, 0.0, 0.0)
    _add_skill("poison_explosion", "Poison Explosion", "Area poison damage.", SkillTree.POISON_BONE, 12, 18, 15, 30, 4, 5.0, 0.0)
    _add_skill("bone_spirit", "Bone Spirit", "Homing bone spirit.", SkillTree.POISON_BONE, 18, 25, 25, 45, 0, 0.0, 0.0)
    _add_skill("poison_nova", "Poison Nova", "Ring of poison.", SkillTree.POISON_BONE, 24, 45, 40, 70, 4, 20.0, 0.0)
    
    # Necromancer - Curse
    _add_skill("amplify_damage", "Amplify Damage", "Increase damage taken.", SkillTree.CURSE, 1, 4, 0, 0, 0, 0.0, 20.0)
    _add_skill("dim_vision", "Dim Vision", "Reduce enemy sight.", SkillTree.CURSE, 6, 8, 0, 0, 0, 0.0, 30.0)
    _add_skill("weaken", "Weaken", "Enemy deals less damage.", SkillTree.CURSE, 12, 10, 0, 0, 0, 0.0, 30.0)
    _add_skill("life_tap", "Life Tap", "Grant life steal.", SkillTree.CURSE, 18, 15, 0, 0, 0, 0.0, 60.0)
    _add_skill("decrepify", "Decrepify", "Slow and weaken.", SkillTree.CURSE, 24, 20, 0, 0, 0, 0.0, 30.0)
    _add_skill("lower_resist", "Lower Resist", "Lower resistances.", SkillTree.CURSE, 30, 30, 0, 0, 0, 0.0, 45.0)
    
    # Shadow - Martial Arts
    _add_skill("tiger_strike", "Tiger Strike", "Powerful charged strike.", SkillTree.MARTIAL, 1, 6, 6, 12, 0, 0.0, 0.0)
    _add_skill("cobra_strike", "Cobra Strike", "Life/mana steal strike.", SkillTree.MARTIAL, 6, 10, 10, 20, 0, 0.0, 0.0)
    _add_skill("dragon_claw", "Dragon Claw", "Dual claw attack.", SkillTree.MARTIAL, 12, 15, 15, 25, 0, 0.0, 0.0)
    _add_skill("phoenix_strike", "Phoenix Strike", "Elemental strike.", SkillTree.MARTIAL, 18, 20, 20, 35, 0, 0.0, 0.0)
    _add_skill("dragon_tail", "Dragon Tail", "Kick explosion.", SkillTree.MARTIAL, 24, 25, 25, 45, 0, 15.0, 0.0)
    
    # Shadow - Trickery
    _add_skill("fire_trap", "Fire Trap", "Place exploding trap.", SkillTree.TRICKERY, 1, 6, 8, 15, 1, 0.0, 0.0)
    _add_skill("lightning_trap", "Lightning Trap", "Place shocking trap.", SkillTree.TRICKERY, 6, 10, 10, 20, 3, 0.0, 0.0)
    _add_skill("wake_of_fire", "Wake of Fire", "Leave trail of fire.", SkillTree.TRICKERY, 12, 18, 6, 12, 1, 2.0, 0.0)
    _add_skill("blade_sentinel", "Blade Sentinel", "Throw spinning blade.", SkillTree.TRICKERY, 18, 15, 15, 25, 0, 0.0, 0.0)
    _add_skill("wake_of_inferno", "Wake of Inferno", "Powerful fire trail.", SkillTree.TRICKERY, 24, 30, 20, 40, 1, 3.0, 0.0)
    
    # Shadow - Shadow
    _add_skill("shadow_warrior", "Shadow Warrior", "Summon shadow copy.", SkillTree.SHADOW, 1, 15, 0, 0, 0, 0.0, 60.0)
    _add_skill("mind_blast", "Mind Blast", "Psychic blast stun.", SkillTree.SHADOW, 6, 12, 10, 20, 0, 0.0, 0.0)
    _add_skill("shadow_master", "Shadow Master", "Powerful shadow.", SkillTree.SHADOW, 12, 30, 0, 0, 0, 0.0, 120.0)
    _add_skill("venom", "Venom", "Deadly poison.", SkillTree.SHADOW, 18, 20, 15, 30, 4, 0.0, 0.0)
    _add_skill("death_sentry", "Death Sentry", "Trap hunts enemies.", SkillTree.SHADOW, 24, 40, 30, 55, 0, 0.0, 30.0)
    
    # Paladin - Holy Magic
    _add_skill("holy_bolt", "Holy Bolt", "Holy projectile.", SkillTree.HOLY, 1, 4, 8, 12, 5, 0.0, 0.0)
    _add_skill("blessed_hammer", "Blessed Hammer", "Consecuted hammer.", SkillTree.HOLY, 6, 12, 10, 18, 5, 0.0, 0.0)
    _add_skill("holy_shield", "Holy Shield", "Holy defense.", SkillTree.HOLY, 12, 15, 0, 0, 5, 0.0, 30.0)
    _add_skill("holy_fire", "Holy Fire", "Aura burns enemies.", SkillTree.HOLY, 18, 20, 15, 30, 1, 0.0, 0.0)
    _add_skill("sanctuary", "Sanctuary", "Aura damages undead.", SkillTree.HOLY, 24, 25, 25, 45, 2, 0.0, 0.0)
    _add_skill("fist_of_heavens", "Fist of Heavens", "Holy lightning.", SkillTree.HOLY, 30, 50, 50, 100, 5, 4.0, 0.0)
    
    # Paladin - Aura Defense
    _add_skill("prayer", "Prayer", "Aura heals allies.", SkillTree.AURA_DEFENSE, 1, 6, 0, 0, 0, 0.0, 5.0)
    _add_skill("resist_fire_aura", "Resist Fire", "Fire resistance.", SkillTree.AURA_DEFENSE, 6, 10, 0, 0, 0, 0.0, 5.0)
    _add_skill("resist_cold_aura", "Resist Cold", "Cold resistance.", SkillTree.AURA_DEFENSE, 12, 12, 0, 0, 0, 0.0, 5.0)
    _add_skill("resist_lightning_aura", "Resist Lightning", "Lightning resistance.", SkillTree.AURA_DEFENSE, 18, 15, 0, 0, 0, 0.0, 5.0)
    _add_skill("cleansing_aura", "Cleansing", "Reduce poison.", SkillTree.AURA_DEFENSE, 24, 20, 0, 0, 0, 0.0, 5.0)
    _add_skill("redemption_aura", "Redemption", "Convert enemies.", SkillTree.AURA_DEFENSE, 30, 30, 0, 0, 0, 0.0, 8.0)
    
    # Paladin - Aura Offense
    _add_skill("might_aura", "Might", "Increase party damage.", SkillTree.AURA_OFFENSE, 1, 6, 0, 0, 0, 0.0, 5.0)
    _add_skill("holy_freeze_aura", "Holy Freeze", "Freeze enemies.", SkillTree.AURA_OFFENSE, 6, 12, 0, 0, 0, 0.0, 5.0)
    _add_skill("thorns_aura", "Thorns", "Damage attackers.", SkillTree.AURA_OFFENSE, 12, 15, 0, 0, 0, 0.0, 5.0)
    _add_skill("concentration_aura", "Concentration", "Critical damage.", SkillTree.AURA_OFFENSE, 18, 20, 0, 0, 0, 0.0, 5.0)
    _add_skill("fanaticism_aura", "Fanaticism", "Attack speed.", SkillTree.AURA_OFFENSE, 24, 25, 0, 0, 0, 0.0, 5.0)
    _add_skill("conviction_aura", "Conviction", "Lower defenses.", SkillTree.AURA_OFFENSE, 30, 35, 0, 0, 0, 0.0, 8.0)

func _add_skill(id: String, name: String, desc: String, tree: SkillTree, req_lvl: int, mana: int, dmg_min: int, dmg_max: int, dmg_type: int, rad: float, dur: float):
    var skill = SkillDefinition.new()
    skill.id = id
    skill.name = name
    skill.description = desc
    skill.tree = tree
    skill.required_level = req_lvl
    skill.mana_cost = mana
    skill.damage_min = dmg_min
    skill.damage_max = dmg_max
    skill.damage_type = dmg_type
    skill.effect_radius = rad
    skill.duration = dur
    skills[id] = skill

func get_skill(skill_id: String) -> SkillDefinition:
    return skills.get(skill_id)

func get_skills_for_tree(tree: SkillTree) -> Array:
    var result = []
    for id in skills:
        if skills[id].tree == tree:
            result.append(id)
    return result

func get_class_trees(char_class: int) -> Array:
    return CLASS_TREES.get(char_class, [])
