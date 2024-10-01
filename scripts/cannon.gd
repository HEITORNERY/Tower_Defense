extends Node3D
class_name Cannon
# variável para armazenar os inimigos na área de detecção
var enemies_in_range : Array[Node3D]
# sinal para detectar quando um inimigo entrar na área
func _on_patrol_zone_area_entered(area: Area3D) -> void:
	# adiciona o inimigo ao array
	enemies_in_range.append(area.get_node("../../../.."))
	print(enemies_in_range.size())
# sinal para quando o inimigo sair da área de detecção
func _on_patrol_zone_area_exited(area: Area3D) -> void:
	# retira o inimigo aasim que sair da área
	enemies_in_range.erase(area.get_node("../../../.."))
	print(enemies_in_range.size())
# Função para ativar e desativar o monitoramento
func set_patrolling(patrolling: bool):
	$PatrolZone.monitoring = patrolling
