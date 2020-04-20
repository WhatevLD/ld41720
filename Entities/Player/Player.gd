extends KinematicBody2D

const ManScript = preload("res://Entities/ManScript.gd")
onready var base = ManScript.new()
var currentFood: Area2D

onready var animations = $Sprite

enum State {
	MOVING
	EATING
	POOPING
}

var state = State.MOVING

func _ready():
	base.animations = animations
	var sprite = self.get_node("Sprite")
	var _err = self.get_node("Area2D").connect("area_entered", self, "_on_Area2D_area_entered")
	_err = sprite.connect("animation_finished", self, "_on_Sprite_animation_finished")

func _physics_process(delta):
	match state:
		State.MOVING:	
			var direction: Vector2
			direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			if direction != Vector2.ZERO:
				if abs(direction.x) == 1 and abs(direction.y) == 1:	
					direction = direction.normalized()	
				base.velocity = base.velocity.move_toward(direction * base.speed(), base.acceleration * delta)
				base.move_animation(direction)
			else:
				base.velocity = base.velocity.move_toward(Vector2.ZERO, base.friction * delta)
				base.idle_animation()
			base.velocity = move_and_slide(base.velocity)
		State.EATING:
			base.velocity = Vector2.ZERO
		State.POOPING:
			base.velocity = Vector2.ZERO



func _on_Area2D_area_entered(area):
	match area.get_groups():
		["food"]:
			base.calories += area.calories
			state = State.EATING
			animations.play(str(base.fatLevel) + "-eat")
			
			# Reposition the food, make it so no one else can eat it
			# Need to free this AFTER eating animation, and disable it's collison
			area.position = position - Vector2(0,5)
			area.z_index = z_index + 1
			area.set_deferred("monitorable", false)
			area.get_node("Crumbs").set_visible(true)
			area.get_node("Crumbs").z_index = z_index + 1
			currentFood = area
			#area.queue_free()
		["outhouse"]:
			self.hide()
			self.position = area.position
			self.position.y += 4
			state = State.POOPING
			area.poop()

func _on_Sprite_animation_finished():
	if state == State.EATING:
		if base.calories > base.fatLevels[base.fatLevel]:
			base.fatLevel += 1
		if base.fatLevel == 6:
			queue_free()
		animations.animation = base.get_animation_direction(Vector2.DOWN)
		base.idle_animation()
		state = State.MOVING
		if currentFood:
			currentFood.queue_free()
	

func _on_Outhouse_done_pooping():
	self.show()
	base.calories = 0
	base.fatLevel = 1
	animations.animation = base.get_animation_direction(Vector2.DOWN)
	base.idle_animation()
	state = State.MOVING
