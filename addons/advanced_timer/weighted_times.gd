## A Resource pairing timer durations with selection weights, intended to be used with
## [method AdvancedTimer.start_weighted].[br]
@tool
class_name WeightedTimeTable
extends Resource

const _MIN_TIME: float = 0.001
const _MIN_WEIGHT: float = 0.0

## The time/weight pairs, where a key is the duration in seconds and the corresponding value
## its weight.[br]
## Keys are clamped to be at least [code]0.001[/code].[br]
## Values are clamped to be at least [code]0[/code].
@export var time_weights: Dictionary[float, float]:
	set(value):
		var clamped: Dictionary[float, float] = { }
		for key: float in value:
			var new_key := maxf(key, _MIN_TIME)
			var new_value := maxf(value[key], _MIN_WEIGHT)
			clamped[new_key] = new_value
		time_weights = clamped

## Add an entry to [member time_weights] with limit checking.[br]
## If [param time] is a non-positive number, it will be set to [code]0.001[/code] before being added
## to the dictionary.[br]
## If [param weight] is a negative number, it will be set to [code]0.0[/code] before being added to
## the dictionary.[br]
func add_time(time: float, weight: float) -> void:
	var new_time := maxf(time, _MIN_TIME)
	var new_weight := maxf(weight, _MIN_WEIGHT)
	time_weights[new_time] = new_weight


## Remove [param time] from [member time_weights].[br]
## Returns true if successfully removed, false otherwise.
func remove_time(time: float) -> bool:
	return time_weights.erase(time)

## Return true if [param time] is found in [member time_weights].
func has_time(time: float) -> bool:
	return time_weights.has(time)


## Returns all keys of [member time_weights].
func get_times() -> PackedFloat32Array:
	return PackedFloat32Array(time_weights.keys())


## Returns all values of [member time_weights].
func get_weights() -> PackedFloat32Array:
	return PackedFloat32Array(time_weights.values())
