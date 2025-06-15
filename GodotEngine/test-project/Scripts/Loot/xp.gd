extends Area2D

@export var experience = 1

var spr_blue = preload("res://Assets/Images/experienceblue.png")
var spr_green = preload("res://Assets/Images/experiencegreen.png")
var spr_yellow = preload("res://Assets/Images/experienceyellow.png")
var spr_red = preload("res://Assets/Images/experiencered.png")

var target = null
var speed = -0.5

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $AudioStreamPlayer

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_green
	elif experience < 100:
		sprite.texture = spr_yellow
	else:
		sprite.texture = spr_red


func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta
		
func collect():
	sound.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience


func _on_audio_stream_player_finished() -> void:
	queue_free()
