
@tool

extends TileMapLayer

# matrizes são [linha][coluna], mas Vector2 é [coluna][linha]

@export_enum("Vizinhança par", "Jogo da vida") var criterio_sobrevivencia = "Jogo da vida"
@export_enum("4", "8") var vizinhos_adjacentes = "8"

@export var fps_maximo: int = 20

var grid_atual: Array[Array]
var proximo_grid: Array[Array]

var linhas
var colunas

var delta_atual = 0
var intervalo

func _ready() -> void:
	intervalo = 1 / fps_maximo
	
	var tamanho_tela = get_viewport_rect().size
	var tamanho_tile = tile_set.tile_size
	
	colunas = ceili(tamanho_tela.x / tamanho_tile.x)  # 129
	linhas = ceili(tamanho_tela.y / tamanho_tile.y)   # 68
	
	grid_atual.resize(linhas)
	for l in range(linhas):
		grid_atual[l].resize(colunas)
		grid_atual[l].fill(0)
	
	proximo_grid.resize(linhas)
	for l in range(linhas):
		proximo_grid[l].resize(colunas)
		proximo_grid[l].fill(0)
	
	# início aleatório
	for l in range(linhas):
		for c in range(colunas):
			var estado = randi() % 2
			set_cell(Vector2i(c, l), estado, Vector2i(0, 0))
			proximo_grid[l][c] = estado


func _process(delta: float) -> void:
	delta_atual += delta
	if delta_atual < intervalo:
		return
	else:
		delta_atual -= intervalo
	
	# atualizar o estado atual
	for l in range(linhas):
		for c in range(colunas):
			var estado = proximo_grid[l][c]
			set_cell(Vector2i(c, l), estado, Vector2i(0, 0))
			grid_atual[l][c] = estado
	
	# calcular próximo estado
	for l in range(linhas):
		for c in range(colunas):
			var estado = calcular_proximo_estado(Vector2i(l, c))
			proximo_grid[l][c] = estado


func calcular_proximo_estado(posicao: Vector2i):
	var soma = soma_dos_vizinhos(posicao)
	
	if criterio_sobrevivencia == "Vizinhança par":
		return vizinhanca_par(soma)
	elif criterio_sobrevivencia == "Jogo da vida":
		var estado: int = grid_atual[posicao.x][posicao.y]
		return jogo_da_vida(estado, soma)


# se a soma dos estados adjacentes é par, vive. Se é ímpar, morre
func vizinhanca_par(soma: int) -> int:
	if soma % 2 == 0:
		return 0
	else:
		return 1


# Subpopulação: Se uma célula viva tiver menos de 2 vizinhos vivos, ela morre (solidão).
# Equilíbrio: Se uma célula viva tiver 2 ou 3 vizinhos vivos, ela sobrevive para a próxima geração.
# Superpopulação: Se uma célula viva tiver mais de 3 vizinhos vivos, ela morre (falta de recursos).
# Reprodução: Se uma célula morta tiver exatamente 3 vizinhos vivos, ela nasce (torna-se viva).
func jogo_da_vida(estado: int, soma: int) -> int:
	if soma < 2:
		return 0
	elif estado == 1 and (soma == 2 or soma == 3):
		return 1
	elif estado == 1 and soma > 3:
		return 0
	elif estado == 0 and soma == 3:
		return 1
	else:
		return 0



func soma_dos_vizinhos(posicao: Vector2i) -> int:
	if vizinhos_adjacentes == "8":
		return soma_oito_vizinhos(posicao)
	elif vizinhos_adjacentes == "4":
		return soma_quatro_vizinhos(posicao)
	else:
		push_error("Número de vizinhos inválido: ", vizinhos_adjacentes)
		return 0

func soma_oito_vizinhos(posicao: Vector2i) -> int:
	var soma = 0
	for l in range(-1, 2): # (-1, 0, 1)
		for c in range(-1, 2):
			var vizinho_l = posicao.x + l
			var vizinho_c = posicao.y + c
			
			if (vizinho_l > linhas-1 or vizinho_c > colunas-1 or 
				vizinho_l < 0 or vizinho_c < 0
				or (l == 0 and c == 0)
			):
				continue
			
			var estado = grid_atual[posicao.x + l][posicao.y + c]
			soma += estado
	
	return soma


func soma_quatro_vizinhos(posicao: Vector2i) -> int:
	var soma = 0
	
	# esquerda meio
	var vizinho_l = posicao.x + -1
	var vizinho_c = posicao.y + 0
	if not (vizinho_l > linhas-1 or vizinho_c > colunas-1 or vizinho_l < 0 or vizinho_c < 0):
		var estado = grid_atual[posicao.x + -1][posicao.y + 0]
		soma += estado
	
	# meio cima
	vizinho_l = posicao.x + 0
	vizinho_c = posicao.y + 1
	if not (vizinho_l > linhas-1 or vizinho_c > colunas-1 or vizinho_l < 0 or vizinho_c < 0):
		var estado = grid_atual[posicao.x + 0][posicao.y + 1]
		soma += estado
	
	# meio baixo
	vizinho_l = posicao.x + 0
	vizinho_c = posicao.y + -1
	if not (vizinho_l > linhas-1 or vizinho_c > colunas-1 or vizinho_l < 0 or vizinho_c < 0):
		var estado = grid_atual[posicao.x + 0][posicao.y + -1]
		soma += estado
	
	# direita meio
	vizinho_l = posicao.x + 1
	vizinho_c = posicao.y + 0
	if not (vizinho_l > linhas-1 or vizinho_c > colunas-1 or vizinho_l < 0 or vizinho_c < 0):
		var estado = grid_atual[posicao.x + 1][posicao.y + 0]
		soma += estado
	
	return soma
