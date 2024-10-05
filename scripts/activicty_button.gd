extends Button
# esse botão precisa de uma textura
@export var activity_button : Texture2D
# a cena do objeto a ser arrastado precisa ser declarado
@export var activity_draggable : PackedScene
# condicional para o objeto estar sendo arrastado ou não
var _is_dragging : bool = false
# variável do objeto node que vai ser instanciado
var _draggable: Node
# crie uma referência para a camera 3d
var _cam : Camera3D
# adicione o tamanho do raycast
var RAYCAST_LENGTH : int = 100
# essa variável serve para saber se a posição para onde o objeto está sendo arrastado é valida
var _is_valid_location:bool = false
# armazena a última posição na qual o objeto arrastado foi colocado, pois essa posição não deve ser disponível agora
var _last_valid_location:Vector3
# array para aramzenar os tiles usados para adicionar as armas
var tiles_used : Array
# Carrega um material de erro da pasta de recursos (usado para indicar locais inválidos)
@onready var _error_mat:BaseMaterial3D = preload("res://materials/material_red.tres")
func _ready() -> void:
	# atribuir ao ícone do botão a textura
	icon = activity_button
	# instanciando o objeto 
	_draggable = activity_draggable.instantiate()
	_draggable.set_patrolling(false)
	add_child(_draggable)
	_draggable.visible = false
	# obter a câmera da janela atual
	_cam = get_viewport().get_camera_3d()
# Chamar a physics process para poder criar o raycast de detecção da área que o mouse está clicando
# E o raycast vai ver as colisões na direção do mouse, para saber se o caminho está livre ou não
func _physics_process(delta: float) -> void:
	# Verifica se o objeto está sendo arrastado.
	if _is_dragging:
		# Obtém o estado do espaço 3D (usado para detecção de colisões e outros cálculos espaciais).
		var space_state = _draggable.get_world_3d().direct_space_state
		# Obtém a posição do mouse na tela.
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		# Converte a posição 2D do mouse para uma origem 3D do raio (Raycast).
		var origin:Vector3 = _cam.project_ray_origin(mouse_pos)
		# Calcula o ponto final do raio projetado no espaço 3D.
		var end:Vector3 = origin + _cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		# Cria parâmetros para o Raycast, com origem e destino definidos.
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		# Define que o Raycast pode colidir com áreas.
		query.collide_with_areas = true
		# Executa o Raycast e armazena o resultado em 'rayResult'.
		var rayResult:Dictionary = space_state.intersect_ray(query)
		# Se o Raycast encontrou algo.
		if rayResult.size() > 0:
			# Obtém o objeto que colidiu com o raio.
			var co:CollisionObject3D = rayResult.get("collider")
			# Verifica se o objeto faz parte do grupo "Grid_Empty" (local válido).
			if co.get_groups().size() > 0 and co.get_groups()[0] == "Grid_Empty":
				# Torna o objeto visível.
				_draggable.visible = true
				# Marca que o local é válido.
				_is_valid_location = true
				# Armazena a última posição válida do objeto.
				_last_valid_location = Vector3(co.global_position.x, 0.2, co.global_position.z)
				# Atualiza a posição do objeto arrastável.
				_draggable.global_position = _last_valid_location
				# Limpa qualquer erro visual no objeto (se houver).
				clear_child_mesh_error(_draggable) 
			# Caso o local não seja válido.
			else:
				# Torna o objeto visível.
				_draggable.visible = true
				# Atualiza a posição do objeto.
				_draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
				# Marca que o local não é válido.
				_is_valid_location = false
				# Aplica um material de erro ao objeto.
				set_child_mesh_error(_draggable)
				
		else:
			# Se o Raycast não encontrar nada, o objeto permanece invisível.
			_draggable.visible = false
# Função para aplicar o material de erro a todos os filhos MeshInstance3D do objeto arrastável
func set_child_mesh_error(n:Node):
	# Itera sobre todos os filhos do nó 'n'.
	for c in n.get_children():
		# Se o filho for uma malha 3D.
		if c is MeshInstance3D:
			# Aplica o erro à malha.
			set_mesh_error(c)
		# Se o filho for um nó com mais filhos.
		if c is Node and c.get_child_count() > 0:
			# Aplica o erro a seus filhos também.
			set_child_mesh_error(c)
# Aplica o material de erro em cada superfície de uma malha 3D.
func set_mesh_error(mesh_3d:MeshInstance3D):
	# Itera sobre todas as superfícies da malha.
	for si in mesh_3d.mesh.get_surface_count():
		# Substitui o material da superfície pelo material de erro.
		mesh_3d.set_surface_override_material(si, _error_mat)
# Função para limpar o material de erro dos filhos de um nó.
func clear_child_mesh_error(n:Node):
	# Itera sobre todos os filhos.
	for c in n.get_children():
		# Se o filho for uma malha 3D
		if c is MeshInstance3D:
			# Limpa o erro da malha.
			clear_mesh_error(c)
		# Se o filho for um nó com filhos.
		if c is Node and c.get_child_count() > 0:
			# Limpa o erro de seus filhos também.
			clear_child_mesh_error(c)
# Remove o material de erro de uma malha 3D.
func clear_mesh_error(mesh_3d:MeshInstance3D):
	# Itera sobre todas as superfícies da malha.
	for si in mesh_3d.mesh.get_surface_count():
		# Remove o material de erro substituindo por 'null'.
		mesh_3d.set_surface_override_material(si, null)
# sinal do botão pressionado, que permite arrastar o objeto
func _on_button_down() -> void:
	# Marca que o objeto está sendo arrastado.
	_is_dragging = true
# sinal que o objeto já chegou no seu destino e vai ser liberado ali
func _on_button_up() -> void:
	# Marca que o objeto não está mais sendo arrastado.
	_is_dragging = false
	# Torna o objeto invisível.
	_draggable.visible = false
	# Se a posição do objeto for válida.
	if _is_valid_location and not tiles_used.has(_last_valid_location):
		# Instancia um novo objeto arrastável.
		var activity = activity_draggable.instantiate()
		# Adiciona o objeto à cena.
		add_child(activity)
		# Posiciona o objeto na última posição válida.
		activity.global_position = _last_valid_location
		tiles_used.append(_last_valid_location)
