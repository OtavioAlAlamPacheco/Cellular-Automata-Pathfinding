
extends Node

var _lista_estados: Array = [     # estado
	preload("uid://ddyrqlllkj0eo"),  # 0
	preload("uid://dt48ypeylypgy"),  # 1
	preload("uid://cgtt4vj2ye1qi"),  # -1
	preload("uid://elmgfmlxdk4w"),   # -2
	preload("uid://brkvtbqad2l7u"),  # -3
	preload("uid://d2xo05dh8o35h"),  # -4
	preload("uid://dpkqvclagatwb"),  # -5
	preload("uid://csx80t2x0mamd"),  # -6
	preload("uid://dvcs11cwbxo8k"),  # -7
	preload("uid://cpa1ewk6w63pq"),  # -8
	preload("uid://bawmmotq3mn27"),  # -9
	preload("uid://wq1c0y3eypbv"),   # -10
]

# quero que a representação no Custom Data do tilemaplayer seja com
# números negativos. Por isso preciso inverter o sinal pra acessar
# o array
func get_estado(estado: int) -> Estado:
	if estado >= 0:
		return _lista_estados[estado]
	return _lista_estados[1 - estado]
