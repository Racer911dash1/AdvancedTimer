# GdUnit generated TestSuite
class_name AdvancedTimerStartRandomTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const _SOURCE: String = 'res://addons/advanced_timer/advanced_timer.gd'


func test_one_second() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var length = timer.start_random()

	assert_float(length).is_equal(1.0)


func test_two_seconds() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 2.0
	timer.max_wait_time = 2.0
	var length = timer.start_random()

	assert_float(length).is_equal(2.0)


func test_between_one_and_two_seconds() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.0
	timer.max_wait_time = 2.0
	var length = timer.start_random()

	assert_float(length).is_between(1.0, 2.0)


func test_timer_started_signal() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	monitor_signals(timer)
	var length = timer.start_random()

	await assert_signal(timer).is_emitted(timer.timer_started, length)


func test_rounding_floor() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.0
	timer.max_wait_time = 2.0
	timer.rounded = true
	timer.rounding_type = timer.Rounding.FLOOR
	var length = timer.start_random()

	assert_float(length).is_equal(1.0)


func test_rounding_round() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.0
	timer.max_wait_time = 2.0
	timer.rounded = true
	timer.rounding_type = timer.Rounding.ROUND
	var length = timer.start_random()

	assert_float(length).is_in([1.0, 2.0])


func test_rounding_ceil() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.0
	timer.max_wait_time = 2.0
	timer.rounded = true
	timer.rounding_type = timer.Rounding.CEIL
	var length = timer.start_random()

	assert_float(length).is_equal(2.0)


func test_step_size_0_5() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.0
	timer.max_wait_time = 2.0
	timer.rounded = true
	timer.step_size = 0.5
	var length = timer.start_random()

	assert_float(length).is_in([1.0, 1.5, 2.0])


func test_step_size_3() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 3.0
	timer.max_wait_time = 12.0
	timer.rounded = true
	timer.step_size = 3
	var length = timer.start_random()

	assert_float(length).is_in([3.0, 6.0, 9.0, 12.0])


func test_step_size_unclamped() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.2
	timer.max_wait_time = 1.8
	timer.rounded = true
	timer.clamped = false
	timer.step_size = 1
	var length = timer.start_random()

	assert_float(length).is_in([1.0, 2.0])


func test_step_size_clamped() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 1.2
	timer.max_wait_time = 1.8
	timer.rounded = true
	timer.clamped = true
	timer.step_size = 1
	var length = timer.start_random()

	assert_float(length).is_in([1.2, 1.8])


func test_seeded_randomization() -> void:
	var timer1 := AdvancedTimer.new()
	add_child(timer1)
	auto_free(timer1)

	timer1.min_wait_time = 1.0
	timer1.max_wait_time = 2.0
	timer1.seed = 0

	var length1 = timer1.start_random()

	assert_float(length1).is_equal_approx(1.202271, 0.00001)


func test_two_seconds_args() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	var length = timer.start_random(2.0, 2.0)

	assert_float(length).is_equal(2.0)


func test_static_rng_is_shared() -> void:
	var timer1 := AdvancedTimer.new()
	var timer2 := AdvancedTimer.new()
	add_child(timer1)
	auto_free(timer1)
	add_child(timer2)
	auto_free(timer2)

	timer1.static_randomization = true
	timer2.static_randomization = true

	assert_object(timer1._rng_static).is_same(timer2._rng_static)


func test_clamping_min_wait_time() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = -2.0
	assert_float(timer.min_wait_time).is_equal(0.001)


func test_clamping_max_wait_time() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.max_wait_time = -2.0
	assert_float(timer.min_wait_time).is_equal(0.001)


func test_clamping_max_wait_time_to_min_wait_time() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.max_wait_time = 1.0
	timer.min_wait_time = 3.0
	assert_float(timer.max_wait_time).is_equal(3.0)


func test_clamping_min_wait_time_to_max_wait_time() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 3.0
	timer.max_wait_time = 1.0
	assert_float(timer.min_wait_time).is_equal(1.0)


func test_5_starts() -> void:
	var timer := AdvancedTimer.new()
	add_child(timer)
	auto_free(timer)

	timer.min_wait_time = 0.1
	timer.max_wait_time = 0.2
	timer.one_shot = true
	for idx in 5:
		assert_float(timer.start_random()).is_between(0.1, 0.2)
