extends Node2D

const dash_delay = 0.4
@onready var timer = $Timer
@onready var ghosttimer = $GhostTimer
var can_dash: bool = true
var ghostscene = preload("res://Scenes/Player/dash_ghost.tscn")
var sprite

func start_dash(prite, duration):
	self.sprite = prite
	timer.wait_time = duration
	timer.start()
	
	ghosttimer.start()
	instance_ghost()
	

func instance_ghost():
	var ghost = ghostscene.instantiate()
	get_parent().get_parent().add_child(ghost)

	ghost.global_position = global_position

	# Copy current frame as static texture
	var anim_name = sprite.animation
	var frame_idx = sprite.frame
	var tex = sprite.sprite_frames.get_frame_texture(anim_name, frame_idx)
	
	ghost.texture = tex  # This assumes your ghost is a Sprite2D
	ghost.flip_h = sprite.flip_h
	
func is_dashing():
	return !timer.is_stopped()

func end_dash():
	ghosttimer.stop()
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true

func _on_timer_timeout() -> void:
	end_dash()


func _on_ghost_timer_timeout() -> void:
	instance_ghost()
