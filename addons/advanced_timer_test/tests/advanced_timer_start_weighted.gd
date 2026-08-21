# GdUnit generated TestSuite
class_name AdvancedTimerStartWeightedTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const _SOURCE: String = 'res://addons/advanced_timer/advanced_timer.gd'


func test_single_entry() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)
	var weights_array := WeightedTimeTable.new()
	weights_array.time_weights[0.1] = 2.0
	timer.weighted_times = weights_array

	var length = timer.start_weighted()
	assert_float(length).is_equal_approx(0.1, 0.000001)


func test_multiple_entries() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)
	var weights_array := WeightedTimeTable.new()
	weights_array.time_weights[1.0] = 2.0
	weights_array.time_weights[2.0] = 1.0
	weights_array.time_weights[4.0] = 5.0
	timer.weighted_times = weights_array

	for idx in 10:
		var length = timer.start_weighted()
		assert_float(length).is_in([1.0, 2.0, 4.0])


func test_weight_0_single_entry() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)
	var weights_array := WeightedTimeTable.new()
	weights_array.time_weights[0.1] = 0.0
	timer.weighted_times = weights_array

	var length = timer.start_weighted()
	assert_float(length).is_equal_approx(0.1, 0.000001)


func test_weight_0_multiple_entry() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)
	var weights_array := WeightedTimeTable.new()
	weights_array.time_weights[1.0] = 0.0
	weights_array.time_weights[2.0] = 0.0
	timer.weighted_times = weights_array

	var length = timer.start_weighted()
	assert_float(length).is_in([1.0, 2.0])


func test_null() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var length = timer.start_weighted()
	assert_float(length).is_equal(1.0)


func test_empty() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)
	var weights_array := WeightedTimeTable.new()
	timer.weighted_times = weights_array

	var length = timer.start_weighted()
	assert_float(length).is_equal(1.0)


func test_args() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var times := PackedFloat32Array([1.0, 2.0, 4.0])
	var weights := PackedFloat32Array([1.5, 2.5, 4.5])
	for idx in 10:
		var length = timer.start_weighted(times, weights)
		assert_float(length).is_in([1.0, 2.0, 4.0])


func test_args_times_larger() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var times := PackedFloat32Array([1.0, 2.0, 4.0])
	var weights := PackedFloat32Array([1.5, 2.5])
	for idx in 10:
		var length = timer.start_weighted(times, weights)
		assert_float(length).is_in([1.0, 2.0])


func test_args_weights_larger() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var times := PackedFloat32Array([1.0, 2.0])
	var weights := PackedFloat32Array([1.5, 2.5, 4.5])
	var length = timer.start_weighted(times, weights)
	assert_float(length).is_in([1.0, 2.0])


func test_non_positive_keys() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var time_table := WeightedTimeTable.new()
	time_table.add_time(-0.1, 1.0)
	time_table.add_time(0.0, 1.0)
	assert_bool(time_table.has_time(-0.1)).is_false()
	assert_bool(time_table.has_time(0.001)).is_true()
	assert_bool(time_table.has_time(0.0)).is_false()


func test_negative_values() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var time_table := WeightedTimeTable.new()
	time_table.add_time(1.0, -0.1)
	time_table.add_time(2.0, 0.0)
	assert_bool(time_table.time_weights[1.0] == -0.1).is_false()
	assert_bool(time_table.time_weights[1.0] == 0.0).is_true()
	assert_bool(time_table.time_weights[2.0] == 0.0).is_true()
