extends "res://niveles/nivel_base.gd"
# =====================================================================
#  NIVEL 1: PLAZA DE ACCESO (mañana) · 6 pantallas (x 0 a 3840)
#  Enseña: correr, saltar (salto variable) y salto de pared.
#  Recompensa: Fragmento 1 -> DASH.
#  Farolas: 3 · Apuntes: 40 · Sellos: 3 (uno necesita dash: rejuega el nivel)
# =====================================================================

var acceso_reparado: bool = false
var reja_acceso: Node2D
var luz_acceso: Node2D
var estado_acceso: Label
var objetivo: Label
var ruido_acceso: Array[Node2D] = []

func configurar() -> void:
	id_nivel = "nivel_1"
	borde_izq = -16.0
	borde_der = 3856.0
	borde_arriba = -200.0
	inicio = Vector2(40, 316)
	musica = "nivel_1"
	fondo_variante = "plaza"

func al_empezar() -> void:
	objetivo = Label.new()
	objetivo.position = Vector2(8, 76)
	objetivo.add_theme_font_size_override("font_size", 10)
	objetivo.add_theme_color_override("font_color", Color("#F5C242"))
	objetivo.add_theme_color_override("font_outline_color", Color("#0B0B14"))
	objetivo.add_theme_constant_override("outline_size", 4)
	objetivo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(objetivo)
	_actualizar_objetivo()
	hud.anuncio("ACTO 1 · PLAZA DE ACCESO\nEl error 404 bloqueó el acceso. Busca la terminal.", 4.0)

