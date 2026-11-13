extends Node2D
# =====================================================================
#  BASE DE TODOS LOS NIVELES. Cada nivel hace:  extends "res://niveles/nivel_base.gd"
#  y escribe solo:
#    configurar()  -> id del nivel, bordes, inicio, música, fondo
#    construir()   -> cada objeto en una línea (bloque(...), bug(...), apunte(...))
#    al_empezar()  -> (opcional) algo al iniciar
#
#  COORDENADAS: x crece a la derecha, y crece hacia ABAJO. 1 pantalla = 640 x 360.
#  El suelo normal está en y = 320. En bloque(), movil(), vacio(), peligro(),
#  luz_rayo() y puerta(), (x, y) es la ESQUINA SUPERIOR IZQUIERDA.
#  En personajes, farolas, palancas, terminales, pantallas y salidas, (x, y)
#  es donde se paran (el piso). En apuntes, sellos, café, credencial y
#  fragmento, (x, y) es su centro.
#
#  pantalla(n) devuelve la x donde empieza la pantalla n (1, 2, 3...).
# =====================================================================

const JUGADOR := preload("res://jugador/yeshua.tscn")
const BLOQUE := preload("res://objetos/bloque.gd")
const MOVIL := preload("res://objetos/plataforma_movil.gd")
const GLITCH := preload("res://objetos/plataforma_glitch.gd")
const VENTILADOR := preload("res://objetos/ventilador.gd")
const BLOQUE_RUIDO := preload("res://objetos/bloque_ruido.gd")
const PANEL_SOLAR := preload("res://objetos/panel_solar.gd")
const INTERRUPTOR := preload("res://objetos/interruptor.gd")
const PUERTA := preload("res://objetos/puerta.gd")
const TERMINAL := preload("res://objetos/terminal.gd")
const FAROLA := preload("res://objetos/farola.gd")
const LUZ := preload("res://objetos/zona_luz.gd")
const PANTALLA_IXCHEL := preload("res://objetos/pantalla.gd")
const PISO_MOJADO := preload("res://objetos/piso_mojado.gd")
const VACIO := preload("res://objetos/vacio.gd")
const PELIGRO := preload("res://objetos/peligro.gd")
const SALIDA := preload("res://objetos/salida.gd")
const FLECHA := preload("res://objetos/flecha.gd")
const PINCHOS := preload("res://objetos/pinchos.gd")
const APUNTE := preload("res://coleccionables/apunte.gd")
const CAFE := preload("res://coleccionables/cafe.gd")
const FRAGMENTO := preload("res://coleccionables/fragmento.gd")
const CREDENCIAL := preload("res://coleccionables/credencial.gd")
const BUG := preload("res://enemigos/bug.gd")
const GUANA := preload("res://enemigos/guana.gd")
const DRON := preload("res://enemigos/dron.gd")
const NUBE := preload("res://enemigos/nube_ruido.gd")
const CABLE := preload("res://enemigos/cable.gd")
const FONDO := preload("res://fondos/fondo_campus.gd")
const HUD := preload("res://ui/hud.gd")
const PAUSA := preload("res://ui/menu_pausa.gd")
const FIN_NIVEL := preload("res://ui/fin_nivel.gd")

# ---------- Lo que cada nivel ajusta en configurar() ----------
var id_nivel: String = "nivel_1"
var borde_izq: float = -16.0
var borde_der: float = 3856.0
var borde_arriba: float = -400.0
var borde_abajo: float = 360.0
var inicio: Vector2 = Vector2(40, 316)
var musica: String = "nivel_1"
var fondo_variante: String = "plaza"
var habilidades_minimas: Array = []   # habilidades que el nivel necesita sí o sí
var usa_fragmento: bool = true

# ---------- Estado ----------
var info: Dictionary = {}
var jugador = null
var hud = null
var pausa = null
var salida = null
var apuntes_total: int = 0
var apuntes_recogidos: int = 0
var sellos_total: int = 0
var sellos_recogidos: int = 0
var sellos_ids: Array = []
var tiempo: float = 0.0
var terminado: bool = false
var desafio_activo: bool = false
var fragmento_obtenido: bool = false
var registro_enemigos: Array = []
var ext: bool = false   # true = modo Extraordinario (en construir() se usa: if ext: ...)

