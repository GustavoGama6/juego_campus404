extends "res://niveles/nivel_base.gd"
# =====================================================================
#  NIVEL 3: AZOTEA Y NÚCLEO (atardecer que se vuelve noche)
#  9 pantallas (x 0 a 5760) + arena del jefe (x 5760 a 6400)
#  Combina todo: salto de pared, dash, planeo, paneles solares, ventiladores,
#  la torre del Núcleo, 3 interruptores y el jefe ERROR 404.
#  Farolas: 3 · Apuntes: 40 · Sellos: 3
# =====================================================================

const ERROR404 := preload("res://enemigos/error404.gd")

const INICIO_ARENA := 5800.0

var jefe: Node2D = null
var puerta_arena: Node2D = null
var terminales: Array = []
var pelea_empezada: bool = false

func configurar() -> void:
	id_nivel = "nivel_3"
	borde_izq = -16.0
	borde_der = 6416.0
	borde_arriba = -440.0
	inicio = Vector2(40, 316)
	musica = "nivel_3"
	fondo_variante = "azotea"
	habilidades_minimas = ["dash", "planeo"]

func al_empezar() -> void:
	hud.anuncio("ACTO 3 · AZOTEA Y NÚCLEO\nActiva los 3 interruptores y entra al Núcleo", 3.5)

