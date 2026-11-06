extends Node
# =====================================================================
#  SONIDO (autoload). Efectos y música PROVISIONALES generados por código.
#  Para usar tus propios sonidos, guarda un archivo en res://audio/ con
#  el mismo nombre (por ejemplo res://audio/salto.wav o res://audio/nivel_1.ogg)
#  y se usará ese en lugar del provisional. No hay que tocar código.
#
#  Uso:  Sonido.sfx("salto")      Sonido.musica("nivel_1")
# =====================================================================

const FRECUENCIA := 22050
const FRECUENCIA_MUSICA := 11025

# Efectos (los 19 del GDD): [onda, frecuencia inicial, frecuencia final, duración, volumen]
const EFECTOS := {
	"salto": ["cuadrada", 320.0, 640.0, 0.12, 0.35],
	"aterrizar": ["ruido", 200.0, 100.0, 0.05, 0.25],
	"pared": ["cuadrada", 500.0, 760.0, 0.08, 0.3],
	"dash": ["ruido", 900.0, 300.0, 0.18, 0.35],
	"planeo": ["triangulo", 240.0, 300.0, 0.35, 0.3],
	"pisar": ["cuadrada", 260.0, 90.0, 0.1, 0.4],
	"dano": ["cuadrada", 200.0, 60.0, 0.28, 0.45],
	"reaparecer": ["triangulo", 200.0, 900.0, 0.35, 0.35],
	"apunte": ["cuadrada", 950.0, 1250.0, 0.07, 0.25],
	"cafe": ["triangulo", 500.0, 950.0, 0.16, 0.35],
	"sello": ["arpegio", 660.0, 0.0, 0.36, 0.3],
	"fragmento": ["fanfarria", 520.0, 0.0, 0.9, 0.35],
	"farola": ["campana", 880.0, 0.0, 0.6, 0.3],
	"interruptor": ["cuadrada", 1100.0, 1100.0, 0.04, 0.3],
	"puerta": ["ruido", 160.0, 90.0, 0.3, 0.35],
	"glitch": ["glitch", 400.0, 0.0, 0.25, 0.3],
	"chispa": ["ruido", 2000.0, 1500.0, 0.12, 0.25],
	"golpe_jefe": ["cuadrada", 140.0, 40.0, 0.45, 0.5],
	"menu": ["cuadrada", 720.0, 720.0, 0.05, 0.25],
}

# Pistas: [pulsos por minuto, raíces de los acordes (nota MIDI), menor?, repetir?]
const PISTAS := {
	"menu": [110, [60, 57, 53, 55], false, true],        # Entrega pendiente
	"nivel_1": [120, [62, 67, 59, 64], false, true],     # Mañana en la plaza
	"nivel_2": [90, [57, 53, 60, 55], true, true],       # Silencio de biblioteca
	"nivel_3": [130, [64, 60, 62, 59], true, true],      # Atardecer digital
	"jefe": [150, [52, 52, 55, 50], true, true],         # Error 404
	"victoria": [120, [60, 65, 67, 72], false, false],   # Entregado
	"extra": [115, [55, 60, 62, 57], false, true],       # El lago
}

var _cache_sfx: Dictionary = {}
var _cache_musica: Dictionary = {}
var _jugadores: Array = []
var _musica: AudioStreamPlayer
var _pista_actual: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(10):
		var p := AudioStreamPlayer.new()
		p.bus = "Efectos"
		add_child(p)
		_jugadores.append(p)
	_musica = AudioStreamPlayer.new()
	_musica.bus = "Musica"
	_musica.volume_db = -6.0
	add_child(_musica)

func sfx(nombre: String) -> void:
	var stream: AudioStream = _obtener_sfx(nombre)
	if stream == null:
		return
	for p in _jugadores:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	_jugadores[0].stream = stream
	_jugadores[0].play()

func musica(nombre: String) -> void:
	if nombre == _pista_actual and _musica.playing:
		return
	_pista_actual = nombre
	var stream: AudioStream = _obtener_musica(nombre)
	if stream == null:
		_musica.stop()
		return
	# Las pistas propias (.ogg / .mp3) se repiten solas, menos la de victoria
	var repetir: bool = nombre != "victoria"
	if "loop" in stream:          # .ogg y .mp3 tienen la propiedad "loop"
		stream.set("loop", repetir)
	_musica.stream = stream
	_musica.play()

func detener_musica() -> void:
	_pista_actual = ""
	_musica.stop()

# ---------- Archivos propios en res://audio ----------
func _archivo(nombre: String) -> AudioStream:
	for ext in ["ogg", "wav", "mp3"]:
		var ruta := "res://audio/%s.%s" % [nombre, ext]
		if ResourceLoader.exists(ruta):
			return load(ruta) as AudioStream
	return null

func _obtener_sfx(nombre: String) -> AudioStream:
	if _cache_sfx.has(nombre):
		return _cache_sfx[nombre]
	var s: AudioStream = _archivo(nombre)
	if s == null and EFECTOS.has(nombre):
		s = _generar_efecto(EFECTOS[nombre])
	_cache_sfx[nombre] = s
	return s

func _obtener_musica(nombre: String) -> AudioStream:
	if _cache_musica.has(nombre):
		return _cache_musica[nombre]
	var s: AudioStream = _archivo(nombre)
	if s != null:
		if "loop" in s:
			s.set("loop", nombre != "victoria")
	elif PISTAS.has(nombre):
		s = _generar_pista(PISTAS[nombre])
	_cache_musica[nombre] = s
	return s

