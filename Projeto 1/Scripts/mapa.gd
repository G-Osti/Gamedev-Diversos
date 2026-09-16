extends Node2D

var Mouse:bool = true
var ProxCoord:Vector2i = Vector2i(0,0)
var Base: PackedVector2Array = []
var Camadas = []
var SelCoord: Vector2i
var SelH:int = 0
var Movimentos: PackedVector2Array = []
var Previa: PackedVector2Array = []
var alvos: PackedVector2Array = []
var cena_objeto: PackedScene = preload("res://Cenas/Modelos/Objeto.tscn")
var cena_turno: PackedScene = preload("res://Cenas/Modelos/Turno.tscn")
var objeto = []
var turno = []
var i = 0
var Tempo:String = "rodando"
var astar_grid = AStarGrid2D.new()
var trodada = 100
#@onready var tween = create_tween()

func _ready():
	_atualizarMapa()
	#objeto.clear()
	#turno.clear()
#
func _process(_delta):
	if Input.is_action_just_pressed("M1"):
		Mouse = true
		print("SelCoord: (",SelCoord.x,",",SelCoord.y,",",SelH,")")
		_foco(SelCoord,SelH)
	if Input.is_action_just_pressed("INT1"):
		_invocar(SelCoord,1,load("res://Sprites/Cubinho Azul Borda.png"),false)
	if Input.is_action_just_pressed("INT2"):
		_invocar(SelCoord,1,load("res://Sprites/Cubinho Azul Borda.png"),true)
	if Input.is_action_just_pressed("INT3"):
		_invocar(SelCoord,11,load("res://Sprites/Cubinho Vermelho Borda.png"),true)
	if not Tempo == "parado":
		_turnos()
	#if Input.is_action_pressed("BAX") or Input.is_action_just_pressed("CIM") or Input.is_action_just_pressed("ESQ") or Input.is_action_just_pressed("DIR"):
		#Mouse = false
		#_seletor_teclado()
		#print("Mouse == false")
		
	if Input.is_action_just_pressed("ESC"):
		get_tree().quit()

func _foco(XY,altura):
	if SelH != -1:
		$Camera2D.position = Global.XY_ISO((XY)*Global.dist)+Vector2(0,-8)*altura
	else:
		$Camera2D.position = Global.XY_ISO((Vector2i(0,0))*Global.dist)+Vector2(0,-8)*0

func _unhandled_input(event):
	if Mouse == true and (event is InputEventMouseMotion or event is InputEventMouseButton):
		_seletor_mouse()

#func _seletor_teclado():
	#if Vector2(SelCoord) in Base:
		#ProxCoord = SelCoord
	#else:
		#ProxCoord = Vector2i(0,0)
	#if SelAltura != -1:
		#Camadas[SelAltura].set_cell(2,SelCoord,2,Vector2i(-1,-1),0)
	#var dir = Input.get_vector("ESQ","DIR","CIM","BAX")
	#if sqrt((dir.x*dir.x)+(dir.y*dir.y))>0.1:
		#if dir.y>0.5:
			#ProxCoord += Vector2i(0,1)
		#if dir.y<-0.5:
			#ProxCoord += Vector2i(0,-1)
		#if dir.x>0.5:
			#ProxCoord += Vector2i(1,0)
		#if dir.x<-0.5:
			#ProxCoord += Vector2i(-1,0)
	#var k = 0
	#while k != Camadas.size():
		#ProxCoord = floor(Global.ISO_XY(get_global_mouse_position()+Vector2(0,16+16*k))/(2*Global.dist))
		#k+=1
		#if Camadas[k].get_cell_atlas_coords(0,floor(Global.ISO_XY(get_global_mouse_position()+Vector2(0,16+16*k))/(2*Global.dist)))==Vector2i(-1,-1):
			#if Camadas[k].get_cell_atlas_coords(0,ProxCoord)==Vector2i(-1,-1):
				#if Camadas[k-1].get_cell_atlas_coords(0,ProxCoord)==Vector2i(-1,-1):
					#SelAltura = -1
				#else:
					#SelAltura = k-1
			#else:
				#ProxCoord = Vector2i(999,999)
				#SelAltura = -1
			#k=Camadas.size()
	#if SelAltura != -1 and Vector2(ProxCoord) in Base:
		#SelCoord = ProxCoord
		#Camadas[SelAltura].set_cell(2,SelCoord,0,Vector2i(7,0))
		#_descricao()
	#else:
		#_limpar_descricao()

