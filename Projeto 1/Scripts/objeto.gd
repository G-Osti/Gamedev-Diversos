extends CharacterBody2D
class_name Objeto

var Coord: Vector2i
@onready var Mapa = $".." as TileMap
var vel = 5000
var sobre:bool = false
var estado:String = "Livre"
var rotaISO: PackedVector2Array = []
var rota: PackedVector2Array = []
var rota_altura: Array = []
var IA = false
var Grupo = 0 #0 Neutro
var Menu = "Início"

var vida_max = 50
var vida = vida_max
var ataque = 18
var mov = 3
var movr = mov
var altura = 0

var velocidade = 8
var turno = 0

var dir = "y"
var rota_total: PackedVector2Array

var movimento = false
var ação = false
var tacao = 100

var anim: Animation

func _ready():
	#Coord = floor(Global.ISO_XY(get_global_mouse_position()+Vector2(0,16))/(2*Global.dist))
	modulate = Color(1,1,1)
	estado = "Gasto"
	
func _process(_delta): 
	if Input.is_action_just_pressed('M1') and Global.estado!="Seleção":
		if estado == "Movimentos":
			_andando()
		if estado == "Livre" and $"../..".SelCoord == Coord and IA == false:
			_andar()
		#if estado == "Livre" and $"../..".SelCoord == Coord and IA == true:
			#_selecionado_IA()
	if Global.estado == "Seleção":
		Global.estado = "Selecionado"

func _unhandled_input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if estado == "Movimentos" and IA == false:
			_movimentos(Coord,$"../..".SelCoord)

func _andando():
	estado = "Andando"
	Global.estado = "Mapa"
	$AnimationPlayer.stop(false)
	for item in rota:
		if rota.find(item)!=0:
			if Vector2i(item)-Coord == Vector2i(-1,0) and not dir == "-x":
				dir = "-x"
				await get_tree().create_timer(0.1*Global.vel_anim).timeout
			if Vector2i(item)-Coord == Vector2i(0,-1) and not dir == "-y":
				dir = "-y"
				await get_tree().create_timer(0.1*Global.vel_anim).timeout
			if Vector2i(item)-Coord == Vector2i(1,0) and not dir == "x":
				dir = "x"
				await get_tree().create_timer(0.1*Global.vel_anim).timeout
			if Vector2i(item)-Coord == Vector2i(0,1) and not dir == "y":
				dir = "y"
				await get_tree().create_timer(0.1*Global.vel_anim).timeout
			var k = -1
			for camada in $"../..".Camadas:
				if item in $"../..".Base and camada.get_cell_atlas_coords(0,item)!=Vector2i(-1,-1):
					k += 1
			if z_index != k+1:
				await get_tree().create_timer((0.1*Global.vel_anim)).timeout
				z_index = k+3
				$AnimationPlayer.play("Pulo",-1,(1.25*Global.vel_anim))
			var tween = create_tween()
			tween.tween_property($".","position",(Global.XY_ISO(Vector2(item+Vector2(1,0)))*Global.dist)+Vector2(0,-8*k),(0.6/Global.vel_anim))
			Coord = Vector2i(item)
			await tween.finished
			z_index = k+1
			#await get_tree().create_timer(0.1*vel_anim).timeout
			$AnimationPlayer.stop(true)
			#position = item
			$Sprite2D.position = Vector2(0,-16)
	$"../.."._limpar()
	$AnimationPlayer.stop(false)
	if ação == false:
		if rota_total.size()>rota.size():
			for entidade in $"../..".objeto:
				if entidade.Coord == Vector2i(rota_total[rota.size()]) and not entidade.estado == "Morto":
					if entidade.Grupo != Grupo:
						ação = true
						_ataque(entidade)
					if entidade.Grupo == Grupo:
						ação = true
						_ajuda(entidade)
			if ação == false:
				print("Menu!")
				_fim_turno()
		else:
			print("Menu!")
			_fim_turno()
	else:
		_fim_turno()
	modulate = Color(1,1,1)
	rota.clear()
	$"../.."._exibir_rota(rota)

func _movimentos(ini:Vector2i,alvo:Vector2i):
	rota.clear()
	rota_total = $"../..".astar_grid.get_point_path(ini,alvo)
	var i=0
	for item in rota_total:
		if i<movr+1 and Vector2(item) in $"../..".Base:
			rota.append(Vector2(item))
			i+=1
	_ver_final()
	$"../.."._exibir_rota(rota)

