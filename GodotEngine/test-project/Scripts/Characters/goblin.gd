extends CharacterBody2D

@onready var animsprite = $AnimatedSprite2D
@export var movementspeed= 30.0
@onready var player = get_tree().get_first_node_in_group("player")

var health = 10
var power = 10
var speed = 100

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	if !GameManager.timefrozen:
		velocity = delta *speed * direction * movementspeed
		animsprite.flip_h = direction.x < 0
	else:
		velocity = 0 * direction 
	anim()
	move_and_slide()
	
func anim():
	if velocity.x**2 + velocity.y**2 >100: #Running Animation
		animsprite.play("walk")
	else:
		animsprite.play("idle")


func _on_hurtbox_hurt(damage: Variant) -> void:
	health -= damage
	if health<= 0:
		queue_free()