func _seletor_mouse():
	if SelH != -1:
		Camadas[SelH].set_cell(2,SelCoord,2,Vector2i(-1,-1),0)
	
	var k = Camadas.size()-2
	while k>=0:
		ProxCoord = floor(Global.ISO_XY(get_global_mouse_position()+Vector2(0,8+8*k))/(2*Global.dist))
		if Camadas[k].get_cell_atlas_coords(0,ProxCoord)!=Vector2i(-1,-1):
			SelH=k
			k=-1
		else:
			k-=1
	#while Camadas[SelH+1].get_cell_atlas_coords(0,ProxCoord)!=Vector2i(-1,-1):
	#	SelH+=1
	
	if SelH != -1 and Vector2(ProxCoord) in Base:
		SelCoord = ProxCoord
		Camadas[SelH].set_cell(2,SelCoord,0,Vector2i(7,0))
		_descricao()
	else:
		_limpar_descricao()

func _invocar(coord,grupo,imagem,IA:bool):
	var livre = true
	for item in objeto:
		if SelCoord == item.Coord:
			livre = false
	if livre == true and SelH != -1:
		objeto.append(cena_objeto.instantiate()) #as CharacterBody2D
		objeto[i].position = Global.XY_ISO((coord+Vector2i(1,0))*Global.dist)+Vector2(0,-8)*SelH
		Camadas[0].add_child(objeto[i])
		objeto[i].y_sort_enabled = true
		objeto[i].z_index = SelH+1
		objeto[i].name = "Objeto"+str(i)
		objeto[i].Coord = SelCoord
		objeto[i].altura = SelH
		objeto[i].Grupo = grupo
		objeto[i].turno = i
		objeto[i].IA = IA
		objeto[i].get_child(1).set_texture(imagem)
		turno.append(cena_turno.instantiate())
		$CanvasLayer/Control/VBoxContainer.add_child(turno[i])
		turno[i].get_child(1).get_child(1).text = "Objeto"+str(i)
		turno[i].get_child(1).get_child(0).set_texture(imagem)
		turno[i].get_child(1).get_child(2).text = str(objeto[i].turno)
		print(objeto[i].name,objeto[i].Coord)
		i+=1
	else:
		print("Ocupado")

func _limpar(h:int=1):
	var variavel = Movimentos
	if h == 3:
		variavel = Previa
	for camada in Camadas:
		camada.clear_layer(h)
	variavel.clear()
	if h==1:
		for item in Base:
			astar_grid.set_point_weight_scale(Vector2i(item),1)
			alvos.clear()

func _alcance(XY:Vector2,personagem:Object,limite:int,h:int=1):
	var variavel = Movimentos
	var Celulas = [0,1,2]
	if h == 3:
		variavel = Previa
		Celulas = [4,6,5]
	for item in Camadas[0].get_surrounding_cells(XY):
		var k = -1
		for camada in Camadas:
			if camada.get_cell_atlas_coords(0,item)!=Vector2i(-1,-1):
				k += 1
		if Vector2(item) in Base and not Vector2(item) in variavel and astar_grid.get_point_path(Vector2i(personagem.Coord),Vector2i(item)).size()<=limite+1:
			var ocupado = "nenhum"
			for entidade in objeto:
				if item == entidade.Coord and not entidade.estado == "Morto":
					if entidade.Grupo != personagem.Grupo and entidade.estado != "Fora":
						ocupado = "inimigo"
					if entidade.Grupo != personagem.Grupo and entidade.estado == "Fora":
						ocupado = "inimigo fora"
					if entidade.Grupo == personagem.Grupo and entidade != personagem:
						ocupado = "aliado"
			print(item,": ",ocupado,", ",personagem.Grupo)
			if ocupado == "nenhum":
				variavel.append(item)
				Camadas[k].set_cell(h,item,0,Vector2i(Celulas[0],0),0)
				_alcance(item,personagem,limite,h)
			if ocupado == "inimigo":
				Camadas[k].set_cell(h,item,0,Vector2i(Celulas[1],0),0)
				if h==1:
					astar_grid.set_point_weight_scale(Vector2i(item),999)
					alvos.append(item)
			if ocupado == "inimigo fora":
				variavel.append(item)
				Camadas[k].set_cell(h,item,0,Vector2i(Celulas[1],0),0)
				if h==1:
					astar_grid.set_point_weight_scale(Vector2i(item),1)
					alvos.append(item)
			if ocupado == "aliado":
				variavel.append(item)
				Camadas[k].set_cell(h,item,0,Vector2i(Celulas[2],0),0)
				if h==1:
					astar_grid.set_point_weight_scale(Vector2i(item),3)
					alvos.append(item)
				_alcance(item,personagem,limite,h,)
		elif Vector2(item) in Base and not Vector2(item) in variavel:
			for entidade in objeto:
				if item == entidade.Coord and entidade.estado != "Morto":
					if entidade.Grupo != personagem.Grupo:
						Camadas[k].set_cell(h,item,0,Vector2i(Celulas[1],0),0)
						if h == 1:
							alvos.append(item)
					if entidade.Grupo == personagem.Grupo and entidade != personagem:
						Camadas[k].set_cell(h,item,0,Vector2i(Celulas[2],0),0)
						if h == 1:
							alvos.append(item)

