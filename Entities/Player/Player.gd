extends KinematicBody2D

export(int, 1, 5) var fatLevel = 1
export var speed = 500
export var acceleration = 2500
export var friction = 5000
export var minAnimationFps = 2
export var maxAnimationFps = 8

var velocity: Vector2
var lastDirection: Vector2
onready var animations = $Sprite

func _input(event):
	if event.is_action_pressed("ToggleFat"):
		fatLevel = fatLevel + 1
		if fatLevel > 5:
			fatLevel = 1

func _physics_process(delta):
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if direction != Vector2.ZERO:
		if abs(direction.x) == 1 and abs(direction.y) == 1:	
			direction = direction.normalized()	
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		move_animation(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		idle_animation()

	move_and_collide(velocity * delta)


func move_animation(direction):
	if direction != lastDirection:
		animations.frame = 0
		lastDirection = direction
	var animation = get_animation_direction(direction)
	animations.frames.set_animation_speed(animation, minAnimationFps + maxAnimationFps * direction.length())
	animations.play(animation)


func idle_animation():
	animations.frame = 3
	animations.stop()	


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	var animation = str(fatLevel) + "-down"
	if norm_direction.y <= -0.707:
		animation = str(fatLevel) + "-up"
	elif norm_direction.x <= -0.707:
		animation = str(fatLevel) +  "-left"
		animations.flip_h = false
	elif norm_direction.x >= 0.707:
		animation = str(fatLevel) + "-left"
		animations.flip_h = true
	return animation
	
