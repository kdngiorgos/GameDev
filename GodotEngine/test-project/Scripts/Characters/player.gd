extends CharacterBody2D


var acc = 6
var health = 100
var level = 0
var experience = 0
var nrg = 50

#Dash Stats
var dashboost = 150
var dashcost = 1


@onready var animsprite = $AnimatedSprite2D

func _physics_process(_delta):
	movement()
	anim()
	if Input.is_action_just_pressed("pause"):
		pausenemies()

func movement():
	var direction = Input.get_vector("left", "right", "up", "down")  #Get Direction
	
	velocity /= 1.05 #Apply Friction
	
	if direction.x != 0 or direction.y!=0:
		velocity += direction * acc #Accelerate
		animsprite.flip_h = direction.x < 0 # Flip horizontally if moving left
	
	if Input.is_action_just_pressed("dash"): #Handle dash movement
		dash(direction) 
	
	move_and_slide()


func anim():
	if velocity.x**2 + velocity.y**2 >5000: #Running Animation
		animsprite.play("run")
	else:
		animsprite.play("idle")

func pausenemies():
	GameManager.freezetime()


func _on_hurtbox_hurt(damage: Variant) -> void:
	health -= damage
	print("player got hit")
	print(health)

func dash(dir):
	if nrg >=dashcost: #Handle dash movement
		nrg -= dashcost
		velocity += dir * dashboost

func getExp(points):
	experience += points
	
func levelup():
	level+=1
	experience = 0
	
