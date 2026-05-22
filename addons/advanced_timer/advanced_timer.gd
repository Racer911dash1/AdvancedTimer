@tool
@icon("res://addons/advanced_timer/advanced_timer.svg")
class_name AdvancedTimer
extends Timer
## An advanced timer class that extends the functionality of the [Timer] class.
##
## It adds a randomized timer to allow for randomized timeouts, while able to
## be consistent with the results by setting a specific seed.

## If [code]true[/code], the duration of the timer will be randomized
## between two ranges.
var random_timer: bool = false:
	set(value):
		if value == random_timer:
			return
		random_timer = value
		notify_property_list_changed()

## The minimum time required for the timer to end, in seconds.
var min_wait_time: float = 1.0:
	set(value):
		min_wait_time = value
		if max_wait_time < min_wait_time:
			max_wait_time = min_wait_time

## The maximum time required for the timer to end, in seconds.
var max_wait_time: float = 1.0:
	set(value):
		max_wait_time = value
		if min_wait_time > max_wait_time:
			min_wait_time = max_wait_time

## If [code]true[/code], the randomizer will use a specified seed.
var seeded: bool = false:
	set(value):
		if value == seeded:
			return
		seeded = value
		notify_property_list_changed()

## The seed that [RandomNumberGenerator] will use for randomizing the
## random timer.
var timer_seed: int = 0

var _rng := RandomNumberGenerator.new()

func _validate_property(property: Dictionary) -> void:
	if property["name"] in ["wait_time"]:
		property["usage"] = PROPERTY_USAGE_NONE


func _get_property_list() -> Array[Dictionary]:
	var property: Array[Dictionary] = []

	property.append({
		"name": "random_timer",
		"type": TYPE_BOOL,
	})
	if random_timer:
		property.append({
			"name": "min_wait_time",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.001,4096.0,0.001,exp,or_greater,suffix:s",
		})
		property.append({
			"name": "max_wait_time",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.001,4096.0,0.001,exp,or_greater,suffix:s",
		})
		property.append({
		"name": "seeded",
		"type": TYPE_BOOL,
		})
		if seeded:
			property.append({
				"name": "timer_seed",
				"type": TYPE_INT,
			})
	else:
		property.append({
			"name": "wait_time_",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.001,4096.0,0.001,exp,or_greater,suffix:s",
		})
	return property


func _property_get_revert(property: StringName) -> Variant:
	match property:
		"random_timer": return false
		"min_wait_time": return 1.0
		"max_wait_time": return 1.0
		"wait_time_": return 1.0
		"seeded": return false
		"timer_seed": return 0
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		"random_timer",
		"min_wait_time",
		"max_wait_time",
		"wait_time_",
		"seeded",
		"timer_seed",
	]


func _get(property: StringName) -> Variant:
	match property:
		"random_timer": return random_timer
		"seeded": return seeded
		"min_wait_time": return min_wait_time
		"max_wait_time": return max_wait_time
		"wait_time_": return wait_time
		"timer_seed": return timer_seed
	return null


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"random_timer":
			random_timer = value
			return true
		"seeded":
			seeded = value
			return true
		"min_wait_time":
			min_wait_time = value
			return true
		"max_wait_time":
			max_wait_time = value
			return true
		"wait_time_":
			wait_time = value
			return true
		"timer_seed":
			timer_seed = value
			return true
	return false


func _ready() -> void:
	if not Engine.is_editor_hint():
		timeout.connect(_on_timeout)

	if seeded:
		_rng.seed = timer_seed

	if autostart and not Engine.is_editor_hint():
		if random_timer:
			start_random()
		else:
			start(wait_time)


func _on_timeout() -> void:
	if not one_shot:
		if random_timer:
			start_random()
		else:
			start(wait_time)


## If [member random_timer] is [code]true[/code], then a random time between
## [member min_wait_time] and [member max_wait_time] will start.
func start_random() -> void:
	if !random_timer: return

	var randf_num = _rng.randf_range(min_wait_time, max_wait_time)
	start(randf_num)
