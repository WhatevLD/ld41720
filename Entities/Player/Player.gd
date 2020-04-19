extends KinematicBody2D

export(int, 1, 5) var fatLevel = 1
export var speed = 500
export var acceleration = 2500
export var friction = 5000
export var animationSpeed = 0

var velocity: Vector2
onready var animations = $Sprite

func _physics_process(delta):
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if direction != Vector2.ZERO:
		if abs(direction.x) == 1 and abs(direction.y) == 1:	
			direction = direction.normalized()	
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_collide(velocity * delta)
	
	var animation = get_animation_direction(direction)
	animationSpeed = 2 + 13 * direction.length()
	animations.frames.set_animation_speed(animation, animationSpeed)
	animations.play(animation)


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	var animation = str(fatLevel) + "-down"
	if norm_direction.y <= -0.707:
		animation = str(fatLevel) + "-up"
	elif norm_direction.x <= -0.707:
		animation = str(fatLevel) +  "-left"
	elif norm_direction.x >= 0.707:
		animation = str(fatLevel) + "-right"
	return animation
	
