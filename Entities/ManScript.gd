extends Node

export(int, 1, 5) var fatLevel = 1
export var speed = 100
export var acceleration = 2500
export var friction = 5000
export var minAnimationFps = 2
export var maxAnimationFps = 4

export var calories = 0

var velocity: Vector2
var lastDirection: Vector2
var animations: AnimatedSprite

var fatLevels = [ 
	0, 		# 1
	35000, 	# 2
	70000, 	# 3
	105000, # 4
	140000, # 5
	175000  # Dead
]

func move_animation(direction):
	var oldDirection = lastDirection
	var animation = get_animation_direction(direction)
	if oldDirection != lastDirection:
		animations.frame = 0
	print(minAnimationFps + maxAnimationFps * direction.length())
	
	animations.frames.set_animation_speed(animation, minAnimationFps + maxAnimationFps * direction.length())
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
		
