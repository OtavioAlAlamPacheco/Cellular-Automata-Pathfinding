

# esse script é só pra fazer o desenho das setas. Ele é irrelevante pra
# o pathfinding em si

class_name Caminho

extends TileMapLayer

# atlas com 9 tiles em uma linha, na ordem do deslocamento:
# esquerda, cima, direita, baixo,
# cima esquerda, cima direita, baixo direita, baixo esquerda, vazio
const ID_ATLAS = 0
const INDICE_VAZIO = 8


# o tile indica para qual direção o agente se desloca a partir dessa célula
func inserir_passo(posicao: Vector2i, indice_direcao: int) -> void:
	set_cell(posicao, ID_ATLAS, Vector2i(indice_direcao, 0))


func inserir_destino(posicao: Vector2i) -> void:
	set_cell(posicao, ID_ATLAS, Vector2i(INDICE_VAZIO, 0))


func limpar_caminho() -> void:
	clear()
