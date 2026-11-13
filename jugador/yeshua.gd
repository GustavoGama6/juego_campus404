extends CharacterBody2D
# =====================================================================
#  JUGADOR (Yoshua). Movimiento, salto, salto de pared, dash, planeo,
#  interactuar, energía (3 vasos de café) y reaparición en la farola.
#  Las habilidades se prenden con desbloquear("dash") o desbloquear("planeo").
#  Para cambiar el dibujo por tus sprites: res://arte/jugador.tres
#  (SpriteFrames con animaciones: reposo, correr, saltar, caer, pared, planear, dash)
# =====================================================================

signal energia_cambio(actual: int, maxima: int)
signal danado
signal reaparecio
signal habilidad_desbloqueada(nombre: String)

const ARTE := preload("res://objetos/arte.gd")

# ================= AJUSTES (también editables en el Inspector) =================
# --- Movimiento ---
@export var velocidad_carrera: float = 120.0
@export var aceleracion: float = 1200.0
@export var friccion: float = 1400.0
@export var gravedad: float = 900.0

# --- Salto (altura = velocidad² / (2 x gravedad)) ---
@export var velocidad_salto: float = -300.0      # sube unos 50 px
@export var corte_salto_minimo: float = -170.0   # salto corto al soltar antes
@export var saltos_aire_extra: int = 0           # 1 = doble salto en el aire

# --- Pared ---
@export var deslizamiento_pared: float = 50.0
@export var salto_pared_y: float = -280.0        # cada salto de pared sube unos 44 px
@export var saltos_pared_max: int = 2            # máximo hasta tocar el piso

# --- Dash (Shift) ---
@export var velocidad_dash: float = 320.0        # 320 px/s durante 0.2 s = 64 px
@export var duracion_dash: float = 0.2
@export var recarga_dash: float = 0.8 # espera después del dash, además de tocar suelo

# --- Planeo (E en el aire; se queda activo, E otra vez cancela) ---
@export var duracion_planeo: float = 5.0
@export var recarga_planeo: float = 10.0
@export var velocidad_caida_planeo: float = 40.0
@export var velocidad_horizontal_planeo: float = 140.0

# --- Energía ---
@export var energia_maxima: int = 3
@export var tiempo_invulnerable: float = 1.0

# --- Lanzar comida (F, solo nivel extra) ---
@export var velocidad_lanzamiento: Vector2 = Vector2(280, -10)
@export var espera_lanzamiento: float = 0.3

# --- Piso mojado ---
@export var friccion_mojado: float = 140.0
@export var aceleracion_mojado: float = 420.0

# --- Habilidades ---
@export var pared_habilitado: bool = true
@export var dash_habilitado: bool = false
@export var planeo_habilitado: bool = false
@export var lanzar_habilitado: bool = false

@export var limite_caida: float = 420.0          # si baja de aquí, cayó al vacío

# ================= ESTADO =================
var energia: int = 3
var muertes: int = 0
var punto_inicio: Vector2 = Vector2.ZERO
var controles_activos: bool = true
var invulnerable: float = 0.0
var temblor: float = 0.0
var mirando_derecha: bool = true
var anim_tiempo: float = 0.0
var en_piso_antes: bool = true

var timer_coyote: float = 0.0
var timer_buffer: float = 0.0
var timer_pared: float = 0.0
var saltos_pared_usados: int = 0
var saltos_aire_usados: int = 0

var dash_tiempo: float = 0.0
var dash_recarga_restante: float = 0.0
var dash_disponible: bool = true
var dash_direccion: float = 1.0

var planeando: bool = false
var planeo_restante: float = 5.0
var planeo_usado: float = 0.0
var planeo_en_recarga: bool = false
var planeo_recarga_restante: float = 0.0

# Efectos que ponen los objetos del nivel cada frame
var viento: float = 0.0          # ventiladores
var empuje_x: float = 0.0        # paneles solares
var piso_mojado: int = 0         # zonas de piso mojado tocando

var objeto_cercano: Node2D = null
var tiene_credencial: bool = false
var comida: int = 0
var comida_vista: bool = false
var timer_lanzar: float = 0.0

var arte: Node2D = null
var camara: Camera2D = null

# Trampas (pinchos, y vacíos en Extraordinario): regresas al último piso seguro
var punto_seguro: Vector2 = Vector2.ZERO
var timer_seguro: float = 0.0
var espera_trampa: float = 0.0

