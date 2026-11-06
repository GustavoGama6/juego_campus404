extends "res://niveles/nivel_base.gd"
# =====================================================================
#  NIVEL EXTRA: EL LAGO (se desbloquea al terminar el juego)
#  Selva y lago con cocodrilos. Empiezas SIN salto de pared y SIN planeo:
#  los desbloqueas con los tótems. Al final peleas contra el Rey Cocodrilo
#  lanzándole la comida (peces) que juntaste con F.
# =====================================================================

const FONDO_SELVA := preload("res://fondos/fondo_selva.gd")
const AGUA := preload("res://objetos/agua.gd")
const COMIDA := preload("res://coleccionables/comida.gd")
const COCODRILO := preload("res://enemigos/cocodrilo.gd")
const COCODRILO_AGUA := preload("res://enemigos/cocodrilo_agua.gd")
const REY_COCODRILO := preload("res://enemigos/rey_cocodrilo.gd")
const DESBLOQUEO := preload("res://objetos/desbloqueo.gd")

const INICIO_ARENA := 3380.0

var jefe: Area2D = null
var reja: Node2D = null

func configurar() -> void:
	id_nivel = "extra_lago"
	borde_izq = -216.0
	borde_der = 4156.0
	borde_arriba = -200.0
	inicio = Vector2(40, 316)
	musica = "extra"
	usa_fragmento = false

func crear_fondo() -> void:
	var f = FONDO_SELVA.new()
	f.ancho_nivel = borde_der - borde_izq
	add_child(f)

func al_empezar() -> void:
	# En este nivel las habilidades se recuperan con los tótems
	jugador.pared_habilitado = false
	jugador.planeo_habilitado = false
	jugador.lanzar_habilitado = true
	hud.anuncio("EXTRA · EL LAGO\nJunta peces y busca los tótems", 3.0)

func _process(delta: float) -> void:
	super(delta)
	if is_instance_valid(jefe) and not jefe.call("esta_despierto") and jugador.global_position.x > INICIO_ARENA:
		jefe.call("despertar")

func construir() -> void:
	var c_tronco := "tronco"
	agua(borde_izq, 334, borde_der - borde_izq, 66)
	bloque(-216, -400, 16, 760, "piedra")

	# ZONA 1: LA ORILLA
	bloque(-200, 320, 500, 40, "tierra")
	cartel("Recoge peces y lánzalos con " + Juego.tecla("lanzar") + ".\nA los cocodrilos les encantan.\nSi les caes encima, rebotas.", 110, 140)
	comida(120, 300)
	cocodrilo(240, 320, 40)
	for i in range(5):
		apunte(290 + i * 20, [296, 280, 274, 280, 296][i])
	bloque(360, 320, 260, 40, "tierra")
	apunte(420, 304)
	bloque(470, 288, 64, 32, "tronco")
	apunte(502, 272)
	sello(502, 226)
	apunte(580, 304)
	cocodrilo_agua(652, 96, 2.6, 0.0)
	bloque(684, 320, 360, 40, "tierra")
	farola(712, 320, "¡Qué calor! Más adelante hay un tótem que te enseña a saltar en las paredes.", 1.0)
	comida(780, 300)
	bug(880, 320, 50)
	apunte(850, 290)
	apunte(880, 280)
	apunte(910, 290)

	# ZONA 2: RUINAS (tótem del salto de pared)
	cartel("TÓTEM DE LA PARED\nTócalo, pégate a la pared y salta\n(hasta 2 veces antes de tocar el piso)", 840, 150)
	desbloqueo("pared", 990, 320)
	bloque(1044, 224, 220, 136, "piedra")
	farola(1070, 224)
	comida(1110, 206)
	cocodrilo(1150, 224, 24)
	movil(1290, 240, 48, 16, 110, 0, 40, c_tronco)
	cocodrilo_agua(1370, 100, 3.0, 0.8)
	apunte(1330, 220)
	apunte(1390, 220)
	bloque(1480, 320, 180, 40, "tierra")
	cocodrilo(1570, 320, 36)
	bloque(1660, 224, 48, 136, "tronco")
	apunte(1644, 256)
	bloque(1736, 208, 72, 16, "hojas")
	sello(1772, 158)
	bloque(1836, 192, 72, 16, "hojas")
	comida(1872, 174)

	# ZONA 3: COPAS Y LAGO (tótem del planeo)
	bloque(1932, 176, 128, 16, "hojas")
	farola(1950, 176)
	desbloqueo("planeo", 2000, 176)
	cartel("TÓTEM DEL PLANEO\nSalta y presiona " + Juego.tecla("planear") + " en el aire", 1910, 74)
	apunte(2140, 128)
	apunte(2190, 142)
	apunte(2240, 156)
	bloque(2280, 208, 120, 16, "hojas")
	farola(2302, 208)
	comida(2360, 190)
	movil(2430, 208, 48, 16, 0, 96, 32, c_tronco)
	cocodrilo_agua(2495, 90, 2.8, 0.3)
	bloque(2510, 320, 230, 40, "tierra")
	farola(2524, 320)
	comida(2550, 300)
	cocodrilo(2595, 320, 28)
	bloque(2640, 288, 40, 32, "piedra")
	bloque(2680, 256, 60, 64, "piedra")
	cartel("Desde lo alto: salta y planea.\nOjo con los cocodrilos del lago.", 2540, 170)
	cocodrilo_agua(2840, 90, 3.0, 0.0)
	cocodrilo_agua(2970, 85, 3.4, 1.5)
	apunte(2820, 205)
	apunte(2890, 220)
	apunte(3000, 250)

	# ZONA 4: ANTES DEL JEFE
	bloque(3060, 320, 760, 40, "tierra")
	farola(3090, 320, "El Rey Cocodrilo solo come con la boca abierta. ¡Guarda peces!", 1.0)
	comida(3150, 300)
	comida(3180, 300)
	apunte(3220, 300)
	cocodrilo(3280, 320, 36)

	# ZONA 5: ARENA DEL REY COCODRILO
	bloque(3460, 280, 64, 16, "tronco")
	bloque(3680, 280, 64, 16, "tronco")
	comida(3492, 262, 6.0)
	comida(3712, 262, 6.0)
	sello(3590, 226)
	jefe = REY_COCODRILO.new()
	jefe.position = Vector2(3640, 320)
	jefe.set("limite_izq", 3410.0)
	jefe.set("limite_der", 3770.0)
	jefe.connect("despertado", _on_jefe_despertado)
	jefe.connect("vida_cambio", _on_jefe_vida)
	jefe.connect("derrotado", _on_jefe_derrotado)
	add_child(jefe)
	reja = bloque(3820, 96, 24, 224, "piedra")
	bloque(3820, 320, 320, 40, "tierra")
	apunte(3900, 300)
	apunte(3940, 290)
	apunte(3980, 300)
	crear_salida(4090, 320, "puerta")
	bloque(4140, -400, 16, 760, "piedra")

