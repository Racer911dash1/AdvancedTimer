## An advanced countdown timer that extends the functionality of the [Timer] class.
##
## The [AdvancedTimer] node expands the [Timer] class by providing a wider
## set of functionalities.[br]
## While able to be used like any other timer, it also allows the user to set
## a random timer in a specified range.[br]
## By enabling rounding, the random timer can be further controlled on how it
## should be rounded.[br]
## Alternatively it also supports weighted randomness if a specific set of times
## are desired.[br]
## Additionally a seed can be set to get consistent results with the
## randomized times.
@tool
@icon("res://addons/advanced_timer/advanced_timer.svg")
class_name AdvancedTimer
extends Timer

## Emitted when the timer starts.[br]
## [param time] is the time in seconds until [signal Timer.timeout] is emitted.
signal timer_started(time: float)

enum Rounding {
	## Round down to the nearest [member step_size]
	FLOOR,
	## Round to the nearest [member step_size]
	ROUND,
	## Round up to the nearest [member step_size]
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
const _DEFAULT_SEED: Variant = null

@export_group("Random Timer")
#region Random Timer Variables

## The minimum time required for the timer to end, in seconds.
@export_range(0.001, 4096.0, 0.001, "or_greater", "suffix:s", "exp")
var min_wait_time: float = _DEFAULT_MIN_WAIT_TIME:
	set(value):
		value = maxf(value, _MIN_TIME)
		min_wait_time = value
		if max_wait_time < min_wait_time:
			max_wait_time = min_wait_time

## The maximum time required for the timer to end, in seconds.
@export_range(0.001, 4096.0, 0.001, "or_greater", "suffix:s", "exp")
var max_wait_time: float = _DEFAULT_MAX_WAIT_TIME:
	set(value):
		value = maxf(value, _MIN_TIME)
		max_wait_time = value
		if min_wait_time > max_wait_time:
			min_wait_time = max_wait_time

## If [code]true[/code], the randomized timeouts are rounded to the nearest
## [member step_size].
## [br][br]
## However when rounding down to [code]0[/code], the value is always
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
@export
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
			push_warning(
				"'rounding_type' is changed, but 'rounded' is false, \
						meaning rounding has no effect."
			)

## If [code]true[/code], clamps the wait time between [member min_wait_time]
## and [member max_wait_time] and prevents the rounding to go out of bounds.
## [codeblock]
## # clamped set to false
## start_random(1.2, 1.8) # Either 1.0 or 2.0
##
## # clamped set to true
## start_random(1.2, 1.8) # Either 1.2 or 1.8
## [/codeblock]
@export
var clamped: bool = _DEFAULT_CLAMPED:
	set(value):
		if value == clamped:
			return
		clamped = value
		if not rounded and clamped:
			push_warning(
				"'clamped' is set to true, but 'rounded' is false, \
						meaning clamping has no effect."
			)

## The step size of which the timer should round to.
## [br]
## Setting [member step_size] to [code]0[/code] is the same as setting
## [member rounded] to [code]false[/code]
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
			push_warning(
				"'step_size' is changed, but 'rounded' is false, \
						meaning step_size has no effect."
			)

#endregion Random Timer Variables

@export_group("Weighted Timer")
#region Weighted Timer Variables

## The [WeightedTimeTable] resource containing the time/weight pairs used by
## [method start_weighted].
## [codeblock]
## # To create and add a resource to a node via code you can do this.
## var plant_growth = WeightedTimeTable.new()
## plant_growth.add_time(40.0, 0.5)
## plant_growth.add_time(50.0, 1.0)
## plant_growth.add_time(60.0, 0.25)
##
## advanced_timer.weighted_times = plant_growth
## advanced_timer.start_weighed()
##
## # or pass it directly to the function like this
## var times := plant_growth.get_times()
## var weights := plant_growth.get_weights()
## advanced_timer.start_weighed(times, weights)
## [/codeblock]
@export var weighted_times: WeightedTimeTable = null:
	set(value):
		weighted_times = value
		notify_property_list_changed()

## Sort all entries in ascending order.[br]
## Main usage is it being a tool button in the inspector
@export_tool_button("Sort Pairs", "Sort") var sort_weighted_times := (func() -> void:
	weighted_times.time_weights.sort()
	notify_property_list_changed()
)

## Read-only shortcut to [member weighted_times]'s [member WeightedTimeTable.time_weights].[br]
## Returns an empty dictionary if [member weighted_times] is [code]null[/code].
## [codeblock]
## # Similar returns, but one is simpler to access.
## advanced_timer.weighted_times.time_weights
## advanced_timer.time_weights
## [/codeblock]
var time_weights: Dictionary[float, float]:
	get:
		return weighted_times.time_weights if weighted_times else { }

#endregion Weighted Timer Variables

@export_group("Timer Modifiers")
#region Timer Modifiers

## If [code]true[/code], a [b]static[/b] [RandomNumberGenerator] is used for
## randomized times that is shared between all instances of [AdvancedTimer].
@export var static_randomization: bool = false:
	set(value):
		if value == static_randomization:
			return
		static_randomization = value
		_set_seed(seed)

## The seed that is set for [RandomNumberGenerator] to randomize the timer.[br]
## If [code]null[/code], disables seeded time generation.
var seed: Variant = _DEFAULT_SEED:
	set(value):
		if value == seed:
			return
		seed = value
		_set_seed(seed)

#endregion Timer Modifiers

static var _rng_static := RandomNumberGenerator.new()
var _rng := RandomNumberGenerator.new()
var _prev_timer: Callable
var _prev_min_wait_time: float
var _prev_max_wait_time: float
var _prev_times: PackedFloat32Array
var _prev_weights: PackedFloat32Array


func _ready() -> void:
	if not Engine.is_editor_hint():
		timeout.connect(_on_timeout)

