extends Area2D

export var poopTime = 5

onready var animations = $AnimatedSprite
signal done_pooping
var poopTimer
var poopSoundTimer

func _ready():
	add_to_group("outhouse")
	poopTimer = Timer.new()
	poopTimer.one_shot = true
	poopTimer.wait_time = poopTime
	poopTimer.connect("timeout", self, "on_poop_complete")
	add_child(poopTimer)
	poopSoundTimer = Timer.new()
	poopSoundTimer.one_shot = true
	poopSoundTimer.wait_time = 2
	poopSoundTimer.connect("timeout", self, "on_soundTimer_complete")
	add_child(poopSoundTimer)

func on_soundTimer_complete():
	$Poop.play()

func on_poop_complete():
	animations.play("open")
	$Door.play()
	emit_signal("done_pooping")

func poop(time):	
	animations.play("closed")
	poopTimer.wait_time = time
	$Door.play()
	poopTimer.start()
	poopSoundTimer.start()