func _ready() -> void:
	add_to_group("jugador")
	punto_inicio = global_position
	punto_seguro = global_position
	energia = energia_maxima
	planeo_restante = duracion_planeo
	for hijo in get_children():
		if hijo is AnimatedSprite2D:
			arte = hijo
		elif hijo is Camera2D:
			camara = hijo
	if arte == null:
		arte = ARTE.poner(self, "jugador")
		if arte is Sprite2D:
			# Región del personaje en jugador.png; conserva el original con sus márgenes.
			# La altura visible coincide con la colisión de 24 px y los pies con el origen.
			arte.region_enabled = true
			arte.region_rect = Rect2(96, 68, 211, 499)
			arte.offset = Vector2(0, -499.0 / 2.0)
			arte.scale = Vector2.ONE * (24.0 / 499.0)
			arte.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# ================= FÍSICA =================
func _physics_process(delta: float) -> void:
	queue_redraw()
	invulnerable = maxf(invulnerable - delta, 0.0)
	dash_recarga_restante = maxf(dash_recarga_restante - delta, 0.0)
	_actualizar_temblor(delta)

	# Un instante quieto después de regresar de una trampa
	if espera_trampa > 0.0:
		espera_trampa -= delta
		velocity = Vector2.ZERO
		_actualizar_animacion(0.0)
		return

	if not controles_activos:
		velocity.x = move_toward(velocity.x, 0.0, friccion * delta)
		if not is_on_floor():
			velocity.y += gravedad * delta
		move_and_slide()
		_actualizar_animacion(0.0)
		return

	if global_position.y > limite_caida:
		caer_al_vacio()
		return

	var en_piso := is_on_floor()
	if en_piso:
		timer_coyote = 0.1
		saltos_pared_usados = 0
		saltos_aire_usados = 0
		if dash_tiempo <= 0.0:
			dash_disponible = true
		_terminar_planeo()
		if not en_piso_antes:
			Sonido.sfx("aterrizar")
	else:
		timer_coyote -= delta
	en_piso_antes = en_piso

	timer_pared -= delta
	if is_on_wall() and not en_piso:
		timer_pared = 0.1

	if Input.is_action_just_pressed("saltar"):
		timer_buffer = 0.12
	else:
		timer_buffer -= delta

	var dir: float = Input.get_axis("izquierda", "derecha")
	if dir > 0.0:
		mirando_derecha = true
	elif dir < 0.0:
		mirando_derecha = false

	# --- Interactuar (E en el piso, cerca de un objeto) ---
	_buscar_interactuable()
	var e_usada := false
	if Input.is_action_just_pressed("interactuar") and objeto_cercano != null and en_piso:
		objeto_cercano.call("interactuar", self)
		e_usada = true

	_actualizar_planeo(delta, e_usada)

	# --- Lanzar comida ---
	timer_lanzar -= delta
	if lanzar_habilitado and Input.is_action_just_pressed("lanzar"):
		_lanzar_comida()

	# --- Dash ---
	if dash_habilitado and dash_disponible and dash_tiempo <= 0.0 and dash_recarga_restante <= 0.0 and Input.is_action_just_pressed("dash"):
		dash_tiempo = duracion_dash
		dash_recarga_restante = duracion_dash + recarga_dash
		dash_disponible = false
		dash_direccion = signf(dir) if dir != 0.0 else (1.0 if mirando_derecha else -1.0)
		mirando_derecha = dash_direccion > 0.0
		planeando = false
		Sonido.sfx("dash")
	if dash_tiempo > 0.0:
		dash_tiempo -= delta
		velocity = Vector2(dash_direccion * velocidad_dash, 0.0)
		move_and_slide()
		_romper_con_dash()
		if dash_tiempo <= 0.0:
			velocity.x = dash_direccion * velocidad_carrera
		_actualizar_animacion(dir)
		_fin_de_frame()
		return

	# --- Gravedad, planeo, pared y viento ---
	if not en_piso:
		velocity.y += gravedad * delta
		if planeando:
			velocity.y = minf(velocity.y, velocidad_caida_planeo)
		if pared_habilitado and is_on_wall() and dir != 0.0 and velocity.y > 0.0:
			velocity.y = minf(velocity.y, deslizamiento_pared)
	if viento > 0.0:
		velocity.y = move_toward(velocity.y, -viento, 1400.0 * delta)

	# --- Saltos ---
	if timer_buffer > 0.0:
		if timer_coyote > 0.0:
			velocity.y = velocidad_salto
			timer_coyote = 0.0
			timer_buffer = 0.0
			Sonido.sfx("salto")
		elif pared_habilitado and timer_pared > 0.0 and not en_piso and saltos_pared_usados < saltos_pared_max:
			velocity.y = salto_pared_y
			saltos_pared_usados += 1
			timer_pared = 0.0
			timer_buffer = 0.0
			Sonido.sfx("pared")
		elif not en_piso and saltos_aire_usados < saltos_aire_extra:
			velocity.y = velocidad_salto
			saltos_aire_usados += 1
			timer_buffer = 0.0
			Sonido.sfx("salto")

	if Input.is_action_just_released("saltar") and velocity.y < corte_salto_minimo and viento <= 0.0:
		velocity.y = corte_salto_minimo

	# --- Movimiento horizontal ---
	var vel_max: float = velocidad_horizontal_planeo if planeando else velocidad_carrera
	var acel: float = aceleracion
	var fric: float = friccion
	if piso_mojado > 0 and en_piso:
		acel = aceleracion_mojado
		fric = friccion_mojado
	var objetivo: float = dir * vel_max + empuje_x
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, objetivo, acel * delta)
		anim_tiempo += delta * 12.0
	else:
		velocity.x = move_toward(velocity.x, empuje_x, fric * delta)
		anim_tiempo = 0.0

	move_and_slide()
	_actualizar_animacion(dir)
	_fin_de_frame()

