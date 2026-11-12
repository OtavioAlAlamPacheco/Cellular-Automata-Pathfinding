
class_name Vizinho

extends Resource

@export var x: int
@export var y: int

func eh_igual(x2: int, y2: int):
	return (x2 == x and y2 == y)

func _init(x_inicial: int = 0, y_inicial: int = 0) -> void:
	x = x_inicial
	y = y_inicial

func oposto() -> Vizinho:
	return Vizinho.new(-x, -y)
