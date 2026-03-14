## CutsceneManager.gd
## Handles cinematic sequences, dialogue, and camera movements

extends Node

signal cutscene_started(cutscene_id: String)
signal cutscene_ended(cutscene_id: String)
signal dialogue_started(dialogue_id: String)
signal dialogue_ended()
signal camera_moved(target: Vector2, duration: float)

# Cutscene element types
enum CutsceneElement {
    DIALOGUE,
    CAMERA_MOVE,
    CAMERA_ZOOM,
    FADE_IN,
    FADE_OUT,
    PLAY_SOUND,
    WAIT,
    SET_FLAG,
    CONDITION,
    ACTOR_MOVE,
    ACTOR_SPAWN,
    ACTOR_DESPAWN,
    SCREEN_SHAKE,
    SHOW_TEXT,
}

class CutsceneActor:
    var actor_id: String
    var sprite_path: String = ""
    var position: Vector2 = Vector2.ZERO
    var visible: bool = true
    var tint: Color = Color.WHITE

class DialogueLine:
    var speaker_id: String
    var speaker_name: String
    var text: String
    var duration: float = 3.0
    var voice_path: String = ""

class CutsceneEvent:
    var event_type: CutsceneElement
    var parameters: Dictionary = {}
    var duration: float = 0.0

class Cutscene:
    var cutscene_id: String
    var name: String
    var events: Array = []
    var repeatable: bool = true
    var conditions: Dictionary = {}

var cutscenes: Dictionary = {}
var active_cutscene: Cutscene = null
var current_event_index: int = 0
var event_timer: float = 0.0
var is_playing: bool = false
var skip_allowed: bool = true

var active_dialogue: Array = []
var current_dialogue_line: DialogueLine = null
var dialogue_box: Control = null
var is_dialogue_active: bool = false

var cutscene_flags: Dictionary = {}
var watched_cutscenes: Array = []

func _ready() -> void:
    _load_cutscenes()
    _setup_dialogue_box()

func _load_cutscenes() -> void:
    # Act 1 Intro
    _add_cutscene("intro_act1", "The Beginning", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 2.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The year is 1264...", "duration": 3.0}),
        _create_event(CutsceneElement.WAIT, {"duration": 1.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Darkness stirs in the East...", "duration": 3.0}),
        _create_event(CutsceneElement.WAIT, {"duration": 1.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "And the Prime Evils seek to plunge the world into eternal chaos.", "duration": 4.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.5}),
    ], false, {"act": 1})
    
    # Andariel Death
    _add_cutscene("andariel_death", "The Fall of Andariel", [
        _create_event(CutsceneElement.CAMERA_MOVE, {"position": Vector2(400, 300), "duration": 1.0}),
        _create_event(CutsceneElement.PLAY_SOUND, {"sound": "boss_die"}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Andariel falls!", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.0}),
    ])
    
    # Act 2 Intro
    _add_cutscene("intro_act2", "Journey East", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 2.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "With Andariel defeated, you head east...", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "To the vast deserts of Lut Gholein.", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.0}),
    ], false, {"act": 2})
    
    # Act 3 Intro
    _add_cutscene("intro_act3", "The Jungle", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 2.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The gateway to Hell awaits in Kurast...", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Where the Prime Evils gather their forces.", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.0}),
    ], false, {"act": 3})
    
    # Act 4 Intro
    _add_cutscene("intro_act4", "Into Hell", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 2.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "You step through the portal...", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Into the very heart of Hell itself.", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.0}),
    ], false, {"act": 4})
    
    # Diablo Intro
    _add_cutscene("diablo_appears", "The Dark Lord", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 3.0}),
        _create_event(CutsceneElement.PLAY_SOUND, {"sound": "boss_appear"}),
        _create_event(CutsceneElement.SCREEN_SHAKE, {"duration": 2.0, "intensity": 10.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Diablo!", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The Lord of Terror has awakened...", "duration": 3.0}),
    ])
    
    # Diablo Death
    _add_cutscene("diablo_death", "Victory Over Terror", [
        _create_event(CutsceneElement.CAMERA_MOVE, {"position": Vector2(400, 300), "duration": 1.0}),
        _create_event(CutsceneElement.PLAY_SOUND, {"sound": "boss_die"}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Diablo has been destroyed!", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 2.0}),
        _create_event(CutsceneElement.PLAY_SOUND, {"sound": "victory"}),
    ])
    
    # Act 5 Intro
    _add_cutscene("intro_act5", "The Frozen North", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 2.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The final battle awaits...", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "In the frozen mountains of Harrogath.", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "Where Baal, the Lord of Destruction, awaits.", "duration": 3.0}),
        _create_event(CutsceneElement.FADE_OUT, {"duration": 1.0}),
    ], false, {"act": 5})
    
    # Game Complete
    _add_cutscene("game_complete", "Victory", [
        _create_event(CutsceneElement.FADE_IN, {"duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The Prime Evils have been vanquished!", "duration": 4.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "The world is saved...", "duration": 3.0}),
        _create_event(CutsceneElement.SHOW_TEXT, {"text": "But darkness will return again...", "duration": 3.0}),
        _create_event(CutsceneElement.WAIT, {"duration": 2.0}),
        _create_event(CutsceneElement.PLAY_SOUND, {"sound": "victory"}),
    ], false)