# ---------- Generador de efectos ----------
func _onda(tipo: String, fase: float) -> float:
	match tipo:
		"cuadrada":
			return 1.0 if fmod(fase, 1.0) < 0.5 else -1.0
		"triangulo":
			var f := fmod(fase, 1.0)
			return 4.0 * f - 1.0 if f < 0.5 else 3.0 - 4.0 * f
		"ruido":
			return randf() * 2.0 - 1.0
	return sin(fase * TAU)

func _generar_efecto(p: Array) -> AudioStreamWAV:
	var tipo: String = p[0]
	var f0: float = p[1]
	var f1: float = p[2]
	var dur: float = p[3]
	var vol: float = p[4]
	var n: int = int(dur * FRECUENCIA)
	var datos := PackedByteArray()
	datos.resize(n * 2)
	var fase := 0.0
	var ruido_valor := 0.0
	var notas: Array = []
	if tipo == "arpegio":
		notas = [f0, f0 * 1.26, f0 * 1.5, f0 * 2.0]
	elif tipo == "fanfarria":
		notas = [f0, f0 * 1.26, f0 * 1.5, f0 * 2.0, f0 * 2.0]
	for i in range(n):
		var t: float = float(i) / FRECUENCIA
		var k: float = t / dur
		var v := 0.0
		var env: float = minf(t / 0.005, 1.0) * (1.0 - k)
		match tipo:
			"arpegio", "fanfarria":
				var idx: int = mini(int(k * notas.size()), notas.size() - 1)
				fase += notas[idx] / FRECUENCIA
				v = _onda("cuadrada", fase) * 0.6 + _onda("triangulo", fase * 0.5) * 0.4
			"campana":
				fase += f0 / FRECUENCIA
				v = sin(fase * TAU) * 0.7 + sin(fase * TAU * 2.76) * 0.3
				env = exp(-k * 5.0)
			"glitch":
				var salto: float = f0 * (1.0 + float(int(k * 12.0) % 4))
				fase += salto / FRECUENCIA
				v = _onda("cuadrada", fase)
			"ruido":
				# Ruido que cambia más lento con frecuencias bajas
				var paso: int = maxi(1, int(FRECUENCIA / lerpf(f0, f1, k)))
				if i % paso == 0:
					ruido_valor = randf() * 2.0 - 1.0
				v = ruido_valor
			_:
				fase += lerpf(f0, f1, k) / FRECUENCIA
				v = _onda(tipo, fase)
		datos.encode_s16(i * 2, int(clampf(v * env * vol, -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = FRECUENCIA
	w.stereo = false
	w.data = datos
	return w

# ---------- Generador de música (chiptune sencillo de 4 compases) ----------
func _midi(nota: float) -> float:
	return 440.0 * pow(2.0, (nota - 69.0) / 12.0)

func _generar_pista(p: Array) -> AudioStreamWAV:
	var bpm: float = float(p[0])
	var raices: Array = p[1]
	var menor: bool = p[2]
	var repetir: bool = p[3]
	var pulso: float = 60.0 / bpm
	var compases: int = raices.size()
	var dur: float = pulso * 4.0 * compases
	var n: int = int(dur * FRECUENCIA_MUSICA)
	var datos := PackedByteArray()
	datos.resize(n * 2)
	var tercera: int = 3 if menor else 4
	var arpegio: Array = [0, tercera, 7, 12, 7, tercera]
	var fase_bajo := 0.0
	var fase_arp := 0.0
	var fase_mel := 0.0
	for i in range(n):
		var t: float = float(i) / FRECUENCIA_MUSICA
		var en_pulsos: float = t / pulso
		var compas: int = int(en_pulsos / 4.0) % compases
		var raiz: float = float(raices[compas])
		var dentro: float = fmod(en_pulsos, 1.0)
		# Bajo: una nota por pulso
		fase_bajo += _midi(raiz - 24.0) / FRECUENCIA_MUSICA
		var bajo: float = _onda("triangulo", fase_bajo) * (1.0 - dentro * 0.7)
		# Arpegio en semicorcheas
		var semi: int = int(en_pulsos * 4.0)
		var nota_arp: float = raiz + float(arpegio[semi % arpegio.size()])
		fase_arp += _midi(nota_arp) / FRECUENCIA_MUSICA
		var dentro_semi: float = fmod(en_pulsos * 4.0, 1.0)
		var arp: float = _onda("cuadrada", fase_arp) * (1.0 - dentro_semi) * 0.35
		# Melodía simple cada 2 pulsos
		var medio: int = int(en_pulsos / 2.0)
		var grados: Array = [12, tercera + 12, 7 + 12, 12, 7, tercera + 12, 14, 12]
		var nota_mel: float = raiz + float(grados[medio % grados.size()])
		fase_mel += _midi(nota_mel) / FRECUENCIA_MUSICA
		var dentro_medio: float = fmod(en_pulsos / 2.0, 1.0)
		var mel: float = _onda("triangulo", fase_mel) * (1.0 - dentro_medio * 0.8) * 0.4
		# Percusión: golpe en cada pulso, platillo en contratiempos
		var perc := 0.0
		if dentro < 0.06:
			perc = (randf() * 2.0 - 1.0) * (1.0 - dentro / 0.06) * 0.5
		elif absf(dentro - 0.5) < 0.02:
			perc = (randf() * 2.0 - 1.0) * 0.15
		var v: float = (bajo * 0.45 + arp + mel + perc) * 0.5
		if not repetir:
			v *= 1.0 - t / dur
		datos.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = FRECUENCIA_MUSICA
	w.stereo = false
	w.data = datos
	if repetir:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = n
	return w
