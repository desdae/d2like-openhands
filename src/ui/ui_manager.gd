## UIManager.gd
## Central UI management and panel coordination

extends CanvasLayer

# UI Panel references
@onready var main_hud: Control
@onready var inventory_panel: Control
@onready var stats_panel: Control
@onready var skills_panel: Control
@onready var menu_panel: Control
@onready var tooltip: Control

# Panel states
enum PanelState {
    CLOSED,
    OPEN
}

var panel_states: Dictionary = {
    "inventory": PanelState.CLOSED,
    "stats": PanelState.CLOSED,
    "skills": PanelState.CLOSED,
    "menu": PanelState.CLOSED
}

# UI themes
var current_theme: String = "dark_gothic"

signal panel_opened(panel_name: String)
signal panel_closed(panel_name: String)
signal tooltip_requested(item_data: Dictionary, position: Vector2)
signal tooltip_hidden()

func _ready() -> void:
    _create_ui_structure()
    _connect_signals()

func _create_ui_structure() -> void:
    # Main HUD (always visible)
    main_hud = _create_hud()
    add_child(main_hud)
    
    # Inventory Panel
    inventory_panel = _create_inventory_panel()
    inventory_panel.visible = false
    add_child(inventory_panel)
    
    # Stats Panel
    stats_panel = _create_stats_panel()
    stats_panel.visible = false
    add_child(stats_panel)
    
    # Skills Panel
    skills_panel = _create_skills_panel()
    skills_panel.visible = false
    add_child(skills_panel)
    
    # Menu Panel
    menu_panel = _create_menu_panel()
    menu_panel.visible = false
    add_child(menu_panel)
    
    # Tooltip (hidden by default)
    tooltip = _create_tooltip()
    tooltip.visible = false
    add_child(tooltip)

func _create_hud() -> Control:
    var hud = Control.new()
    hud.set_anchors_preset(Control.PRESET_FULL_RECT)
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Get viewport size
    var viewport_size = get_viewport().get_visible_rect().size
    
    # Health bar (bottom left)
    var hp_bar = _create_bar("hp_bar", Color(0.8, 0.1, 0.1), Vector2(20, viewport_size.y - 140), Vector2(200, 20))
    hud.add_child(hp_bar)
    
    # Mana bar (below HP)
    var mp_bar = _create_bar("mp_bar", Color(0.1, 0.2, 0.8), Vector2(20, viewport_size.y - 115), Vector2(200, 20))
    hud.add_child(mp_bar)
    
    # Stamina bar (below Mana)
    var stam_bar = _create_bar("stamina_bar", Color(0.3, 0.7, 0.2), Vector2(20, viewport_size.y - 90), Vector2(200, 20))
    hud.add_child(stam_bar)
    
    # Experience bar (above HP bar)
    var xp_bar = _create_bar("xp_bar", Color(0.7, 0.5, 0.1), Vector2(20, viewport_size.y - 165), Vector2(400, 10))
    hud.add_child(xp_bar)
    
    # Gold display
    var gold_label = Label.new()
    gold_label.name = "gold_label"
    gold_label.position = Vector2(20, viewport_size.y - 180)
    gold_label.text = "Gold: 0"
    gold_label.add_theme_font_size_override("font_size", 16)
    hud.add_child(gold_label)
    
    # Level display
    var level_label = Label.new()
    level_label.name = "level_label"
    level_label.position = Vector2(240, viewport_size.y - 135)
    level_label.text = "Lv. 1"
    level_label.add_theme_font_size_override("font_size", 20)
    hud.add_child(level_label)
    
    # Mini-map placeholder (top right)
    var minimap = Panel.new()
    minimap.name = "minimap"
    minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    minimap.position = Vector2(-120, 20)
    minimap.size = Vector2(100, 100)
    hud.add_child(minimap)
    
    # Action bar (bottom center)
    var action_bar = _create_action_bar()
    action_bar.set_anchors_preset(Control.PRESET_HORIZONTAL_CENTER)
    action_bar.position = Vector2(viewport_size.x / 2 - 200, viewport_size.y - 60)
    action_bar.size = Vector2(400, 50)
    hud.add_child(action_bar)
    
    # FPS counter (top left, debug)
    var fps_label = Label.new()
    fps_label.name = "fps_label"
    fps_label.position = Vector2(10, 10)
    fps_label.text = "FPS: 60"
    fps_label.add_theme_font_size_override("font_size", 12)
    hud.add_child(fps_label)
    
    return hud

