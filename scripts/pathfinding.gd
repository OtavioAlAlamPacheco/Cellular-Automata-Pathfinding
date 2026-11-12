

extends RefCounted

const CUSTO_RETO = 10
const CUSTO_DIAGONAL = 14
const CUSTO_INFINITO = 999999
const SEM_DIRECAO = -1

# Índices das direções (mesma ordem de direcoes e do atlas do Caminho)
const ESQUERDA = 0
const CIMA = 1
const DIREITA = 2
const BAIXO = 3
const CIMA_ESQUERDA = 4
const CIMA_DIREITA = 5
const BAIXO_DIREITA = 6
const BAIXO_ESQUERDA = 7

# Em Vizinho, y = +1 é cima e y = -1 é baixo (no TileMap é invertido)
var direcoes: Array[Vizinho] = [
	Vizinho.new(-1, 0),
	Vizinho.new(0, 1),
	Vizinho.new(1, 0),
	Vizinho.new(0, -1),
	Vizinho.new(-1, 1),
	Vizinho.new(1, 1),
	Vizinho.new(1, -1),
	Vizinho.new(-1, -1),
]
var direcoes_opostas: Array[Vizinho] = []

# Os dois movimentos retos que formam cada diagonal
var componentes_diagonais = {
	CIMA_ESQUERDA: [CIMA, ESQUERDA],
	CIMA_DIREITA: [CIMA, DIREITA],
	BAIXO_DIREITA: [BAIXO, DIREITA],
	BAIXO_ESQUERDA: [BAIXO, ESQUERDA],
}

# matrizes são [linha][coluna], mas Vector2i é (coluna, linha)
var estados: Array[Array]
var grid_atual: Array[Array]
var proximo_grid: Array[Array]
var grid_direcoes: Array[Array]

var linhas: int
var colunas: int


func _init() -> void:
	for direcao in direcoes:
		direcoes_opostas.append(direcao.oposto())


func menor_caminho(coord_inicial: Vector2i, coord_final: Vector2i, mapa: Mapa) -> int:
	mapa.caminho.limpar_caminho()
	preparar_grids(mapa)
	
	if not celula_acessivel(coord_inicial) or not celula_acessivel(coord_final):
		push_error("Agente ou alvo estão em uma célula inválida")
		return CUSTO_INFINITO
	
	grid_atual[coord_final.y][coord_final.x] = 0
	proximo_grid[coord_final.y][coord_final.x] = 0
	
	var terminou = false
	while not terminou:
		var menor_custo_alterado = calcular_proximo_grid()
		trocar_buffers()
		terminou = onda_terminou(coord_inicial, menor_custo_alterado)
	
	var custo_total = grid_atual[coord_inicial.y][coord_inicial.x]
	if custo_total == CUSTO_INFINITO:
		push_warning("Não existe caminho até o alvo")
		return CUSTO_INFINITO
	
	desenhar_caminho(coord_inicial, coord_final, mapa.caminho)
	return custo_total


func preparar_grids(mapa: Mapa) -> void:
	var area = mapa.get_used_rect()
	colunas = area.end.x
	linhas = area.end.y
	
	estados = criar_grid(null)
	grid_atual = criar_grid(CUSTO_INFINITO)
	proximo_grid = criar_grid(CUSTO_INFINITO)
	grid_direcoes = criar_grid(SEM_DIRECAO)
	
	for l in range(linhas):
		for c in range(colunas):
			estados[l][c] = mapa.get_estado_da_celula(Vector2i(c, l))


func criar_grid(valor_inicial) -> Array[Array]:
	var grid: Array[Array] = []
	for l in range(linhas):
		var linha: Array = []
		linha.resize(colunas)
		linha.fill(valor_inicial)
		grid.append(linha)
	return grid


func calcular_proximo_grid() -> int:
	var menor_custo_alterado = CUSTO_INFINITO
	
	for l in range(linhas):
		for c in range(colunas):
			var custo_antigo = grid_atual[l][c]
			var custo_novo = calcular_proximo_estado(Vector2i(c, l))
			proximo_grid[l][c] = custo_novo
			
			if custo_novo < custo_antigo and custo_novo < menor_custo_alterado:
				menor_custo_alterado = custo_novo
	
	return menor_custo_alterado


func calcular_proximo_estado(posicao: Vector2i) -> int:
	var melhor_custo = grid_atual[posicao.y][posicao.x]
	
	if not celula_acessivel(posicao):
		return melhor_custo
	
	for i in range(direcoes.size()):
		var custo = custo_atraves_de_vizinho(posicao, i)
		if custo < melhor_custo:
			melhor_custo = custo
			grid_direcoes[posicao.y][posicao.x] = i
	
	return melhor_custo


