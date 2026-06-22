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

## Emitted when the timer starts.
## [br]
## [param time] is the time in seconds until [signal Timer.timeout] is emitted.
signal timer_started(time: float)

enum Rounding {
	## Always round down to the nearest [member step_size]
	FLOOR,
	## Round to the nearest [member step_size]
	ROUND,
	## Always round up to the nearest [member step_size]
	CEIL,
}

const _MIN_TIME: float = 0.001
const _DEFAULT_MIN_WAIT_TIME: float = 1.0
const _DEFAULT_MAX_WAIT_TIME: float = 1.0
const _DEFAULT_ROUNDED: bool = false
# For some reason it shows up in the Documentation if set to Rounding.ROUND
# TODO: Change typing to Rounding when Documentation is fixed.
const _DEFAULT_ROUNDING_TYPE: int = 1
const _DEFAULT_STEP_SIZE: float = 1.0
const _DEFAULT_CLAMPED: bool = false
const _DEFAULT_SEEDED: bool = false
const _DEFAULT_TIMER_SEED: int = 0

## The minimum time required for the timer to end, in seconds.
var min_wait_time: float = _DEFAULT_MIN_WAIT_TIME:
	set(value):
		min_wait_time = value
		if max_wait_time < min_wait_time:
			max_wait_time = min_wait_time

## The maximum time required for the timer to end, in seconds.
var max_wait_time: float = _DEFAULT_MAX_WAIT_TIME:
	set(value):
		max_wait_time = value
		if min_wait_time > max_wait_time:
			min_wait_time = max_wait_time

## If [code]true[/code], the randomized timeouts will be rounded to the nearest
## [member step_size].
## [br][br]
## However when rounding down to [code]0[/code], the value will always be
## clamped to [code]0.001[/code].
## [codeblock]
## # rounded set to false
## start_random(1.0, 2.0) # 1.154
## start_random(1.0, 2.0) # 1.676
## start_random(1.0, 2.0) # 1.934
##
## # rounded set to true
## start_random(1.0, 2.0) # 2.0
## start_random(1.0, 2.0) # 1.0
## start_random(0.001, 1.0) # 0.001
## [/codeblock]
var rounded: bool = _DEFAULT_ROUNDED:
	set(value):
		if value == rounded:
			return
		rounded = value
		notify_property_list_changed()

## How the timer should be rounded
## [codeblock]
## rounding_type = Rounding.FLOOR
## start_random(1.0, 2.0) # Always 1.0
##
## rounding_type = Rounding.ROUND
## start_random(1.0, 2.0) # Either 1.0 or 2.0 depending on which is closer
##
## rounding_type = Rounding.CEIL
## start_random(1.0, 2.0) # Always 2.0
## [/codeblock]
var rounding_type: Rounding = _DEFAULT_ROUNDING_TYPE:
	set(value):
		if value == rounding_type:
			return
		rounding_type = value
		if not rounded and rounding_type != _DEFAULT_ROUNDING_TYPE:
			push_warning("'rounding_type' is changed, but 'rounded' is false, \
						meaning rounding will have no effect.")

## If [code]true[/code], clamps the wait time between [member min_wait_time]
## and [member max_wait_time] and prevents the rounding to go out of bounds.
## [codeblock]
## # clamped set to false
## start_random(1.2, 1.8) # Either 1.0 or 2.0
##
## # clamped set to true
## start_random(1.2, 1.8) # Either 1.2 or 1.8
## [/codeblock]
var clamped: bool = _DEFAULT_CLAMPED:
	set(value):
		if value == clamped:
			return
		clamped = value
		if not rounded and clamped:
			push_warning("'clamped' is set to true, but 'rounded' is false, \
						meaning clamping will have no effect.")

## The step size of which the timer should round to.
## [br]
## Setting [member step_size] to [code]0[/code] is the same as disabling
## [member rounded]
## [codeblock]
## step_size = 0.5
## start_random(1.0, 2.0) # 1.0
## start_random(1.0, 2.0) # 1.5
## start_random(1.0, 2.0) # 2.0
## [/codeblock]
var step_size: float = _DEFAULT_STEP_SIZE:
	set(value):
		if value == step_size:
			return
		step_size = value
		if not rounded and step_size != _DEFAULT_STEP_SIZE:
			push_warning("'step_size' is changed, but 'rounded' is false, \
						meaning step_size will have no effect.")

## If [code]true[/code], the randomizer will use [member timer_seed]
## to set the seed for [RandomNumberGenerator].
## [br]
## Using it will result in random, but consistent wait times.
var seeded: bool = _DEFAULT_SEEDED:
	set(value):
		if value == seeded:
			return
		seeded = value
		notify_property_list_changed()

