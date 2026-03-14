## SoundManager.gd
## Handles all audio: music, SFX, ambient sounds

extends Node

# Sound categories
enum SoundCategory {
    MUSIC,
    SFX,
    AMBIENT,
    UI,
    VOICE
}

# Sound events for easy reference
enum SoundEvent {
    # UI
    UI_CLICK,
    UI_HOVER,
    UI_OPEN,
    UI_CLOSE,
    
    # Player
    PLAYER_ATTACK,
    PLAYER_HIT,
    PLAYER_DIE,
    PLAYER_LEVEL_UP,
    PLAYER_SKILL_USE,
    PLAYER_POTION_USE,
    PLAYER_TELEPORT,
    
    # Combat
    HIT_SLASH,
    HIT_BLUNT,
    HIT_BLOCK,
    HIT_CRITICAL,
    
    # Spells
    SPELL_FIRE,
    SPELL_ICE,
    SPELL_LIGHTNING,
    SPELL_HEAL,
    SPELL_TELEPORT,
    SPELL_SUMMON,
    
    # Environment
    FOOTSTEP_WALK,
    FOOTSTEP_RUN,
    DOOR_OPEN,
    DOOR_CLOSE,
    CHEST_OPEN,
    STAIRS,
    TELEPORT_PAD,
    
    # Items
    ITEM_PICKUP,
    ITEM_DROP,
    ITEM_EQUIP,
    ITEM_IDENTIFY,
    ITEM_REPAIR,
    
    # Monsters
    MONSTER_ATTACK,
    MONSTER_DIE,
    MONSTER_SPELL,
    BOSS_APPEAR,
    BOSS_DIE,
    
    # Quest
    QUEST_COMPLETE,
    QUEST_UPDATE,
    NPC_GREET,
    
    # Ambient
    AMBIENT_TOWN,
    AMBIENT_FOREST,
    AMBIENT_DUNGEON,
    AMBIENT_HELL,
    AMBIENT_RAIN,
    AMBIENT_THUNDER,
}

# Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9
var ambient_volume: float = 0.7
var ui_volume: float = 0.85

# Audio streams
var current_music: AudioStreamPlayer
var music_fade_tween: Tween
var sfx_players: Array = []
var ambient_player: AudioStreamPlayer

const MAX_SFX_PLAYERS: int = 8

# Sound paths (would be loaded from files)
var sound_paths: Dictionary = {}

# Music tracks
var music_tracks: Dictionary = {}

# Current state
var current_ambient: SoundEvent = SoundEvent.AMBIENT_TOWN
var is_muted: bool = false

signal volume_changed(category: SoundCategory, volume: float)
signal music_track_changed(track_name: String)
signal sound_played(event: SoundEvent)

func _ready() -> void:
    _initialize_audio_players()
    _load_sound_database()

func _initialize_audio_players() -> void:
    # Main music player
    current_music = AudioStreamPlayer.new()
    current_music.name = "MusicPlayer"
    current_music.bus = "Music"
    add_child(current_music)
    
    # Ambient player
    ambient_player = AudioStreamPlayer.new()
    ambient_player.name = "AmbientPlayer"
    ambient_player.bus = "Ambient"
    add_child(ambient_player)
    
    # SFX players pool
    for i in range(MAX_SFX_PLAYERS):
        var player = AudioStreamPlayer.new()
        player.name = "SFXPlayer_" + str(i)
        player.bus = "SFX"
        player.volume_db = 0
        sfx_players.append(player)
        add_child(player)

