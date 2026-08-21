extends Node

@onready var advanced_timer: AdvancedTimer = $AdvancedTimer

func _ready() -> void:
	var plant_growth = WeightedTimeTable.new()
	plant_growth.add_time(40.0, 0.5)
	plant_growth.add_time(50.0, 1.0)
	plant_growth.add_time(60.0, 0.25)
	advanced_timer.weighted_times = plant_growth
	advanced_timer.start_weighted(plant_growth.get_times(), plant_growth.get_weights())
	pass
