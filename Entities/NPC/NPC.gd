extends KinematicBody2D

const changeColor = """
shader_type canvas_item;

uniform vec3 pants_color = vec3(1, .2, .3);
const vec4 base_pants = vec4(0, 0.6, .85882, 1);

void fragment() {
	COLOR = texture(TEXTURE,UV); // Get current color of pixel

	vec4 diff = COLOR - base_pants;
	if (abs(length(diff)) < 0.01) {
		COLOR.rgb = pants_color
	}
}"""

const ManScript = preload("res://Entities/ManScript.gd")
onready var base = ManScript.new()
onready var animations = $Sprite
var trackedFood
var state = State.SEARCH
var currentFood: Area2D

enum State {
	SEARCH
	MOVING
	EATING
}

func _ready():
	base.animations = animations
	var colorShader = Shader.new()
	colorShader.code = changeColor
	var materialShader = ShaderMaterial.new()
	materialShader.shader = colorShader
	animations.material = materialShader
		
	var _err = self.get_node("Area2D").connect("area_entered", self, "_on_Area2D_area_entered")
	_err = animations.connect("animation_finished", self, "_on_Sprite_animation_finished")

func _physics_process(delta):
	match state:
		State.SEARCH:
			base.idle_animation()
			var food_positions = get_tree().get_nodes_in_group("food")
			if food_positions.size() > 0:
				var nearest = food_positions[0]
				var nearest_distance = nearest.position.distance_to(self.position)
				for food in food_positions:
					if food.monitorable:
						var distance = food.position.distance_to(self.position)
						if distance < nearest_distance:
							nearest = food
							nearest_distance = distance
				trackedFood = weakref(nearest)
				state = State.MOVING
		State.MOVING:
			if trackedFood and trackedFood.get_ref() and trackedFood.get_ref().monitorable:
				var direction = trackedFood.get_ref().position - self.position
				direction = direction.normalized()
				if direction != Vector2.ZERO:
					base.velocity = base.velocity.move_toward(direction * base.speed, base.acceleration * delta)
					base.move_animation(direction)
				else:
					base.velocity = base.velocity.move_toward(Vector2.ZERO, base.friction * delta)
					base.idle_animation()
				base.velocity = move_and_slide(base.velocity)
			else:
				trackedFood = null
				state = State.SEARCH
		State.EATING:
			base.velocity = Vector2.ZERO
				

func _on_Area2D_area_entered(area):
	match area.get_groups():
		["food"]:
			base.calories += area.calories
			state = State.EATING
			animations.play(str(base.fatLevel) + "-eat")
			
			area.position = position - Vector2(0,5)
			area.z_index = z_index + 1
			area.set_deferred("monitorable", false)
			area.get_node("Crumbs").set_visible(true)
			area.get_node("Crumbs").z_index = z_index + 1
			currentFood = area
			#area.queue_free()

func _on_Sprite_animation_finished():
	if state == State.EATING:
		if base.calories > base.fatLevels[base.fatLevel]:
			base.fatLevel += 1
		if base.fatLevel == 6:
			queue_free()
		animations.animation = base.get_animation_direction(Vector2.DOWN)
		base.idle_animation()
		state = State.SEARCH
		if currentFood:
			currentFood.queue_free()

