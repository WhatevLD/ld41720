extends Timer


onready var Food = preload("res://Entities/Food/Food.tscn")


func _on_Timer_timeout():
	var rand = RandomNumberGenerator.new()
	rand.randomize()

	var screen_size = get_viewport().get_visible_rect().size
	# Bounding rectangles for spawns
	var bottom = get_parent().get_node("PlayField").get_node("Bottom")
	var top = get_parent().get_node("PlayField").get_node("Top")
	var newX = (screen_size.x / 2) - bottom.shape.extents.x
	var newXSize = bottom.shape.extents.x * 2
	var newY = (screen_size.y / 2) - bottom.shape.extents.y
	var newYSize = bottom.shape.extents.y * 2
	var bottomRect = Rect2(newX, newY, newXSize, newYSize)
	
	newX = (screen_size.x / 2) - top.shape.extents.x
	newXSize = top.shape.extents.x * 2
	newY = (screen_size.y / 2) - top.shape.extents.y
	newYSize = top.shape.extents.y * 2
	var topRect = Rect2(newX, newY, newXSize, newYSize)
	#---------------------------------------
	var food = Food.instance()
	
	food.calories = rand.randi_range(1000, 10000)
	food.tileId = rand.randi_range(0, 63)

	var x = null
	var y = null
	
	while x == null:
		x = rand.randf_range(16,screen_size.x - 16)
		y = rand.randf_range(16,screen_size.y - 16)
		if bottomRect.has_point(Vector2(x,y)) == true || topRect.has_point(Vector2(x,y)) == true:
			break
		else:
			x = null
			y = null
	
	food.position.x = x
	food.position.y = y
	get_parent().get_node("YSort").add_child(food)
	food.add_to_group("food")