# custo para o agente ir de "origem" até o alvo passando pelo vizinho
# que está na direção "indice"
func custo_atraves_de_vizinho(origem: Vector2i, indice: int) -> int:
	var direcao = direcoes[indice]
	var destino = aplicar_direcao(origem, direcao)
	
	if not dentro_do_grid(destino):
		return CUSTO_INFINITO
	
	var custo_destino = grid_atual[destino.y][destino.x]
	if custo_destino == CUSTO_INFINITO:
		return CUSTO_INFINITO
	
	if not movimento_permitido(origem, indice):
		return CUSTO_INFINITO
	
	return custo_destino + custo_do_movimento(direcao)


func movimento_permitido(origem: Vector2i, indice: int) -> bool:
	if not passo_permitido(origem, indice):
		return false
	
	if custo_do_movimento(direcoes[indice]) == CUSTO_RETO:
		return true
	
	var componentes = componentes_diagonais[indice]
	var primeiro = componentes[0]
	var segundo = componentes[1]
	
	return (caminho_reto_livre(origem, primeiro, segundo, indice)
		and caminho_reto_livre(origem, segundo, primeiro, indice))


func caminho_reto_livre(origem: Vector2i, primeiro: int, segundo: int, indice_diagonal: int) -> bool:
	var intermediaria = aplicar_direcao(origem, direcoes[primeiro])
	
	if celula_acessivel(intermediaria):
		return (passo_permitido(origem, primeiro)
			and passo_permitido(intermediaria, segundo))
	
	return parede_permite_diagonal(intermediaria, indice_diagonal)


func parede_permite_diagonal(posicao: Vector2i, indice_diagonal: int) -> bool:
	var estado: Estado = estados[posicao.y][posicao.x]
	if estado == null:
		return false
	
	return estado.pode_entrar_em(direcoes[indice_diagonal])


func passo_permitido(origem: Vector2i, indice: int) -> bool:
	var destino = aplicar_direcao(origem, direcoes[indice])
	if not celula_acessivel(destino):
		return false
	
	var estado_origem: Estado = estados[origem.y][origem.x]
	var estado_destino: Estado = estados[destino.y][destino.x]
	
	# movimento de saída
	if not estado_origem.pode_entrar_em(direcoes[indice]):
		return false
	
	# movimento de entrada
	return estado_destino.pode_entrar_em(direcoes_opostas[indice])


func custo_do_movimento(direcao: Vizinho) -> int:
	if direcao.x != 0 and direcao.y != 0:
		return CUSTO_DIAGONAL
	return CUSTO_RETO


# a próxima geração vira a atual
func trocar_buffers() -> void:
	var anterior: Array[Array] = grid_atual
	grid_atual = proximo_grid
	proximo_grid = anterior


# mesmo que chegue no personagem, pode ter caminho mais curto do que
# o encontrado (por causa do movimento diagonal ser mais custoso)
func onda_terminou(coord_inicial: Vector2i, menor_custo_alterado: int) -> bool:
	if menor_custo_alterado == CUSTO_INFINITO:
		return true
	
	var custo_agente = grid_atual[coord_inicial.y][coord_inicial.x]
	if custo_agente == CUSTO_INFINITO:
		return false
	
	return custo_agente <= menor_custo_alterado + CUSTO_RETO



func desenhar_caminho(coord_inicial: Vector2i, coord_final: Vector2i, caminho: Caminho) -> void:
	var posicao = coord_inicial
	while posicao != coord_final:
		var indice = grid_direcoes[posicao.y][posicao.x]
		caminho.inserir_passo(posicao, indice)
		posicao = aplicar_direcao(posicao, direcoes[indice])
	
	caminho.inserir_destino(coord_final)


# em Vizinho, y positivo é cima. No TileMap, y positivo é baixo
func aplicar_direcao(posicao: Vector2i, direcao: Vizinho) -> Vector2i:
	return Vector2i(posicao.x + direcao.x, posicao.y - direcao.y)


func dentro_do_grid(posicao: Vector2i) -> bool:
	return (posicao.x >= 0 and posicao.x < colunas
		and posicao.y >= 0 and posicao.y < linhas)


func celula_acessivel(posicao: Vector2i) -> bool:
	if not dentro_do_grid(posicao):
		return false
	
	var estado: Estado = estados[posicao.y][posicao.x]
	if estado == null:
		return false
	
	return estado.pode_ser_acessada
