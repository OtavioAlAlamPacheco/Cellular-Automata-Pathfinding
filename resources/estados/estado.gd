

class_name Estado

extends Resource

# Se essa é a célula atual do agente, é só chamar pode_entrar_em
# (movimento de saída)
# Se essa é uma célula vizinha do agente, chamar pode_entrar_em
# passando os sinais do vizinho trocados (movimento de entrada)
@export var movimentos_permitidos: Array[Vizinho]

# os estados -9 e -10 não podem ser acessados (mas influenciam nos
# movimentos de saída para as células adjacentes a essa)
@export var pode_ser_acessada: bool = true


func pode_entrar_em(vizinho: Vizinho) -> bool:
	for permitido in movimentos_permitidos:
		if permitido.eh_igual(vizinho.x, vizinho.y):
			return true
	return false
