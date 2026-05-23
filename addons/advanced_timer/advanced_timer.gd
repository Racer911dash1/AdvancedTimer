@tool
@icon("res://addons/advanced_timer/advanced_timer.svg")
class_name AdvancedTimer
extends Timer
## An advanced countdown timer that extends the functionality of the [Timer] class.
##
## The [AdvancedTimer] node expands the [Timer] class by providing a wider
## set of functionalities.[br]
## While able to be used like any other timer, it also allows the user to set
## a random timer in a specified range.[br]
## By enabling rounding, the random timer can be further controlled on how it
## should be rounded.[br]
## Additionally a seed can be set to get consistent results with the
## randomized times.

enum Rounding {
	## Always round down to the nearest [member step]
	FLOOR,
	## Round to the nearest [member step]
	ROUND,
	## Always round up to the nearest [member step]
	CEIL,
}

const _MIN_TIME: float = 0.001

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

## If [code]true[/code], the randomized timeouts will be rounded to the nearest
## step.
## [br][br]
## However when rounding down to [code]0[/code], the value will always be
## clamped to [code]0.001[/code].
var rounded: bool = false:
	set(value):
		if value == rounded:
			return
		rounded = value
		notify_property_list_changed()

## How the timer should be rounded
var rounded_type: Rounding = Rounding.ROUND

## If [code]true[/code], clamps the wait time between [member min_wait_time]
## and [member max_wait_time] and prevents the rounding to go out of bounds.
var rounded_clamped: bool = false:
	set(value):
		if value == rounded_clamped:
			return
		rounded_clamped = value
		notify_property_list_changed()

## The step size of which the timer should round to.
var rounded_step: float = 1.0:
	set(value):
		rounded_step = maxf(value, _MIN_TIME)

## If [code]true[/code], the randomizer will use [member seeded_timer_seed] for
## to set the seed for [RandomNumberGenerator]
var seeded: bool = false:
	set(value):
		if value == seeded:
			return
		seeded = value
		notify_property_list_changed()

## The seed that will be set for [RandomNumberGenerator] to randomize the timer.
var seeded_timer_seed: int = 0:
	set(value):
		seeded_timer_seed = maxi(value, 0)

var _rng := RandomNumberGenerator.new()
var _prev_min_wait_time: float = 1.0
var _prev_max_wait_time: float = 1.0

## @deprecated: Use [method start_random] instead.
## To simulate [method start_random] as a normal timer, set
## [member min_wait_time] and [member max_wait_time] to the same value.
func start(time_sec: float = -1) -> void:
	start_random(time_sec, time_sec)

