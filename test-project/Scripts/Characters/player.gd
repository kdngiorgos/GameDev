extends CharacterBody2D


var acc = 6
var health = 100
var level = 0
var experience = 0
var nrg = 50

#Dash Stats
var dashboost = 150
var dashcost = 1


var waterOrb = preload("res://Scenes/Player/waterorb.tscn") 

#AttackNodes

@onready var waterOrbTimer = get_node("%WaterOrbTimer")
@onready var waterOrbAttackTimer = get_node("%WaterOrbAttackTimer")

#WaterOrb
var waterorb_ammo = 0
var waterorb_baseammo = 1
var waterorb_attackspeed = 0.5
var waterorb_level = 1 

#Enemy Related
var enemy_close = []


@onready var animsprite = $AnimatedSprite2D

func _ready():
	attack()

func _physics_process(_delta):
	movement()
	anim()
	if Input.is_action_just_pressed("pause"):
		pausenemies()


func _on_hurtbox_hurt(damage: Variant) -> void:
	health -= damage
	print("player got hit")
	print(health)

func attack():
	print("attack called")
	if waterorb_level > 0:
		waterOrbTimer.wait_time = waterorb_attackspeed
		if waterOrbTimer.is_stopped():
			waterOrbTimer.start()

func _on_water_orb_timer_timeout() -> void:
	if waterorb_ammo == 0:
		waterorb_ammo = waterorb_baseammo
	waterOrbAttackTimer.start()

func _on_water_orb_attack_timer_timeout() -> void:
	if waterorb_ammo > 0:
		var waterorb_attack = waterOrb.instantiate()
		waterorb_attack.position = position
		waterorb_attack.target = get_random_target()
		if waterorb_attack.target != Vector2.ZERO:
			waterorb_attack.level = waterorb_level
			add_child(waterorb_attack)
			waterorb_ammo -= 1 
			if waterorb_ammo > 0:
				waterOrbAttackTimer.start()
			else:
				waterOrbAttackTimer.stop()
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.ZERO


func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)






func dash(dir):
	if nrg >=dashcost: #Handle dash movement
		nrg -= dashcost
		velocity += dir * dashboost

func getExp(points):
	experience += points
	
func levelup():
	level+=1
	experience = 0
	
func anim():
	if velocity.x**2 + velocity.y**2 >5000: #Running Animation
		animsprite.play("run")
	else:
		animsprite.play("idle")

func pausenemies():
	GameManager.freezetime()

func movement():
	var direction = Input.get_vector("left", "right", "up", "down")  #Get Direction
	
	velocity /= 1.05 #Apply Friction
	
	if direction.x != 0 or direction.y!=0:
		velocity += direction * acc #Accelerate
		animsprite.flip_h = direction.x < 0 # Flip horizontally if moving left
	
	if Input.is_action_just_pressed("dash"): #Handle dash movement
		dash(direction) 
	
	move_and_slide()
	
