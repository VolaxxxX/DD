extends Node
# Persistent user settings: audio levels, graphics quality.
# Audio buses are created at startup so volume sliders work even on the
# default Master-only project. Autoloaded as "Settings".

const PATH := "user://settings.cfg"

var music_db: float = -16.0
var sfx_db: float = -8.0
var quality: int = 1               # 0=low, 1=mid, 2=high
var grain_amount: float = 0.06

const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

func _ready() -> void:
	_ensure_buses()
	_load()
	apply()

func _ensure_buses() -> void:
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK: return
	music_db = float(cfg.get_value("audio", "music_db", music_db))
	sfx_db = float(cfg.get_value("audio", "sfx_db", sfx_db))
	quality = int(cfg.get_value("graphics", "quality", quality))
	grain_amount = float(cfg.get_value("graphics", "grain", grain_amount))

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_db", music_db)
	cfg.set_value("audio", "sfx_db", sfx_db)
	cfg.set_value("graphics", "quality", quality)
	cfg.set_value("graphics", "grain", grain_amount)
	cfg.save(PATH)

func apply() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), music_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), sfx_db)
	# Quality applied at the rendering server level (anti-aliasing + msaa).
	var vp := get_viewport()
	if vp:
		match quality:
			0:
				vp.msaa_3d = Viewport.MSAA_DISABLED
				vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			1:
				vp.msaa_3d = Viewport.MSAA_2X
				vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			2:
				vp.msaa_3d = Viewport.MSAA_4X
				vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

func set_music_db(v: float) -> void:
	music_db = v; apply(); save()

func set_sfx_db(v: float) -> void:
	sfx_db = v; apply(); save()

func set_quality(q: int) -> void:
	quality = q; apply(); save()
