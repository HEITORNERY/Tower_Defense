extends Area3D
class_name Tower
# vida da torre
var health : int 
var enemy : Enemy
func _ready() -> void:
	# escolhendo aleatoriamente a vida da torre
	var health_choice : int = randi_range(40, 50)
	health = health_choice