func _create_bar(name: String, color: Color, pos: Vector2, size: Vector2) -> Control:
    var container = Panel.new()
    container.name = name
    container.position = pos
    container.size = size
    
    # Background
    var bg = ColorRect.new()
    bg.color = Color(0.2, 0.2, 0.2, 0.8)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    container.add_child(bg)
    
    # Fill
    var fill = ColorRect.new()
    fill.name = "fill"
    fill.color = color
    fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
    fill.offset_right = 0  # Will be updated dynamically
    container.add_child(fill)
    
    return container

func _create_action_bar() -> Control:
    var bar = HBoxContainer.new()
    bar.name = "action_bar"
    bar.size = Vector2(180, 50)
    bar.add_theme_constant_override("separation", 5)
    
    # Create 8 action slots
    for i in range(8):
        var slot = _create_action_slot(i)
        bar.add_child(slot)
    
    return bar

func _create_action_slot(index: int) -> Control:
    var slot = Panel.new()
    slot.custom_minimum_size = Vector2(40, 40)
    slot.name = "slot_" + str(index)
    
    # Border
    var border = ColorRect.new()
    border.color = Color(0.5, 0.5, 0.5)
    border.set_anchors_preset(Control.PRESET_FULL_RECT)
    border.offset_left = 1
    border.offset_top = 1
    border.offset_right = -1
    border.offset_bottom = -1
    slot.add_child(border)
    
    # Hotkey label
    var hotkey = Label.new()
    hotkey.name = "hotkey"
    hotkey.text = str(index + 1)
    hotkey.position = Vector2(2, 2)
    hotkey.add_theme_font_size_override("font_size", 10)
    slot.add_child(hotkey)
    
    return slot

func _create_inventory_panel() -> Control:
    var panel = PanelContainer.new()
    panel.name = "inventory_panel"
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.custom_minimum_size = Vector2(500, 400)
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    
    # Title
    var title = Label.new()
    title.text = "Inventory"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    vbox.add_child(title)
    
    # Main inventory grid
    var grid = _create_inventory_grid("inventory", 10, 4)
    vbox.add_child(grid)
    
    # Belt (potion slots)
    var belt_label = Label.new()
    belt_label.text = "Belt"
    belt_label.add_theme_font_size_override("font_size", 16)
    vbox.add_child(belt_label)
    
    var belt = _create_inventory_grid("belt", 10, 1)
    belt.custom_minimum_size = Vector2(400, 40)
    vbox.add_child(belt)
    
    panel.add_child(vbox)
    return panel

func _create_inventory_grid(grid_name: String, cols: int, rows: int) -> Control:
    var grid = GridContainer.new()
    grid.name = grid_name
    grid.columns = cols
    grid.add_theme_constant_override("h_separation", 2)
    grid.add_theme_constant_override("v_separation", 2)
    
    for i in range(cols * rows):
        var slot = _create_inventory_slot()
        grid.add_child(slot)
    
    return grid

func _create_inventory_slot() -> Control:
    var slot = Panel.new()
    slot.custom_minimum_size = Vector2(36, 36)
    
    var bg = ColorRect.new()
    bg.color = Color(0.15, 0.15, 0.15, 0.9)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    slot.add_child(bg)
    
    var border = ColorRect.new()
    border.color = Color(0.4, 0.4, 0.4)
    border.set_anchors_preset(Control.PRESET_FULL_RECT)
    border.offset_left = 1
    border.offset_top = 1
    border.offset_right = -1
    border.offset_bottom = -1
    slot.add_child(border)
    
    return slot

