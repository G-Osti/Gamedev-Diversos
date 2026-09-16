extends Area2D
class_name Caixa

@export var vida : Vida

func dano(ataque: Dictionary):
	if vida:
		vida.dano(ataque)
