
class_name Mapa

extends TileMapLayer

@onready var personagem: Sprite2D = $"../Personagem"
@onready var bau: Sprite2D = $"../Bau"
@onready var caminho: Caminho = $"../Caminho"


var coord_agente
var coord_alvo

func _ready():
	setar_posicoes()

func setar_posicoes():
	var pos_agente_local = to_local(personagem.global_position)
	var pos_alvo_local = to_local(bau.global_position)
	
	coord_agente = local_to_map(pos_agente_local)
	coord_alvo = local_to_map(pos_alvo_local)
	print("Agente está na célula: ", coord_agente)
	print("Alvo está na célula: ", coord_alvo)


func get_estado_da_celula(posicao: Vector2i) -> Estado:
	var dados = get_cell_tile_data(posicao)
	if dados == null:
		return null
	
	var cod_estado: int = dados.get_custom_data("cod_estado")
	return ListaEstados.get_estado(cod_estado)