func construir() -> void:
	bloque(-16, -600, 16, 960, "metal")                             # pared izquierda
	# La puerta del Núcleo (pantalla 8) se crea primero para conectarle los 3 interruptores
	var puerta_nucleo := puerta(5060, -424, 32, 200, "sellada", 3)

	# ------------------------------------------------------------------
	# PANTALLA 1: escalera de emergencia (repaso de salto y dash)
	# ------------------------------------------------------------------
	bloque(0, 320, 200, 40, "azotea")
	pantalla_ixchel(60, 320, "Último tramo, Kin. Activa los 3 interruptores de la azotea para abrir la puerta del Núcleo. Error 404 te espera adentro.")
	vacio(200, 330, 400)
	bloque(210, 288, 70, 12, "metal")
	bloque(310, 256, 70, 12, "metal")
	bloque(410, 224, 70, 12, "metal")                               # 410 a 480
	apunte(245, 272)
	apunte(345, 240)
	apunte(445, 208)
	# Hueco de 120 px: salto + dash
	apunte(520, 200)
	apunte(560, 200)

	# ------------------------------------------------------------------
	# PANTALLAS 2 y 3: campo de paneles solares basculantes
	# ------------------------------------------------------------------
	bloque(600, 224, 300, 136, "azotea")                            # techo A (600 a 900)
	farola(700, 224, "Los paneles solares se inclinan hacia donde pisas. ¡Sigue avanzando sin detenerte!", 1.0)
	vacio(900, 330, 560)
	panel_solar(920, 232)
	panel_solar(1010, 224)
	panel_solar(1100, 232)
	panel_solar(1190, 224)
	panel_solar(1280, 232)
	panel_solar(1370, 224)
	apunte(952, 212)
	apunte(1042, 204)
	apunte(1132, 212)
	apunte(1222, 204)
	apunte(1312, 212)
	apunte(1402, 204)
	bloque(1460, 224, 540, 136, "azotea")                           # techo B (1460 a 2000)
	apunte(1520, 208)
	apunte(1580, 208)
	guana(1650, 224, 50)
	cafe(1700, 200)
	interruptor(1850, 224, puerta_nucleo)                           # INTERRUPTOR 1

	# ------------------------------------------------------------------
	# PANTALLAS 4 y 5: pasarela con cables y el gran ventilador
	# ------------------------------------------------------------------
	bloque(2000, 240, 400, 10, "metal")                             # pasarela (2000 a 2400)
	vacio(2000, 330, 720)
	cable(2120, 240, 48)
	cable(2280, 240, 48, 1.2)
	dron(2200, 180, 120)
	apunte(2060, 224)
	apunte(2200, 224)
	apunte(2340, 224)
	cartel("Salta, planea (" + Juego.tecla("planear") + ") y deja que el aire te suba", 2240, 120)
	ventilador(2560, 330, 40, 230, 230)
	apunte(2470, 220)
	apunte(2560, 170)
	apunte(2650, 150)
	sello(2560, 96)                                                  # SELLO 1: arriba del ventilador
	bloque(2720, 256, 800, 104, "azotea")                           # techo C (2720 a 3520)
	farola(2760, 256, "La torre se sube saltando en las paredes. Si te caes, no pasa nada: ¡otra vez!", 1.0)
	apunte(2800, 240)
	apunte(2860, 240)
	dron(2950, 200, 100)
	interruptor(3000, 256, puerta_nucleo, 0.0, "placa")             # INTERRUPTOR 2 (placa: se activa al pisarla)
	cable(3100, 256, 48, 0.5)

	# ------------------------------------------------------------------
	# PANTALLAS 6 y 7: torre del Núcleo (salto de pared en zigzag)
	# ------------------------------------------------------------------
	bloque(3300, 176, 80, 80, "columna")                            # B1 (arriba en y 176)
	bloque(3420, 96, 100, 160, "columna")                           # B2 (y 96)
	bloque(3200, 16, 160, 80, "columna")                            # B3 (y 16)
	bloque(3420, -64, 100, 80, "columna")                           # B4 (y -64)
	bloque(3200, -144, 160, 80, "columna")                          # B5 (y -144)
	bloque(3420, -224, 100, 80, "columna")                          # B6 (y -224)
	apunte(3340, 160)
	apunte(3470, 80)
	apunte(3280, 0)
	apunte(3470, -80)
	apunte(3280, -160)
	apunte(3470, -240)
	sello(3212, -160)                                                # SELLO 2: esquina de la torre

	# ------------------------------------------------------------------
	# PANTALLA 8: azotea alta, interruptor 3 y la puerta del Núcleo
	# ------------------------------------------------------------------
	bloque(3520, -224, 900, 584, "azotea")                          # edificio, ala 1 (3520 a 4420)
	farola(3560, -224, "¡Llegaste arriba! Falta un interruptor. Después, la puerta del Núcleo.", 1.0)
	apunte(3700, -240)
	apunte(3900, -240)
	bloque_ruido(3980, -288, 32, 64)                                 # rómpelo con el dash
	apunte(4100, -240)
	nube(4200, -330, 4200, -236, 50)                                 # nube de ruido: cruza cuando suba
	cable(4300, -224, 48)
	# Hueco entre las alas con plataformas glitch
	vacio(4420, 330, 200)
	glitch(4460, -232)
	glitch(4540, -232)
	apunte(4520, -256)
	bloque(4620, -224, 500, 584, "azotea")                          # edificio, ala 2 (4620 a 5120)
	dron(4720, -290, 70)
	apunte(4700, -240)
	interruptor(4800, -224, puerta_nucleo)                          # INTERRUPTOR 3
	apunte(4900, -240)
	cartel("Puerta del Núcleo: necesita los 3 interruptores", 4900, -330)
	# Repisa del sello: solo planeando desde la orilla del edificio
	bloque(5300, -220, 40, 12, "metal")
	sello(5320, -236)                                                # SELLO 3

	# ------------------------------------------------------------------
	# PANTALLA 9: antesala del Núcleo (después de la puerta, déjate caer)
	# ------------------------------------------------------------------
	bloque(5120, 320, 640, 40, "nucleo")                            # 5120 a 5760
	farola(5180, 320, "La sala del Núcleo está adelante. Si caes en la pelea, regresas aquí.", 1.0)
	apunte(5200, 304)
	apunte(5260, 304)
	bug(5300, 320, 60)
	apunte(5360, 304)
	cafe(5400, 290)
	apunte(5440, 304)
	guana(5500, 320, 50)
	apunte(5560, 304)
	apunte(5600, 304)
	bug(5650, 320, 40)
	cafe(5700, 290)
	apunte(5720, 304)

	# ------------------------------------------------------------------
	# ARENA DEL JEFE: ERROR 404 (x 5760 a 6400)
	# ------------------------------------------------------------------
	bloque(5760, 320, 640, 40, "nucleo")
	bloque(5760, 0, 656, 24, "nucleo")                              # techo de la arena
	bloque(6400, -600, 16, 960, "metal")                            # pared derecha
	puerta_arena = puerta(5760, 24, 16, 296, "interruptor")
	puerta_arena.call("abrir")
	terminales = [terminal(5860, 320), terminal(6080, 320), terminal(6300, 320)]
	_crear_jefe()

	if ext:
		_construir_extraordinario()

func _crear_jefe() -> void:
	jefe = ERROR404.new()
	jefe.set("arena_izq", 5776.0)
	jefe.set("arena_der", 6400.0)
	jefe.set("piso_y", 320.0)
	jefe.set("techo_y", 34.0)
	jefe.set("terminales", terminales)
	jefe.connect("vida_cambio", _on_jefe_vida)
	jefe.connect("derrotado", _on_jefe_derrotado)
	add_child(jefe)
	for t in terminales:
		t.set("jefe", jefe)