func construir() -> void:
	bloque(-16, -400, 16, 760, "columna")                          # pared izquierda

	# ------------------------------------------------------------------
	# PANTALLA 1: inicio seguro (mover y saltar)
	# ------------------------------------------------------------------
	var x := pantalla(1)
	bloque(x, 320, 640, 40, "concreto")                           # piso (0 a 640)
	pantalla_ixchel(x + 70, 320, "Kin, el error 404 dañó los sistemas de la Universidad del Caribe. Restaura el acceso en la terminal y recupera el fragmento del Códice en la escalinata.")
	cartel("%s / %s mover\n%s saltar (mantén para subir más)" % [Juego.tecla("izquierda"), Juego.tecla("derecha"), Juego.tecla("saltar")], x + 150, 200)
	flecha(x + 240, 300)
	flecha(x + 600, 300)
	bloque(x + 320, 288, 64, 32, "escalon")                       # escalón de práctica
	apunte(x + 296, 292)
	apunte(x + 318, 272)
	apunte(x + 352, 262)
	apunte(x + 386, 272)
	apunte(x + 408, 292)
	bloque(x + 424, 248, 48, 12, "pasillo")                       # repisa del sello
	sello(x + 448, 232)                                            # SELLO 1
	apunte(x + 500, 304)
	apunte(x + 540, 304)
	apunte(x + 580, 304)

	# ------------------------------------------------------------------
	# PANTALLAS 2 y 3: escalinata con huecos pequeños (salto variable)
	# ------------------------------------------------------------------
	x = pantalla(2)
	bloque(x, 320, 120, 40, "concreto")                           # 640 a 760
	if not ext:
		farola(x + 60, 320, "Soy Chicle. Esta farola guarda tu punto de regreso. Si caes, puedes volver a intentarlo desde aquí.", 1.0)
	vacio(x + 120, 330, 40)
	bloque(x + 160, 296, 96, 64, "escalon")                       # 800 a 896
	vacio(x + 256, 330, 40)
	bloque(x + 296, 272, 96, 88, "escalon")                       # 936 a 1032
	vacio(x + 392, 330, 40)
	bloque(x + 432, 248, 112, 112, "escalon")                     # 1072 a 1184
	vacio(x + 544, 330, 32)
	# Margen para el cuerpo de Kin (24 px) y una pulsación corta humana.
	# El salto completo aún alcanza el glitch; el corto permite cruzar 32 px.
	peligro(x + 530, 162, 70, 14)
	cartel("Salta cerca del borde y suelta %s pronto" % Juego.tecla("saltar"), x + 360, 130)
	bloque(x + 576, 248, 144, 112, "escalon")                     # 1216 a 1360
	apunte(x + 140, 286)
	apunte(x + 208, 280)
	apunte(x + 276, 262)
	apunte(x + 344, 256)
	apunte(x + 412, 238)
	apunte(x + 488, 232)

	# ------------------------------------------------------------------
	# PANTALLA 3: columnas blancas para el salto de pared
	# ------------------------------------------------------------------
	x = pantalla(3)
	bloque(x + 80, 320, 1200, 40, "concreto")                     # piso largo (1360 a 2560)
	cartel("Pégate a la columna y vuelve a saltar\n(hasta 2 saltos de pared antes de tocar el piso)", x + 60, 150)
	bloque(x + 280, 240, 32, 80, "columna")                       # columna baja (1560 a 1592)
	bloque(x + 360, 208, 32, 112, "columna")                      # columna alta (1640 a 1672)
	sello(x + 336, 304)                                            # SELLO 2: en el hueco entre columnas
	apunte(x + 296, 224)
	apunte(x + 376, 192)
	bloque(x + 392, 208, 248, 16, "pasillo")                      # pasillo con barandal (1672 a 1920)
	apunte(x + 440, 192)
	apunte(x + 490, 192)
	apunte(x + 540, 192)
	apunte(x + 590, 192)

	# ------------------------------------------------------------------
	# PANTALLA 4: reparar el acceso cambia el escenario y abre la reja
	# ------------------------------------------------------------------
	x = pantalla(4)
	farola(x + 40, 320, "La terminal amarilla controla el acceso. Acércate y presiona " + Juego.tecla("interactuar") + " para reparar la conexión.", 1.0)
	reja_acceso = puerta(x + 480, 128, 16, 192, "interruptor")
	var terminal_acceso := terminal(x + 280, 320)
	terminal_acceso.activar(true)
	terminal_acceso.usada_signal.connect(_reparar_acceso)
	estado_acceso = cartel("ACCESO SIN CONEXIÓN\nTerminal: " + Juego.tecla("interactuar"), x + 220, 230)
	luz_acceso = luz_rayo(x + 444, 128, 88, 192)
	luz_acceso.activa = false
	# Son avisos visuales, fuera del camino: no dañan durante la interacción.
	for desplazamiento in [Vector2(448, 152), Vector2(510, 192)]:
		var ruido := Polygon2D.new()
		ruido.position = Vector2(x, 0) + desplazamiento
		ruido.polygon = PackedVector2Array([Vector2.ZERO, Vector2(16, 0), Vector2(16, 12), Vector2(0, 12)])
		ruido.color = Color("#D81B8C")
		add_child(ruido)
		ruido_acceso.append(ruido)
	apunte(x + 120, 304)
	apunte(x + 160, 304)
	apunte(x + 200, 304)
	apunte(x + 380, 304)
	apunte(x + 420, 304)
	# Repisa alta: solo se alcanza con DASH (vuelve con el dash para el sello)
	bloque(x + 100, 196, 44, 12, "pasillo")                       # 2020 a 2064
	sello(x + 122, 180)                                            # SELLO 3 (necesita dash)

	# ------------------------------------------------------------------
	# PANTALLA 5: pasillo con bugs, guanas y vacíos glitch
	# ------------------------------------------------------------------
	x = pantalla(5)
	cartel("Bug: cáele encima para rebotar", x + 20, 234)
	bloque(x, 320, 240, 40, "concreto")                           # 2560 a 2800
	bug(x + 140, 320, 60)
	vacio(x + 240, 330, 56)
	apunte(x + 248, 290)
	apunte(x + 268, 278)
	apunte(x + 288, 290)
	bloque(x + 296, 320, 184, 40, "concreto")                     # 2856 a 3040
	cartel("Guana: embiste si te ve.\nSalta sobre ella o písala.", x + 300, 182)
	guana(x + 390, 320, 40)
	cafe(x + 390, 262)
	apunte(x + 320, 304)
	apunte(x + 450, 304)
	vacio(x + 480, 330, 60)
	apunte(x + 490, 290)
	apunte(x + 510, 278)
	apunte(x + 530, 290)
	bloque(x + 540, 320, 300, 40, "concreto")                     # 3100 a 3400
	farola(x + 570, 320, "Ya casi llegas. Sube la escalinata y recoge el fragmento para recuperar el dash y abrir la salida.", 1.0)
	bug(x + 690, 320, 50)

	# ------------------------------------------------------------------
	# PANTALLA 6: escalinata final, Fragmento 1 y puerta principal
	# ------------------------------------------------------------------
	x = pantalla(6)
	bloque(x + 200, 288, 64, 72, "escalon")                       # 3400
	bloque(x + 264, 256, 64, 104, "escalon")                      # 3464
	bloque(x + 328, 224, 64, 136, "escalon")                      # 3528
	bloque(x + 392, 192, 64, 168, "escalon")                      # 3592
	bloque(x + 456, 160, 184, 200, "concreto")                    # cima (3656 a 3840)
	apunte(x + 232, 272)
	apunte(x + 296, 240)
	apunte(x + 360, 208)
	apunte(x + 424, 176)
	apunte(x + 480, 144)
	apunte(x + 540, 144)
	apunte(x + 570, 144)
	fragmento(x + 510, 136)
	crear_salida(x + 600, 160, "puerta")
	bloque(3840, -400, 16, 760, "columna")                        # pared derecha

	if ext:
		_construir_extraordinario()