func _create_stats_panel() -> Control:
    var panel = PanelContainer.new()
    panel.name = "stats_panel"
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.custom_minimum_size = Vector2(400, 500)
    
    var scroll = ScrollContainer.new()
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 15)
    
    # Title
    var title = Label.new()
    title.text = "Character Stats"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    vbox.add_child(title)
    
    # Character info
    var info = _create_stat_section("Character")
    info.add_child(_create_stat_row("Name", "Hero"))
    info.add_child(_create_stat_row("Class", "Marauder"))
    info.add_child(_create_stat_row("Level", "1"))
    info.add_child(_create_stat_row("Experience", "0 / 500"))
    vbox.add_child(info)
    
    # Core stats
    var core = _create_stat_section("Core Attributes")
    core.add_child(_create_stat_row("Strength", "30"))
    core.add_child(_create_stat_row("Dexterity", "20"))
    core.add_child(_create_stat_row("Vitality", "25"))
    core.add_child(_create_stat_row("Energy", "10"))
    vbox.add_child(core)
    
    # Combat stats
    var combat = _create_stat_section("Combat")
    combat.add_child(_create_stat_row("Life", "120 / 120"))
    combat.add_child(_create_stat_row("Mana", "60 / 60"))
    combat.add_child(_create_stat_row("Stamina", "100 / 100"))
    combat.add_child(_create_stat_row("Defense", "0"))
    combat.add_child(_create_stat_row("Attack Rating", "0"))
    combat.add_child(_create_stat_row("Enhanced Damage", "0%"))
    combat.add_child(_create_stat_row("Critical Hit", "0%"))
    vbox.add_child(combat)
    
    # Resistances
    var resists = _create_stat_section("Resistances")
    resists.add_child(_create_stat_row("Fire", "0%"))
    resists.add_child(_create_stat_row("Cold", "0%"))
    resists.add_child(_create_stat_row("Lightning", "0%"))
    resists.add_child(_create_stat_row("Poison", "0%"))
    vbox.add_child(resists)
    
    # Leech
    var leech = _create_stat_section("Life & Mana")
    leech.add_child(_create_stat_row("Life Leech", "0%"))
    leech.add_child(_create_stat_row("Mana Leech", "0%"))
    vbox.add_child(leech)
    
    scroll.add_child(vbox)
    panel.add_child(scroll)
    
    return panel

func _create_stat_section(title: String) -> VBoxContainer:
    var vbox = VBoxContainer.new()
    
    var header = Label.new()
    header.text = title
    header.add_theme_font_size_override("font_size", 18)
    header.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
    vbox.add_child(header)
    
    var sep = HSeparator.new()
    vbox.add_child(sep)
    
    return vbox

func _create_stat_row(label: String, value: String) -> Control:
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 10)
    
    var lbl = Label.new()
    lbl.text = label
    lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(lbl)
    
    var val = Label.new()
    val.text = value
    val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hbox.add_child(val)
    
    return hbox

func _create_skills_panel() -> Control:
    var panel = PanelContainer.new()
    panel.name = "skills_panel"
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.custom_minimum_size = Vector2(600, 500)
    
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 20)
    
    # Skill trees list (left)
    var tree_list = VBoxContainer.new()
    tree_list.custom_minimum_size = Vector2(150, 0)
    
    var tree_title = Label.new()
    tree_title.text = "Skill Trees"
    tree_title.add_theme_font_size_override("font_size", 18)
    tree_list.add_child(tree_title)
    
    for i in range(3):
        var btn = Button.new()
        btn.text = "Tree " + str(i + 1)
        btn.custom_minimum_size = Vector2(0, 40)
        tree_list.add_child(btn)
    
    hbox.add_child(tree_list)
    
    # Skills grid (right)
    var skills_grid = GridContainer.new()
    skills_grid.columns = 4
    skills_grid.add_theme_constant_override("h_separation", 5)
    skills_grid.add_theme_constant_override("v_separation", 5)
    
    for i in range(20):
        var skill_icon = _create_skill_icon()
        skills_grid.add_child(skill_icon)
    
    hbox.add_child(skills_grid)
    
    panel.add_child(hbox)
    
    return panel

func _create_skill_icon() -> Control:
    var icon = Panel.new()
    icon.custom_minimum_size = Vector2(60, 60)
    icon.name = "skill_icon"
    
    var bg = ColorRect.new()
    bg.color = Color(0.2, 0.2, 0.2)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    icon.add_child(bg)
    
    var border = ColorRect.new()
    border.color = Color(0.5, 0.5, 0.3)
    border.set_anchors_preset(Control.PRESET_FULL_RECT)
    border.offset_left = 1
    border.offset_top = 1
    border.offset_right = -1
    border.offset_bottom = -1
    icon.add_child(border)
    
    return icon

func _create_menu_panel() -> Control:
    var panel = PanelContainer.new()
    panel.name = "menu_panel"
    panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20)
    vbox.set_anchors_preset(Control.PRESET_CENTER)
    
    # Title
    var title = Label.new()
    title.text = "PAUSED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 48)
    vbox.add_child(title)
    
    # Menu buttons
    var buttons = ["Resume", "Inventory", "Skills", "Stats", "Options", "Exit to Title"]
    for btn_text in buttons:
        var btn = Button.new()
        btn.text = btn_text
        btn.custom_minimum_size = Vector2(200, 40)
        btn.pressed.connect(_on_menu_button_pressed.bind(btn_text))
        vbox.add_child(btn)
    
    panel.add_child(vbox)
    
    return panel

