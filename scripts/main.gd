

extends Node2D

var Pathfinding = preload("uid://c1cev5886mpsp").new()

@onready var mapa: Mapa = $Mapa
@onready var label_custo: Label = $Custo


func _ready() -> void:
	await get_tree().process_frame
	
	var custo = Pathfinding.menor_caminho(mapa.coord_agente, mapa.coord_alvo, mapa)
	label_custo.text = str("Custo do caminho: ", custo)
	print("Custo: ", custo)