func _ready() -> void:
	add_to_group("nivel")
	ext = Juego.extraordinario()
	configurar()
	info = Juego.nivel_info(id_nivel)
	crear_fondo()
	construir()
	_crear_jugador()
	hud = HUD.new()
	hud.nivel = self
	hud.jugador = jugador
	add_child(hud)
	pausa = PAUSA.new()
	pausa.nivel = self
	add_child(pausa)
	Sonido.musica(musica)
	al_empezar()

func configurar() -> void:
	pass

func construir() -> void:
	pass

func al_empezar() -> void:
	pass

func crear_fondo() -> void:
	var f = FONDO.new()
	f.variante = fondo_variante
	f.ancho_nivel = borde_der - borde_izq
	add_child(f)
	if ext:
		# Extraordinario: todo se ve un poco más oscuro y morado
		var tinte := CanvasModulate.new()
		tinte.color = Color(0.86, 0.8, 0.95)
		add_child(tinte)

func _process(delta: float) -> void:
	if not terminado:
		tiempo += delta

func pantalla(n: int) -> float:
	return 640.0 * float(n - 1)

# ======================================================================
#  Jugador
# ======================================================================
func _crear_jugador() -> void:
	jugador = JUGADOR.instantiate()
	jugador.position = inicio
	jugador.dash_habilitado = Juego.tiene_habilidad("dash") or habilidades_minimas.has("dash")
	jugador.planeo_habilitado = Juego.tiene_habilidad("planeo") or habilidades_minimas.has("planeo")
	if ext:
		# Extraordinario: todas las habilidades, pero solo 2 vasos de café,
		# menos tiempo invulnerable y el piso mojado resbala más
		jugador.dash_habilitado = true
		jugador.planeo_habilitado = true
		jugador.energia_maxima = 2
		jugador.tiempo_invulnerable = 0.8
		jugador.friccion_mojado = 80.0
		jugador.aceleracion_mojado = 320.0
	add_child(jugador)
	var cam = jugador.get("camara")
	if cam:
		cam.limit_left = int(borde_izq)
		cam.limit_right = int(borde_der)
		cam.limit_top = int(borde_arriba)
		cam.limit_bottom = int(borde_abajo)
		cam.reset_smoothing()
	jugador.reaparecio.connect(_al_reaparecer)

func _al_reaparecer() -> void:
	if hud:
		hud.aviso("REINTENTO · Checkpoint restaurado; conservas tus objetos", 2.5)
	call_deferred("_reponer_enemigos")

# Los enemigos derrotados vuelven a aparecer cuando Yoshua reaparece (GDD)
func _reponer_enemigos() -> void:
	for r in registro_enemigos:
		if not is_instance_valid(r["nodo"]) or r["nodo"].get("muerto"):
			if is_instance_valid(r["nodo"]):
				r["nodo"].queue_free()
			r["nodo"] = r["fabrica"].call()

func _registrar(fabrica: Callable) -> Node2D:
	var n: Node2D = fabrica.call()
	registro_enemigos.append({"fabrica": fabrica, "nodo": n})
	return n

# ======================================================================
#  PIEZAS DEL ESCENARIO
# ======================================================================
func bloque(x: float, y: float, w: float, h: float, estilo: String = "concreto") -> Node2D:
	var b = BLOQUE.new()
	b.tamano = Vector2(w, h)
	b.estilo = estilo
	b.position = Vector2(x + w / 2.0, y + h / 2.0)
	add_child(b)
	return b

# Plataforma que va y viene. dx, dy = cuánto se mueve. desfase 0..1
func movil(x: float, y: float, w: float, h: float, dx: float, dy: float, vel: float, estilo: String = "carrito", desfase: float = 0.0) -> Node2D:
	var m = MOVIL.new()
	m.tamano = Vector2(w, h)
	m.recorrido = Vector2(dx, dy)
	m.velocidad = vel
	m.estilo = estilo
	m.desfase = desfase
	m.position = Vector2(x + w / 2.0, y + h / 2.0)
	add_child(m)
	return m

