extends Area2D

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player") 
signal remove_from_array(object)


var level = 1
var hp = 1
var speed = 100
var damage =5
var knockback_amount = 100
var attack_size = 1.0


func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp =1
			speed = 200
			damage =5 
			knockback_amount = 100
			attack_size = 1.0
		2:
			hp =3
			speed = 300
			damage =20 
			knockback_amount = 100
			attack_size = 1.5
	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,0.7).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	
func _physics_process(delta: float) -> void:
	position += angle*speed*delta

func enemy_hit(charge =1):
	hp -= charge
	if hp <=0:
		emit_signal("remove_from_array",self)
		queue_free()
	


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