func _load_sound_database() -> void:
    # UI Sounds
    sound_paths[SoundEvent.UI_CLICK] = "res://assets/audio/sfx/ui/click.wav"
    sound_paths[SoundEvent.UI_HOVER] = "res://assets/audio/sfx/ui/hover.wav"
    sound_paths[SoundEvent.UI_OPEN] = "res://assets/audio/sfx/ui/open.wav"
    sound_paths[SoundEvent.UI_CLOSE] = "res://assets/audio/sfx/ui/close.wav"
    
    # Player Sounds
    sound_paths[SoundEvent.PLAYER_ATTACK] = "res://assets/audio/sfx/player/attack.wav"
    sound_paths[SoundEvent.PLAYER_HIT] = "res://assets/audio/sfx/player/hit.wav"
    sound_paths[SoundEvent.PLAYER_DIE] = "res://assets/audio/sfx/player/die.wav"
    sound_paths[SoundEvent.PLAYER_LEVEL_UP] = "res://assets/audio/sfx/player/levelup.wav"
    sound_paths[SoundEvent.PLAYER_SKILL_USE] = "res://assets/audio/sfx/player/skill.wav"
    sound_paths[SoundEvent.PLAYER_POTION_USE] = "res://assets/audio/sfx/player/potion.wav"
    sound_paths[SoundEvent.PLAYER_TELEPORT] = "res://assets/audio/sfx/player/teleport.wav"
    
    # Combat Sounds
    sound_paths[SoundEvent.HIT_SLASH] = "res://assets/audio/sfx/combat/slash.wav"
    sound_paths[SoundEvent.HIT_BLUNT] = "res://assets/audio/sfx/combat/blunt.wav"
    sound_paths[SoundEvent.HIT_BLOCK] = "res://assets/audio/sfx/combat/block.wav"
    sound_paths[SoundEvent.HIT_CRITICAL] = "res://assets/audio/sfx/combat/critical.wav"
    
    # Spell Sounds
    sound_paths[SoundEvent.SPELL_FIRE] = "res://assets/audio/sfx/spell/fire.wav"
    sound_paths[SoundEvent.SPELL_ICE] = "res://assets/audio/sfx/spell/ice.wav"
    sound_paths[SoundEvent.SPELL_LIGHTNING] = "res://assets/audio/sfx/spell/lightning.wav"
    sound_paths[SoundEvent.SPELL_HEAL] = "res://assets/audio/sfx/spell/heal.wav"
    sound_paths[SoundEvent.SPELL_TELEPORT] = "res://assets/audio/sfx/spell/teleport.wav"
    sound_paths[SoundEvent.SPELL_SUMMON] = "res://assets/audio/sfx/spell/summon.wav"
    
    # Environment Sounds
    sound_paths[SoundEvent.FOOTSTEP_WALK] = "res://assets/audio/sfx/environment/walk.wav"
    sound_paths[SoundEvent.FOOTSTEP_RUN] = "res://assets/audio/sfx/environment/run.wav"
    sound_paths[SoundEvent.DOOR_OPEN] = "res://assets/audio/sfx/environment/door_open.wav"
    sound_paths[SoundEvent.DOOR_CLOSE] = "res://assets/audio/sfx/environment/door_close.wav"
    sound_paths[SoundEvent.CHEST_OPEN] = "res://assets/audio/sfx/environment/chest.wav"
    sound_paths[SoundEvent.STAIRS] = "res://assets/audio/sfx/environment/stairs.wav"
    sound_paths[SoundEvent.TELEPORT_PAD] = "res://assets/audio/sfx/environment/teleport.wav"
    
    # Item Sounds
    sound_paths[SoundEvent.ITEM_PICKUP] = "res://assets/audio/sfx/item/pickup.wav"
    sound_paths[SoundEvent.ITEM_DROP] = "res://assets/audio/sfx/item/drop.wav"
    sound_paths[SoundEvent.ITEM_EQUIP] = "res://assets/audio/sfx/item/equip.wav"
    sound_paths[SoundEvent.ITEM_IDENTIFY] = "res://assets/audio/sfx/item/identify.wav"
    sound_paths[SoundEvent.ITEM_REPAIR] = "res://assets/audio/sfx/item/repair.wav"
    
    # Monster Sounds
    sound_paths[SoundEvent.MONSTER_ATTACK] = "res://assets/audio/sfx/monster/attack.wav"
    sound_paths[SoundEvent.MONSTER_DIE] = "res://assets/audio/sfx/monster/die.wav"
    sound_paths[SoundEvent.MONSTER_SPELL] = "res://assets/audio/sfx/monster/spell.wav"
    sound_paths[SoundEvent.BOSS_APPEAR] = "res://assets/audio/sfx/monster/boss_appear.wav"
    sound_paths[SoundEvent.BOSS_DIE] = "res://assets/audio/sfx/monster/boss_die.wav"
    
    # Quest Sounds
    sound_paths[SoundEvent.QUEST_COMPLETE] = "res://assets/audio/sfx/quest/complete.wav"
    sound_paths[SoundEvent.QUEST_UPDATE] = "res://assets/audio/sfx/quest/update.wav"
    sound_paths[SoundEvent.NPC_GREET] = "res://assets/audio/sfx/npc/greet.wav"
    
    # Music Tracks
    music_tracks["title"] = "res://assets/audio/music/title.ogg"
    music_tracks["act1_town"] = "res://assets/audio/music/act1_town.ogg"
    music_tracks["act1_wilderness"] = "res://assets/audio/music/act1_wild.ogg"
    music_tracks["act1_dungeon"] = "res://assets/audio/music/act1_dungeon.ogg"
    music_tracks["act1_boss"] = "res://assets/audio/music/act1_boss.ogg"
    music_tracks["act2_town"] = "res://assets/audio/music/act2_town.ogg"
    music_tracks["act2_desert"] = "res://assets/audio/music/act2_desert.ogg"
    music_tracks["act2_boss"] = "res://assets/audio/music/act2_boss.ogg"
    music_tracks["act3_town"] = "res://assets/audio/music/act3_town.ogg"
    music_tracks["act3_jungle"] = "res://assets/audio/music/act3_jungle.ogg"
    music_tracks["act3_boss"] = "res://assets/audio/music/act3_boss.ogg"
    music_tracks["act4_hell"] = "res://assets/audio/music/act4_hell.ogg"
    music_tracks["act4_boss"] = "res://assets/audio/music/act4_boss.ogg"
    music_tracks["act5_frozen"] = "res://assets/audio/music/act5_frozen.ogg"
    music_tracks["act5_boss"] = "res://assets/audio/music/act5_boss.ogg"
    music_tracks["diablo"] = "res://assets/audio/music/diablo.ogg"
    music_tracks["victory"] = "res://assets/audio/music/victory.ogg"
    music_tracks["death"] = "res://assets/audio/music/death.ogg"