func glitch(x: float, y: float, w: float = 40.0, h: float = 12.0) -> Node2D:
	var g = GLITCH.new()
	g.tamano = Vector2(w, h)
	g.position = Vector2(x + w / 2.0, y + h / 2.0)
	add_child(g)
	return g

# Ventilador: x = centro, y = base (de donde sale el aire)
func ventilador(x: float, y: float, ancho: float = 40.0, alto: float = 200.0, fuerza: float = 200.0) -> Node2D:
	var v = VENTILADOR.new()
	v.ancho = ancho
	v.alto = alto
	v.fuerza = fuerza
	v.position = Vector2(x, y)
	add_child(v)
	return v

func bloque_ruido(x: float, y: float, w: float = 32.0, h: float = 64.0) -> Node2D:
	var b = BLOQUE_RUIDO.new()
	b.tamano = Vector2(w, h)
	b.position = Vector2(x + w / 2.0, y + h / 2.0)
	add_child(b)
	return b

func panel_solar(x: float, y: float, w: float = 64.0) -> Node2D:
	var p = PANEL_SOLAR.new()
	p.tamano = Vector2(w, 8)
	p.position = Vector2(x + w / 2.0, y + 4.0)
	add_child(p)
	return p

# modo: "interruptor", "credencial" o "sellada"
func puerta(x: float, y: float, w: float, h: float, modo: String = "interruptor", necesarios: int = 3) -> Node2D:
	var p = PUERTA.new()
	p.tamano = Vector2(w, h)
	p.modo = modo
	p.necesarios = necesarios
	p.position = Vector2(x + w / 2.0, y + h / 2.0)
	add_child(p)
	return p

# Palanca (E) o placa (pisar) conectada a una puerta.
# duracion 0 = la puerta queda abierta; > 0 = se cierra después de esos segundos.
func interruptor(x: float, y: float, la_puerta: Node2D, duracion: float = 0.0, tipo: String = "palanca") -> Node2D:
	var i = INTERRUPTOR.new()
	i.tipo = tipo
	i.duracion = duracion
	i.position = Vector2(x, y)
	add_child(i)
	if la_puerta:
		if la_puerta.get("modo") == "sellada":
			i.activado.connect(Callable(la_puerta, "registrar"))
		else:
			i.activado.connect(Callable(la_puerta, "abrir").bind(duracion))
	i.activado.connect(_on_interruptor)
	return i

func terminal(x: float, y: float) -> Node2D:
	var t = TERMINAL.new()
	t.position = Vector2(x, y)
	add_child(t)
	return t

# Farola (checkpoint). mensaje = lo que dice Chicle. senala: -1 izq, 1 der (pista)
func farola(x: float, y: float, mensaje: String = "", senala: float = 0.0, lado: float = 1.0) -> Node2D:
	var f = FAROLA.new()
	f.position = Vector2(x, y)
	f.mensaje_chicle = mensaje
	f.senala = senala
	f.lado_chicle = lado
	f.activada.connect(_on_farola)
	add_child(f)
	return f

# Rayo de sol: (x, y) esquina superior izquierda
func luz_rayo(x: float, y: float, w: float, h: float) -> Node2D:
	var l = LUZ.new()
	l.forma = "rayo"
	l.tamano = Vector2(w, h)
	l.position = Vector2(x, y)
	add_child(l)
	return l

# Pantalla del campus con mensaje de la Profe Ixchel
func pantalla_ixchel(x: float, y: float, mensaje: String) -> Node2D:
	var p = PANTALLA_IXCHEL.new()
	p.position = Vector2(x, y)
	p.mensaje = mensaje
	add_child(p)
	return p

func piso_mojado(x: float, y: float, ancho: float) -> Node2D:
	var p = PISO_MOJADO.new()
	p.ancho = ancho
	p.position = Vector2(x, y)
	add_child(p)
	return p

func vacio(x: float, y: float, w: float, h: float = 80.0) -> Node2D:
	var v = VACIO.new()
	v.tamano = Vector2(w, h)
	v.position = Vector2(x, y)
	add_child(v)
	return v