func _create_tooltip() -> Control:
    var tooltip_panel = PanelContainer.new()
    tooltip_panel.name = "tooltip"
    tooltip_panel.z_index = 100
    tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 5)
    
    # Item name
    var name_label = Label.new()
    name_label.name = "name"
    name_label.add_theme_font_size_override("font_size", 16)
    vbox.add_child(name_label)
    
    # Item type
    var type_label = Label.new()
    type_label.name = "type"
    type_label.add_theme_font_size_override("font_size", 12)
    vbox.add_child(type_label)
    
    # Stats
    var stats_label = Label.new()
    stats_label.name = "stats"
    stats_label.add_theme_font_size_override("font_size", 12)
    vbox.add_child(stats_label)
    
    # Description
    var desc_label = Label.new()
    desc_label.name = "description"
    desc_label.add_theme_font_size_override("font_size", 11)
    vbox.add_child(desc_label)
    
    tooltip_panel.add_child(vbox)
    
    return tooltip_panel

func _connect_signals() -> void:
    # Connect to game manager for state changes
    GameManager.game_paused.connect(_on_game_paused)
    GameManager.game_over.connect(_on_game_over)
    
    # Connect to player manager for updates
    PlayerManager.player_level_up.connect(_on_player_level_up)

# Panel toggle functions
func toggle_inventory() -> void:
    _toggle_panel("inventory")

func toggle_stats() -> void:
    _toggle_panel("stats")

func toggle_skills() -> void:
    _toggle_panel("skills")

func toggle_menu() -> void:
    _toggle_panel("menu")

func _toggle_panel(panel_name: String) -> void:
    var panel: Control
    match panel_name:
        "inventory": panel = inventory_panel
        "stats": panel = stats_panel
        "skills": panel = skills_panel
        "menu": panel = menu_panel
    
    if not panel:
        return
    
    if panel.visible:
        panel.visible = false
        panel_states[panel_name] = PanelState.CLOSED
        panel_closed.emit(panel_name)
    else:
        # Close other panels
        for name in panel_states:
            if panel_states[name] == PanelState.OPEN:
                _close_panel(name)
        
        panel.visible = true
        panel_states[panel_name] = PanelState.OPEN
        panel_opened.emit(panel_name)
        
        # Update panel content
        match panel_name:
            "stats": _update_stats_panel()
            "skills": _update_skills_panel()

func _close_panel(panel_name: String) -> void:
    var panel: Control
    match panel_name:
        "inventory": panel = inventory_panel
        "stats": panel = stats_panel
        "skills": panel = skills_panel
        "menu": panel = menu_panel
    
    if panel:
        panel.visible = false
        panel_states[panel_name] = PanelState.CLOSED
        panel_closed.emit(panel_name)

func close_all_panels() -> void:
    for name in panel_states:
        if panel_states[name] == PanelState.OPEN:
            _close_panel(name)

# UI Update functions
func update_hud() -> void:
    var player = PlayerManager.get_current_player()
    if not player:
        return
    
    # Update HP bar
    var hp_bar = main_hud.get_node("hp_bar/fill")
    if hp_bar:
        var hp_percent = float(player.current_hp) / float(player.max_hp)
        hp_bar.size.x = 200 * hp_percent
    
    # Update MP bar
    var mp_bar = main_hud.get_node("mp_bar/fill")
    if mp_bar:
        var mp_percent = float(player.current_mp) / float(player.max_mp)
        mp_bar.size.x = 200 * mp_percent
    
    # Update Stamina bar
    var stam_bar = main_hud.get_node("stamina_bar/fill")
    if stam_bar:
        var stam_percent = float(player.current_stamina) / float(player.max_stamina)
        stam_bar.size.x = 200 * stam_percent
    
    # Update XP bar
    var xp_bar = main_hud.get_node("xp_bar/fill")
    if xp_bar:
        var exp_needed = player.get_experience_for_next_level()
        var xp_percent = float(player.experience) / float(exp_needed)
        xp_bar.size.x = 400 * xp_percent
    
    # Update gold
    var gold_label = main_hud.get_node("gold_label")
    if gold_label:
        gold_label.text = "Gold: " + str(player.gold)
    
    # Update level
    var level_label = main_hud.get_node("level_label")
    if level_label:
        level_label.text = "Lv. " + str(player.level)