func _exibir_rota(rota:PackedVector2Array):
	for camada in Camadas:
		camada.clear_layer(2)
	if not rota.is_empty():
		for item in rota:
			var k = 0
			for camada in Camadas:
				if item in Base and camada.get_cell_atlas_coords(0,item)!=Vector2i(-1,-1):
					k += 1
			Camadas[k-1].set_cell(2,item,0,Vector2i(3,0),0)

func _turnos():
	if objeto.size()>0:
		if Tempo == "rodando":
			for item in objeto:
				$CanvasLayer/Control/VBoxContainer.get_child(objeto.find(item)).get_child(0).visible=false
				if not item.estado == "Morto":
					item.turno += item.velocidade+randi_range(-1,+1)
					if item.turno >= trodada:
						Tempo = "turno"
					if item.estado == "Fora": #jogar pro objeto
						$CanvasLayer/Control/VBoxContainer.get_child(objeto.find(item)).get_child(1).get_child(0).modulate = Color(0.5,0.5,0.5)
				else:
					$CanvasLayer/Control/VBoxContainer.get_child(objeto.find(item)).get_child(2).visible = true
				$CanvasLayer/Control/VBoxContainer.get_child(objeto.find(item)).get_child(1).get_child(2).text = str(item.turno)
		if Tempo == "turno":
			var turnos: Array = []
			for item in objeto:
				turnos.append(item.turno)
			if turnos.max() >= trodada:
				print("Vez de: ",objeto[turnos.find(turnos.max())].name)
				objeto[turnos.find(turnos.max())]._turno()
				$CanvasLayer/Control/VBoxContainer.get_child(turnos.find(turnos.max())).get_child(0).visible=true
				$CanvasLayer/Control/VBoxContainer.get_child(turnos.find(turnos.max())).get_child(1).get_child(2).text = str(objeto[turnos.find(turnos.max())].turno)
				$CanvasLayer/Control/VBoxContainer.get_child(turnos.find(turnos.max())).get_child(1)
			else:
				Tempo = "rodando"

func _atualizarMapa():
	astar_grid.region = $Camada.get_used_rect()
	astar_grid.update()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.fill_solid_region(astar_grid.region,true)
	for camada in get_children():
		if camada is TileMap:
			Camadas.append(camada)
			for XY in camada.get_used_cells(0):
				if not Vector2(XY) in Base:
					Base.append(Vector2(XY.x,XY.y))
					astar_grid.set_point_solid(Vector2(XY.x,XY.y),false)

func _descricao():
	_limpar_descricao()
	$CanvasLayer/Bloco.visible = true
	$CanvasLayer/Bloco/HBoxContainer/TextureRect/Camada.set_cell(0,Vector2i(0,0),1,get_child(SelH).get_cell_atlas_coords(0,SelCoord))
	var Data = get_child(SelH).get_cell_tile_data(0,SelCoord)
	$CanvasLayer/Bloco/HBoxContainer/Label.text = Data.get_custom_data("Nome")
	$CanvasLayer/Bloco/HBoxContainer/Label2.text = str("(",SelCoord.x,",",SelCoord.y,",",SelH,")")
	var mostrar_entidade = false
	for entidade in objeto:
		if entidade.Coord == SelCoord:
			$CanvasLayer/Entidade.visible = true
			$CanvasLayer/Entidade/HBoxContainer2/TextureRect.texture = entidade.get_child(1).texture
			$CanvasLayer/Entidade/HBoxContainer2/ProgressBar.max_value = entidade.vida_max
			$CanvasLayer/Entidade/HBoxContainer2/ProgressBar.value = entidade.vida
			$CanvasLayer/Entidade/HBoxContainer2/Label.text = str(entidade.vida)+"/"+str(entidade.vida_max)
			mostrar_entidade = true
			if Input.is_action_pressed("M2"):
				_alcance(SelCoord,entidade,entidade.movr,3)
			else:
				_limpar(3)
	if mostrar_entidade == false:
		$CanvasLayer/Entidade.visible = false

func _limpar_descricao():
	$CanvasLayer/Bloco.visible = false
	$CanvasLayer/Entidade.visible = false
