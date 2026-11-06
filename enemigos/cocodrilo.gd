extends Area2D
# Cocodrilo de la orilla. Patrulla de un lado a otro y, si te ve enfrente,
# acelera con la boca abierta.
#   - Si le caes encima: rebotas alto (su lomo es un trampolín) y se aturde un rato.
#   - Si te toca de lado: regresas a la última farola.
#   - Si le lanzas comida (F): se la come y se va.
# El origen (position) está a la altura de sus patas. (Nivel extra: El Lago)

@export var rango: float = 50.0             # cuánto camina hacia cada lado
@export var velocidad: float = 32.0
@export var velocidad_ataque: float = 80.0
@export var distancia_vista: float = 80.0   # a qué distancia te ve
@export var fuerza_rebote: float = -320.0   # qué tan alto rebotas en su lomo
@export var tiempo_aturdido: float = 1.5

var origen_x: float = 0.0
var direccion: float = 1.0
var aturdido: float = 0.0
var atacando: bool = false
var saciado: bool = false
var tiempo: float = 0.0
var arte: Node2D = null   # res://arte/cocodrilo.png o .tres (animaciones: caminar, atacar, aturdido)

const ARTE := preload("res://objetos/arte.gd")

func _ready() -> void:
	origen_x = position.x
	arte = ARTE.poner(self, "cocodrilo")
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(30, 14)
	colision.shape = forma
	colision.position = Vector2(0, -7)
	add_child(colision)

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	if arte:
		ARTE.voltear(arte, direccion < 0.0)
		ARTE.animar(arte, "aturdido" if aturdido > 0.0 else ("atacar" if atacando else "caminar"))

	# Se comió la comida: se aleja flotando y desaparece
	if saciado:
		modulate.a -= delta * 1.5
		position.y -= delta * 10.0
		if modulate.a <= 0.0:
			queue_free()
		return

	if aturdido > 0.0:
		aturdido -= delta
		return

	# ¿Ve al jugador enfrente y a su altura?
	atacando = false
	var jugador := get_tree().get_first_node_in_group("jugador") as Node2D
	if jugador:
		var dx: float = jugador.global_position.x - global_position.x
		var dy: float = absf(jugador.global_position.y - global_position.y)
		if signf(dx) == direccion and absf(dx) < distancia_vista and dy < 24.0:
			atacando = true

	var vel: float = velocidad_ataque if atacando else velocidad
	position.x += direccion * vel * delta
	if position.x > origen_x + rango:
		position.x = origen_x + rango
		if not atacando:
			direccion = -1.0
	elif position.x < origen_x - rango:
		position.x = origen_x - rango
		if not atacando:
			direccion = 1.0

	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_tocar_jugador(cuerpo)
			return

func _tocar_jugador(cuerpo: Node2D) -> void:
	var jugador := cuerpo as CharacterBody2D
	var cae: bool = jugador.velocity.y > 0.0
	var por_encima: bool = jugador.global_position.y < global_position.y - 6.0
	if cae and por_encima:
		jugador.call("rebotar", fuerza_rebote)
		aturdido = tiempo_aturdido
	else:
		jugador.call("danar", 1, global_position)

# La llama la comida lanzada. Devuelve true si se la comió.
func recibir_comida() -> bool:
	if saciado:
		return false
	saciado = true
	set_deferred("monitoring", false)
	return true

# ----------------- Dibujo -----------------
# Rectángulo que se voltea según hacia dónde mira
func _rect(x: float, y: float, w: float, h: float, c: Color) -> void:
	var izq: float = x if direccion > 0.0 else -(x + w)
	draw_rect(Rect2(izq, y, w, h), c)

func _poli(puntos: Array, c: Color) -> void:
	var p := PackedVector2Array()
	for v in puntos:
		p.append(Vector2(v.x * direccion, v.y))
	draw_colored_polygon(p, c)

func _draw() -> void:
	if arte:
		return
	var verde := Color("#2E6B34")
	var oscuro := Color("#1F4D24")
	var panza := Color("#A7C46A")
	var paso: float = 0.0 if aturdido > 0.0 else sin(tiempo * 12.0) * 1.0

	# Cola
	_poli([Vector2(-14, -9), Vector2(-25, -3), Vector2(-14, -3)], verde)
	# Patas
	_rect(-11, -3 + paso, 4, 3, oscuro)
	_rect(-3, -3 - paso, 4, 3, oscuro)
	_rect(4, -3 + paso, 4, 3, oscuro)
	# Cuerpo y panza
	_rect(-14, -11, 22, 8, verde)
	_rect(-14, -5, 22, 2, panza)
	# Picos del lomo
	for k in range(5):
		var bx: float = -13.0 + float(k) * 4.5
		_poli([Vector2(bx, -11), Vector2(bx + 2.0, -14), Vector2(bx + 4.0, -11)], oscuro)

	# Cabeza: hocico de arriba y de abajo
	var boca: float = 0.0
	if atacando:
		boca = 3.0 + absf(sin(tiempo * 14.0)) * 3.0
	_rect(8, -10 - boca, 13, 4, verde)        # mandíbula de arriba
	_rect(8, -5, 13, 3, verde)                # mandíbula de abajo
	if boca > 0.0:
		_rect(8, -6 - boca, 13, boca, Color("#8E2A2A"))
		for k in range(3):
			var tx: float = 10.0 + float(k) * 4.0
			_poli([Vector2(tx, -6 - boca), Vector2(tx + 1.5, -4 - boca), Vector2(tx + 3.0, -6 - boca)], Color("#F4F1EA"))
	# Ojo
	_rect(8, -14 - boca, 4, 4, verde)
	if aturdido > 0.0:
		# Ojos en X cuando está aturdido
		_rect(9, -13 - boca, 2, 2, Color("#0B0B14"))
		draw_circle(Vector2(0, -20), 2.0 + sin(tiempo * 10.0), Color("#F5C242"))
	else:
		_rect(9, -13 - boca, 2, 2, Color("#F5D742"))
		_rect(10, -12 - boca, 1, 1, Color("#0B0B14"))
	if saciado:
		# Corazón pequeño: está feliz
		draw_circle(Vector2(-2, -24), 2.5, Color("#E04B6B"))
		draw_circle(Vector2(2, -24), 2.5, Color("#E04B6B"))
		draw_colored_polygon(PackedVector2Array([Vector2(-4.5, -23), Vector2(4.5, -23), Vector2(0, -18)]), Color("#E04B6B"))
