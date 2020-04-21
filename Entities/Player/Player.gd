extends KinematicBody2D

const ManScript = preload("res://Entities/ManScript.gd")
onready var base = ManScript.new()
var currentFood: Area2D

onready var animations = $Sprite

enum State {
	MOVING
	EATING
	POOPING
	DYING
}

var state = State.MOVING

func _ready():
	base.animations = animations
	var sprite = self.get_node("Sprite")
	var _err = self.get_node("Area2D").connect("area_entered", self, "_on_Area2D_area_entered")
	_err = sprite.connect("animation_finished", self, "_on_Sprite_animation_finished")
	get_parent().get_parent().get_node("PlayerCalories").max_value = base.fatLevel()
	
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
		State.DYING:
			base.velocity = Vector2.ZERO



func _on_Area2D_area_entered(area):
	match area.get_groups():
		["food"]:
			base.eat_food(area, position, z_index, get_parent().get_parent().get_node("PlayerCalories"), get_parent().get_parent().get_node("PlayerFatLevel"))
			state = State.EATING
		["outhouse"]:
			self.hide()
			self.position = area.position
			self.position.y += 4
			state = State.POOPING
			area.poop(base.poopTime())

func _on_Sprite_animation_finished():
	match state:
		State.EATING:
			base.done_eating(get_parent().get_parent().get_node("PlayerCalories"), get_parent().get_parent().get_node("PlayerFatLevel"))
			if base.fatLevel == 6:
				base.die_animation()
				state = State.DYING
			else:
				state = State.MOVING
		State.DYING:
			queue_free()
			var score = get_parent().get_parent().get_node("ScoreLabel")
			score.text = "SCORE: %s" % [base.score]
			score.visible = true
			get_tree().paused = true
	
func _on_Outhouse_done_pooping():
	self.show()
	var progress = get_parent().get_parent().get_node("PlayerCalories")
	var level = get_parent().get_parent().get_node("PlayerFatLevel")
	base.calories = 0
	base.fatLevel = 1
	progress.value = 0
	progress.max_value = base.fatLevel()
	level.value = 0
	animations.animation = base.get_animation_direction(Vector2.DOWN)
	base.idle_animation()
	state = State.MOVING
