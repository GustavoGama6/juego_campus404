extends Area2D
# =====================================================================
#  ERROR 404 (jefe final). Criatura de ruido que nació del fallo del Núcleo.
#  Tiene 3 de vida: se le quita 1 activando la terminal (E) mientras está
#  ATURDIDO. Cada golpe lo hace entrar a una fase más agresiva.
#
#  Ciclo de ataques:
#    1. LLUVIA:   bloques "404" caen del techo (la sombra avisa dónde).
#    2. INVOCAR:  invoca 2 bugs (en Extraordinario, desde la fase 2 también un dron).
#    3. RAYOS:    rayos verticales que siguen a Kin (la línea delgada avisa).
#                 Extraordinario fase 2+: rayo horizontal a ras de piso (¡salta!).
#    4. CAÍDA:    (solo Extraordinario) se eleva, cae sobre Kin y suelta
#                 dos ondas por el piso (sáltalas). 1, 2 o 3 caídas según la fase.
#    5. BARRIDO:  ola de ruido a ras de piso (sáltala). En la última fase son
#                 dos olas desde los dos lados.
#    6. ATURDIDO: queda aturdido junto a una terminal: acércate y presiona E.
#  Extraordinario: todo más rápido, más bloques y menos tiempo aturdido.
#  Después de cada golpe suelta un café (en Extraordinario).
#  Arte: res://arte/error404.png (o error404.tres con "flotar", "aturdido", "caida")
# =====================================================================

signal vida_cambio(vida: int, maxima: int)
signal derrotado

const ARTE := preload("res://objetos/arte.gd")
const BLOQUE := preload("res://enemigos/bloque_404.gd")
const BARRIDO := preload("res://enemigos/barrido.gd")
const RAYO := preload("res://enemigos/rayo_404.gd")

var arena_izq: float = 0.0
var arena_der: float = 640.0
var piso_y: float = 320.0
var techo_y: float = 0.0
var altura_vuelo: float = 110.0
var terminales: Array = []
var tiempo_aturdido: float = 3.5
var vida_maxima: int = 3
var vida: int = 3
var ext: bool = false

enum { ESPERA, ENTRADA, LLUVIA, INVOCAR, RAYOS, CAIDA, BARRIDO_ESTADO, ATURDIDO, REGRESO, DERROTADO }
var estado: int = ESPERA
var timer: float = 0.0
var tiempo: float = 0.0
var bloques_restantes: int = 0
var rayos_restantes: int = 0
var caidas_restantes: int = 0
var paso_caida: int = 0            # 0 sube, 1 apunta, 2 cae, 3 en el piso
var lado_barrido: float = 1.0
var barridos_vivos: int = 0
var barrido_lanzado: bool = false
var terminal_actual: Node2D = null
var objetivo: Vector2 = Vector2.ZERO
var destello: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	ext = Juego.extraordinario()
	if ext:
		tiempo_aturdido = 2.6
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(56, 44)
	c.shape = f
	add_child(c)
	arte = ARTE.poner(self, "error404", false)
	vida = vida_maxima
	position = Vector2((arena_izq + arena_der) / 2.0, techo_y - 60.0)

func empezar() -> void:
	if estado != ESPERA:
		return
	estado = ENTRADA
	objetivo = Vector2((arena_izq + arena_der) / 2.0, piso_y - altura_vuelo)
	vida_cambio.emit(vida, vida_maxima)

func esta_activo() -> bool:
	return estado != ESPERA and estado != DERROTADO

# 1 al empezar, 2 después del primer golpe, 3 después del segundo
func fase() -> int:
	return vida_maxima - vida + 1

func _kin() -> Node2D:
	return get_tree().get_first_node_in_group("jugador") as Node2D

