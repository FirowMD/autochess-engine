class_name AcWaveController
extends Node
## Class for controlling waves of enemies
## This class keeps info about passed waves
## And generates new waves according to known info

@export_group("General")
## Current wave index (starting from 1)
@export var wave_idx: int = 1
## How much waves are there in total
@export var wave_count: int = 10

@export_group("Advanced")
@export var game_controller: AcGameController = null

var current_wave: AcWave = null

signal wctrl_wave_generated(enemies)
signal wctrl_wave_ended(is_victory)


func _ready() -> void:
	setup_references()
	setup_waves()


func setup_references() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return
	game_controller = AcPctrl.get_game_controller(get_tree())


func setup_waves() -> void:
	for wave in get_children():
		if wave is AcWave:
			wave.wave_completed.connect(handler_wave_completed)
			wave.wave_failed.connect(handler_wave_failed)


func get_current_wave() -> int:
	return wave_idx


func get_wave_count() -> int:
	return wave_count


func start_wave() -> void:
	if current_wave != null and current_wave.is_active:
		return
		
	var waves = get_children().filter(func(node): return node is AcWave)
	if wave_idx > waves.size():
		push_error("no more waves")
		return
		
	current_wave = waves[wave_idx - 1]
	current_wave.start()
	wctrl_wave_generated.emit(current_wave.get_spawn_data())


func end_wave(is_victory: bool) -> void:
	if current_wave == null:
		return
	current_wave.end(false)
	wctrl_wave_ended.emit(is_victory)


func handler_wave_completed() -> void:
	if current_wave == null:
		return
	wave_idx += 1
	current_wave = null
	wctrl_wave_ended.emit(true)


func handler_wave_failed() -> void:
	if current_wave == null:
		return
	wave_idx += 1
	current_wave = null
	wctrl_wave_ended.emit(false)
