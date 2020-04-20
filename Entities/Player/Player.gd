extends KinematicBody2D

export(int, 1, 5) var fatLevel = 1
export var speed = 100
export var acceleration = 2500
export var friction = 5000
export var minAnimationFps = 2
export var maxAnimationFps = 4

export var calories = 0

var velocity: Vector2
var lastDirection: Vector2
onready var animations = $Sprite

enum State {
	MOVING
	EATING
	POOPING
}

var fatLevels = [ 
	0, 		# 1
	35000, 	# 2
	70000, 	# 3
	105000, # 4
	140000, # 5
	175000  # Dead
]

var state = State.MOVING

func _ready():
	var sprite = self.get_node("Sprite")
	var _err = self.get_node("Area2D").connect("area_entered", self, "_on_Area2D_area_entered")
	_err = sprite.connect("animation_finished", self, "_on_Sprite_animation_finished")
	#sprite.material.set_shader_param("pants_color", Vector3(1, 0, 0))

func _input(event):
	if event.is_action_pressed("ToggleFat"):
		fatLevel = fatLevel + 1
		if fatLevel > 5:
			fatLevel = 1

func _physics_process(delta):
	match state:
		State.MOVING:	
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
			velocity = move_and_slide(velocity)
		State.EATING:
			velocity = Vector2.ZERO
		State.POOPING:
			velocity = Vector2.ZERO


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
		


func _on_Area2D_area_entered(area):
	match area.get_groups():
		["food"]:
			calories += area.calories
			state = State.EATING
			animations.play(str(fatLevel) + "-eat")
			area.queue_free()
		["outhouse"]:
			self.hide()
			self.position = area.position
			self.position.y += 4
			state = State.POOPING
			area.poop()

func _on_Sprite_animation_finished():
	if state == State.EATING:
		if calories > fatLevels[fatLevel]:
			fatLevel += 1
		if fatLevel == 6:
			queue_free()
		animations.animation = get_animation_direction(Vector2.DOWN)
		idle_animation()
		state = State.MOVING


func _on_Outhouse_done_pooping():
	self.show()
	self.calories = 0
	self.fatLevel = 1
	animations.animation = get_animation_direction(Vector2.DOWN)
	idle_animation()
	state = State.MOVING
