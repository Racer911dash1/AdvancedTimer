@tool
@icon("res://addons/advanced_timer/advanced_timer.svg")
class_name AdvancedTimer
extends Timer
## An advanced countdown timer that extends the functionality of the [Timer] class.
##
## Outside of using it to start a predetermined countdown timer, this node also provides a random timer of equal distribution and weighted distribution.[br]
## The random times can be further tweaked by applying rounding rules, or forcing a specific seed for reliable timeouts.

## Emitted when the timer is started, with [param time] being time in seconds until [signal Timer.timeout] is emitted.[br]
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
const _DEFAULT_WEIGHTED_TIMES: WeightedTimeTable = null

#region Random Timer Variables
@export_group("Random Timer")
## The minimum time required for the timer to end, in seconds.[br]
## [b]Note:[/b] [member min_wait_time] is never greater than [member max_wait_time].
@export_range(0.001, 4096.0, 0.001, "or_greater", "suffix:s", "exp")
var min_wait_time: float = _DEFAULT_MIN_WAIT_TIME:
	set = set_min_wait_time

## The maximum time required for the timer to end, in seconds.[br]
## [b]Note:[/b] [member max_wait_time] is never less than [member min_wait_time].
@export_range(0.001, 4096.0, 0.001, "or_greater", "suffix:s", "exp")
var max_wait_time: float = _DEFAULT_MAX_WAIT_TIME:
	set = set_max_wait_time

## If [code]true[/code], the randomized timeouts are rounded to the nearest
## [member step_size].
## [codeblock]
## # Examples are truncated
## rounded = false
## start_random(1.0, 2.0) # 1.154
## start_random(1.0, 2.0) # 1.676
## start_random(1.0, 2.0) # 1.934
##
## rounded = true
## start_random(1.0, 2.0) # Either 1.0 or 2.0
## [/codeblock]
@export
var rounded: bool = _DEFAULT_ROUNDED:
	set = set_rounded

## How the timer should be rounded
## [codeblock]
## rounding_type = Rounding.FLOOR
## start_random(1.0, 2.0) # Always 1.0
##
## rounding_type = Rounding.ROUND
## start_random(1.0, 2.0) # Either 1.0 or 2.0
##
## rounding_type = Rounding.CEIL
## start_random(1.0, 2.0) # Always 2.0
## [/codeblock]
var rounding_type: Rounding = _DEFAULT_ROUNDING_TYPE:
	set = set_rounding_type

## If [code]true[/code], clamps the time between [member min_wait_time]
## and [member max_wait_time].
## [codeblock]
## clamped = false
## start_random(1.2, 1.8) # Either 1.0 or 2.0
##
## clamped = true
## start_random(1.2, 1.8) # Either 1.2 or 1.8
## [/codeblock]
@export
var clamped: bool = _DEFAULT_CLAMPED:
	set = set_clamped

## The step size of which the timer should round to.
## [br]
## Setting [member step_size] to [code]0.0[/code] is the same as setting
## [member rounded] to [code]false[/code]
## [codeblock]
## step_size = 1.0
## start_random(1.0, 2.0) # Either 1.0 or 2.0
##
## step_size = 0.5
## start_random(1.0, 2.0) # Either 1.0, 1.5 or 2.0
## [/codeblock]
var step_size: float = _DEFAULT_STEP_SIZE:
	set = set_step_size
#endregion Random Timer Variables

#region Weighted Timer Variables
@export_group("Weighted Timer")
## The [WeightedTimeTable] resource containing the time/weight pairs used by
## [method start_weighted].
## [codeblock]
## # Example of creating and adding a resource to a node via code.
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
@export var weighted_times: WeightedTimeTable = _DEFAULT_WEIGHTED_TIMES:
	set = set_weighted_times

## Sort all [member weighted_times] entries in ascending order.
@export_tool_button("Sort Pairs", "Sort")
var sort_weighted_times_action := (
	func() -> void:
		time_weights.sort()
		notify_property_list_changed()
)

## Read-only shortcut to [member weighted_times]'s [member WeightedTimeTable.time_weights].[br]
## Returns an empty dictionary if [member weighted_times] is [code]null[/code].
## [codeblock]
## # Similar returns, but one is simpler to access.
## # Good
## advanced_timer.time_weights
## # Bad
## advanced_timer.weighted_times.time_weights
## [/codeblock]
var time_weights: Dictionary[float, float]:
	get = get_time_weights
#endregion Weighted Timer Variables

#region Timer Modifiers
@export_group("Timer Modifiers")
## If [code]true[/code], a [b]static[/b] [RandomNumberGenerator] is used for
## randomized times that is shared between all instances of [AdvancedTimer].[br]
## [b]Note:[/b] Setting it also updates [member seed]
@export var static_randomization: bool = _DEFAULT_STATIC_RANDOMIZATION:
	set = set_static_randomization

