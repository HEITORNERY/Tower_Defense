extends Area3D
class_name Tower
# vida da torre
var health : float
func _ready() -> void:
	# escolhendo aleatoriamente a vida da torre
	var health_choice : float = float(randi_range(40, 50))
	health = health_choice
	$ProgressBar.min_value = float(0.0)
	$ProgressBar.max_value = health
func _process(_delta: float) -> void:
	$ProgressBar.value = health
	
