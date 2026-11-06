extends "res://niveles/nivel_base.gd"
# =====================================================================
#  NIVEL 2: BIBLIOTECA (mediodía) · 8 pantallas (x 0 a 5120)
#  Enseña: dash, bloques de ruido, piso mojado, carritos de libros,
#  ventiladores, plataformas glitch y la credencial.
#  Recompensa: Fragmento 2 -> PLANEO.
#  Farolas: 3 · Apuntes: 40 · Sellos: 3 (uno necesita planeo: rejuega el nivel)
# =====================================================================

func configurar() -> void:
	id_nivel = "nivel_2"
	borde_izq = -16.0
	borde_der = 5136.0
	borde_arriba = 0.0
	inicio = Vector2(40, 316)
	musica = "nivel_2"
	fondo_variante = "biblioteca"
	habilidades_minimas = ["dash"]

func al_empezar() -> void:
	hud.anuncio("ACTO 2 · BIBLIOTECA\nLa luz hace retroceder al ruido", 3.5)

func construir() -> void:
	bloque(-16, -400, 16, 760, "estante")                          # pared izquierda

	# ------------------------------------------------------------------
	# PANTALLA 1: vestíbulo con rayos de luz y el hueco del dash
	# ------------------------------------------------------------------
	bloque(0, 320, 420, 40, "piso")                                # 0 a 420
	pantalla_ixchel(60, 320, "Aquí la Profe Ixchel. La luz del sol congela al ruido: los bugs se quedan quietos en ella. Para el hueco grande: salta y presiona " + Juego.tecla("dash") + " en el aire.")
	luz_rayo(140, 30, 50, 290)
	luz_rayo(270, 30, 50, 290)
	bug(210, 320, 90)
	sello(16, 210)                                                  # SELLO 1: sube por la pared del inicio
	apunte(100, 304)
	apunte(240, 304)
	apunte(330, 304)
	cartel("SALTA + " + Juego.tecla("dash") + " (dash)", 350, 200)
	vacio(420, 330, 112)                                            # hueco de 112 px: necesita dash
	apunte(450, 286)
	apunte(476, 276)
	apunte(502, 286)
	bloque(532, 320, 548, 40, "piso")                               # 532 a 1080
	farola(580, 320, "¡Ese dash estuvo genial! También rompe los bloques de ruido como el de adelante.", 1.0)

	# ------------------------------------------------------------------
	# PANTALLA 2: bloque de ruido (solo con dash) y piso mojado
	# ------------------------------------------------------------------
	bloque_ruido(720, 256, 32, 64)
	apunte(790, 304)
	piso_mojado(840, 320, 240)
	apunte(900, 304)
	apunte(960, 304)
	apunte(1020, 304)
	vacio(1080, 330, 60)
	apunte(1110, 286)
	bloque(1140, 320, 140, 40, "piso")                              # 1140 a 1280
	apunte(1200, 304)

	# ------------------------------------------------------------------
	# PANTALLAS 3 y 4: carritos de libros sobre el vacío y ventilador
	# ------------------------------------------------------------------
	vacio(1280, 330, 510)
	movil(1300, 288, 56, 16, 160, 0, 45, "carrito", 0.0)
	movil(1540, 272, 56, 16, 160, 0, 45, "carrito", 1.0)
	apunte(1400, 262)
	apunte(1600, 246)
	apunte(1700, 246)
	bloque(1790, 320, 770, 40, "piso")                              # 1790 a 2560
	farola(1840, 320, "El aire del ventilador te sube al pasillo de arriba. ¡Métete en la corriente!", 1.0)
	ventilador(2000, 320, 40, 220, 220)
	apunte(2000, 250)
	apunte(2000, 170)
	# Repisa del sello: solo se alcanza PLANEANDO desde lo alto del ventilador
	bloque(1796, 216, 48, 12, "pasillo")                           # 1796 a 1844
	sello(1820, 200)                                                # SELLO 3 (necesita planeo)
	# Pasillo de abajo (sin salida) con un secreto al fondo
	apunte(2300, 304)
	guana(2350, 320, 50)
	apunte(2400, 304)
	sello(2530, 304)                                                # SELLO 2: al fondo del pasillo de abajo
	bloque(2560, 192, 32, 168, "estante")                           # pared del fondo

	# ------------------------------------------------------------------
	# PANTALLAS 5 y 6: pasillo de arriba con barandal
	# ------------------------------------------------------------------
	bloque(2030, 176, 900, 16, "pasillo")                           # 2030 a 2930
	vacio(2592, 330, 1888)
	apunte(2150, 160)
	apunte(2250, 160)
	apunte(2350, 160)
	apunte(2450, 160)
	dron(2700, 120, 100)
	apunte(2650, 160)
	cable(2820, 176, 64)
	nube(2960, 100, 2960, 260, 55)                                  # nube de ruido en el hueco
	apunte(2960, 150)
	bloque(2990, 176, 500, 16, "pasillo")                           # 2990 a 3490
	bloque(3100, 152, 48, 24, "mesa")
	apunte(3050, 160)
	apunte(3124, 136)
	cable(3200, 176, 64, 1.0)
	dron(3300, 130, 80)
	apunte(3250, 160)
	apunte(3400, 160)
	# Hueco de 116 px: salto + dash
	apunte(3530, 150)
	apunte(3570, 150)
	bloque(3606, 176, 1514, 16, "pasillo")                          # 3606 a 5120
	farola(3640, 176, "La credencial está arriba, en la sala de estudio. Las plataformas glitch desaparecen: ¡no te detengas!", 1.0)
	bloque(3700, 160, 40, 16, "mesa")
	apunte(3760, 160)
	bug(3820, 176, 60)
	apunte(3900, 160)

	# ------------------------------------------------------------------
	# PANTALLA 7: sala de estudio (plataformas glitch y credencial)
	# ------------------------------------------------------------------
	glitch(3960, 144)
	glitch(4030, 112)
	glitch(4100, 80)
	bloque(4160, 64, 64, 12, "estante")
	apunte(3980, 128)
	apunte(4050, 96)
	apunte(4120, 64)
	credencial(4210, 52)
	apunte(4300, 160)
	apunte(4380, 160)
	bloque(4440, 0, 40, 80, "estante")                              # techo sobre la puerta
	puerta(4448, 80, 24, 96, "credencial")                          # puerta con candado

	# ------------------------------------------------------------------
	# PANTALLA 8: sala de lectura (Fragmento 2) y escalera a la azotea
	# ------------------------------------------------------------------
	apunte(4600, 160)
	fragmento(4700, 150)
	dron(4900, 120, 60)
	apunte(4800, 160)
	crear_salida(5060, 176, "escalera")
	bloque(5120, -400, 16, 760, "estante")                          # pared derecha

	if ext:
		_construir_extraordinario()

# =====================================================================
#  MODO EXTRAORDINARIO
# =====================================================================
func _construir_extraordinario() -> void:
	# P2: pinchos al final del piso mojado: salta, aterriza resbalando y salta el hueco
	pinchos(970, 312, 36)
	# P3: dron sobre los carritos (en la luz no puede disparar... pero aquí no hay luz)
	dron(1560, 180, 100)
	# P5: pinchos en el pasillo de arriba
	pinchos(2280, 168, 40)
	pinchos(2480, 168, 40)
	# P6: techo de pinchos sobre el hueco: salto CORTO + dash en lo más alto (o planea)
	pinchos(3480, 100, 136, "abajo")
	cartel("Techo con pinchos: salto corto + DASH arriba", 3330, 60)
	# P7: si te caes de las plataformas glitch, hay pinchos abajo
	pinchos(3950, 168, 210)
	# P8: sala de lectura: techo de pinchos (solo saltos cortos) y pinchos en el piso
	farola(4500, 176, "Última sala. El techo pica: brinca bajito.", 1.0)
	pinchos(4520, 100, 380, "abajo")
	for px in [4560, 4640, 4740, 4840]:
		pinchos(px, 168, 32)