func _fin_de_frame() -> void:
	viento = 0.0
	empuje_x = 0.0
	_actualizar_punto_seguro(get_physics_process_delta_time())

# Guarda dónde estaba parado en piso firme (bloques) para regresar ahí
# si cae en una trampa. No cuenta plataformas que se mueven o desaparecen.
func _actualizar_punto_seguro(delta: float) -> void:
	var firme := false
	if is_on_floor():
		for i in get_slide_collision_count():
			var c := get_slide_collision(i)
			var otro = c.get_collider()
			if c.get_normal().y < -0.7 and otro is Node and (otro as Node).is_in_group("suelo_seguro"):
				firme = true
				break
	if firme:
		timer_seguro += delta
		if timer_seguro >= 0.1:
			punto_seguro = global_position
	else:
		timer_seguro = 0.0

# ================= DASH =================
func _romper_con_dash() -> void:
	for i in range(get_slide_collision_count()):
		var c := get_slide_collision(i).get_collider()
		if c and c.has_method("romper"):
			c.call("romper")

func esta_dasheando() -> bool:
	return dash_tiempo > 0.0

# ================= PLANEO =================
func _actualizar_planeo(delta: float, e_usada: bool) -> void:
	if planeo_en_recarga:
		planeo_recarga_restante -= delta
		if planeo_recarga_restante <= 0.0:
			planeo_en_recarga = false
			planeo_restante = duracion_planeo

	if planeo_habilitado and not e_usada and Input.is_action_just_pressed("planear"):
		if planeando:
			_terminar_planeo()
		elif not planeo_en_recarga and not is_on_floor():
			planeando = true
			planeo_usado = 0.0
			Sonido.sfx("planeo")

	if planeando:
		planeo_restante -= delta
		planeo_usado += delta
		if planeo_restante <= 0.0:
			_terminar_planeo()

func _terminar_planeo() -> void:
	if not planeando:
		return
	planeando = false
	if planeo_usado > 0.1:
		planeo_en_recarga = true
		planeo_recarga_restante = recarga_planeo
	else:
		planeo_restante = duracion_planeo

# ================= INTERACTUAR =================
func _buscar_interactuable() -> void:
	objeto_cercano = null
	var mejor: float = 1e9
	for n in get_tree().get_nodes_in_group("interactuable"):
		var obj := n as Node2D
		if obj == null:
			continue
		if obj.has_method("puede_interactuar") and not obj.call("puede_interactuar", self):
			continue
		var punto: Vector2 = obj.call("punto_interaccion") if obj.has_method("punto_interaccion") else obj.global_position
		var d: Vector2 = punto - global_position
		if absf(d.x) < 24.0 and absf(d.y) < 40.0 and d.length() < mejor:
			# No activar terminales ni interruptores a través de paredes.
			var consulta := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -12), punto + Vector2(0, -12), collision_mask, [get_rid()])
			var impacto := get_world_2d().direct_space_state.intersect_ray(consulta)
			if not impacto.is_empty() and impacto["collider"] != obj:
				continue
			mejor = d.length()
			objeto_cercano = obj

# ================= COMIDA (nivel extra) =================
func agregar_comida(cantidad: int = 1) -> void:
	comida += cantidad
	comida_vista = true