func _reparar_acceso() -> void:
	if acceso_reparado:
		return
	acceso_reparado = true
	reja_acceso.abrir()
	luz_acceso.activa = true
	estado_acceso.text = "ACCESO RESTAURADO\nConexión estable"
	estado_acceso.modulate = Color("#7CFFB2")
	for ruido in ruido_acceso:
		ruido.queue_free()
	ruido_acceso.clear()
	_actualizar_objetivo()
	hud.anuncio("¡ACCESO RESTAURADO!\nRecupera el fragmento en la escalinata.", 3.5)

func _actualizar_objetivo() -> void:
	if fragmento_obtenido:
		objetivo.text = "OBJETIVO: llega a la salida →"
	elif acceso_reparado:
		objetivo.text = "OBJETIVO: recupera el fragmento del Códice →"
	else:
		objetivo.text = "OBJETIVO: repara la terminal de acceso →"

func _on_fragmento() -> void:
	super._on_fragmento()
	_actualizar_objetivo()

# =====================================================================
#  MODO EXTRAORDINARIO: el mismo nivel con pinchos y enemigos más listos.
#  (Kin ya tiene dash y planeo, y solo 2 vasos; las farolas curan.)
# =====================================================================
func _construir_extraordinario() -> void:
	# P1: pinchos bajo la repisa del sello: sube a la repisa y bájate del otro lado
	pinchos(416, 312, 72)
	cartel("Pinchos: -1 vaso y regresas\nal último piso firme", 490, 196)
	farola(700, 320, "¡Modo Extraordinario! Solo tienes 2 vasos y no hay cafés. Las farolas te curan.", 1.0)
	# P2: bug con púas en el último escalón y un dron que dispara
	bug(1120, 248, 40)
	dron(950, 190, 80)
	# P3: pinchos antes de la columna: salta + DASH contra la pared y trepa
	pinchos(1440, 312, 104)
	cartel("Salta + DASH hacia la columna y trepa", 1360, 100)
	# P4: guana acorazada junto a la terminal: hazla chocar contra la columna
	guana(2110, 320, 50)
	cartel("Guana acorazada: haz que choque\ncontra una pared y písala volteada", 2120, 120)
	# P5: dron que dispara sobre los vacíos (la guana de aquí se cae si embiste)
	dron(2950, 210, 90)
	# P6: pinchos en la mitad lejana de dos escalones: aterriza en la mitad
	# cercana y vuelve a saltar antes de llegar a los pinchos (ritmo)
	pinchos(3504, 248, 24)
	pinchos(3632, 184, 24)
