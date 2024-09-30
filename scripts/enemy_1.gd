extends Node3D
# criar uma variável para a curva 3d
var curve_3d : Curve3D
# criar variáveis para a velocidade do inimigo e seu progresso
var enemy_speed = 2
var enemy_progress : float
# variável para todos as cenas dos inimigos
@export var enemies : Array[PackedScene]
# criando uma curva 3d com os pontos do path
func _ready() -> void:
	var enemy = enemies.pick_random().instantiate()
	$Path3D/PathFollow3D.add_child(enemy)
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
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	queue_free()
