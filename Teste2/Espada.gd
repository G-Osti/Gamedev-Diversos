extends Area2D
signal fim()
var dir:Vector2
var dano = 2.0
var recuo = 5.0
var recarga = 1.0

func ataque(dira):
	dir=dira
	$AnimationPlayer.speed_scale=(1/(recarga*0.4))
	$AnimationPlayer.play("Ataque")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.speed_scale=(1/(recarga*0.6))
	$AnimationPlayer.play("Guardar")
	await $AnimationPlayer.animation_finished
	fim.emit()

func _on_body_entered(body):
	if "bateu" in body:
		body.bateu(dir,dano,recuo)
	#if area.vida:
		#area.vida.dano(2)