	_set_seed(seed)

	if autostart and not Engine.is_editor_hint():
		start_random()

#region Variable Properties

func _validate_property(property: Dictionary) -> void:
	const HIDE: Array[String] = ["wait_time"]
	if property.name in HIDE:
		property.usage = PROPERTY_USAGE_NONE

	if property.name == "seed":
		property.type = TYPE_INT
		property.usage = PROPERTY_USAGE_CHECKABLE | PROPERTY_USAGE_DEFAULT

	if property.name == "rounding_type":
		property.type = TYPE_INT
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = "Floor,Round,Ceil"
		property.usage = PROPERTY_USAGE_STORAGE
		if rounded:
			property.usage |= PROPERTY_USAGE_EDITOR

	if property.name == "clamped":
		property.type = TYPE_BOOL
		property.usage = PROPERTY_USAGE_STORAGE
		if rounded:
			property.usage |= PROPERTY_USAGE_EDITOR

	if property.name == "step_size":
		property.type = TYPE_FLOAT
		property.usage = PROPERTY_USAGE_STORAGE
		if rounded:
			property.usage |= PROPERTY_USAGE_EDITOR

	if property.name == "sort":
		property.type = TYPE_CALLABLE
		property.usage = PROPERTY_USAGE_STORAGE
		if weighted_times:
			property.usage |= PROPERTY_USAGE_EDITOR


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"min_wait_time":
			return _DEFAULT_MIN_WAIT_TIME
		&"max_wait_time":
			return _DEFAULT_MAX_WAIT_TIME
		&"static_randomization":
			return _DEFAULT_STATIC_RANDOMIZATION
		&"seed":
			return _DEFAULT_SEED
		&"rounded":
			return _DEFAULT_ROUNDED
		&"rounding_type":
			return _DEFAULT_ROUNDING_TYPE
		&"clamped":
			return _DEFAULT_CLAMPED
		&"step_size":
			return _DEFAULT_STEP_SIZE
	return null


func _property_can_revert(property: StringName) -> bool:
	return property in [
		&"min_wait_time",
		&"max_wait_time",
		&"static_randomization",
		&"seed",
		&"rounded",
		&"rounding_type",
		&"clamped",
		&"step_size",
	]

#endregion

## @deprecated: Use [method start_random] instead.
## To simulate [method start_random] as a normal timer, set
## [member min_wait_time] and [member max_wait_time] to the same value.
func start(time_sec: float = -1) -> void:
	start_random(time_sec, time_sec)


## [b]Description[/b][br]
## Starts the timer between [param min_time] and [param max_time].[br]
## If [param min_time] and [param max_time] are omitted, then [member min_wait_time]
## and [member max_wait_time] will be used.[br]
## If [param max_time] is smaller than [param min_time], its value will be set
## to match [param min_time].[br]
## [br][b]Signals[/b][br]
## [signal timer_started] upon function call.[br]
## [br][b]Returns[/b][br]
## The duration of the timer, somewhere between [param min_time] and [param max_time].[br]
func start_random(min_time: float = -1.0, max_time: float = -1.0) -> float:
	_prev_timer = start_random

