## SkillDatabase.gd
## Database for all skills and skill trees

extends Node

enum SkillTree {
    # Marauder
    BERSERKER,
    DEFENDER,
    WARRIOR,
    # Sorceress
    FIRE,
    COLD,
    LIGHTNING,
    # Shadow
    MARTIAL,
    TRICKERY,
    SHADOW,
    # Necromancer
    SUMMONING,
    POISON_BONE,
    CURSE,
    # Paladin
    AURA_DEFENSE,
    AURA_OFFENSE,
    HOLY,
}

class SkillDefinition:
    var id: String
    var name: String
    var description: String
    var tree: SkillTree
    var icon: String
    var max_level: int = 20
    var required_level: int = 1
    var required_skill: String = ""
    var required_skill_level: int = 1
    var mana_cost: int = 0
    var cooldown: float = 0.0
    var skill_type: int = 0
    var damage_type: int = 0
    var damage_min: int = 0
    var damage_max: int = 0
    var effect_radius: float = 0.0
    var duration: float = 0.0
    var projectiles: int = 1
    var pierce: float = 0.0

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
    _add_skill("bash", "Bash", "A powerful melee strike.", SkillTree.BERSERKER, 1, 5, 6.0, 0, 6, 10)
    _add_skill("berserker_rage", "Berserker Rage", "Enter a rage, increasing damage but decreasing defense.", SkillTree.BERSERKER, 6, 15, 30.0, 2, 0, 0)
    _add_skill("whirlwind", "Whirlwind", "Spin continuously, damaging all nearby enemies.", SkillTree.BERSERKER, 12, 25, 0.5, 0, 15, 25)
    _add_skill("frenzy", "Frenzy", "Dual wield attack speed boost.", SkillTree.BERSERKER, 18, 10, 5.0, 0, 10, 18)
    _add_skill("maul", "Maul", "Heavy damage with chance to stun.", SkillTree.BERSERKER, 24, 20, 8.0, 0, 20, 35)
    _add_skill("consumption", "Consumption", "Life steal on hit.", SkillTree.BERSERKER, 30, 0, 0.0, 0, 0, 0)
    
    # Marauder - Defender
    _add_skill("iron_skin", "Iron Skin", "Passively increases defense.", SkillTree.DEFENDER, 1, 0, 0.0, 0, 0, 0)
    _add_skill("war_cry", "War Cry", "Shout that weakens enemy defense.", SkillTree.DEFENDER, 6, 8, 20.0, 0, 5, 10)
    _add_skill("defiance", "Defiance", "Increases block chance.", SkillTree.DEFENDER, 12, 0, 0.0, 0, 0, 0)
    _add_skill("wall", "Wall", "Become immune to knockback.", SkillTree.DEFENDER, 18, 0, 12.0, 2, 0, 0)
    _add_skill("fervor", "Fervor", "Reduce all non-physical damage taken.", SkillTree.DEFENDER, 24, 0, 0.0, 0, 0, 0)
    
    # Marauder - Warrior
    _add_skill("battle_cry", "Battle Cry", "Shout that weakens enemy defense.", SkillTree.WARRIOR, 1, 3, 20.0, 0, 3, 6)
    _add_skill("shout", "Shout", "Buff allies' damage.", SkillTree.WARRIOR, 6, 5, 30.0, 0, 5, 10)
    _add_skill("battle_orders", "Battle Orders", "Grant bonus life/mana to party.", SkillTree.WARRIOR, 12, 10, 60.0, 0, 0, 0, 5.0)
    _add_skill("grim_ward", "Grim Ward", "Aura that terrorizes enemies.", SkillTree.WARRIOR, 18, 8, 45.0, 0, 8, 15)
    _add_skill("battle_command", "Battle Command", "Instantly ready all skills.", SkillTree.WARRIOR, 24, 25, 180.0, 0, 0, 0)
    
    # Sorceress - Fire
    _add_skill("fire_bolt", "Fire Bolt", "Hurl a bolt of fire.", SkillTree.FIRE, 1, 4, 0.0, 1, 4, 8)
    _add_skill("inferno", "Inferno", "Channel fire at enemies in front.", SkillTree.FIRE, 6, 8, 0.0, 1, 8, 15)
    _add_skill("fire_ball", "Fire Ball", "Hurl an explosive fireball.", SkillTree.FIRE, 12, 12, 0.0, 1, 15, 30)
    _add_skill("fire_mastery", "Fire Mastery", "Passive fire damage boost.", SkillTree.FIRE, 18, 0, 0.0, 0, 0, 0)
    _add_skill("meteor", "Meteor", "Summon a meteor from the sky.", SkillTree.FIRE, 24, 50, 3.0, 1, 40, 80)
    _add_skill("hydra", "Hydra", "Summon a multi-headed fire serpent.", SkillTree.FIRE, 30, 35, 0.0, 1, 20, 40)
    
    # Sorceress - Cold
    _add_skill("ice_bolt", "Ice Bolt", "Hurl a bolt of ice.", SkillTree.COLD, 1, 3, 0.0, 1, 3, 6)
    _add_skill("frost_nova", "Frost Nova", "Freeze enemies around you.", SkillTree.COLD, 6, 10, 15.0, 0, 8, 15)
    _add_skill("ice_blast", "Ice Blast", "Blast enemies with cold.", SkillTree.COLD, 12, 15, 0.0, 1, 10, 20)
    _add_skill("cold_mastery", "Cold Mastery", "Passive cold damage boost.", SkillTree.COLD, 18, 0, 0.0, 0, 0, 0)
    _add_skill("blizzard", "Blizzard", "Call down a devastating ice storm.", SkillTree.COLD, 24, 50, 2.0, 0, 30, 60)
    _add_skill("frozen_orb", "Frozen Orb", "Launch an orb of piercing cold.", SkillTree.COLD, 30, 40, 0.5, 0, 25, 50)
    
    # Sorceress - Lightning
    _add_skill("charged_bolt", "Charged Bolt", "Hurl bolts of lightning.", SkillTree.LIGHTNING, 1, 2, 0.0, 1, 1, 4)
    _add_skill("static_field", "Static Field", "Damage all enemies based on their life.", SkillTree.LIGHTNING, 6, 5, 2.5, 0, 0, 0)
    _add_skill("lightning", "Lightning", "Chain lightning attack.", SkillTree.LIGHTNING, 12, 12, 0.0, 1, 8, 16)
    _add_skill("lightning_mastery", "Lightning Mastery", "Passive lightning damage boost.", SkillTree.LIGHTNING, 18, 0, 0.0, 0, 0, 0)
    _add_skill("chain_lightning", "Chain Lightning", "Powerful chaining lightning.", SkillTree.LIGHTNING, 24, 30, 1.0, 0, 25, 45)
    _add_skill("thunder_storm", "Thunder Storm", "Summon storm that strikes nearby enemies.", SkillTree.LIGHTNING, 30, 40, 3.0, 0, 40, 70)
    
    # Necromancer - Summoning
    _add_skill("skeleton", "Skeleton", "Raise a skeleton warrior.", SkillTree.SUMMONING, 1, 10, 0.0, 0, 8, 15)
    _add_skill("golem", "Golem", "Summon a golem to fight for you.", SkillTree.SUMMONING, 6, 25, 60.0, 0, 20, 35)
    _add_skill("skeleton_mage", "Skeleton Mage", "Raise a skeleton that casts spells.", SkillTree.SUMMONING, 12, 20, 0.0, 0, 12, 22)
    _add_skill("revive", "Revive", "Revive a fallen enemy as your servant.", SkillTree.SUMMONING, 18, 50, 30.0, 0, 30, 50)
    _add_skill("summon_mastery", "Summon Mastery", "Passive boost to all minions.", SkillTree.SUMMONING, 24, 0, 0.0, 0, 0, 0)
    
    # Necromancer - Poison/Bone
    _add_skill("poison_dagger", "Poison Dagger", "Coat weapon in poison.", SkillTree.POISON_BONE, 1, 4, 10.0, 0, 3, 6)
    _add_skill("bone_spear", "Bone Spear", "Fire a spear of bone.", SkillTree.POISON_BONE, 6, 10, 0.0, 1, 10, 20)
    _add_skill("poison_explosion", "Poison Explosion", "Area poison damage.", SkillTree.POISON_BONE, 12, 18, 5.0, 0, 15, 30)
    _add_skill("bone_spirit", "Bone Spirit", "Homing bone spirit seeks enemies.", SkillTree.POISON_BONE, 18, 25, 0.0, 1, 25, 45)
    _add_skill("poison_nova", "Poison Nova", "Ring of poison around you.", SkillTree.POISON_BONE, 24, 45, 20.0, 0, 40, 70)
    
    # Necromancer - Curse
    _add_skill("amplify_damage", "Amplify Damage", "Curse enemy to take increased damage.", SkillTree.CURSE, 1, 4, 20.0, 0, 0, 0)
    _add_skill("dim_vision", "Dim Vision", "Curse enemy to have reduced sight.", SkillTree.CURSE, 6, 8, 30.0, 0, 0, 0)
    _add_skill("weaken", "Weaken", "Curse enemy to deal less damage.", SkillTree.CURSE, 12, 10, 30.0, 0, 0, 0)
    _add_skill("life_tap", "Life Tap", "Curse enemy to grant life steal to attackers.", SkillTree.CURSE, 18, 15, 60.0, 0, 0, 0)
    _add_skill("decrepify", "Decrepify", "Curse enemy to slow and weaken.", SkillTree.CURSE, 24, 20, 30.0, 0, 0, 0)
    _add_skill("lower_resist", "Lower Resist", "Curse enemy to lower resistances.", SkillTree.CURSE, 30, 30, 45.0, 0, 0, 0)
    
    # Shadow - Martial Arts
    _add_skill("tiger_strike", "Tiger Strike", "Charge up for a powerful strike.", SkillTree.MARTIAL, 1, 6, 0.0, 0, 6, 12)
    _add_skill("cobra_strike", "Cobra Strike", "Life/mana steal charged strike.", SkillTree.MARTIAL, 6, 10, 8.0, 0, 10, 20)
    _add_skill("dragon_claw", "Dragon Claw", "Dual claw attack.", SkillTree.MARTIAL, 12, 15, 4.0, 0, 15, 25)
    _add_skill("phoenix_strike", "Phoenix Strike", "Elemental charged strike.", SkillTree.MARTIAL, 18, 20, 10.0, 0, 20, 35)
    _add_skill("dragon_tail", "Dragon Tail", "Kick that creates an explosion.", SkillTree.MARTIAL, 24, 25, 15.0, 0, 25, 45)
    
    # Shadow - Trickery
    _add_skill("fire_trap", "Fire Trap", "Place a trap that explodes.", SkillTree.TRICKERY, 1, 6, 0.0, 0, 8, 15)
    _add_skill("lightning_trap", "Lightning Trap", "Place a shocking trap.", SkillTree.TRICKERY, 6, 10, 0.0, 0, 10, 20)
    _add_skill("wake_of_fire", "Wake of Fire", "Leave a trail of fire.", SkillTree.TRICKERY, 12, 18, 2.0, 0, 6, 12)
    _add_skill("blade_sentinel", "Blade Sentinel", "Throw a spinning blade.", SkillTree.TRICKERY, 18, 15, 6.0, 0, 15, 25)
    _add_skill("wake_of_inferno", "Wake of Inferno", "Powerful fire trail.", SkillTree.TRICKERY, 24, 30, 3.0, 0, 20, 40)
    
    # Shadow - Shadow
    _add_skill("shadow_warrior", "Shadow Warrior", "Summon a shadow copy.", SkillTree.SHADOW, 1, 15, 60.0, 0, 0, 0)
    _add_skill("mind_blast", "Mind Blast", "Stun enemies with psychic blast.", SkillTree.SHADOW, 6, 12, 10.0, 0, 10, 20)
    _add_skill("shadow_master", "Shadow Master", "Powerful shadow that fights for you.", SkillTree.SHADOW, 12, 30, 120.0, 0, 0, 0)
    _add_skill("venom", "Venom", "Deadly poison on attacks.", SkillTree.SHADOW, 18, 20, 0.0, 4, 15, 30)
    _add_skill("death_sentry", "Death Sentry", "Trap that hunts enemies.", SkillTree.SHADOW, 24, 40, 30.0, 0, 30, 55)
    
    # Paladin - Holy Magic
    _add_skill("holy_bolt", "Holy Bolt", "Holy projectile that heals allies/hurts undead.", SkillTree.HOLY, 1, 4, 0.0, 1, 8, 12)
    _add_skill("blessed_hammer", "Blessed Hammer", "Consecuted hammer that spins.", SkillTree.HOLY, 6, 12, 0.0, 1, 10, 18)
    _add_skill("holy_shield", "Holy Shield", "Add holy damage and defense.", SkillTree.HOLY, 12, 15, 30.0, 2, 0, 0)
    _add_skill("holy_fire", "Holy Fire", "Aura that burns enemies.", SkillTree.HOLY, 18, 20, 0.0, 1, 15, 30)
    _add_skill("sanctuary", "Sanctuary", "Aura that damages undead.", SkillTree.HOLY, 24, 25, 0.0, 2, 25, 45)
    _add_skill("fist_of_heavens", "Fist of the Heavens", "Powerful holy lightning.", SkillTree.HOLY, 30, 50, 4.0, 3, 50, 100)
    
    # Paladin - Aura Defense
    _add_skill("prayer", "Prayer", "Aura that heals nearby allies.", SkillTree.AURA_DEFENSE, 1, 6, 0.0, 0, 0, 0, 5.0)
    _add_skill("resist_fire", "Resist Fire", "Aura grants fire resistance.", SkillTree.AURA_DEFENSE, 6, 10, 0.0, 0, 0, 0, 5.0)
    _add_skill("resist_cold", "Resist Cold", "Aura grants cold resistance.", SkillTree.AURA_DEFENSE, 12, 12, 0.0, 0, 0, 0, 5.0)
    _add_skill("resist_lightning", "Resist Lightning", "Aura grants lightning resistance.", SkillTree.AURA_DEFENSE, 18, 15, 0.0, 0, 0, 0, 5.0)
    _add_skill("cleansing", "Cleansing", "Aura reduces poison duration.", SkillTree.AURA_DEFENSE, 24, 20, 0.0, 0, 0, 0, 5.0)
    _add_skill("redemption", "Redemption", "Aura converts enemies to allies.", SkillTree.AURA_DEFENSE, 30, 30, 0.0, 0, 0, 0, 8.0)
    
    # Paladin - Aura Offense
    _add_skill("might", "Might", "Aura increases party damage.", SkillTree.AURA_OFFENSE, 1, 6, 0.0, 0, 0, 0, 5.0)
    _add_skill("holy_freeze", "Holy Freeze", "Aura that freezes enemies.", SkillTree.AURA_OFFENSE, 6, 12, 0.0, 2, 0, 0, 5.0)
    _add_skill("thorns_aura", "Thorns", "Aura damages melee attackers.", SkillTree.AURA_OFFENSE, 12, 15, 0.0, 0, 0, 0, 5.0)
    _add_skill("concentration", "Concentration", "Aura increases party damage critically.", SkillTree.AURA_OFFENSE, 18, 20, 0.0, 0, 0, 0, 5.0)
    _add_skill("fanaticism", "Fanaticism", "Aura increases attack speed and damage.", SkillTree.AURA_OFFENSE, 24, 25, 0.0, 0, 0, 0, 5.0)
    _add_skill("conviction", "Conviction", "Aura lowers enemy defenses.", SkillTree.AURA_OFFENSE, 30, 35, 0.0, 0, 0, 0, 8.0)

func _add_skill(id: String, name: String, desc: String, tree: SkillTree, req_lvl: int, mana: int, dmg_min: int, dmg_max: int, dmg_type: int = 0, rad: float = 0.0) -> void:
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
