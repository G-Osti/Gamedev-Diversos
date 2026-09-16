extends Node2D
class_name VIDA

var VIDAMAX = 10.0
@onready var vida = VIDAMAX

func dano(dano):
	vida-=dano
	print(vida,"! Bateu")