func peligro(x: float, y: float, w: float, h: float) -> Node2D:
	var p = PELIGRO.new()
	p.tamano = Vector2(w, h)
	p.position = Vector2(x, y)
	add_child(p)
	return p

func crear_salida(x: float, y: float, estilo: String = "puerta") -> Node2D:
	salida = SALIDA.new()
	salida.estilo = estilo
	salida.position = Vector2(x, y)
	salida.entrada.connect(completar_nivel)
	add_child(salida)
	return salida

# Pinchos: (x, y) esquina superior izquierda. orientacion: "arriba" (en el piso,
# ocupan de y a y+8), "abajo" (en el techo), "izquierda" / "derecha" (en paredes:
# largo = alto de la fila de pinchos).
# Para poner pinchos SOBRE un piso que está en y = 320 usa: pinchos(x, 312, ancho)
func pinchos(x: float, y: float, largo: float, orientacion: String = "arriba") -> Node2D:
	var p = PINCHOS.new()
	p.largo = largo
	p.orientacion = orientacion
	p.position = Vector2(x, y)
	add_child(p)
	return p

func flecha(x: float, y: float, direccion: float = 1.0) -> void:
	var f = FLECHA.new()
	f.direccion = direccion
	f.position = Vector2(x, y)
	add_child(f)

func cartel(texto: String, x: float, y: float) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", Color("#F4F1EA"))
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(0.08, 0.1, 0.14, 0.82)
	caja.border_color = Color("#1FB6C1")
	caja.set_border_width_all(1)
	caja.set_corner_radius_all(3)
	caja.set_content_margin_all(5)
	l.add_theme_stylebox_override("normal", caja)
	add_child(l)
	return l

# ======================================================================
#  COLECCIONABLES
# ======================================================================
func apunte(x: float, y: float) -> void:
	var a = APUNTE.new()
	a.position = Vector2(x, y)
	a.recogido.connect(_on_recogido)
	apuntes_total += 1
	add_child(a)

func sello(x: float, y: float) -> void:
	var a = APUNTE.new()
	a.es_sello = true
	a.id = sellos_total
	a.position = Vector2(x, y)
	# Si ya lo tenías de otra partida se ve transparente (igual cuenta para esta)
	for guardado in Juego.progreso(id_nivel)["sellos_ids"]:
		if int(guardado) == sellos_total:
			a.modulate.a = 0.45
	a.recogido.connect(_on_recogido)
	sellos_total += 1
	add_child(a)

# En Extraordinario no hay cafés (las farolas te curan). siempre = true lo pone igual.
func cafe(x: float, y: float, siempre: bool = false) -> void:
	if ext and not siempre:
		return
	var c = CAFE.new()
	c.position = Vector2(x, y)
	add_child(c)

func fragmento(x: float, y: float) -> Node2D:
	var f = FRAGMENTO.new()
	f.position = Vector2(x, y)
	f.tomado.connect(_on_fragmento)
	add_child(f)
	return f

func credencial(x: float, y: float) -> void:
	var c = CREDENCIAL.new()
	c.position = Vector2(x, y)
	c.tomada.connect(_on_credencial)
	add_child(c)

# ======================================================================
#  ENEMIGOS (vuelven a aparecer cuando Yoshua reaparece)
# ======================================================================
func bug(x: float, y: float, rango: float = 60.0) -> void:
	_registrar(func(): return _hacer_bug(x, y, rango))

func guana(x: float, y: float, rango: float = 50.0) -> void:
	_registrar(func(): return _hacer_guana(x, y, rango))

func dron(x: float, y: float, rango: float = 100.0) -> void:
	_registrar(func(): return _hacer_dron(x, y, rango))

# Nube de ruido que va de (ax, ay) a (bx, by)
func nube(ax: float, ay: float, bx: float, by: float, vel: float = 50.0) -> void:
	_registrar(func(): return _hacer_nube(ax, ay, bx, by, vel))

# Cable pelado: (x, y) = piso; alto = largo del arco eléctrico
func cable(x: float, y: float, alto: float = 64.0, desfase: float = 0.0) -> void:
	_registrar(func(): return _hacer_cable(x, y, alto, desfase))

# Enemigos que invoca el jefe (no vuelven a aparecer)
func crear_bug_temporal(x: float, y: float, rango: float) -> void:
	_hacer_bug(x, y, rango)

