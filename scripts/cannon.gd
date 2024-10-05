extends Node3D
class_name Cannon
# variável para armazenar os inimigos na área de detecção
var enemies_in_range : Array[Node3D]
# criar a variável para o progresso do slerp
var acquire_slerp_progress : float
# criar uma variável para o inimigo direcionado
var current_enemy_targetted : bool = false
# variável para o inimigo atual
var current_enemy : Area3D
# sinal para detectar quando um inimigo entrar na área
func _on_patrol_zone_area_entered(area: Node3D) -> void:
	# adicionar a área 3d do inimigo ao current_enemy
	if current_enemy == null:
		current_enemy = area
	# adiciona o inimigo ao array
	enemies_in_range.append(area.get_node("."))
# sinal para quando o inimigo sair da área de detecção
func _on_patrol_zone_area_exited(area: Area3D) -> void:
	# retira o inimigo aasim que sair da área
	enemies_in_range.erase(area.get_node("."))
# Função para ativar e desativar o monitoramento
func set_patrolling(patrolling: bool):
	$PatrolZone.monitoring = patrolling
# função para rotacionar o cannon
func rotate_towards_target(rtarget, delta):
	# esse aqui é o vetor que vai apontar para o alvo
	var target_vector = $".".global_position.direction_to(Vector3(rtarget.global_position.x, global_position.y, rtarget.global_position.z))
	# precisa-se de um vetor auxiliar, esse vetor é o basis, que vai dizer para olhar para o vetor target
	var target_basis : Basis = Basis.looking_at(target_vector)
	# agora faremos a interpolação entre a posição atual e a posição de onde deseja estar
	$".".basis = $".".basis.slerp(target_basis, acquire_slerp_progress)
	# acquire slerp é um valor entre 0 e 1, que diz respeito aonde estamos e onde queremos estar
	acquire_slerp_progress += delta
	if acquire_slerp_progress > 1:
		$StateChart.send_event("To_Attacking_State")
# sinal da atualização do estado de patrulha
func _on_patrolling_state_state_processing(delta: float) -> void:
	# o primeiro inimigo detectado vai ser seguido até sair da área de detecção
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[0]
		$StateChart.send_event("To_Acquiring_State")
# Sinal para quando entrar no estado de aquisição
func _on_acquiring_state_state_entered() -> void:
	current_enemy_targetted = false
	acquire_slerp_progress = 0
# sinal para processamento da física no estado de aquisição
func _on_acquiring_state_state_physics_processing(delta: float) -> void:
	# verificar se o inimigo atual está na lista de inimigos detectados
	if current_enemy != null and enemies_in_range.has(current_enemy):
		rotate_towards_target(current_enemy,delta)
	else:
		$StateChart.send_event("To_Patrolling_State")
	# faça a torre girar em direção ao inimigo, por meio da função de giro
	rotate_towards_target(current_enemy, delta)
# sinal do processamento das físicas para o estado de ataque
func _on_attacking_state_state_physics_processing(delta: float) -> void:
	# verificar se o inimigo atual está na lista de inimigos detectados
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$".".look_at(current_enemy.global_position)
	else:
		$StateChart.send_event("To_Patrolling_State")
