extends Area2D
# =====================================================================
#  BASE DE LOS ENEMIGOS. Bug, guana, dron, nube y cable heredan de aquí:
#    extends "res://enemigos/enemigo.gd"
#  Ya resuelve: hitbox, daño al tocar, pisotón, congelarse con la luz,
#  animación de muerte y el arte reemplazable (res://arte/<nombre_arte>.png).
#  Cada enemigo solo cambia mover(), _dibujar() y sus ajustes.
# =====================================================================

const ARTE := preload("res://objetos/arte.gd")
const PROYECTIL := preload("res://enemigos/proyectil.gd")

var tamano: Vector2 = Vector2(16, 12)   # hitbox
var centrado: bool = false              # false: el origen está en las patas; true: en el centro
var pisable: bool = true                # se puede derrotar cayéndole encima
var dano: int = 1
var fuerza_rebote: float = -240.0
var nombre_arte: String = ""
var estirar_al_alto: bool = false     # true: la imagen se estira al alto de la hitbox (cable)
var muere_con_trampas: bool = true    # si cae en pinchos o en el vacío, se destruye
var ext: bool = false                 # true en el modo Extraordinario (más ataques)

var direccion: float = 1.0
var tiempo: float = 0.0
var muerto: bool = false
var muerte_timer: float = 0.0
var congelado: bool = false
var arte: Node2D = null
var hitbox: CollisionShape2D

func _ready() -> void:
	ext = Juego.extraordinario()
	add_to_group("enemigo")
	preparar()
	hitbox = CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamano
	hitbox.shape = forma
	hitbox.position = Vector2.ZERO if centrado else Vector2(0, -tamano.y / 2.0)
	add_child(hitbox)
	if nombre_arte != "":
		arte = ARTE.poner(self, nombre_arte, not centrado)
		if estirar_al_alto:
			ARTE.ajustar(arte, tamano, true)

# Cada enemigo pone aquí sus ajustes (tamano, pisable, nombre_arte...)
func preparar() -> void:
	pass

# Cada enemigo se mueve aquí
func mover(_delta: float) -> void:
	pass

func activo() -> bool:
	return true   # el cable lo usa para apagarse

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	if muerto:
		muerte_timer -= delta
		modulate.a = clampf(muerte_timer / 0.3, 0.0, 1.0)
		scale.y = clampf(muerte_timer / 0.3, 0.2, 1.0)
		if muerte_timer <= 0.0:
			queue_free()
		return
	congelado = en_luz()
	if not congelado:
		mover(delta)
	if arte:
		ARTE.voltear(arte, direccion < 0.0)
		arte.modulate = Color(0.75, 0.75, 1.0) if congelado else Color.WHITE
	if not activo():
		return
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_tocar_jugador(cuerpo)
			return

func _tocar_jugador(j) -> void:
	var arriba_de_mi: float = global_position.y - (0.0 if centrado else tamano.y * 0.5)
	# Dónde estaban los pies de Kin un par de cuadros antes (así un pisotón
	# rápido no se cuenta como golpe de lado)
	var pies_antes: float = j.global_position.y - j.velocity.y * get_physics_process_delta_time() * 2.0
	if pisable and j.velocity.y > 0.0 and pies_antes <= arriba_de_mi + 2.0:
		j.call("rebotar", fuerza_rebote)
		al_ser_pisado()
	else:
		j.call("danar", dano, global_position)

func al_ser_pisado() -> void:
	morir()

func morir() -> void:
	if muerto:
		return
	muerto = true
	muerte_timer = 0.3
	set_deferred("monitoring", false)
	Sonido.sfx("pisar")

# ---------- Ayudas para los enemigos ----------
func jugador() -> Node2D:
	return get_tree().get_first_node_in_group("jugador") as Node2D

# Lanza un rayo invisible y dice qué bloque toca (para detectar paredes y orillas)
func rayo(desde: Vector2, hasta: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(desde, hasta)
	q.collide_with_areas = false
	var j := jugador()
	if j is CollisionObject2D:
		q.exclude = [(j as CollisionObject2D).get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(q)

# Dispara un proyectil de ruido desde "desde" hacia "hacia"
func disparar(desde: Vector2, hacia: Vector2, rapidez: float = 120.0) -> void:
	var p = PROYECTIL.new()
	p.velocidad = (hacia - desde).normalized() * rapidez
	p.position = desde
	get_parent().add_child(p)
	Sonido.sfx("glitch")

# ¿Está dentro de una zona de luz? (farolas encendidas y rayos de sol)
func en_luz() -> bool:
	var p: Vector2 = global_position + (Vector2.ZERO if centrado else Vector2(0, -tamano.y / 2.0))
	for z in get_tree().get_nodes_in_group("luz"):
		if z.call("contiene", p):
			return true
	return false

func _draw() -> void:
	if arte:
		return
	_dibujar()

func _dibujar() -> void:
	pass

# Rectángulo que se voltea según hacia dónde mira
func rect_v(x: float, y: float, w: float, h: float, c: Color) -> void:
	var izq: float = x if direccion > 0.0 else -(x + w)
	draw_rect(Rect2(izq, y, w, h), c.lerp(Color(0.6, 0.7, 1.0), 0.45) if congelado else c)
