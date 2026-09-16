extends Control

var nome: String = "":
	set(value):
		name = value
		$HBoxContainer/Nome.text = value
		nome = value
var imagem = load("res://Sprites/Cubinho Azul Borda.png"):
	set(value):
		$HBoxContainer/Imagem.set_texture(value)
		imagem = value
var turno: String = "0":
	set(value):
		$HBoxContainer/Turno.text = value
		turno = value
		_invisivel()

func _visivel():
	$Caixa.visible = true

func _invisivel():
	$Caixa.visible = false
