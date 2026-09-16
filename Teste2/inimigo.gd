extends CharacterBody2D

var VIDAMAX = 10.0
@onready var vida = VIDAMAX
@onready var tam = scale
var imortal:bool = false
var timortal = 0.5

func bateu(dira,dano,recuo):
	print(dira)
	if imortal==false:
		imortal=true
		vida-=dano
		print(vida,"! Bateu")
		var tween = create_tween().set_parallel(true)
		if vida>0:
			tween.tween_property($".","position",position+64*dira*recuo,timortal/2)
			tween.tween_property($".","modulate",Color(1,0,0,1),timortal/2)
			tween.tween_property($".","scale",1.4*tam,timortal/2)
			tween.chain().tween_property($".","modulate",Color(1,1,1,1),timortal/2)
			tween.tween_property($".","scale",tam,timortal/2)
		else:
			print("morreu")
			$CollisionShape2D.disabled=true
			$Timer.start()
			tween.tween_property($".","modulate",Color(1,0,0,1),0.4)
			tween.tween_property($".","skew",2*PI,0.4)
		imortal=false

func _on_timer_timeout():
	queue_free()
