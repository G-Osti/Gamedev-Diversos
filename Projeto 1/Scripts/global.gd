extends Node

@onready var dist: float = 8
@onready var escala: float = 2
var estado: String = "Mapa"
var vel_anim: float = 2

func XY_ISO(CI:Vector2):
	var CO: Vector2 = Vector2(0,0)
	CO.x = CI.x - CI.y
	CO.y = 0.5*CI.x + 0.5*CI.y
	return CO

func ISO_XY(CI:Vector2):
	var CO: Vector2 = Vector2(0,0)
	CO.x = 0.5*CI.x + CI.y
	CO.y = -0.5*CI.x + CI.y
	return CO

func V2inV3A(V2:Vector2,V3A:PackedVector3Array,altura:int):
	for camada in altura:
		if Vector3(V2.x,V2.y,camada) in V3A:
			return camada

#func _vizinhos(X:int,Y:int,XY:Vector2i,Reg:PackedVector2Array): #Responde se há vizinhos registrados
	#if (Vector2(XY+Vector2i(X,Y+1)) in Reg or Vector2(XY+Vector2i(X,Y-1)) in Reg or Vector2(XY+Vector2i(X+1,Y)) in Reg or Vector2(XY+Vector2i(X-1,Y)) in Reg): #or Vector2(XY+Vector2i(X+1,Y+1)) in Reg or Vector2(XY+Vector2i(X+1,Y-1)) in Reg or Vector2(XY+Vector2i(X-1,Y+1)) in Reg or Vector2(XY+Vector2i(X-1,Y-1)) in Reg):
		#return true