# ---------- Piezas propias de este nivel ----------
func agua(x: float, y: float, w: float, h: float) -> void:
	var a = AGUA.new()
	a.tamano = Vector2(w, h)
	a.position = Vector2(x, y)
	add_child(a)

func comida(x: float, y: float, reaparece: float = 0.0) -> void:
	var c = COMIDA.new()
	c.position = Vector2(x, y)
	c.reaparece = reaparece
	add_child(c)

func cocodrilo(x: float, y: float, rango: float) -> void:
	_registrar(func(): return _hacer_cocodrilo(x, y, rango))

func _hacer_cocodrilo(x: float, y: float, rango: float) -> Node2D:
	var c = COCODRILO.new()
	c.position = Vector2(x, y)
	c.rango = rango
	add_child(c)
	return c

func cocodrilo_agua(x: float, altura: float, espera: float, desfase: float) -> void:
	var c = COCODRILO_AGUA.new()
	c.position = Vector2(x, 336)
	c.altura = altura
	c.espera = espera
	c.desfase = desfase
	add_child(c)

func desbloqueo(habilidad: String, x: float, y: float) -> void:
	var d = DESBLOQUEO.new()
	d.habilidad = habilidad
	d.position = Vector2(x, y)
	d.activado.connect(_on_desbloqueo)
	add_child(d)

func _on_desbloqueo(habilidad: String) -> void:
	match habilidad:
		"pared":
			hud.anuncio("¡SALTO DE PARED!\nPégate a una pared y presiona " + Juego.tecla("saltar") + " (hasta 2 veces)")
		"planeo":
			hud.anuncio("¡PLANEO!\nSalta y presiona " + Juego.tecla("planear") + " en el aire. Otra vez para cancelar")

func _on_jefe_despertado() -> void:
	hud.mostrar_jefe("REY COCODRILO", 5, 5)
	Sonido.musica("jefe")
	hud.anuncio("¡EL REY COCODRILO DESPERTÓ!\nLánzale comida (%s) cuando abra la boca" % Juego.tecla("lanzar"), 3.0)

func _on_jefe_vida(vida: int, maxima: int) -> void:
	hud.vida_jefe(vida, maxima)

func _on_jefe_derrotado() -> void:
	hud.ocultar_jefe()
	Sonido.musica("extra")
	if is_instance_valid(reja):
		reja.queue_free()
	salida.abrir()
	hud.anuncio("¡DERROTASTE AL REY COCODRILO!\nLa reja se abrió", 3.5)