## The seed that is set for [RandomNumberGenerator] to randomize the timer.[br]
## If [code]null[/code], disables seeded time generation by randomizing its seed.
var seed: Variant = _DEFAULT_SEED:
	set = set_seed
#endregion Timer Modifiers

static var _rng_static := RandomNumberGenerator.new()
var _rng := RandomNumberGenerator.new()
var _prev_timer: Callable
var _prev_min_wait_time: float
var _prev_max_wait_time: float
var _prev_times: PackedFloat32Array
var _prev_weights: PackedFloat32Array

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	timeout.connect(_on_timeout)
	if not seed == null:
		_set_rng_seed(seed)
	if autostart:
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

	if property.name == "sort_weighted_times_action":
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
#endregion Variable Properties

## @deprecated: Use [method start_random] instead.
## To simulate [method start_random] as a normal timer, set
## [member min_wait_time] and [member max_wait_time] to the same value.
func start(time_sec: float = -1.0) -> void:
	start_random(time_sec, time_sec)


## Starts the timer between [param min_time] and [param max_time].[br]
## If [param min_time] and [param max_time] are omitted, then [member min_wait_time]
## and [member max_wait_time] will be used.[br]
## If [param max_time] is smaller than [param min_time], its value will be set
## to match [param min_time].[br]
## [br][b]Signals[/b][br]
## Emits [signal timer_started] upon function call.[br]
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


## Starts the timer using a random weighted duration.[br]
## If [param times] and [param weights] are omitted, then [member weighted_times] will be used.[br]
## If [param times] and [param weights] differ in size, then the larger will be resized to the
## smaller.[br]
## [br][b]Signals[/b][br]
## Emits [signal timer_started] upon function call.[br]
## [br][b]Returns[/b][br]
## The duration of the timer, picked from [param times].[br]
## [br][b]Note[/b][br]
## If [member weighted_times] is null or empty and the function gets called without both arguments,
## a fallback time of [code]1.0[/code] second gets started.
func start_weighted(times: PackedFloat32Array = [], weights: PackedFloat32Array = []) -> float:
	_prev_timer = start_weighted

	if (
			(not weighted_times or time_weights.is_empty())
			and (times.is_empty() or weights.is_empty())
	):
		const FALLBACK_TIME: float = 1.0
		if weighted_times == null or time_weights.is_empty():
			push_warning(
					"Called start_weighted while weighted_times property is null or empty. \
					Falling back to a %d second timer" % FALLBACK_TIME
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


#region Setters and Getters
func set_min_wait_time(new_min_wait_time: float) -> void:
	if new_min_wait_time == min_wait_time:
		return
	min_wait_time = maxf(new_min_wait_time, _MIN_TIME)
	max_wait_time = maxf(min_wait_time, max_wait_time)


func set_max_wait_time(new_max_wait_time: float) -> void:
	if new_max_wait_time == max_wait_time:
		return
	max_wait_time = maxf(new_max_wait_time, _MIN_TIME)
	min_wait_time = minf(max_wait_time, min_wait_time)


func set_rounded(new_rounded: bool) -> void:
	if new_rounded == rounded:
		return
	rounded = new_rounded
	notify_property_list_changed()


func set_rounding_type(new_rounding_type: Rounding) -> void:
	rounding_type = new_rounding_type
	if not rounded and not rounding_type == _DEFAULT_ROUNDING_TYPE:
		push_warning(
				"'rounding_type' is changed, but 'rounded' is false, \
				meaning rounding has no effect."
			)


func set_clamped(new_clamped: bool) -> void:
	clamped = new_clamped
	if not rounded and clamped:
		push_warning(
				"'clamped' is set to true, but 'rounded' is false, \
				meaning clamping has no effect."
			)


func set_step_size(new_step_size: float) -> void:
	step_size = new_step_size
	if not rounded and not step_size == _DEFAULT_STEP_SIZE:
		push_warning(
				"'step_size' is changed, but 'rounded' is false, \
				meaning step_size has no effect."
			)


func set_weighted_times(new_weighted_times: WeightedTimeTable) -> void:
	if new_weighted_times == weighted_times:
		return
	weighted_times = new_weighted_times
	notify_property_list_changed()


func get_time_weights() -> Dictionary[float, float]:
	return weighted_times.time_weights if weighted_times else {}


func set_static_randomization(new_static_randomization: bool) -> void:
	static_randomization = new_static_randomization
	_set_rng_seed(seed)


func set_seed(new_seed: Variant) -> void:
	if new_seed == seed:
		return
	seed = new_seed
	_set_rng_seed(seed)
#endregion Setters and Getters


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


func _set_rng_seed(seed: Variant) -> void:
	if seed == null:
		if static_randomization:
			_rng_static.randomize()
		else:
			_rng.randomize()
		return

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
