extends CharacterBody2D

#@onready var coord: Vector2 = position/128
var vell = 200
var vells = 3*vell
var dir: Vector2
var correndo: bool = false
var livre: bool = true
var dira: Vector2

func _process(_delta):
	dir = Input.get_vector("ESQ","DIR","CIMA","BAIXO").normalized()
	if livre == true:
		
		if Input.is_action_just_pressed("CORRE"):
			correndo = true
		if Input.is_action_just_released("CORRE"):
			correndo = false
		
		if Input.is_action_just_pressed("ATK"):
			$Espada.ataque(dira)
			#livre = false
			print("ataque")
		
		if abs(dir.x)>0.01 or abs(dir.y)>0.01:
			rotation = dir.angle()
			dira = dir
			if correndo == false:
				velocity = dir*vell
			if correndo == true:
				velocity = dir*vells
		else:
			velocity = Vector2.ZERO
		move_and_slide()


func _on_espada_fim():
	livre = true