	if min_time == -1.0:
		min_time = min_wait_time
	if max_time == -1.0:
		max_time = max_wait_time

	if min_time < _MIN_TIME:
		push_warning("min_time (%.3f) is smaller than %.3f" % [min_time, _MIN_TIME])
		min_time = _MIN_TIME
	if max_time < _MIN_TIME:
		push_warning("max_time (%.3f) is smaller than %.3f" % [max_time, _MIN_TIME])
		max_time = _MIN_TIME

	if min_time > max_time:
		push_warning(
			"min_time (%.3f) should not be larger than max_time (%.3f)" % [min_time, max_time]
		)
		max_time = min_time

	var random_time: float = _get_random_time(min_time, max_time)

	if rounded:
		random_time = _round_time(random_time, min_time, max_time)

	_prev_min_wait_time = min_time
	_prev_max_wait_time = max_time
	super.start(random_time)
	timer_started.emit(random_time)
	return random_time


## [b]Description[/b][br]
## Starts the timer using a random weighted duration.[br]
## If [param times] and [param weights] are omitted, then [member weighted_times] will be used.[br]
## If [param times] and [param weights] differ in size, then the larger will be resized to the
## smaller.[br]
## [br][b]Signals[/b][br]
## [signal timer_started] upon function call.[br]
## [br][b]Returns[/b][br]
## The duration of the timer, chosen from [param times].[br]
## [br][b]NOTE[/b][br]
## If [member weighted_times] is null or empty and the function gets called without both arguments,
## a fallback time of [code]1[/code] second gets started.
func start_weighted(times: PackedFloat32Array = [], weights: PackedFloat32Array = []) -> float:
	_prev_timer = start_weighted

	if (
		(weighted_times == null or time_weights.is_empty())
		and (times.is_empty() or weights.is_empty())
	):
		const FALLBACK_TIME: float = 1.0
		if weighted_times == null or time_weights.is_empty():
			push_warning(
				"Called start_weighted while weighted_times property is null or empty. \
			Falling back to a %d second timer"
				% FALLBACK_TIME
			)
		super.start(FALLBACK_TIME)
		timer_started.emit(FALLBACK_TIME)
		return FALLBACK_TIME

	if times.is_empty():
		times = weighted_times.get_times()
	if weights.is_empty():
		weights = weighted_times.get_weights()

	if times.size() > weights.size():
		push_warning("times is larger than weights, resizing it to match weights")
		times.resize(weights.size())
	if times.size() < weights.size():
		push_warning("weights is larger than times, resizing it to match times")
		weights.resize(times.size())

	_prev_times = times
	_prev_weights = weights
	var weighted_time = _get_weighted_time(times, weights)
	super.start(weighted_time)
	timer_started.emit(weighted_time)
	return weighted_time


func _get_random_time(min_time: float, max_time: float) -> float:
	if static_randomization:
		return _rng_static.randf_range(min_time, max_time)
	return _rng.randf_range(min_time, max_time)


func _get_weighted_time(times: PackedFloat32Array, weights: PackedFloat32Array) -> float:
	if static_randomization:
		return times[_rng_static.rand_weighted(weights)]
	return times[_rng.rand_weighted(weights)]


func _round_time(time: float, min_time: float, max_time: float) -> float:
	match rounding_type:
		Rounding.FLOOR:
			if clamped:
				return clampf(_snappedf_floor(time, step_size), min_time, max_time)
			return maxf(_snappedf_floor(time, step_size), _MIN_TIME)
		Rounding.ROUND:
			if clamped:
				return clampf(snappedf(time, step_size), min_time, max_time)
			return maxf(snappedf(time, step_size), _MIN_TIME)
		Rounding.CEIL:
			if clamped:
				return clampf(_snappedf_ceil(time, step_size), min_time, max_time)
			return maxf(_snappedf_ceil(time, step_size), _MIN_TIME)
		_:
			push_error("Missing rounding type")
			return time


func _set_seed(seed: Variant) -> void:
	if seed != null:
		if static_randomization:
			_rng_static.seed = seed
		else:
			_rng.seed = seed


func _on_timeout() -> void:
	if not one_shot:
		if _prev_timer == start_random:
			start_random(_prev_min_wait_time, _prev_max_wait_time)
		if _prev_timer == start_weighted:
			start_weighted(_prev_times, _prev_weights)


func _snappedf_floor(value: float, step: float) -> float:
	return floorf(value / step) * step


func _snappedf_ceil(value: float, step: float) -> float:
	return ceilf(value / step) * step