func _update_stats_panel() -> void:
    var player = PlayerManager.get_current_player()
    if not player:
        return
    
    # This would update all the stat labels in the stats panel
    # For now, just refresh the panel
    pass

func _update_skills_panel() -> void:
    # Update skill icons based on player's class and unlocked skills
    pass

# Tooltip functions
func show_tooltip(item_data: Dictionary, position: Vector2) -> void:
    tooltip.visible = true
    tooltip.position = position + Vector2(15, 15)
    
    # Update tooltip content
    var name = tooltip.get_node("name")
    var type = tooltip.get_node("type")
    var stats = tooltip.get_node("stats")
    var desc = tooltip.get_node("description")
    
    if item_data.has("name"):
        name.text = item_data["name"]
        name.add_theme_color_override("font_color", _get_rarity_color(item_data.get("rarity", 0)))
    
    if item_data.has("base_type"):
        type.text = item_data["base_type"]
    
    # Build stats string
    var stats_text = ""
    if item_data.get("damage_min", 0) > 0:
        stats_text += "Damage: " + str(item_data["damage_min"]) + "-" + str(item_data.get("damage_max", 0)) + "\n"
    if item_data.get("defense", 0) > 0:
        stats_text += "Defense: " + str(item_data["defense"]) + "\n"
    if item_data.get("str_bonus", 0) > 0:
        stats_text += "+" + str(item_data["str_bonus"]) + " Strength\n"
    if item_data.get("dex_bonus", 0) > 0:
        stats_text += "+" + str(item_data["dex_bonus"]) + " Dexterity\n"
    if item_data.get("vit_bonus", 0) > 0:
        stats_text += "+" + str(item_data["vit_bonus"]) + " Vitality\n"
    if item_data.get("ene_bonus", 0) > 0:
        stats_text += "+" + str(item_data["ene_bonus"]) + " Energy\n"
    if item_data.get("fire_resist", 0) > 0:
        stats_text += "+" + str(item_data["fire_resist"]) + "% Fire Resist\n"
    if item_data.get("cold_resist", 0) > 0:
        stats_text += "+" + str(item_data["cold_resist"]) + "% Cold Resist\n"
    if item_data.get("lightning_resist", 0) > 0:
        stats_text += "+" + str(item_data["lightning_resist"]) + "% Lightning Resist\n"
    if item_data.get("poison_resist", 0) > 0:
        stats_text += "+" + str(item_data["poison_resist"]) + "% Poison Resist\n"
    if item_data.get("enhanced_damage", 0) > 0:
        stats_text += "+" + str(item_data["enhanced_damage"]) + "% Enhanced Damage\n"
    
    stats.text = stats_text
    
    if item_data.has("affixes"):
        desc.text = ", ".join(item_data["affixes"])
    
    tooltip_requested.emit(item_data, position)

func hide_tooltip() -> void:
    tooltip.visible = false
    tooltip_hidden.emit()

func _get_rarity_color(rarity: int) -> Color:
    match rarity:
        0: return Color(1, 1, 1)        # Normal - white
        1: return Color(0.6, 0.6, 1)    # Magic - blue
        2: return Color(1, 1, 0.2)     # Rare - yellow
        3: return Color(0.2, 0.9, 0.2) # Set - green
        4: return Color(1, 0.8, 0)     # Unique - gold
        5: return Color(1, 0.5, 0)     # Rune - orange
    return Color.WHITE

# Input handling
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        toggle_menu()
    elif event.is_action_pressed("ui_inventory"):
        toggle_inventory()
    elif event.is_action_pressed("ui_skills"):
        toggle_skills()
    elif event.is_action_pressed("ui_statistics"):
        toggle_stats()

# Signal handlers
func _on_game_paused(paused: bool) -> void:
    if paused:
        toggle_menu()

func _on_game_over(dead: bool) -> void:
    # Show death screen
    pass

func _on_player_level_up(player_id: int, new_level: int) -> void:
    update_hud()

func _on_menu_button_pressed(button_text: String) -> void:
    match button_text:
        "Resume":
            toggle_menu()
        "Inventory":
            _close_panel("menu")
            toggle_inventory()
        "Skills":
            _close_panel("menu")
            toggle_skills()
        "Stats":
            _close_panel("menu")
            toggle_stats()
        "Options":
            pass  # TODO
        "Exit to Title":
            get_tree().change_scene_to_file("res://src/world/main_menu.tscn")
