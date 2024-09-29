extends Node3D
# primeiro preciso das referências as cenas dos objetos que vão compor o cenário
@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]
# como o script da geração de mapa está no autoload não é mais necessário criar um objeto para ele
func _ready():
	_display_path()
	_complete_grid()
	# esperar dois segundos par spawnar o inimigo e fazer ele seguir os pontos
	await get_tree().create_timer(2).timeout
	_pop_along_grid()
# uma função para adicionar os pontos numa curva, pontos estes que serão seguidos pelo inimigo
func _add_curve_point(c3d:Curve3D, v3:Vector3) ->bool:
	c3d.add_point(v3)
	return true
# função para mover o inimigo pelo caminho
func _pop_along_grid():
	var enemy = tile_enemy.instantiate()
	# criar um objeto curve3d no qual vai conter os pontos a serem percorridos pelo inimigo
	var c3d:Curve3D = Curve3D.new()
	# adicionar cada elemento do meu array de posições nessa curva
	for element in PathGenInstance.get_path_route(): # agora tudo relacionado ao path generator vai ser carregado do PathGenInstance
		c3d.add_point(Vector3(element.x, 0.4, element.y))
	# criar um objeto path3d no qual os pontos do caminho a ser percorridos serão atribuídos
	var p3d:Path3D = Path3D.new()
	# adicionar esse elemento na cena 
	add_child(p3d)
	# adicionar todos os pontos da curva nesse path3d
	p3d.curve = c3d
	## adicionar um pathfollow3d para o inimigo prosseguir no caminho
	## o inimigo deve ser filho do path follow 3d e o path follow 3d deve ser filho do path3d
	var pf3d:PathFollow3D = PathFollow3D.new()
	p3d.add_child(pf3d)
	pf3d.add_child(enemy)
	# o inimigo vai percorrer o caminho do path follow 3d, por meio da atualização do progresso
	var curr_distance:float = 0.0
	while curr_distance < c3d.point_count-1:
		curr_distance += 0.02 # velocidade de movimento do inimigo
		pf3d.progress = clamp(curr_distance, 0, c3d.point_count-1.00001)
		# o progresso vai de 0 até um valor muito pequeno depois do máximo, assim não ultrapassa o valor máximo
		await get_tree().create_timer(0.01).timeout
		# quando esse tempo acabar uma nova iteração será feita
# aqui está a função para garantir que os tiles que não são o caminho sejam preenchidos com decoração
func _complete_grid():
	for x in range(PathGenInstance.path_config.map_length):
		for y in range(PathGenInstance.path_config.map_height):
			if not PathGenInstance.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
# função para exibir o caminho
func _display_path():
	# não precisa mais das iterações que eram feitas para criar o caminho, agora isso já é feito no script do path generator
	for i in range(PathGenInstance.get_path_route().size()):
		var tile_score:int = PathGenInstance.get_tile_score(i)
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		if tile_score == 2:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 8:
			tile = tile_end.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,360,0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,-90,0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,-270,0)
		elif tile_score == 15:
			tile = tile_crossroads.instantiate()
			tile_rotation = Vector3(0,0,0)
		# adicionar os tiles na cena
		add_child(tile)
		tile.global_position = Vector3(PathGenInstance.get_position_tile(i).x, 0, PathGenInstance.get_position_tile(i).y)
		tile.global_rotation_degrees = tile_rotation
