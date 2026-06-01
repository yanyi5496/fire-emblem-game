extends Node

class_name AudioManager

enum Bus { MASTER = 0, BGM = 1, SFX = 2, VOICE = 3 }

var _current_bgm: AudioStreamPlayer = null
var _bgm_fade_tween = null

func play_bgm(bgm_id: String, fade_in: float = 0.5) -> void:
	var path := "res://assets/audio/bgm/%s.ogg" % bgm_id
	var stream := load(path) as AudioStream
	if not stream:
		push_warning("BGM not found: %s" % path)
		return
	_stop_current_bgm()
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "BGM"
	player.volume_db = -40.0 if fade_in > 0 else _get_volume_db(Bus.BGM)
	add_child(player)
	player.play()
	_current_bgm = player
	if fade_in > 0:
		_fade_in(player, fade_in)

func stop_bgm(fade_out: float = 0.5) -> void:
	if not _current_bgm:
		return
	if fade_out > 0:
		_fade_out_and_free(_current_bgm, fade_out)
	else:
		_current_bgm.stop()
		_current_bgm.queue_free()
		_current_bgm = null

func play_sfx(sfx_id: String) -> void:
	var path := "res://assets/audio/sfx/%s.wav" % sfx_id
	var stream := load(path) as AudioStream
	if not stream:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = _get_volume_db(Bus.SFX)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	if player.is_inside_tree():
		get_tree().create_timer(10.0).timeout.connect(func():
			if is_instance_valid(player):
				player.queue_free()
		)

func set_volume(bus: Bus, volume: int) -> void:
	AudioServer.set_bus_volume_db(bus, linear_to_db(volume / 100.0))

func _get_volume_db(bus: Bus) -> float:
	return AudioServer.get_bus_volume_db(bus)

func _stop_current_bgm() -> void:
	if _current_bgm:
		_current_bgm.stop()
		_current_bgm.queue_free()
		_current_bgm = null

func _fade_in(player: AudioStreamPlayer, duration: float) -> void:
	var tween := create_tween()
	_bgm_fade_tween = tween
	tween.tween_method(_set_bgm_volume, -40.0, 0.0, duration)

func _fade_out_and_free(player: AudioStreamPlayer, duration: float) -> void:
	_current_bgm = null
	var tween := create_tween()
	tween.tween_method(_fade_out_target, 0.0, -40.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
	)

func _set_bgm_volume(value: float) -> void:
	if _current_bgm:
		_current_bgm.volume_db = value

func _fade_out_target(value: float) -> void:
	pass