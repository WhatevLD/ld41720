extends Timer


onready var Food = preload("res://Entities/Food/Food.tscn")


func _on_Timer_timeout():
	var rand = RandomNumberGenerator.new()
	rand.randomize()

	var screen_size = get_viewport().get_visible_rect().size
	var food = Food.instance()
	
	food.calories = rand.randi_range(1000, 10000)
	food.tileId = rand.randi_range(0, 63)

	var x = rand.randf_range(0,screen_size.x)
	var y = rand.randf_range(0,screen_size.y)
	
	food.position.x = x
	food.position.y = y
	get_parent().add_child(food)
	food.add_to_group("food")