func _lanzar_comida() -> void:
	if timer_lanzar > 0.0 or comida <= 0:
		return
	var script_comida := load("res://coleccionables/comida_lanzada.gd") as Script
	if script_comida == null:
		return
	var dir_x: float = 1.0 if mirando_derecha else -1.0
	var proyectil = script_comida.new()
	proyectil.set("velocidad", Vector2(velocidad_lanzamiento.x * dir_x + velocity.x * 0.3, velocidad_lanzamiento.y))
	get_parent().add_child(proyectil)
	proyectil.global_position = global_position + Vector2(8.0 * dir_x, -12.0)
	comida -= 1
	timer_lanzar = espera_lanzamiento
	Sonido.sfx("salto")

# ================= ENERGÍA Y REAPARECER =================
# Los enemigos y trampas llaman esto. origen = de dónde vino el golpe.
func danar(cantidad: int = 1, origen: Vector2 = Vector2.INF) -> void:
	if invulnerable > 0.0 or dash_tiempo > 0.0 or not controles_activos:
		return
	energia = maxi(energia - cantidad, 0)
	energia_cambio.emit(energia, energia_maxima)
	danado.emit()
	Sonido.sfx("dano")
	temblor = 0.25
	if energia <= 0:
		_reaparecer()
		return
	invulnerable = tiempo_invulnerable
	planeando = false
	if origen != Vector2.INF:
		var lado: float = signf(global_position.x - origen.x)
		if lado == 0.0:
			lado = -1.0 if mirando_derecha else 1.0
		velocity = Vector2(lado * 150.0, -170.0)

func curar(cantidad: int = 1) -> void:
	energia = mini(energia + cantidad, energia_maxima)
	energia_cambio.emit(energia, energia_maxima)

# Caer al vacío o al agua: vuelve a la farola con la energía llena.
# En Extraordinario cuenta como trampa: -1 vaso y regresas al último piso seguro.
func caer_al_vacio() -> void:
	if Juego.extraordinario():
		golpe_trampa()
	else:
		_reaparecer()

# PINCHOS (y vacíos en Extraordinario): -1 vaso y regresas al último piso
# firme. Si te quedas sin vasos, regresas a la farola.
func golpe_trampa() -> void:
	if espera_trampa > 0.0 or not controles_activos:
		return
	energia = maxi(energia - 1, 0)
	energia_cambio.emit(energia, energia_maxima)
	danado.emit()
	Sonido.sfx("dano")
	temblor = 0.25
	if energia <= 0:
		_reaparecer()
		return
	velocity = Vector2.ZERO
	global_position = punto_seguro
	planeando = false
	dash_tiempo = 0.0
	dash_recarga_restante = 0.0
	dash_disponible = true
	saltos_pared_usados = 0
	timer_buffer = 0.0
	invulnerable = maxf(invulnerable, tiempo_invulnerable)
	espera_trampa = 0.35
	if camara:
		camara.reset_smoothing()

# Nombre antiguo (lo usan algunos objetos del nivel extra)
func reiniciar_posicion() -> void:
	_reaparecer()

func _reaparecer() -> void:
	muertes += 1
	velocity = Vector2.ZERO
	global_position = punto_inicio
	punto_seguro = punto_inicio
	espera_trampa = 0.0
	energia = energia_maxima
	energia_cambio.emit(energia, energia_maxima)
	invulnerable = 1.0
	planeando = false
	dash_tiempo = 0.0
	dash_recarga_restante = 0.0
	dash_disponible = true
	saltos_pared_usados = 0
	saltos_aire_usados = 0
	timer_buffer = 0.0
	timer_coyote = 0.0
	timer_pared = 0.0
	viento = 0.0
	empuje_x = 0.0
	piso_mojado = 0
	objeto_cercano = null
	if camara:
		camara.reset_smoothing()
	Sonido.sfx("reaparecer")
	reaparecio.emit()

func establecer_checkpoint(pos: Vector2) -> void:
	punto_inicio = pos
	punto_seguro = pos

func rebotar(fuerza: float = -240.0) -> void:
	velocity.y = fuerza
	timer_coyote = 0.0

func empujar_viento(fuerza: float) -> void:
	viento = maxf(viento, fuerza * (1.25 if planeando else 1.0))

func empujar_lateral(v: float) -> void:
	empuje_x = v

func desbloquear(nombre: String) -> void:
	match nombre:
		"pared":
			pared_habilitado = true
		"dash":
			dash_habilitado = true
		"planeo":
			planeo_habilitado = true
			planeando = false
			planeo_en_recarga = false
			planeo_restante = duracion_planeo
		"lanzar":
			lanzar_habilitado = true
	habilidad_desbloqueada.emit(nombre)

