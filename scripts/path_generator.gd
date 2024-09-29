extends Object
# vou dar um nome para essa classe
class_name PathGenerator
# vou criar as variáveis privadas para a geração do maoa
var _grid_length:int # comprimento do mapa
var _grid_height:int # largura do mapa
var _loop_count:int # contador de loops
# array com as posições do caminho
var _path: Array[Vector2i]
# chamar o construtor para iniciar as variáveis privadas da classe
func _init(length:int, height:int):
	_grid_length = length
	_grid_height = height
# função para escolher as posições que vão compor o array _path
func generate_path(add_loops:bool = false):
	# caso queira que seja gerado loops no path, passe true para a função
	_path.clear()
	# o array _path no início sempre deve estar vazio
	_loop_count = 0
	# chamar a função que garante a aleatoriedade 
	randomize()
	# posição inicial
	var x = 0
	var y = int(_grid_height/2.0)
	while x < _grid_length:
		# adiciona a posição inicial
		if not _path.has(Vector2i(x,y)):
			_path.append(Vector2i(x,y))
		# criar a variável para a escolha da direção a seguir
		var choice:int = randi_range(0,2)
		# 0 avança para a direita, 1 avança para baixo e 2 avança para cima
		if choice == 0 or x < 2 or x % 2 == 0 or x == _grid_length-1:
			x += 1
		elif choice == 1 and y < _grid_height-2 and not _path.has(Vector2i(x,y+1)):
			y += 1
		elif choice == 2 and y > 1 and not _path.has(Vector2i(x,y-1)):
			y -= 1
	# caso seja escolhido adicionar loops no caminho
	if add_loops:
		_add_loops()
	# a função vai retornar o caminho com as posições
	return _path
# função para ver atribuir uma pontuação a posição e com isso saber o tile a ser adicionado nessa posição
func get_tile_score(index:int) -> int:
	var score:int = 0
	var x = _path[index].x
	var y = _path[index].y
	# se a posição estiver acima a pontuação é 1
	score += 1 if _path.has(Vector2i(x,y-1)) else 0
	# se a posição estiver ao lado a pontuação é 2
	score += 2 if _path.has(Vector2i(x+1,y)) else 0
	# se a posição estiver em baixo a pontuação é 4
	score += 4 if _path.has(Vector2i(x,y+1)) else 0
	# se a posição estiver à esquerda a pontuação é 8
	score += 8 if _path.has(Vector2i(x-1,y)) else 0
	return score
# uma função para retornar o array com as posições
func get_path() -> Array[Vector2i]:
	return _path
# função para adicionar loops no _path
func _add_loops():
	# criar a variável para gerar loops
	var loops_generated:bool = true
	while loops_generated:
		loops_generated = false # só vai ser adicionado um loop por vez
		# vou ver todas as opções do array path caçando uma posição que possa ser adicionado um loop
		for i in range(_path.size()):
			var loop:Array[Vector2i] = _is_loop_option(i)
			## o array loop vai ser preenchido com as posições do loop
			## agora tem que adicionar essas posições ao _path
			if loop.size() > 0:
				loops_generated = true # pode voltar a gerar loops
				for j in range(loop.size()):
					_path.insert(i+1+j, loop[j])
# agora é a hora de criar a função para verificar as posições que podem ter um loop
func _is_loop_option(index:int) -> Array[Vector2i]:
	# preciso saber a posição x e y de cada índice
	var x: int = _path[index].x
	var y: int = _path[index].y
	# variável para armazenar as posições do loop
	var return_path:Array[Vector2i]
 ###### estrutura do loop ####
##   (2°L) ----------- (1° Loop)
	##    |         |
	##    |         |
## 3°L    |         | (4 ° Loop)
	## ----         ----
	# condição pro primeiro loop
	if (x < _grid_length-1 and y > 1
		and _tile_loc_free(x, y-3) and _tile_loc_free(x+1, y-3) and _tile_loc_free(x+2, y-3)		
		and _tile_loc_free(x-1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x+1, y-2) and _tile_loc_free(x+2, y-2) and _tile_loc_free(x+3, y-2)
		and _tile_loc_free(x-1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1) and _tile_loc_free(x+3, y-1)
		and _tile_loc_free(x+1,y) and _tile_loc_free(x+2,y) and _tile_loc_free(x+3,y)
		and _tile_loc_free(x+1,y+1) and _tile_loc_free(x+2,y+1)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y-1), Vector2i(x+2,y-2), Vector2i(x+1,y-2), Vector2i(x,y-2), Vector2i(x,y-1)]
	
		if _path[index-1].y > y:
			return_path.reverse()
			
		_loop_count += 1
		return_path.append(Vector2i(x,y))
	# condição pro segundo loop
	elif (x > 2 and y > 1
			and _tile_loc_free(x, y-3) and _tile_loc_free(x-1, y-3) and _tile_loc_free(x-2, y-3)		
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x-2, y-1) and _tile_loc_free(x-3, y-1)
			and _tile_loc_free(x+1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x-1, y-2) and _tile_loc_free(x-2, y-2) and _tile_loc_free(x-3, y-2)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x-2, y+1)):
		return_path = [Vector2i(x,y-1), Vector2i(x,y-2), Vector2i(x-1,y-2), Vector2i(x-2,y-2), Vector2i(x-2,y-1), Vector2i(x-2,y), Vector2i(x-1,y)]
	
		if _path[index-1].x > x:
			return_path.reverse()

		_loop_count += 1
		return_path.append(Vector2i(x,y))
	# condição pro terceiro loop
	elif (x < _grid_length-1 and y < _grid_height-2
			and _tile_loc_free(x, y+3) and _tile_loc_free(x+1, y+3) and _tile_loc_free(x+2, y+3)		
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1)
			and _tile_loc_free(x+1, y) and _tile_loc_free(x+2, y) and _tile_loc_free(x+3, y)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x+2, y+1) and _tile_loc_free(x+3, y+1)
			and _tile_loc_free(x-1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x+1, y+2) and _tile_loc_free(x+2, y+2) and _tile_loc_free(x+3, y+2)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y+1), Vector2i(x+2,y+2), Vector2i(x+1,y+2), Vector2i(x,y+2), Vector2i(x,y+1)]

		if _path[index-1].y < y:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x,y))
	# condição pro Quarto loop
	elif (x > 2 and y < _grid_height-2
			and _tile_loc_free(x, y+3) and _tile_loc_free(x-1, y+3) and _tile_loc_free(x-2, y+3)
			and _tile_loc_free(x-1, y-1) and _tile_loc_free(x-2, y-1)
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x-2, y+1) and _tile_loc_free(x-3, y+1)
			and _tile_loc_free(x+1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x-1, y+2) and _tile_loc_free(x-2, y+2) and _tile_loc_free(x-3, y+2)):
		return_path = [Vector2i(x,y+1), Vector2i(x,y+2), Vector2i(x-1,y+2), Vector2i(x-2,y+2), Vector2i(x-2,y+1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if _path[index-1].x > x:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x,y))
		
	return return_path
# função para verificar se já foi usado a posição no _path
func _tile_loc_taken(x: int, y: int) -> bool:
	return _path.has(Vector2i(x,y))
# função para verificar se a posição está livre
func _tile_loc_free(x: int, y: int) -> bool:
	return not _path.has(Vector2i(x,y))
# uma função para retornar a quantidade de loops criados
func get_loop_count() -> int:
	return _loop_count
# uma função para retornar a posição x e y de cada índice do array _path
func get_path_tile(index:int) -> Vector2i:
	return _path[index]
