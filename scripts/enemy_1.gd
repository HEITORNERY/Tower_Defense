extends Node3D
class_name Enemy
# criar uma variável para a curva 3d
var curve_3d : Curve3D
# criar variáveis para a velocidade do inimigo e seu progresso
var enemy_speed = 2
var enemy_progress : float
# variável para todos as cenas dos inimigos
@export var enemies : Array[PackedScene]
# criar a variável para a área do inimigo
var area_3d : Area3D
var colision_3d : CollisionShape3D
var cylinder_shape = CylinderShape3D
# vida dos inimigos
var health : int 
# inimigo instanciado
var enemy : Node3D
# variável de dano do inimigo
var damage : int
# criando uma curva 3d com os pontos do path
func _ready() -> void:
	var health_choice = randi_range(60, 80)
	health = health_choice
	# o dano vai ser aleatório para cada nível
	var damage_choice = randi_range(3, 9)
	damage = damage_choice
	enemy = enemies.pick_random().instantiate()
	$Path3D/PathFollow3D.add_child(enemy)
	# Configurar a camada de colisão (camada 2)
	# adicionar uma área 3d ao inimigo e uma colisão para ele
	area_3d = Area3D.new()
	colision_3d = CollisionShape3D.new()
	cylinder_shape = CylinderShape3D.new()
	cylinder_shape.height = 0.92
	cylinder_shape.radius = 0.45
	colision_3d.shape = cylinder_shape
	enemy.add_child(area_3d)
	area_3d.collision_layer = 2
	area_3d.add_child(colision_3d)
	# conectar um sinal de quando uma área 3d entrou na área do inimigo
	area_3d.area_entered.connect(_on_area_3d_entered)
	curve_3d = Curve3D.new()
	for element in PathGenInstance.get_path_route():
		curve_3d.add_point(Vector3(element.x, 0, element.y))
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress_ratio = 0
# sinal para iniciar uma ação, assim que entrar no estado de spawn
func _on_spawn_state_entered() -> void:
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$Enemy_State.send_event("To_Travel")
# Sinal para executar uma ação durante todo o estado
func _on_travel_state_processing(delta: float) -> void:
	enemy_progress += enemy_speed * delta
	$Path3D/PathFollow3D.progress = enemy_progress
	if enemy_progress > PathGenInstance.get_path_route().size():
		$Enemy_State.send_event("To_Despawn")
# sinal que vai fazer o inimigo sumir, quando chegar no final do percursso
func _on_despawn_state_entered() -> void:
	queue_free()
# função que vai ser conectada à área 3d e fazer o que um sinal de detecção de área
func _on_area_3d_entered(body: Area3D) -> void:
	if body is Projectile:
		health -= body.damage
		if health <= 0:
			$Enemy_State.send_event("To_Dying")
	elif body is Tower:
		body.health -= damage
		if body.health <= 0:
			get_tree().change_scene_to_file("res://scenes/loser.tscn")
# sinal de que entrou no estado de morte
func _on_die_state_entered() -> void:
	$Enemy_State.send_event("Remove")
