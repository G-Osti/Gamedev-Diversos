extends Node2D
class_name Vida

@export var VidaMax := 10.0
@onready var vida := VidaMax

func dano(ataque: Dictionary):
	vida -= ataque["dano"]
	
	if vida <= 0:
		get_parent().queue_free()