func congelar(si: bool) -> void:
	controles_activos = not si
	if si:
		planeando = false
		dash_tiempo = 0.0

func _actualizar_temblor(delta: float) -> void:
	if camara == null:
		return
	if temblor > 0.0:
		temblor -= delta
		camara.offset = Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
	else:
		camara.offset = Vector2.ZERO

# ================= ANIMACIÓN CON IMAGEN (si hay arte) =================
func _actualizar_animacion(dir: float) -> void:
	if arte == null:
		return
	ARTE.voltear(arte, not mirando_derecha)
	var nombre := "reposo"
	if dash_tiempo > 0.0:
		nombre = "dash"
	elif not is_on_floor():
		if planeando:
			nombre = "planear"
		elif pared_habilitado and is_on_wall() and dir != 0.0 and velocity.y > 0.0:
			nombre = "pared"
		elif velocity.y < 0.0:
			nombre = "saltar"
		else:
			nombre = "caer"
	elif absf(velocity.x) > 10.0:
		nombre = "correr"
	ARTE.animar(arte, nombre)
	if arte is Sprite2D:
		# Movimiento sutil para el PNG existente, sin requerir una hoja de sprites.
		arte.position.y = sin(anim_tiempo * 2.0) * 0.7 if nombre == "correr" else 0.0
		arte.rotation = clampf(velocity.x * 0.00025, -0.08, 0.08) if nombre == "dash" else 0.0
	# Parpadeo de invulnerabilidad
	arte.visible = invulnerable <= 0.0 or fmod(invulnerable, 0.15) > 0.07

# ================= DIBUJO PROVISIONAL =================
func _draw() -> void:
	if planeando:
		draw_rect(Rect2(-11.0, -32.0, 22.0, 3.0), Color("#F5C242"))
		draw_line(Vector2(-9.0, -29.0), Vector2(-3.0, -24.0), Color("#9AA5A8"), 1.0)
		draw_line(Vector2(9.0, -29.0), Vector2(3.0, -24.0), Color("#9AA5A8"), 1.0)
	if is_on_floor():
		draw_line(Vector2(-7, -1), Vector2(7, -1), Color(0.02, 0.03, 0.05, 0.3), 3.0)
	var dir_estela: float = 1.0 if mirando_derecha else -1.0
	# Estela del dash
	if dash_tiempo > 0.0:
		for k in range(3):
			draw_rect(Rect2(-5.0 - dir_estela * (8.0 + k * 6.0), -18.0, 10.0, 12.0), Color(0.12, 0.71, 0.76, 0.25 - k * 0.07))

	if arte != null:
		return
	# Parpadeo cuando acaba de recibir daño
	if invulnerable > 0.0 and fmod(invulnerable, 0.15) < 0.07:
		return

	var dir_x: float = 1.0 if mirando_derecha else -1.0
	var offset_pie: float = sin(anim_tiempo) * 2.0 if is_on_floor() and absf(velocity.x) > 10.0 else 0.0


	# Mochila planeadora
	draw_rect(Rect2(-6.0 * dir_x - 2.0, -17.0, 5.0, 9.0), Color("#9AA5A8"))
	draw_rect(Rect2(-6.0 * dir_x - 1.0, -15.0, 3.0, 3.0), Color("#F5C242"))
	# Piernas
	draw_rect(Rect2(-4.0, -7.0 + offset_pie, 3.0, 7.0 - offset_pie), Color("#1E2229"))
	draw_rect(Rect2(1.0, -7.0 - offset_pie, 3.0, 7.0 + offset_pie), Color("#1E2229"))
	# Chamarra
	draw_rect(Rect2(-5.0, -16.0, 10.0, 9.0), Color("#1FB6C1"))
	draw_rect(Rect2(-2.0, -16.0, 4.0, 9.0), Color("#F4F1EA"))
	# Cabeza y cabello
	draw_rect(Rect2(-4.0, -23.0, 8.0, 7.0), Color("#E5A87E"))
	draw_rect(Rect2(-5.0, -24.0, 10.0, 3.0), Color("#2B1E16"))
	draw_rect(Rect2(2.0 * dir_x - 1.0, -20.0, 2.0, 2.0), Color("#0B0B14"))
	# Credencial colgando
	if tiene_credencial:
		draw_rect(Rect2(-1.0, -12.0, 3.0, 4.0), Color("#F5C242"))