func _physics_process(delta: float) -> void:
	tiempo += delta
	destello -= delta
	queue_redraw()
	match estado:
		ESPERA:
			return
		ENTRADA:
			position = position.move_toward(objetivo, 90.0 * delta)
			if position.distance_to(objetivo) < 1.0:
				_iniciar_lluvia()
		LLUVIA:
			_flotar(delta)
			timer -= delta
			if timer <= 0.0:
				if bloques_restantes > 0:
					_soltar_bloque()
					bloques_restantes -= 1
					timer = 0.25 if ext else 0.35
				else:
					if ext:
						_iniciar_rayos()
					else:
						estado = INVOCAR
						timer = 1.0
		INVOCAR:
			_flotar(delta)
			timer -= delta
			if timer <= 0.0:
				_invocar()
				if ext:
					_iniciar_caida()
				else:
					_iniciar_rayos()
		RAYOS:
			_flotar(delta)
			timer -= delta
			if timer <= 0.0:
				if rayos_restantes > 0:
					_lanzar_rayo()
					rayos_restantes -= 1
					timer = 0.35 if ext else 0.55
				elif ext and fase() >= 2 and rayos_restantes == 0:
					# Rayo horizontal a ras de piso: hay que saltarlo
					_lanzar_rayo_horizontal()
					rayos_restantes = -1
					timer = 1.4
				else:
					if ext:
						estado = INVOCAR
						timer = 0.6
					else:
						_iniciar_barrido()
		CAIDA:
			_actualizar_caida(delta)
		BARRIDO_ESTADO:
			# Se va a una orilla y lanza el barrido hacia la otra
			var orilla: float = arena_izq + 50.0 if lado_barrido < 0.0 else arena_der - 50.0
			position = position.move_toward(Vector2(orilla, piso_y - altura_vuelo), 160.0 * delta)
			timer -= delta
			if timer <= 0.0 and not barrido_lanzado:
				barrido_lanzado = true
				_lanzar_barridos(orilla)
		ATURDIDO:
			position = position.move_toward(objetivo, 160.0 * delta)
			if position.distance_to(objetivo) < 2.0:
				timer -= delta
				if timer <= 0.0:
					# Se acabó el tiempo: se recupera
					if is_instance_valid(terminal_actual):
						terminal_actual.call("activar", false)
					_regresar()
		REGRESO:
			position = position.move_toward(objetivo, 140.0 * delta)
			if position.distance_to(objetivo) < 2.0:
				_iniciar_lluvia()
		DERROTADO:
			timer -= delta
			position += Vector2(randf_range(-2, 2), randf_range(-2, 2))
			modulate.a = clampf(timer / 2.0, 0.0, 1.0)
			if timer <= 0.0:
				queue_free()
			return
	if arte:
		ARTE.animar(arte, "aturdido" if estado == ATURDIDO else ("caida" if estado == CAIDA else "flotar"))
	if estado == ATURDIDO or estado == ENTRADA or estado == REGRESO:
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("danar", 1, global_position)

func _flotar(delta: float) -> void:
	# Sigue un poco al jugador por arriba
	var j := _kin()
	var meta_x: float = position.x
	if j:
		meta_x = clampf(j.global_position.x, arena_izq + 60.0, arena_der - 60.0)
	position.x = move_toward(position.x, meta_x, (75.0 if ext else 55.0) * delta)
	position.y = move_toward(position.y, piso_y - altura_vuelo + sin(tiempo * 2.0) * 8.0, 120.0 * delta)

# ---------------- 1. LLUVIA ----------------
func _iniciar_lluvia() -> void:
	estado = LLUVIA
	if ext:
		bloques_restantes = 9 + (fase() - 1) * 3
	else:
		bloques_restantes = 6 + (fase() - 1) * 2
	timer = 0.6

func _soltar_bloque() -> void:
	var j := _kin()
	var x: float = randf_range(arena_izq + 30.0, arena_der - 30.0)
	if j and bloques_restantes % 2 == 0:
		x = clampf(j.global_position.x, arena_izq + 30.0, arena_der - 30.0)
	var b = BLOQUE.new()
	b.piso_y = piso_y
	b.techo_y = techo_y
	b.aviso = 0.55 if ext else 0.7
	b.position = Vector2(x, techo_y)
	get_parent().add_child(b)

# ---------------- 2. INVOCAR ----------------
func _invocar() -> void:
	var nivel := get_tree().get_first_node_in_group("nivel")
	if nivel and nivel.has_method("crear_bug_temporal"):
		var vivos: int = 0
		for e in get_tree().get_nodes_in_group("enemigo"):
			if not e.get("muerto"):
				vivos += 1
		if vivos < 4:
			nivel.call("crear_bug_temporal", arena_izq + 70.0, piso_y, 50.0)
			nivel.call("crear_bug_temporal", arena_der - 70.0, piso_y, 50.0)
			if ext and fase() >= 2 and nivel.has_method("crear_dron_temporal"):
				nivel.call("crear_dron_temporal", (arena_izq + arena_der) / 2.0, piso_y - 150.0, 160.0)
	Sonido.sfx("glitch")

# ---------------- 3. RAYOS ----------------
func _iniciar_rayos() -> void:
	estado = RAYOS
	if ext:
		rayos_restantes = 4 + (fase() - 1)
	else:
		rayos_restantes = 2 + (1 if fase() >= 3 else 0)
	timer = 0.5

