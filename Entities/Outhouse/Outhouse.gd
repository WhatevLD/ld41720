extends Area2D

export var poopTime = 5

onready var animations = $AnimatedSprite
signal done_pooping
var poopTimer

func _ready():
	add_to_group("outhouse")
	poopTimer = Timer.new()
	poopTimer.one_shot = true
	poopTimer.wait_time = poopTime
	poopTimer.connect("timeout", self, "on_poop_complete")
	add_child(poopTimer)

func on_poop_complete():
	animations.play("open")
	emit_signal("done_pooping")

func poop():	
	animations.play("closed")
	poopTimer.start()
