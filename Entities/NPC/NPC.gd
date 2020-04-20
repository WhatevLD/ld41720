extends KinematicBody2D


var colorShader

# Called when the node enters the scene tree for the first time.
func _ready():
	var changeColor = """
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

	var colorShader = Shader.new()
	colorShader.code = changeColor
	var materialShader = ShaderMaterial.new()
	materialShader.shader = colorShader
	var sprite = get_node("Sprite")	
	sprite.material = materialShader
	
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