func _lanzar_rayo() -> void:
	var j := _kin()
	var x: float = clampf(j.global_position.x if j else position.x, arena_izq + 12.0, arena_der - 12.0)
	var r = RAYO.new()
	r.vertical = true
	r.position = Vector2(x, piso_y)
	r.desde = techo_y
	r.hasta = piso_y
	r.aviso = 0.6 if ext else 0.8
	get_parent().add_child(r)

func _lanzar_rayo_horizontal() -> void:
	var r = RAYO.new()
	r.vertical = false
	r.grosor = 12.0
	r.position = Vector2((arena_izq + arena_der) / 2.0, piso_y - 7.0)
	r.desde = arena_izq
	r.hasta = arena_der
	r.aviso = 0.9
	r.duracion = 0.3
	get_parent().add_child(r)

# ---------------- 4. CAÍDA (Extraordinario) ----------------
func _iniciar_caida() -> void:
	estado = CAIDA
	caidas_restantes = fase()
	paso_caida = 0
	objetivo = Vector2(position.x, techo_y + 40.0)

func _actualizar_caida(delta: float) -> void:
	match paso_caida:
		0:   # sube al techo
			position = position.move_toward(objetivo, 260.0 * delta)
			if position.distance_to(objetivo) < 2.0:
				paso_caida = 1
				timer = 0.65
		1:   # se acomoda arriba de Kin (la sombra avisa) y se queda quieto un momento
			var j := _kin()
			if j and timer > 0.2:
				position.x = move_toward(position.x, clampf(j.global_position.x, arena_izq + 30.0, arena_der - 30.0), 220.0 * delta)
			timer -= delta
			if timer <= 0.0:
				paso_caida = 2
		2:   # cae
			position.y += 520.0 * delta
			if position.y >= piso_y - 22.0:
				position.y = piso_y - 22.0
				paso_caida = 3
				timer = 0.5
				var j2 := _kin()
				if j2:
					j2.set("temblor", 0.3)
				Sonido.sfx("golpe_jefe")
		3:   # en el piso: un instante después suelta las ondas y se vuelve a elevar
			var antes: float = timer
			timer -= delta
			if antes > 0.35 and timer <= 0.35:
				_ondas()
			if timer <= 0.0:
				caidas_restantes -= 1
				if caidas_restantes > 0:
					paso_caida = 0
					objetivo = Vector2(position.x, techo_y + 40.0)
				else:
					_iniciar_barrido()

func _ondas() -> void:
	Sonido.sfx("glitch")
	for lado in [-1.0, 1.0]:
		var o = BARRIDO.new()
		o.alto = 10.0
		o.velocidad = 140.0
		o.position = Vector2(position.x + lado * 28.0, piso_y)
		o.x_final = arena_izq + 6.0 if lado < 0.0 else arena_der - 6.0
		get_parent().add_child(o)

# ---------------- 5. BARRIDO ----------------
func _iniciar_barrido() -> void:
	estado = BARRIDO_ESTADO
	timer = 0.9
	lado_barrido = -lado_barrido
	barrido_lanzado = false

func _lanzar_barridos(_orilla: float) -> void:
	# Las olas recorren la arena de pared a pared (no hay dónde esconderse: hay que saltar)
	var dobles: bool = (ext and fase() >= 2) or (not ext and fase() >= 3)
	var borde_a: float = arena_izq + 10.0 if lado_barrido < 0.0 else arena_der - 10.0
	var borde_b: float = arena_der - 10.0 if lado_barrido < 0.0 else arena_izq + 10.0
	barridos_vivos = 0
	_un_barrido(borde_a, borde_b, 0.0)
	if dobles:
		_un_barrido(borde_b, borde_a, 0.0)
	if ext and fase() >= 3:
		_un_barrido(borde_a, borde_b, 0.7)
	Sonido.sfx("glitch")

func _un_barrido(desde: float, hacia: float, retraso: float) -> void:
	barridos_vivos += 1
	if retraso > 0.0:
		await get_tree().create_timer(retraso, false).timeout
		if not is_instance_valid(self) or estado != BARRIDO_ESTADO:
			barridos_vivos -= 1
			return
	var b = BARRIDO.new()
	b.position = Vector2(desde, piso_y)
	b.x_final = hacia
	b.velocidad = 230.0 if ext else 190.0
	b.alto = 22.0 if ext else 18.0
	b.terminado.connect(_on_barrido_terminado)
	get_parent().add_child(b)