func _create_event(event_type: CutsceneElement, params: Dictionary) -> CutsceneEvent:
    var event = CutsceneEvent.new()
    event.event_type = event_type
    event.parameters = params
    event.duration = params.get("duration", 0.0)
    return event

func _add_cutscene(cutscene_id: String, name: String, events: Array, repeatable: bool = true, conditions: Dictionary = {}) -> void:
    var cutscene = Cutscene.new()
    cutscene.cutscene_id = cutscene_id
    cutscene.name = name
    cutscene.events = events
    cutscene.repeatable = repeatable
    cutscene.conditions = conditions
    cutscenes[cutscene_id] = cutscene

func _setup_dialogue_box() -> void:
    dialogue_box = PanelContainer.new()
    dialogue_box.name = "DialogueBox"
    dialogue_box.visible = false
    
    var vbox = VBoxContainer.new()
    
    var speaker_label = Label.new()
    speaker_label.name = "SpeakerName"
    speaker_label.add_theme_font_size_override("font_size", 18)
    vbox.add_child(speaker_label)
    
    var text_label = Label.new()
    text_label.name = "DialogueText"
    text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_child(text_label)
    
    dialogue_box.add_child(vbox)
    add_child(dialogue_box)

func _process(delta: float) -> void:
    if not is_playing:
        return
    
    event_timer -= delta
    
    if event_timer <= 0:
        _play_next_event()

func _play_next_event() -> void:
    if current_event_index >= active_cutscene.events.size():
        _end_cutscene()
        return
    
    var event = active_cutscene.events[current_event_index]
    current_event_index += 1
    _execute_event(event)

func _execute_event(event: CutsceneEvent) -> void:
    match event.event_type:
        CutsceneElement.FADE_IN, CutsceneElement.FADE_OUT, CutsceneElement.SHOW_TEXT, CutsceneElement.WAIT:
            event_timer = event.duration
        CutsceneElement.CAMERA_MOVE:
            var pos = event.parameters.get("position", Vector2.ZERO)
            var dur = event.parameters.get("duration", 1.0)
            camera_moved.emit(pos, dur)
            event_timer = dur
        CutsceneElement.PLAY_SOUND:
            event_timer = 0.5
        CutsceneElement.SCREEN_SHAKE:
            event_timer = event.duration
        CutsceneElement.SET_FLAG:
            var flag = event.parameters.get("flag", "")
            var value = event.parameters.get("value", true)
            if flag != "":
                cutscene_flags[flag] = value
            event_timer = 0.1

func _end_cutscene() -> void:
    is_playing = false
    var cutscene_id = active_cutscene.cutscene_id
    
    if not active_cutscene.repeatable and not cutscene_id in watched_cutscenes:
        watched_cutscenes.append(cutscene_id)
    
    var ended_cutscene = active_cutscene
    active_cutscene = null
    current_event_index = 0
    
    cutscene_ended.emit(cutscene_id)

func skip_cutscene() -> void:
    if is_playing and skip_allowed:
        _end_cutscene()

func play_cutscene(cutscene_id: String) -> bool:
    if not cutscenes.has(cutscene_id):
        return false
    
    var cutscene = cutscenes[cutscene_id]
    
    if cutscene_id in watched_cutscenes and not cutscene.repeatable:
        return false
    
    is_playing = true
    active_cutscene = cutscene
    current_event_index = 0
    event_timer = 0
    
    cutscene_started.emit(cutscene_id)
    return true

func is_cutscene_playing() -> bool:
    return is_playing

func start_dialogue(dialogue_lines: Array) -> void:
    active_dialogue = dialogue_lines.duplicate()
    is_dialogue_active = true
    _show_next_dialogue()

func _show_next_dialogue() -> void:
    if active_dialogue.size() == 0:
        _end_dialogue()
        return
    
    current_dialogue_line = active_dialogue.pop_front()
    _display_dialogue_line(current_dialogue_line)

func _display_dialogue_line(line: DialogueLine) -> void:
    if not dialogue_box:
        return
    
    var speaker = dialogue_box.get_node("SpeakerName")
    var text = dialogue_box.get_node("DialogueText")
    
    speaker.text = line.speaker_name
    text.text = line.text
    
    dialogue_box.visible = true
    dialogue_started.emit(line.speaker_id)
    
    await get_tree().create_timer(line.duration).timeout
    _advance_dialogue()

func _advance_dialogue() -> void:
    _show_next_dialogue()

func close_dialogue() -> void:
    active_dialogue.clear()
    _end_dialogue()

func _end_dialogue() -> void:
    is_dialogue_active = false
    current_dialogue_line = null
    if dialogue_box:
        dialogue_box.visible = false
    dialogue_ended.emit()

func is_dialogue_active() -> bool:
    return is_dialogue_active

func set_flag(flag: String, value: bool = true) -> void:
    cutscene_flags[flag] = value

func get_flag(flag: String) -> bool:
    return cutscene_flags.get(flag, false)

func has_flag(flag: String) -> bool:
    return cutscene_flags.has(flag)

func play_act_intro(act: int) -> void:
    play_cutscene("intro_act" + str(act))

func play_boss_death(boss_name: String) -> void:
    play_cutscene(boss_name + "_death")

func has_watched_cutscene(cutscene_id: String) -> bool:
    return cutscene_id in watched_cutscenes
