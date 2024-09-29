extends Resource
# precisa de um nome essa classe
class_name PathGeneratorConfig
# Os dados necessários para o path generator estarão contidos aqui
@export var map_length:int = 16
@export var map_height:int = 10
@export var min_path_size = 50
@export var max_path_size = 70
@export var min_loops = 3
@export var max_loops = 5
@export var add_loops : bool = false
