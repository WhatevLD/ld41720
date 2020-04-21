extends Node

export(int, 1, 5) var fatLevel = 1
export var baseSpeed = 100
export var acceleration = 2500
export var friction = 5000
export var minAnimationFps = 2
export var maxAnimationFps = 4

export var calories = 0

var velocity: Vector2
var lastDirection: Vector2
var animations: AnimatedSprite
var currentFood
var score = 0

var fatLevels = [ 
	0, 		# 1
	35000, 	# 2
	70000, 	# 3
	105000, # 4
	140000, # 5
	175000  # Dead
]

func speed():
	var modifier = float((6 - fatLevel)) / 5.0
	return baseSpeed * modifier

func animationFps():
	var modifier = float((6 - fatLevel)) / 5.0
	return maxAnimationFps * modifier
	
func poopTime():
	return fatLevel * 2

func move_animation(direction):
	var oldDirection = lastDirection
	var animation = get_animation_direction(direction)
	if oldDirection != lastDirection:
		animations.frame = 0
			
	animations.frames.set_animation_speed(animation, minAnimationFps + animationFps() * direction.length())
	animations.play(animation)


func idle_animation():
	animations.frame = 3
	animations.stop()	


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	var animation = str(fatLevel) + "-down"
	lastDirection = Vector2.DOWN
	if norm_direction.y <= -0.707:
		animation = str(fatLevel) + "-up"
		lastDirection = Vector2.UP
	elif norm_direction.x <= -0.707:
		animation = str(fatLevel) +  "-right"
		lastDirection = Vector2.RIGHT
	elif norm_direction.x >= 0.707:
		animation = str(fatLevel) + "-left"
		lastDirection = Vector2.LEFT
	return animation
		
	
func fatLevel():
	return fatLevels[fatLevel] - fatLevels[fatLevel - 1]
		
func die_animation():
	animations.play("explode")
	
func done_eating(bar, level):
	currentFood.queue_free()
	currentFood = null
	if calories > fatLevels[fatLevel]:
		fatLevel += 1
		bar.value = calories - fatLevels[fatLevel - 1]
		level.value = fatLevel - 1
		if fatLevel != 6:
			bar.max_value = fatLevel()
		animations.animation = get_animation_direction(Vector2.DOWN)
	idle_animation()
	
func eat_food(food, position, z_index, bar, level):
	if !currentFood:		
		calories += food.calories
		score += food.calories
		bar.value = calories - fatLevels[fatLevel - 1]
		level.value = fatLevel - 1
		animations.play(str(fatLevel) + "-eat")
		
		# Reposition the food, make it so no one else can eat it
		# Need to free this AFTER eating animation, and disable it's collison
		food.position = position - Vector2(0,5)
		food.z_index = z_index + 1
		food.set_deferred("monitorable", false)
		food.get_node("Crumbs").set_visible(true)
		food.get_node("Crumbs").z_index = z_index + 1
		food.get_node("Chew").playing = true
		currentFood = food
