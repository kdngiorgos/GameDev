extends Area2D
var value = 1

func _on_body_entered(_body: Node2D) -> void:
	GameManager.add_point(value)
	queue_free()