# Play sound effects
func play_sfx(event: SoundEvent, volume_mod: float = 1.0) -> void:
    if is_muted or sfx_volume <= 0:
        return
    
    var path = sound_paths.get(event, "")
    if path == "":
        return
    
    # Find available player
    var player = _get_available_sfx_player()
    if not player:
        return
    
    # Load and play sound
    _load_and_play(player, path, sfx_volume * volume_mod)
    sound_played.emit(event)

func _get_available_sfx_player() -> AudioStreamPlayer:
    for player in sfx_players:
        if not player.playing:
            return player
    # All busy, use first one
    return sfx_players[0]

func _load_and_play(player: AudioStreamPlayer, path: String, volume: float) -> void:
    # In production, would preload the audio file
    # For now, just mark as played
    player.volume_db = linear_to_db(volume * master_volume)
    # player.stream = load(path)  # Would load actual file
    # player.play()
    pass

# Music functions
func play_music(track_name: String, fade_time: float = 2.0) -> void:
    if is_muted or music_volume <= 0:
        return
    
    var path = music_tracks.get(track_name, "")
    if path == "":
        return
    
    if current_music.playing:
        _fade_music_out(fade_time / 2.0)
    
    # Wait for fade then play new
    await get_tree().create_timer(fade_time / 2.0).timeout
    
    # current_music.stream = load(path)
    # current_music.volume_db = linear_to_db(music_volume * master_volume)
    # current_music.play()
    
    music_track_changed.emit(track_name)

func _fade_music_out(duration: float) -> void:
    if music_fade_tween:
        music_fade_tween.kill()
    
    music_fade_tween = create_tween()
    music_fade_tween.tween_property(current_music, "volume_db", -80, duration)
    music_fade_tween.tween_callback(current_music.stop)

func _fade_music_in(duration: float) -> void:
    current_music.volume_db = -80
    var target_db = linear_to_db(music_volume * master_volume)
    
    if music_fade_tween:
        music_fade_tween.kill()
    
    music_fade_tween = create_tween()
    music_fade_tween.tween_property(current_music, "volume_db", target_db, duration)

