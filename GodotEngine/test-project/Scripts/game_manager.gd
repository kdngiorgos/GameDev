extends Node

#Pause Enemies Stats
var freezetimer = 10
var timefrozen = false
var temptimer =0
@onready var player = "%Player"

var score = 0 


func _physics_process(delta):
	if timefrozen:
		temptimer -= delta*10
		if temptimer <= 0:
			timefrozen = false
			temptimer = freezetimer 




func add_point(val):
	score +=val
	
func freezetime():
	timefrozen = true
