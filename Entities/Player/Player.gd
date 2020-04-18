extends KinematicBody2D


export var speed = 500
export var acceleration = 2500
export var friction = 5000

var velocity: Vector2

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
