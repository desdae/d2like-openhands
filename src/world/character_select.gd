## CharacterSelect.gd
## Character class selection screen

extends Control

signal class_selected(class_type: int)

var classes = [
    {"id": 0, "name": "Marauder", "desc": "Strong warrior with melee skills", "color": Color(0.8, 0.2, 0.2)},
    {"id": 1, "name": "Sorceress", "desc": "Master of elemental magic", "color": Color(0.2, 0.4, 0.8)},
    {"id": 2, "name": "Shadow", "desc": "Agile assassin with tricks", "color": Color(0.3, 0.3, 0.5)},
    {"id": 3, "name": "Necromancer", "desc": "Summoner of dead and curses", "color": Color(0.4, 0.6, 0.3)},
    {"id": 4, "name": "Paladin", "desc": "Holy warrior with auras", "color": Color(0.8, 0.7, 0.2)},
]

var selected_class: int = 0

func _ready() -> void:
    _create_ui()

func _create_ui() -> void:
    # Background
    var bg = ColorRect.new()
    bg.color = Color(0.05, 0.05, 0.1, 0.95)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # Title
    var title = Label.new()
    title.text = "Choose Your Class"
    title.set_anchors_preset(Control.PRESET_CENTER_TOP)
    title.position = Vector2(0, 50)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    add_child(title)
    
    # Class buttons
    var spacing = 180
    var start_x = get_viewport().get_visible_rect().size.x / 2 - (classes.size() * spacing) / 2
    
    for i in range(classes.size()):
        var cls = classes[i]
        var btn = Button.new()
        btn.text = cls["name"]
        btn.position = Vector2(start_x + i * spacing, 150)
        btn.size = Vector2(150, 200)
        btn.pressed.connect(_on_class_selected.bind(i))
        
        # Style
        var style = StyleBoxFlat.new()
        style.bg_color = Color(0.15, 0.15, 0.2)
        style.border_color = cls["color"]
        style.set_border_width_all(2)
        style.set_corner_radius_all(8)
        btn.add_theme_stylebox_override("normal", style)
        
        var style_hover = StyleBoxFlat.new()
        style_hover.bg_color = Color(0.2, 0.2, 0.3)
        style_hover.border_color = cls["color"]
        style_hover.set_border_width_all(3)
        style_hover.set_corner_radius_all(8)
        btn.add_theme_stylebox_override("hover", style_hover)
        
        add_child(btn)
        
        # Description
        var desc = Label.new()
        desc.text = cls["desc"]
        desc.position = Vector2(start_x + i * spacing, 360)
        desc.size = Vector2(150, 60)
        desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        desc.add_theme_font_size_override("font_size", 12)
        add_child(desc)
    
    # Select button
    var select_btn = Button.new()
    select_btn.text = "Select"
    select_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    select_btn.position = Vector2(-75, -100)
    select_btn.size = Vector2(150, 50)
    select_btn.pressed.connect(_on_select_pressed)
    add_child(select_btn)
    
    # Back button
    var back_btn = Button.new()
    back_btn.text = "Back"
    back_btn.position = Vector2(20, 20)
    back_btn.size = Vector2(100, 40)
    back_btn.pressed.connect(_on_back_pressed)
    add_child(back_btn)

func _on_class_selected(class_id: int) -> void:
    selected_class = class_id

func _on_select_pressed() -> void:
    # Store selected class in GameManager
    GameManager.selected_class = selected_class
    get_tree().change_scene_to_file("res://src/world/game.tscn")

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://src/world/main_menu.tscn")
