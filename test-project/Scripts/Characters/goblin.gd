extends CharacterBody2D

@onready var animsprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO
@export var movementspeed= 30.0

var health = 10
var power = 10
var speed = 100
var isAlive =1 



func _physics_process(delta: float) -> void:
	
	if isAlive:
		if health <=0:
			isAlive = 0
			
		#knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
		var direction = global_position.direction_to(player.global_position)
		if !GameManager.timefrozen:
			velocity = delta *speed * direction * movementspeed
			velocity += knockback
			animsprite.flip_h = direction.x < 0
		else:
			velocity = 0 * direction 
		anim()
		move_and_slide()
	
func anim():
	if !isAlive:
		animsprite.play("death")
	elif velocity.x**2 + velocity.y**2 >100: #Running Animation
		animsprite.play("walk")
	else:
		animsprite.play("idle")


func _on_hurtbox_hurt(damage, angle, knockback_amount):
	health -= damage
	knockback = angle * knockback_amount
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animsprite.animation == "death":
		await get_tree().create_timer(2.0).timeout
		queue_free()
