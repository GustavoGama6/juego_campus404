extends "res://niveles/nivel_base.gd"
# =====================================================================
#  NIVEL 1: PLAZA DE ACCESO (mañana) · 6 pantallas (x 0 a 3840)
#  Enseña: correr, saltar (salto variable) y salto de pared.
#  Recompensa: Fragmento 1 -> DASH.
#  Farolas: 2 · Apuntes: 40 · Sellos: 3 (uno necesita dash: rejuega el nivel)
# =====================================================================

func configurar() -> void:
	id_nivel = "nivel_1"
	borde_izq = -16.0
	borde_der = 3856.0
	borde_arriba = -200.0
	inicio = Vector2(40, 316)
	musica = "nivel_1"
	fondo_variante = "plaza"

func al_empezar() -> void:
	hud.anuncio("ACTO 1 · PLAZA DE ACCESO\nRecupera el primer fragmento del Códice", 3.5)

func construir() -> void:
	bloque(-16, -400, 16, 760, "columna")                          # pared izquierda

	# ------------------------------------------------------------------
	# PANTALLA 1: inicio seguro (mover y saltar)
	# ------------------------------------------------------------------
	var x := pantalla(1)
	bloque(x, 320, 640, 40, "concreto")                           # piso (0 a 640)
	pantalla_ixchel(x + 70, 320, "Kin, el Núcleo de Datos falló y el Códice se rompió en 3 fragmentos. El primero está en lo alto de la escalinata. ¡Corre!")
	cartel("A / D mover\nESPACIO saltar (mantén para saltar más alto)", x + 150, 200)
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
	vacio(x + 120, 330, 40)
	bloque(x + 160, 296, 96, 64, "escalon")                       # 800 a 896
	vacio(x + 256, 330, 40)
	bloque(x + 296, 272, 96, 88, "escalon")                       # 936 a 1032
	vacio(x + 392, 330, 40)
	bloque(x + 432, 248, 112, 112, "escalon")                     # 1072 a 1184
	vacio(x + 544, 330, 40)
	# Barra de glitch arriba del hueco: aquí conviene un SALTO CORTO
	peligro(x + 530, 168, 70, 14)
	cartel("Toca ESPACIO rápido para un salto corto", x + 420, 140)
	bloque(x + 584, 248, 136, 112, "escalon")                     # 1224 a 1360
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
	# PANTALLA 4: primera farola y la palanca que abre la reja
	# ------------------------------------------------------------------
	x = pantalla(4)
	farola(x + 40, 320, "¡Hola, Kin! Soy Chicle. Esta farola guarda tu avance. Adelante hay una palanca: acércate y presiona " + Juego.tecla("interactuar") + ".", 1.0)
	var reja := puerta(x + 480, 128, 16, 192, "interruptor")       # reja (2400)
	interruptor(x + 280, 320, reja)                                # palanca (2200)
	cartel("Palanca: acércate y presiona " + Juego.tecla("interactuar"), x + 220, 230)
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
	bloque(x, 320, 240, 40, "concreto")                           # 2560 a 2800
	bug(x + 140, 320, 60)
	vacio(x + 240, 330, 56)
	apunte(x + 248, 290)
	apunte(x + 268, 278)
	apunte(x + 288, 290)
	bloque(x + 296, 320, 184, 40, "concreto")                     # 2856 a 3040
	guana(x + 390, 320, 40)
	cafe(x + 390, 262)
	apunte(x + 320, 304)
	apunte(x + 450, 304)
	vacio(x + 480, 330, 60)
	apunte(x + 490, 290)
	apunte(x + 510, 278)
	apunte(x + 530, 290)
	bloque(x + 540, 320, 300, 40, "concreto")                     # 3100 a 3400
	farola(x + 570, 320, "¡Cuidado! Si una guana te ve, embiste. Cáele encima o salta sobre ella.", 1.0)
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
	# P4: guana acorazada junto a la palanca: hazla chocar contra la columna
	guana(2110, 320, 50)
	cartel("Guana acorazada: haz que choque\ncontra una pared y písala volteada", 2120, 120)
	# P5: dron que dispara sobre los vacíos (la guana de aquí se cae si embiste)
	dron(2950, 210, 90)
	# P6: pinchos en la mitad lejana de dos escalones: aterriza en la mitad
	# cercana y vuelve a saltar antes de llegar a los pinchos (ritmo)
	pinchos(3504, 248, 24)
	pinchos(3632, 184, 24)