func stop_music(fade_time: float = 1.0) -> void:
    _fade_music_out(fade_time)

func play_title_music() -> void:
    play_music("title")

func play_act_music(act: int, zone_type: String) -> void:
    var track_name = "act" + str(act) + "_"
    
    match zone_type:
        "town":
            track_name += "town"
        "wilderness":
            if act == 1:
                track_name = "act1_wilderness"
            elif act == 2:
                track_name = "act2_desert"
            elif act == 3:
                track_name = "act3_jungle"
            else:
                track_name = "act" + str(act) + "_wilderness"
        "dungeon":
            track_name += "dungeon"
        "boss":
            track_name += "boss"
    
    play_music(track_name)

# Ambient sounds
func play_ambient(event: SoundEvent, fade_time: float = 2.0) -> void:
    if is_muted or ambient_volume <= 0:
        return
    
    var path = sound_paths.get(event, "")
    if path == "":
        return
    
    # ambient_player.stream = load(path)
    # ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
    # ambient_player.play()
    
    current_ambient = event

func stop_ambient(fade_time: float = 1.0) -> void:
    if ambient_player.playing:
        var tween = create_tween()
        tween.tween_property(ambient_player, "volume_db", -80, fade_time)
        tween.tween_callback(ambient_player.stop)

# Volume controls
func set_volume(category: SoundCategory, volume: float) -> void:
    volume = clamp(volume, 0.0, 1.0)
    
    match category:
        SoundCategory.MUSIC:
            music_volume = volume
            current_music.volume_db = linear_to_db(volume * master_volume)
        SoundCategory.SFX:
            sfx_volume = volume
        SoundCategory.AMBIENT:
            ambient_volume = volume
            ambient_player.volume_db = linear_to_db(volume * master_volume)
        SoundCategory.UI:
            ui_volume = volume
        SoundCategory.VOICE:
            pass  # Voice volume
    
    volume_changed.emit(category, volume)

func set_master_volume(volume: float) -> void:
    master_volume = clamp(volume, 0.0, 1.0)
    
    # Update all players
    current_music.volume_db = linear_to_db(music_volume * master_volume)
    ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
    
    volume_changed.emit(SoundCategory.MUSIC, music_volume)
    volume_changed.emit(SoundCategory.AMBIENT, ambient_volume)

func get_volume(category: SoundCategory) -> float:
    match category:
        SoundCategory.MUSIC: return music_volume
        SoundCategory.SFX: return sfx_volume
        SoundCategory.AMBIENT: return ambient_volume
        SoundCategory.UI: return ui_volume
    return 1.0

func toggle_mute() -> void:
    is_muted = not is_muted
    
    if is_muted:
        current_music.volume_db = -80
        ambient_player.volume_db = -80
    else:
        current_music.volume_db = linear_to_db(music_volume * master_volume)
        ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)

# Convenience methods for common sounds
func play_footstep(running: bool = false) -> void:
    play_sfx(SoundEvent.FOOTSTEP_WALK if not running else SoundEvent.FOOTSTEP_RUN)

func play_ui_click() -> void:
    play_sfx(SoundEvent.UI_CLICK)

func play_item_pickup() -> void:
    play_sfx(SoundEvent.ITEM_PICKUP)

func play_quest_complete() -> void:
    play_sfx(SoundEvent.QUEST_COMPLETE)

func play_monster_die() -> void:
    play_sfx(SoundEvent.MONSTER_DIE)

func play_boss_die() -> void:
    play_sfx(SoundEvent.BOSS_DIE)
    play_music("victory", 3.0)

func play_player_die() -> void:
    play_sfx(SoundEvent.PLAYER_DIE)
    play_music("death", 3.0)

func play_level_up() -> void:
    play_sfx(SoundEvent.PLAYER_LEVEL_UP)

# Crossfade between music tracks
func crossfade_music(from_track: String, to_track: String, duration: float = 3.0) -> void:
    # This would play both and crossfade
    play_music(to_track, duration)