func crear_dron_temporal(x: float, y: float, rango: float) -> void:
	_hacer_dron(x, y, rango)

func _hacer_bug(x: float, y: float, rango: float) -> Node2D:
	var e = BUG.new()
	e.position = Vector2(x, y)
	e.rango = rango
	add_child(e)
	return e

func _hacer_guana(x: float, y: float, rango: float) -> Node2D:
	var e = GUANA.new()
	e.position = Vector2(x, y)
	e.rango = rango
	add_child(e)
	return e

func _hacer_dron(x: float, y: float, rango: float) -> Node2D:
	var e = DRON.new()
	e.position = Vector2(x, y)
	e.rango = rango
	add_child(e)
	return e

func _hacer_nube(ax: float, ay: float, bx: float, by: float, vel: float) -> Node2D:
	var e = NUBE.new()
	e.punto_a = Vector2(ax, ay)
	e.punto_b = Vector2(bx, by)
	e.velocidad = vel
	e.position = Vector2(ax, ay)
	add_child(e)
	return e

func _hacer_cable(x: float, y: float, alto: float, desfase: float) -> Node2D:
	var e = CABLE.new()
	e.alto = alto
	e.desfase = desfase
	e.position = Vector2(x, y)
	add_child(e)
	return e

# ======================================================================
#  EVENTOS
# ======================================================================
func _on_recogido(es_sello: bool, id: int) -> void:
	if es_sello:
		if sellos_ids.has(id):
			return
		sellos_recogidos += 1
		sellos_ids.append(id)
		hud.aviso("¡SELLO DE HONOR! (%d/%d)" % [sellos_recogidos, sellos_total])
	else:
		apuntes_recogidos += 1

func _on_farola() -> void:
	hud.aviso("CHECKPOINT")

func _on_interruptor() -> void:
	hud.aviso("¡INTERRUPTOR ACTIVADO!")

func _on_credencial() -> void:
	hud.anuncio("¡CREDENCIAL!\nAbre la puerta con candado: acércate y presiona %s" % Juego.tecla("interactuar"), 3.0)

func _on_fragmento() -> void:
	if fragmento_obtenido or terminado:
		return
	fragmento_obtenido = true
	hud.flash.color = Color(0.16, 0.9, 1.0, 0.18)
	var premio: String = info.get("premio", "") if not ext else ""
	var texto: String = "¡FRAGMENTO %d DEL CÓDICE!" % int(info["numero"])
	if premio != "":
		jugador.desbloquear(premio)
		Juego.desbloquear_habilidad(premio)
		match premio:
			"dash":
				texto += "\nDASH reactivado: presiona %s" % Juego.tecla("dash")
			"planeo":
				texto += "\nPLANEO reactivado: en el aire presiona %s" % Juego.tecla("planear")
	if salida:
		salida.abrir()
		texto += "\nLa salida está abierta"
	hud.anuncio(texto, 4.0)

func estadisticas() -> Dictionary:
	return {
		"apuntes": apuntes_recogidos, "apuntes_total": apuntes_total,
		"sellos": sellos_recogidos, "sellos_total": sellos_total, "sellos_ids": sellos_ids,
		"tiempo": tiempo, "muertes": int(jugador.get("muertes")), "usa_fragmento": usa_fragmento,
	}

# Se llama al entrar a la salida (o al final del jefe)
func completar_nivel() -> void:
	if usa_fragmento and not fragmento_obtenido:
		return
	if terminado:
		return
	terminado = true
	jugador.congelar(true)
	var stats := estadisticas()
	var r := Juego.registrar_resultado(id_nivel, stats)
	Sonido.musica("victoria")
	var fin = FIN_NIVEL.new()
	add_child(fin)
	fin.mostrar(info, stats, r)

# Una guía breve que sigue los estados reales de cada acto.
func mision_actual() -> String:
	if not usa_fragmento:
		return "Explora el lago y vence al Rey Cocodrilo"
	if fragmento_obtenido:
		return "Llega a la salida para guardar el fragmento"
	return "Explora %s y recupera el fragmento" % info["nombre"]
