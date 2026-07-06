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
const _DEFAULT_STATIC_RANDOMIZATION: bool = false
const _DEFAULT_ROUNDED: bool = false
# For some reason it shows up in the Documentation if set to Rounding.ROUND
# TODO: Change typing to Rounding when Documentation is fixed.
const _DEFAULT_ROUNDING_TYPE: int = 1
const _DEFAULT_STEP_SIZE: float = 1.0
const _DEFAULT_CLAMPED: bool = false
const _DEFAULT_SEEDED: bool = false
const _DEFAULT_TIMER_SEED: Variant = null

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

## If [code]true[/code], a static [RandomNumberGenerator] will be used for
## randomized times that is shared between all instances of [AdvancedTimer].
## [br][br]
## [b]Note:[/b] Using this in combination with [member seeded] affects every
## other class of this type to follow that specified seed.
var static_randomization: bool = false:
	set(value):
		if value == static_randomization:
			return
		static_randomization = value

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

## The seed that will be set for [RandomNumberGenerator] to randomize the timer.
var timer_seed: Variant = _DEFAULT_TIMER_SEED:
	set(value):
		if value == timer_seed:
			return
		timer_seed = value

static var _rng_static := RandomNumberGenerator.new()
var _rng := RandomNumberGenerator.new()
var _prev_min_wait_time: float = 1.0
var _prev_max_wait_time: float = 1.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		timeout.connect(_on_timeout)

	if timer_seed != null:
		if static_randomization:
			_rng_static.seed = timer_seed
		else:
			_rng.seed = timer_seed

	if autostart and not Engine.is_editor_hint():
		start_random()


## @deprecated: Use [method start_random] instead.
## To simulate [method start_random] as a normal timer, set
## [member min_wait_time] and [member max_wait_time] to the same value.
func start(time_sec: float = -1) -> void:
	start_random(time_sec, time_sec)

## Starts the timer between [member min_time] and [member max_time].
## If the arguments are greater than [code]0[/code], then those will be used
## instead of [member min_wait_time] and [member max_wait_time].[br]
## Calling this function with [param min_time] and [param max_time]
## being equal is the same as calling [method start]
## [br][br]
## [b][color=yellow]Warning:[/color][/b] If [param max_time] is less than [param min_time].
## A timer of [param min_time] will start.[br]
## If any argument is below [code]0.001[/code], their value will be clamped to
## [code]0.001[/code].[br]
## Additionally in either of those cases, a warning will be pushed.
func start_random(min_time: float = -1.0, max_time: float = -1.0) -> void:
	if min_time == -1.0:
		min_time = min_wait_time
	if max_time == -1.0:
		max_time = max_wait_time

	if min_time < _MIN_TIME:
		push_warning("min_time (%.3f) is smaller than %.3f"
				% [min_time, _MIN_TIME])
		min_time = _MIN_TIME
	if max_time < _MIN_TIME:
		push_warning("max_time (%.3f) is smaller than %.3f"
				% [max_time, _MIN_TIME])
		max_time = _MIN_TIME

	if min_time > max_time:
		push_warning("min_time (%.3f) should not be larger than
					max_time (%.3f)" % [min_time, max_time])
		max_time = min_time

	var random_time: float
	if static_randomization:
		random_time = _rng_static.randf_range(min_time, max_time)
		print("_rng_static: ", _rng_static.seed)
	else:
		random_time = _rng.randf_range(min_time, max_time)
		print("_rng: ", _rng.seed)
	if rounded:
		match rounding_type:
			Rounding.FLOOR:
				if clamped:
					random_time = clampf(_snappedf_floor(random_time, step_size), min_time, max_time)
				else:
					random_time = maxf(_snappedf_floor(random_time, step_size), _MIN_TIME)
			Rounding.ROUND:
				if clamped:
					random_time = clampf(snappedf(random_time, step_size), min_time, max_time)
				else:
					random_time = maxf(snappedf(random_time, step_size), _MIN_TIME)
			Rounding.CEIL:
				if clamped:
					random_time = clampf(_snappedf_ceil(random_time, step_size), min_time, max_time)
				else:
					random_time = maxf(_snappedf_ceil(random_time, step_size), _MIN_TIME)

	_prev_min_wait_time = min_time
	_prev_max_wait_time = max_time
	super.start(random_time)
	timer_started.emit(random_time)


func _on_timeout() -> void:
	if not one_shot:
		start_random(_prev_min_wait_time, _prev_max_wait_time)

#region Variable Properties

func _validate_property(property: Dictionary) -> void:
	const HIDE: Array[String] = ["wait_time"]
	if property.name in HIDE:
		property.usage = PROPERTY_USAGE_NONE

	if property.name == "min_wait_time":
		property.type = TYPE_FLOAT
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "0.001,4096.0,0.001,exp,or_greater,suffix:s"
		property.usage = PROPERTY_USAGE_DEFAULT
	if property.name == "max_wait_time":
		property.type = TYPE_FLOAT
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "0.001,4096.0,0.001,exp,or_greater,suffix:s"
		property.usage = PROPERTY_USAGE_DEFAULT
	if property.name == "static_randomization":
		property.type = TYPE_BOOL
		property.usage = PROPERTY_USAGE_DEFAULT
	if property.name == "timer_seed":
		property.type = TYPE_INT
		property.usage = PROPERTY_USAGE_CHECKABLE | PROPERTY_USAGE_DEFAULT
	if property.name == "rounded":
		property.type = TYPE_BOOL
		property.usage = PROPERTY_USAGE_DEFAULT
	if property.name == "rounding_type":
		property.type = TYPE_INT
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = "Floor,Round,Ceil"
	if property.name == "clamped":
		property.type = TYPE_BOOL
	if property.name == "step_size":
		property.type = TYPE_FLOAT
	if property.name in ["rounding_type", "clamped", "step_size"]:
		property.usage = PROPERTY_USAGE_STORAGE
		if rounded:
			property.usage |= PROPERTY_USAGE_EDITOR


func _property_get_revert(property: StringName) -> Variant:
	match property:
		"min_wait_time": return _DEFAULT_MIN_WAIT_TIME
		"max_wait_time": return _DEFAULT_MAX_WAIT_TIME
		"static_randomization": return _DEFAULT_STATIC_RANDOMIZATION
		"rounded": return _DEFAULT_ROUNDED
		"rounding_type": return _DEFAULT_ROUNDING_TYPE
		"clamped": return _DEFAULT_CLAMPED
		"step_size": return _DEFAULT_STEP_SIZE
		"timer_seed": return _DEFAULT_TIMER_SEED
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		"min_wait_time",
		"max_wait_time",
		"static_randomization",
		"rounded",
		"rounding_type",
		"clamped",
		"step_size",
		"timer_seed",
	]

#endregion

func _snappedf_floor(value: float, step: float) -> float:
	return floorf(value / step) * step


func _snappedf_ceil(value: float, step: float) -> float:
	return ceilf(value / step) * step
