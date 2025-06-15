extends Sprite2D

@onready var tween = get_tree().create_tween()

func _ready():
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()