func _ver_final():
	if not rota[rota.size()-1] in $"../..".Movimentos and not rota[rota.size()-1] in $"../..".alvos:
			rota.remove_at(rota.size()-1)
			_ver_final()
	for entidade in $"../..".objeto:
		if entidade.Coord != Coord and rota[rota.size()-1] == Vector2(entidade.Coord) and entidade.estado!="Morto":
			rota.remove_at(rota.size()-1)
			_ver_final()

func _andar():
	estado = "Movimentos"
	Global.estado = "Selecionado"
	$"../.."._alcance(Coord,self,movr)

func _selecionado_IA():
	_andar()
	var proximo: Vector2i
	for item in $"../..".objeto:
		if item.Grupo!=Grupo and item.estado != "Fora":
			if proximo.length() == 0:
				proximo = item.Coord
			elif $"../..".astar_grid.get_id_path(Coord,item.Coord).size() < $"../..".astar_grid.get_id_path(Coord,proximo).size():
				proximo = item.Coord
	print("Início: ",Coord," Alvo: ",proximo)
	_movimentos(Coord,proximo)
	_andando()

func _turno():
	$"../.."._foco(Coord,altura)
	$"../..".Tempo = "parado"
	if estado != "Fora":
		estado = "Livre"
		anim = $AnimationPlayer.get_animation("Turno")
		anim.loop_mode = Animation.LOOP_PINGPONG
		$AnimationPlayer.play("Turno")
		if IA==true:
			_selecionado_IA()
		else:
			#_menu()
			pass
	else:
		_morte()

func _fim_turno():
	turno -= tacao
	estado = "Gasto"
	$"../..".Tempo = "rodando"

func _ataque(alvo):
	print("Ataque!")
	var tween = create_tween()
	var pos = position
	tween.tween_property(self,"position",pos+((alvo.position-pos)/2),0.2/Global.vel_anim)
	tween.tween_property(self,"position",pos,0.6/Global.vel_anim)
	alvo.vida-=ataque
	if alvo.vida<=0:
		alvo.estado = "Fora"
		alvo.modulate = Color(0.5,0.5,0.5)
	if alvo.vida<=-alvo.vida_max:
		alvo.estado = "Morto"
		alvo.turno = 0
		alvo.modulate = Color(0.5,0.5,0.5,0)
	_fim_turno()

func _ajuda(alvo):
	print("Ajuda!")
	var tween = create_tween()
	var pos = position
	tween.tween_property(self,"position",pos+((alvo.position-pos)/2),0.2/Global.vel_anim)
	tween.tween_property(self,"position",pos,0.6/Global.vel_anim)
	alvo.vida+=ataque
	if alvo.vida>=0 and alvo.estado=="Fora":
		alvo.estado = "Gasto"
		alvo.modulate = Color(1,1,1)
	_fim_turno()

func _morte():
	turno = 0
	$"../..".Tempo = "rodando"

func _menu():
	$"../../Canvaslayer/Menu/VBoxContainer".clear()
	$"../../Canvaslayer/Menu".visible = true
	if ação == false:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Atacar",null,true)
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Especial",null,true)
	if ação == true:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Atacar",null,false)
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Especial",null,false)
	if movimento == false:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Mover",null,true)
	if movimento == true:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Mover",null,false)
	if movimento == false or ação == false:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Item",null,true)
	else:
		$"../../Canvaslayer/Menu/VBoxContainer".add_item("Item",null,false)

func _on_v_box_container_item_clicked(index, at_position, mouse_button_index):
	if Menu == "Início":
		if Input.is_action_just_pressed("M1"):
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Atacar":
				$"../.."._alcance(Coord,self,0)
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Especial":
				$"../../Canvaslayer/Menu/VBoxContainer".clear()
				$"../../Canvaslayer/Menu".visible = true
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Correr",null,true)
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Magia",null,true)
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Cura",null,true)
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Saltar",null,true)
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Voltar",null,true)
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Mover":
				print("Item ",index,": ",$"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index))
				_andar()
				$"../../Canvaslayer/Menu".visible = false
				Global.estado = "Seleção"
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Item":
				$"../../Canvaslayer/Menu/VBoxContainer".clear()
				$"../../Canvaslayer/Menu".visible = true
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Vazio",null,true)
				$"../../Canvaslayer/Menu/VBoxContainer".add_item("Voltar",null,true)
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Correr":
				ação = true
				movr += mov
				$"../../Canvaslayer/Menu".visible = false
				_andar()
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Magia":
				pass
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Cura":
				pass
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Saltar":
				pass
			if $"../../Canvaslayer/Menu/VBoxContainer".get_item_text(index)=="Voltar":
				_menu()
		if Input.is_action_just_pressed("M2"):
			_menu()
