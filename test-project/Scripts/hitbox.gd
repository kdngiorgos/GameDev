extends Area2D

@export var damage = 10
@onready var collision = $CollisionShape2D
@onready var disableTimer = $Timer

func tempdisable():
	collision.call_deferred("set","disabled",true)
	disableTimer.start()


func _on_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