## The seed that will be set for [RandomNumberGenerator] to randomize the timer.
var timer_seed: int = _DEFAULT_TIMER_SEED:
	set(value):
		timer_seed = value
		if not seeded and timer_seed != _DEFAULT_TIMER_SEED:
			push_warning("'timer_seed' is changed, but 'seeded' is false, \
						meaning timer_seed will have no effect.")

var _rng := RandomNumberGenerator.new()
var _prev_min_wait_time: float = 1.0
var _prev_max_wait_time: float = 1.0

## @deprecated: Use [method start_random] instead.
## To simulate [method start_random] as a normal timer, set
## [member min_wait_time] and [member max_wait_time] to the same value.
func start(time_sec: float = -1) -> void:
	start_random(time_sec, time_sec)

## Starts the timer between [member _min_wait_time] and [member _max_wait_time].
## If the arguments are greater than [code]0[/code], then those will be used
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
		push_error("_min_wait_time (%.3f) must not be larger than _max_wait_time (%.3f), \
					no timer has been started" % [_min_wait_time, _max_wait_time])
		return

	if _min_wait_time == -1.0:
		_min_wait_time = min_wait_time

	if _max_wait_time == -1.0:
		_max_wait_time = max_wait_time

	if _min_wait_time < _MIN_TIME:
		push_error("_min_wait_time (%.3f) is smaller than %.3f, no timer has been started" \
				% [_min_wait_time, _MIN_TIME])
		return

	if _max_wait_time < _MIN_TIME:
		push_error("_max_wait_time (%.3f) is smaller than %.3f, no timer has been started" \
				% [_max_wait_time, _MIN_TIME])
		return

	if _min_wait_time == _max_wait_time:
		super.start(_min_wait_time)
		return

	var random_time: float = _rng.randf_range(_min_wait_time, _max_wait_time)
	if rounded:
		match rounding_type:
			Rounding.FLOOR:
				if clamped:
					random_time = clampf(_snappedf_floor(random_time, step_size), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(_snappedf_floor(random_time, step_size), _MIN_TIME)
			Rounding.ROUND:
				if clamped:
					random_time = clampf(snappedf(random_time, step_size), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(snappedf(random_time, step_size), _MIN_TIME)
			Rounding.CEIL:
				if clamped:
					random_time = clampf(_snappedf_ceil(random_time, step_size), _min_wait_time, _max_wait_time)
				else:
					random_time = maxf(_snappedf_ceil(random_time, step_size), _MIN_TIME)

	_prev_min_wait_time = _min_wait_time
	_prev_max_wait_time = _max_wait_time
	super.start(random_time)
	timer_started.emit(random_time)


func _ready() -> void:
	if not Engine.is_editor_hint():
		timeout.connect(_on_timeout)

	if seeded:
		_rng.seed = timer_seed

	if autostart and not Engine.is_editor_hint():
		start_random()


func _on_timeout() -> void:
	if not one_shot:
		start_random(_prev_min_wait_time, _prev_max_wait_time)

#region Variable Properties

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
			"name": "rounded_step_size",
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
		"min_wait_time": return _DEFAULT_MIN_WAIT_TIME
		"max_wait_time": return _DEFAULT_MAX_WAIT_TIME
		"rounded": return _DEFAULT_ROUNDED
		"rounded_type": return _DEFAULT_ROUNDING_TYPE
		"rounded_clamped": return _DEFAULT_CLAMPED
		"rounded_step_size": return _DEFAULT_STEP_SIZE
		"seeded": return _DEFAULT_SEEDED
		"seeded_timer_seed": return _DEFAULT_TIMER_SEED
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		"min_wait_time",
		"max_wait_time",
		"rounded",
		"rounded_type",
		"rounded_clamped",
		"rounded_step_size",
		"seeded",
		"seeded_timer_seed",
	]


func _get(property: StringName) -> Variant:
	match property:
		"min_wait_time": return min_wait_time
		"max_wait_time": return max_wait_time
		"rounded": return rounded
		"rounded_type": return rounding_type
		"rounded_clamped": return clamped
		"rounded_step_size": return step_size
		"seeded": return seeded
		"seeded_timer_seed": return timer_seed
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
			rounding_type = value
			return true
		"rounded_clamped":
			clamped = value
			return true
		"rounded_step_size":
			step_size = value
			return true
		"seeded":
			seeded = value
			return true
		"seeded_timer_seed":
			timer_seed = value
			return true
	return false

#endregion

func _snappedf_floor(value: float, step: float) -> float:
	return floorf(value / step) * step


func _snappedf_ceil(value: float, step: float) -> float:
	return ceilf(value / step) * step
