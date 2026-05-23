@tool
@icon("res://addons/advanced_timer/advanced_timer.svg")
class_name AdvancedTimer
extends Timer
## An advanced timer class that extends the functionality of the [Timer] class.
##
## It adds a randomized timer to allow for randomized timeouts, while able to
## be consistent with the results by setting a specific seed.

enum Rounding {
	## Always round down to the nearest [member step]
	FLOOR,
	## Round to the nearest [member step]
	ROUND,
	## Always round up to the nearest [member step]
	CEIL,
}

const _MIN_TIME: float = 0.001

## If [code]true[/code], the duration of the timer will be randomized
## between [member min_wait_time] and [member max_wait_time].
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

## If [code]true[/code], the randomized timeouts will be rounded to a full
## second.
## [br][br]
## However when rounding down to [code]0[/code], the value will always be clamped to
## [code]0.001[/code]
var rounded: bool = false:
	set(value):
		if value == rounded:
			return
		rounded = value
		notify_property_list_changed()

## How the timer should be rounded
var round_type: Rounding = Rounding.ROUND

## If [code]true[/code], clamps the wait time between [member min_wait_time]
## and [member max_wait_time] and prevents the rounding to go out of bounds.
var clamped: bool = false:
	set(value):
		if value == clamped:
			return
		clamped = value
		notify_property_list_changed()

## The step size of which the timer should round to.
var step: float = 1.0:
	set(value):
		step = maxf(value, _MIN_TIME)

## If [code]true[/code], the randomizer will use [member timer_seed] for
## its generations.
var seeded: bool = false:
	set(value):
		if value == seeded:
			return
		seeded = value
		notify_property_list_changed()

## The seed that [RandomNumberGenerator] will use for randomizing the timer.
var timer_seed: int = 0:
	set(value):
		timer_seed = maxi(value, 0)

var _rng := RandomNumberGenerator.new()
var _started_as_random: bool = false

## A random time between [member min_wait_time] and [member max_wait_time]
## will start if no arguments are provided, otherwise starts a timer between
## [param _min_wait_time] and [param _max_wait_time]
## [br][br]
## If [param _max_wait_time] is less than [param _min_wait_time], or
## any argument is below [code]0.001[/code], it will result in an error.
func start_random(_min_wait_time: float = -1.0, _max_wait_time: float = -1.0) -> void:
	_started_as_random = true

	if _min_wait_time > _max_wait_time:
		assert(false, "start_random: _min_wait_time (%f) must not be larger than _max_wait_time (%f)" % [_min_wait_time, _max_wait_time])
		push_error("start_random: _min_wait_time (%f) must not be larger than _max_wait_time (%f)" % [_min_wait_time, _max_wait_time])
		return

	if _min_wait_time == -1.0:
		_min_wait_time = min_wait_time
	if _max_wait_time == -1.0:
		_max_wait_time = max_wait_time

	if _min_wait_time < _MIN_TIME:
		assert(false, "start_random: _min_wait_time (%f) smaller than %f" % [_min_wait_time, _MIN_TIME])
		push_error("start_random: _min_wait_time (%f) smaller than %f" % [_min_wait_time, _MIN_TIME])
		return

	if _max_wait_time < _MIN_TIME:
		assert(false, "start_random: _max_wait_time (%f) smaller than %f" % [_max_wait_time, _MIN_TIME])
		push_error("start_random: _max_wait_time (%f) smaller than %f" % [_max_wait_time, _MIN_TIME])
		return

	var randf_num = _rng.randf_range(min_wait_time, max_wait_time)
	if rounded:
		match round_type:
			Rounding.FLOOR:
				if clamped == true:
					randf_num = clampf(_snappedf_floor(randf_num, step), _min_wait_time, _max_wait_time)
				else:
					randf_num = maxf(_snappedf_floor(randf_num, step), _MIN_TIME)
			Rounding.ROUND:
				if clamped == true:
					randf_num = clampf(snappedf(randf_num, step), _min_wait_time, _max_wait_time)
				else:
					randf_num = maxf(snappedf(randf_num, step), _MIN_TIME)
			Rounding.CEIL:
				if clamped == true:
					randf_num = clampf(_snappedf_ceil(randf_num, step), _min_wait_time, _max_wait_time)
				else:
					randf_num = maxf(_snappedf_ceil(randf_num, step), _MIN_TIME)

	start(randf_num)


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
		if _started_as_random:
			start_random()
		else:
			start(wait_time)


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
			"name": "rounded",
			"type": TYPE_BOOL
		})
		if rounded:
			property.append({
				"name": "round_type",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Floor,Round,Ceil",
			})
			property.append({
				"name": "clamped",
				"type": TYPE_BOOL,
			})
			property.append({
				"name": "step",
				"type": TYPE_FLOAT,
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
		"rounded": return false
		"round_type": return Rounding.ROUND
		"clamped": return false
		"step": return 1.0
		"seeded": return false
		"timer_seed": return 0
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		"random_timer",
		"min_wait_time",
		"max_wait_time",
		"wait_time_",
		"rounded",
		"round_type",
		"clamped",
		"step",
		"seeded",
		"timer_seed",
	]


func _get(property: StringName) -> Variant:
	match property:
		"random_timer": return random_timer
		"rounded": return rounded
		"round_type": return round_type
		"clamped": return clamped
		"step": return step
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
		"rounded":
			rounded = value
			return true
		"round_type":
			round_type = value
			return true
		"clamped":
			clamped = value
			return true
		"step":
			step = value
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


func _snappedf_floor(value: float, step: float) -> float:
	return floorf(value / step) * step


func _snappedf_ceil(value: float, step: float) -> float:
	return ceilf(value / step) * step
