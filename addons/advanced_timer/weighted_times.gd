@tool
class_name WeightedTime
extends Resource

const _MIN_TIME: float = 0.001
const _MIN_WEIGHT: float = 0.0

@export var pairs: Dictionary[float, float]:
	set(value):
		var clamped: Dictionary[float, float] = {}
		for key: float in value:
			var new_key := maxf(key, _MIN_TIME)
			var new_value := maxf(value[key], _MIN_WEIGHT)
			clamped[new_key] = new_value
		pairs = clamped

func get_times() -> PackedFloat32Array:
	return PackedFloat32Array(pairs.keys())

func get_weights() -> PackedFloat32Array:
	return PackedFloat32Array(pairs.values())
