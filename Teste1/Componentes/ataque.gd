extends Node2D
class_name Ataque

var ataque = {
	dano = 2.5,
	duracao = 1.0,
	recarga = 1.5,
	forca = 1.0,
	nocaute = 1.0
	}

func _on_area_entered(area):
	if area is Caixa:
		area.dano(ataque)
