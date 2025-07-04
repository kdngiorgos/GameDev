extends CharacterBody2D

#Imports
@onready var animsprite = $AnimatedSprite2D
@onready var dash = $Dash

#Wave
var wave = preload("res://Scenes/Player/attacks/wave.tscn")
@onready var waveAttackTimer = get_node("%WaveAttackTimer")
#WaterOrb
var waterOrb = preload("res://Scenes/Player/attacks/waterorb.tscn")
@onready var waterOrbTimer = get_node("%WaterOrbTimer")
@onready var waterOrbAttackTimer = get_node("%WaterOrbAttackTimer")

#Cloud
var cloud = preload("res://Scenes/Player/attacks/cloud.tscn")
@onready var cloudTimer = get_node("%CloudTimer")
@onready var cloudAttackTimer = get_node("%CloudAttackTimer")


#GUI
@onready var expBar = get_node("%TextureProgressBar")
@onready var lbllevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%Levelup")
@onready var upgradeoptions = get_node("%UpgradeOptions")
@onready var sndLevelUp = get_node("%SoundLevelup")
@onready var itemOptions = preload("res://Scenes/Player/item_option.tscn")



var last_movement = Vector2.ZERO
var isRunning = 0 

#Variables

var acc = 6
var health = 100
var experience_level = 1
var experience = 0
var collected_experience =0 
var nrg = 50

#Dash Stats
var dashboost = 300
var dashcost = 2
var dash_duration = 0.2



#Wave
var wave_attackspeed = 3
var wave_level = 0

#Cloud
var cloud_ammo = 0
var cloud_baseammo = 0
var cloud_attackspeed = 3
var cloud_level = 0


#WaterOrb
var waterorb_ammo = 0
var waterorb_baseammo =5
var waterorb_attackspeed = 1
var waterorb_level = 1

#Enemy Related
var enemy_close = []


func _ready():
	attack()
	set_expbar(experience, calculate_experiencecap())

func _physics_process(_delta):
	movement()
	anim()
	if Input.is_action_just_pressed("pause"):
		pausenemies()


func _on_hurtbox_hurt(damage, _angle, _knockback_amount):
	if dash.is_dashing(): return
	health -= damage
	print("player got hit")
	print(health)

func attack():
	if waterorb_level > 0:
		waterOrbTimer.wait_time = waterorb_attackspeed
		if waterOrbTimer.is_stopped():
			waterOrbTimer.start()
			
	if cloud_level > 0:
		cloudTimer.wait_time = cloud_attackspeed
		if cloudTimer.is_stopped():
			cloudTimer.start()
	
	if wave_level > 0:
		waveAttackTimer.wait_time = wave_attackspeed
		if waveAttackTimer.is_stopped():
			waveAttackTimer.start()


#Wave
func _on_wave_attack_timer_timeout() -> void:
	var wave1 = wave.instantiate()
	var wave2 = wave.instantiate()
	wave1.position = position 
	wave2.position = position 
	wave1.angle = Vector2.LEFT
	wave2.angle = Vector2.RIGHT
	add_child(wave1)
	add_child(wave2)
	waveAttackTimer.start()

#Water Orb Attack
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

#Cloud Attack
func _on_cloud_attack_timer_timeout() -> void:
	if cloud_ammo > 0:
		var cloud_attack = cloud.instantiate()
		cloud_attack.position = position
		cloud_attack.last_movement = last_movement
		if cloud_attack.last_movement != Vector2.ZERO:
			cloud_attack.level = cloud_level
			add_child(cloud_attack)
			cloud_ammo -= 1 
			if cloud_ammo > 0:
				cloudAttackTimer.start()
			else:
				cloudAttackTimer.stop()

func _on_cloud_timer_timeout() -> void:
	if cloud_ammo == 0:
		cloud_ammo = cloud_baseammo
	cloudAttackTimer.start()




#General Attack Functions
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)

func get_random_target():
	if enemy_close.size() > 0:
		#return enemy_close.pick_random().global_position
		var tmp = enemy_close.pick_random()
		if tmp.isAlive:
			return tmp.global_position
		else:
			return Vector2.ZERO
	else:
		return Vector2.ZERO


func getExp(points):
	experience += points
	
func levelup():
	sndLevelUp.play()
	lbllevel.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(760,320),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible=true
	
	var options = 0
	var optionsmax =3 
	while options<optionsmax:
		var option_choise = itemOptions.instantiate()
		upgradeoptions.add_child(option_choise)
		options+=1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	var option_children = upgradeoptions.get_children()
	for i in option_children:
		i.queue_free()
	levelPanel.visible=false
	levelPanel.position=Vector2(2219,313)
	get_tree().paused = false
	calculate_experience(0)

func anim():
	if velocity.x**2 + velocity.y**2 >5000: #Running Animation
		isRunning = 1 
		animsprite.play("run")
	else:
		isRunning = 0
		animsprite.play("idle")

func pausenemies():
	GameManager.freezetime()


func movement():
	var direction = Input.get_vector("left", "right", "up", "down")  #Get Direction
	velocity /= 1.05 #Apply Friction
	if direction.x != 0 or direction.y!=0:
		velocity += direction * acc #Accelerate
		animsprite.flip_h = direction.x < 0 # Flip horizontally if moving left

		
	if Input.is_action_just_pressed("dash") && dash.can_dash && !dash.is_dashing(): #Handle dash movement
		if nrg >= dashcost:
			nrg -= dashcost
			dash.start_dash(animsprite, dash_duration)
			velocity += dashboost * direction
	
	move_and_slide()
	
	last_movement = direction


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

		
func calculate_experience(loot):
	var exp_required = calculate_experiencecap()
	collected_experience += loot
	if experience + collected_experience >= exp_required: #levelup
		collected_experience -= exp_required-experience
		experience_level += 1 
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0 
	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var base_xp = 5.0    # starting XP needed for level 1
	var growth_rate = 1.2 # how fast it grows per level
	return int(base_xp * pow(growth_rate, experience_level - 1))


func set_expbar(set_value =1, set_max_value = 100):
	var tween = get_tree().create_tween()
	tween.tween_property(expBar,"value",set_value,0.2).set_trans(Tween.TRANS_LINEAR)
	expBar.max_value = set_max_value
