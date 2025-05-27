extends Area2D
var value = 10


func _on_body_entered(_body: Node2D) -> void:
	GameManager.add_point(value)
	queue_free()