func _on_barrido_terminado() -> void:
	barridos_vivos -= 1
	if estado != BARRIDO_ESTADO or barridos_vivos > 0:
		return
	# Queda aturdido frente a la terminal libre más cercana al jugador
	var j := _kin()
	terminal_actual = null
	var mejor: float = 1e9
	for t in terminales:
		if not is_instance_valid(t) or t.get("usada"):
			continue
		var d: float = absf(t.global_position.x - (j.global_position.x if j else position.x))
		if d < mejor:
			mejor = d
			terminal_actual = t
	if terminal_actual == null:
		_regresar()
		return
	estado = ATURDIDO
	timer = tiempo_aturdido
	objetivo = Vector2(terminal_actual.global_position.x, piso_y - 64.0)
	terminal_actual.call("activar", true)

# ---------------- 6. GOLPE ----------------
# La terminal llama esto cuando Kin la activa
func recibir_golpe() -> void:
	if estado != ATURDIDO:
		return
	vida -= 1
	destello = 0.5
	vida_cambio.emit(vida, vida_maxima)
	Sonido.sfx("golpe_jefe")
	if vida <= 0:
		estado = DERROTADO
		timer = 2.0
		set_deferred("monitoring", false)
		derrotado.emit()
		return
	# Extraordinario: suelta un café para recuperar 1 vaso
	if ext:
		var nivel := get_tree().get_first_node_in_group("nivel")
		if nivel and nivel.has_method("cafe"):
			nivel.call_deferred("cafe", clampf(position.x + 60.0, arena_izq + 30.0, arena_der - 30.0), piso_y - 14.0, true)
	_regresar()

func _regresar() -> void:
	estado = REGRESO
	objetivo = Vector2((arena_izq + arena_der) / 2.0, piso_y - altura_vuelo)

func _draw() -> void:
	# Sombra de aviso de la caída
	if estado == CAIDA and paso_caida <= 1:
		var sombra_y: float = piso_y - position.y
		var a: float = 0.3 + 0.3 * sin(tiempo * 25.0)
		draw_rect(Rect2(-28, sombra_y - 4, 56, 4), Color(0.85, 0.1, 0.55, a))
	if arte:
		if estado == ATURDIDO:
			draw_string(ThemeDB.fallback_font, Vector2(-70, -30), "¡ACTIVA LA TERMINAL!", HORIZONTAL_ALIGNMENT_CENTER, 140, 8, Color("#F5C242"))
		return
	var aturdido: bool = estado == ATURDIDO or estado == DERROTADO
	var cuerpo: Color = Color("#0B0B14") if destello <= 0.0 else Color("#F4F1EA")
	if fase() >= 3 and not aturdido and int(tiempo * 8.0) % 2 == 0:
		cuerpo = Color("#2A0B1E")   # última fase: parpadea en rojo oscuro
	# Cuerpo de ruido
	draw_rect(Rect2(-28, -22, 56, 44), cuerpo)
	var semilla: int = int(tiempo * (4.0 if aturdido else 14.0 + fase() * 4.0))
	for k in range(40):
		var h: int = (k * 53 + semilla * 29) % 1009
		var x: float = float(h % 56) - 28.0
		var y: float = float((h * 3) % 44) - 22.0
		draw_rect(Rect2(x, y, 3, 3), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
	# Bordes rotos
	for k in range(6):
		var lado: float = -32.0 if k % 2 == 0 else 28.0
		draw_rect(Rect2(lado, -18.0 + k * 7.0, 4, 3), Color("#29E7FF"))
	# Ojos
	if aturdido:
		draw_line(Vector2(-14, -8), Vector2(-6, 0), Color("#F5C242"), 2.0)
		draw_line(Vector2(-14, 0), Vector2(-6, -8), Color("#F5C242"), 2.0)
		draw_line(Vector2(6, -8), Vector2(14, 0), Color("#F5C242"), 2.0)
		draw_line(Vector2(6, 0), Vector2(14, -8), Color("#F5C242"), 2.0)
	else:
		draw_rect(Rect2(-14, -8, 8, 8), Color("#F4F1EA"))
		draw_rect(Rect2(6, -8, 8, 8), Color("#F4F1EA"))
		var ojo: Color = Color("#D81B8C") if fase() < 3 else Color("#FF4D4D")
		draw_rect(Rect2(-11, -5, 3, 3), ojo)
		draw_rect(Rect2(9, -5, 3, 3), ojo)
	draw_string(ThemeDB.fallback_font, Vector2(-14, 16), "404", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#29E7FF"))
	if estado == ATURDIDO:
		draw_string(ThemeDB.fallback_font, Vector2(-70, -30), "¡ACTIVA LA TERMINAL!", HORIZONTAL_ALIGNMENT_CENTER, 140, 8, Color("#F5C242"))
