extends Node

@onready var advanced_timer: AdvancedTimer = $AdvancedTimer
@onready var advanced_timer_2: AdvancedTimer = $AdvancedTimer2
@onready var advanced_timer_3: AdvancedTimer = $AdvancedTimer3

func _ready() -> void:
	advanced_timer.start()
	advanced_timer_2.start()
	advanced_timer_3.start()
	print(advanced_timer_3.timer_seed)
	advanced_timer_3.timer_seed = 0
	print(advanced_timer_3.timer_seed)
	#advanced_timer_3.timer_seed = null
	print(advanced_timer_3.timer_seed)
