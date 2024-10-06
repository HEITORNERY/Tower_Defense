extends Area3D
class_name Projectile
var starting_position : Vector3
var target : Node3D
@export var speed : float = 2
var lerp_pos : float = 0
# variável para o dano
@export var damage : int = 2
func _ready() -> void:
	global_position = starting_position
func _process(delta: float) -> void:
	if target != null and lerp_pos < 1:
		global_position = starting_position.lerp(target.global_position, lerp_pos)
		lerp_pos += delta * speed
	else:
		queue_free()