# =====================================================================
#  MODO EXTRAORDINARIO
# =====================================================================
func _construir_extraordinario() -> void:
	# P1: dron que se lanza sobre la escalera de emergencia
	dron(345, 170, 70)
	# P2: nube de ruido que cruza por encima de los paneles (brinca bajito)
	nube(950, 150, 1400, 150, 60)
	# P4: pinchos en la pasarela entre los dos cables
	pinchos(2150, 232, 32)
	# Torre: pinchos en el hueco de abajo y un dron que dispara arriba
	pinchos(3380, 248, 40)
	dron(3310, -270, 70)
	# Azotea alta: techo de pinchos sobre las plataformas glitch (saltos cortos)
	pinchos(4420, -306, 200, "abajo")
	# Guana acorazada junto a la puerta del Núcleo (que choque contra la puerta o caiga al hueco)
	guana(4900, -224, 40)
	# Antesala: pinchos en el piso. Atrae a la guana para que embista contra ellos
	pinchos(5400, 312, 40)
	pinchos(5570, 312, 30)

func _process(delta: float) -> void:
	super(delta)
	if not pelea_empezada and jugador and jugador.global_position.x > INICIO_ARENA and jugador.global_position.y > 200.0:
		_empezar_pelea()

func _empezar_pelea() -> void:
	pelea_empezada = true
	puerta_arena.call("cerrar")
	# Normal: si caes, reapareces dentro de la arena y el jefe conserva el daño.
	# Extraordinario: regresas a la farola de la antesala y la pelea empieza de cero.
	if not ext:
		jugador.establecer_checkpoint(Vector2(INICIO_ARENA + 20.0, 316))
	Sonido.musica("jefe")
	hud.mostrar_jefe("ERROR 404", 3, 3)
	hud.anuncio("¡ERROR 404!\nEsquiva sus ataques y activa la terminal (%s) cuando quede aturdido" % Juego.tecla("interactuar"), 4.0)
	jefe.call("empezar")

# Extraordinario: si Kin se queda sin vasos durante la pelea, todo se reinicia
func _al_reaparecer() -> void:
	super()
	if ext and pelea_empezada and is_instance_valid(jefe) and jefe.call("esta_activo"):
		call_deferred("_reiniciar_pelea")

func _reiniciar_pelea() -> void:
	pelea_empezada = false
	for n in get_children():
		var s = n.get_script()
		if s == null:
			continue
		var r: String = s.resource_path
		if r.ends_with("bloque_404.gd") or r.ends_with("barrido.gd") or r.ends_with("rayo_404.gd") or r.ends_with("proyectil.gd"):
			n.queue_free()
		elif n.is_in_group("enemigo") and (n as Node2D).global_position.x > 5760.0:
			n.queue_free()
		elif r.ends_with("cafe.gd") and (n as Node2D).global_position.x > 5760.0:
			n.queue_free()
	jefe.queue_free()
	for t in terminales:
		t.call("reiniciar")
	_crear_jefe()
	puerta_arena.call("abrir")
	hud.ocultar_jefe()
	Sonido.musica(musica)
	hud.anuncio("Error 404 se reinició...
Inténtalo otra vez", 2.5)

func _on_jefe_vida(vida: int, maxima: int) -> void:
	hud.vida_jefe(vida, maxima)

func _on_jefe_derrotado() -> void:
	hud.ocultar_jefe()
	Juego.destello(0.8)
	Sonido.musica("victoria")
	hud.anuncio("¡NÚCLEO REINICIADO!\nToma el último fragmento del Códice", 4.0)
	# Quitar los ataques que queden
	for n in get_children():
		var s = n.get_script()
		if s and (s.resource_path.ends_with("bloque_404.gd") or s.resource_path.ends_with("barrido.gd") or s.resource_path.ends_with("rayo_404.gd") or s.resource_path.ends_with("proyectil.gd")):
			n.queue_free()
		elif n.is_in_group("enemigo"):
			n.call("morir")
	call_deferred("fragmento", 6080.0, 250.0)

func _on_fragmento() -> void:
	fragmento_obtenido = true
	hud.anuncio("¡FRAGMENTO 3 DEL CÓDICE!\nEl Códice está completo", 3.0)
	await get_tree().create_timer(1.6).timeout
	completar_nivel()

# El último nivel termina con la viñeta final y la pantalla de fin del juego
func completar_nivel() -> void:
	if terminado:
		return
	terminado = true
	jugador.congelar(true)
	var stats := estadisticas()
	var r := Juego.registrar_resultado(id_nivel, stats)
	Juego.ultimo_resultado = {"stats": stats, "r": r}
	Juego.destello(1.0)
	await get_tree().create_timer(1.0).timeout
	Juego.ver_historia("final", Juego.FIN_JUEGO)