## Starts the timer between [member _min_wait_time] and [member _max_wait_time],
## with the length of the timer being a random value of up to 3 decimal places.
## If those values are greater than [code]0[/code], then they will be used
## instead of [member min_wait_time] and [member max_wait_time].
## [br]
## Calling this function with [param _min_wait_time] and [param _max_wait_time]
## being equal is the same as calling [method start]
## [br][br]
## [b]Note: [/b]If [param _max_wait_time] is less than [param _min_wait_time] or
## any argument is below [code]0.001[/code], no timer will be started and an
## error message will be pushed
func start_random(_min_wait_time: float = -1.0, _max_wait_time: float = -1.0) -> void:
	if _min_wait_time > _max_wait_time:
		assert(false, "_min_wait_time (%.3f) must not be larger than _max_wait_time (%.3f)" % [_min_wait_time, _max_wait_time])
		push_error("_min_wait_time (%.3f) must not be larger than _max_wait_time (%.3f)" % [_min_wait_time, _max_wait_time])
		return

	if _min_wait_time == -1.0:
		_min_wait_time = min_wait_time

	if _max_wait_time == -1.0:
		_max_wait_time = max_wait_time

	if _min_wait_time < _MIN_TIME:
		assert(false, "_min_wait_time (%.3f) smaller than %.3f" % [_min_wait_time, _MIN_TIME])
		push_error("_min_wait_time (%.3f) smaller than %.3f" % [_min_wait_time, _MIN_TIME])
		return

	if _max_wait_time < _MIN_TIME:
		assert(false, "_max_wait_time (%.3f) smaller than %.3f" % [_max_wait_time, _MIN_TIME])
		push_error("_max_wait_time (%.3f) smaller than %.3f" % [_max_wait_time, _MIN_TIME])
		return

	if _min_wait_time == _max_wait_time:
		super.start(_min_wait_time)
		return

	var random_time = snappedf(_rng.randf_range(_min_wait_time, _max_wait_time), 0.001)
	if rounded:
		match rounded_type:
			Rounding.FLOOR:
				if rounded_clamped == true:
					random_time = clampf(_snappedf_floor(random_time, rounded_step), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(_snappedf_floor(random_time, rounded_step), _MIN_TIME)
			Rounding.ROUND:
				if rounded_clamped == true:
					random_time = clampf(snappedf(random_time, rounded_step), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(snappedf(random_time, rounded_step), _MIN_TIME)
			Rounding.CEIL:
				if rounded_clamped == true:
					random_time = clampf(_snappedf_ceil(random_time, rounded_step), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(_snappedf_ceil(random_time, rounded_step), _MIN_TIME)

	_prev_min_wait_time = _min_wait_time
	_prev_max_wait_time = _max_wait_time
	super.start(random_time)


func _ready() -> void:
	if not Engine.is_editor_hint():
		timeout.connect(_on_timeout)

	if seeded:
		_rng.seed = seeded_timer_seed

	if autostart and not Engine.is_editor_hint():
		start_random()


func _on_timeout() -> void:
	if not one_shot:
		start_random(_prev_min_wait_time, _prev_max_wait_time)


func _validate_property(property: Dictionary) -> void:
	if property["name"] in ["wait_time"]:
		property["usage"] = PROPERTY_USAGE_NONE


func _get_property_list() -> Array[Dictionary]:
	var property: Array[Dictionary] = []

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
		"name": "Rounding",
		"type": TYPE_NIL,
		"hint_string": "rounded_",
		"usage": PROPERTY_USAGE_GROUP,
	})
	property.append({
		"name": "rounded",
		"type": TYPE_BOOL
	})
	if rounded:
		property.append({
			"name": "rounded_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Floor,Round,Ceil",
		})
		property.append({
			"name": "rounded_clamped",
			"type": TYPE_BOOL,
		})
		property.append({
			"name": "rounded_step",
			"type": TYPE_FLOAT,
		})
	property.append({
		"name": "Seeding",
		"type": TYPE_NIL,
		"hint_string": "seeded_",
		"usage": PROPERTY_USAGE_GROUP,
	})
	property.append({
	"name": "seeded",
	"type": TYPE_BOOL,
	})
	if seeded:
		property.append({
			"name": "seeded_timer_seed",
			"type": TYPE_INT,
		})
	return property


func _property_get_revert(property: StringName) -> Variant:
	match property:
		"min_wait_time": return 1.0
		"max_wait_time": return 1.0
		"rounded": return false
		"rounded_type": return Rounding.ROUND
		"rounded_clamped": return false
		"rounded_step": return 1.0
		"seeded": return false
		"seeded_timer_seed": return 0
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		"min_wait_time",
		"max_wait_time",
		"rounded",
		"rounded_type",
		"rounded_clamped",
		"rounded_step",
		"seeded",
		"seeded_timer_seed",
	]


func _get(property: StringName) -> Variant:
	match property:
		"min_wait_time": return min_wait_time
		"max_wait_time": return max_wait_time
		"rounded": return rounded
		"rounded_type": return rounded_type
		"rounded_clamped": return rounded_clamped
		"rounded_step": return rounded_step
		"seeded": return seeded
		"seeded_timer_seed": return seeded_timer_seed
	return null


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"min_wait_time":
			min_wait_time = value
			return true
		"max_wait_time":
			max_wait_time = value
			return true
		"rounded":
			rounded = value
			return true
		"rounded_type":
			rounded_type = value
			return true
		"rounded_clamped":
			rounded_clamped = value
			return true
		"rounded_step":
			rounded_step = value
			return true
		"seeded":
			seeded = value
			return true
		"seeded_timer_seed":
			seeded_timer_seed = value
			return true
	return false


func _snappedf_floor(value: float, step: float) -> float:
	return floorf(value / step) * step


func _snappedf_ceil(value: float, step: float) -> float:
	return ceilf(value / step) * step
