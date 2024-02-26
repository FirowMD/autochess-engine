class_name AcGameTimer
extends Node


const NAME_TIMER = "Timer"
const NAME_LABEL = "Label"


@export var game_time_sec: int = 0
@export var timer: Timer = null
@export var label: Label = null

var alarm_list: Array = []

func setup_counting_up() -> void:
	timer.connect("timeout", update_time)
	timer.start()


func get_pretty_time_string() -> String:
	var hours = floor(game_time_sec / 3600.0)
	var minutes = floor((game_time_sec - hours * 3600) / 60.0)
	var seconds = game_time_sec - hours * 3600 - minutes * 60
	var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]

	return time_string


func get_pretty_time_string_minutes() -> String:
	var minutes = floor(game_time_sec / 60.0)
	var seconds = game_time_sec - minutes * 60
	var time_string = "%02d:%02d" % [minutes, seconds]

	return time_string


func get_time() -> int:
	return game_time_sec


func update_time() -> void:
	game_time_sec += 1
	label.text = get_pretty_time_string_minutes()

	for alarm in alarm_list:
		if alarm["time"] == game_time_sec:
			alarm["function"].call(alarm["object"], alarm["args"])
			alarm_list.erase(alarm)


# Pass `foo` - function, and `time` - how many seconds to wait to call `foo`
func add_alarm_event(obj: Object, foo: Callable, wait_time: int, args: Array = []) -> void:
	var alarm = Dictionary()
	alarm["object"] = obj
	alarm["function"] = foo
	alarm["time"] = wait_time + game_time_sec
	alarm["args"] = args
	alarm_list.append(alarm)


func auto_setup() -> void:
	var children = get_children()
	for child in children:
		# Check names instead of types
		if child.name == NAME_TIMER:
			timer = child
		elif child.name == NAME_LABEL:
			label = child

func check_setup() -> bool:
	if timer == null:
		push_error("timer is not set")
		return false
	if label == null:
		push_error("label is not set")
		return false
	
	return true


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	setup_counting_up()
