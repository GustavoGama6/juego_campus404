# CAMPUS 404 · Proyecto completo en Godot 4

Juego completo según el GDD: menú inicial con los creadores, 3 viñetas de historia,
3 niveles progresivos (Plaza de Acceso → Biblioteca → Azotea y Núcleo), jefe final
Error 404, viñeta final, calificación del 0 al 10, guardado, selección de nivel,
opciones, pausa, créditos, el nivel extra del Lago y el **modo Extraordinario** (muy difícil,
se desbloquea al terminar el juego).

Todo lo que se ve ahora es **provisional** (dibujado con código y sonidos generados
por código). Para poner sus sprites, fondos y sonidos lean **COMO_CAMBIAR_EL_ARTE.md**.

---

## 1. Cómo abrirlo (paso a paso)

1. **Descomprimir** el ZIP (clic derecho → *Extraer todo*). No lo abran desde dentro del ZIP.
2. Abrir **Godot 4.7** (sirve cualquier 4.4 o más nueva; si sale un aviso de versión, acepten).
3. En el *Administrador de proyectos* → botón **Importar** → buscar la carpeta
   `campus404_juego` → seleccionar **project.godot** → **Importar y editar**.
4. La primera vez tarda unos segundos (crea la carpeta oculta `.godot`).
5. Presionar **F5** (o ▶ arriba a la derecha). El juego arranca en el menú principal.
6. Para probar **un solo nivel**: abrir `niveles/nivel_2_biblioteca.tscn` y presionar **F6**
   (corre la escena abierta).

> Si ven la vista 2D de un nivel vacía en el editor, es normal: los niveles se arman
> **con código al correr el juego** (ver sección 6).

---

## 2. Controles

| Acción | Teclado | Control (gamepad) |
|---|---|---|
| Mover | A / D o flechas | Stick izquierdo o cruceta |
| Saltar (mantén = más alto) | Espacio, W o ↑ | A |
| Salto de pared (vertical, máx. 2 antes de tocar piso) | Saltar pegado a una pared | A |
| Dash (se gana en el nivel 1) | Shift | X |
| Planeo (se gana en el nivel 2): 5 s, recarga 10 s, E otra vez cancela | E en el aire | Y |
| Interactuar (palancas, puerta con credencial, terminales) | E en el piso cerca del objeto | Y |
| Lanzar comida (solo nivel extra) | F | B |
| Pausa | Esc o P | Start |
| Ver posición de Kin (para diseñar niveles) | F3 | — |
| Modo prueba: desbloquear todo (en el menú principal) | F12 | — |

Las teclas se pueden cambiar en **Opciones** (menú principal o pausa).

---

## 3. Cómo funciona el juego (lo que pide el GDD)

**Flujo:** Menú principal → *Jugar* → 3 viñetas de introducción (solo la primera vez)
→ Nivel 1 → pantalla de resultados → Nivel 2 → Nivel 3 → jefe Error 404 → viñeta final
→ pantalla final con la calificación total → Créditos.
Al terminar el juego se desbloquean el **nivel extra: El Lago** y el **modo Extraordinario**
(botón magenta en el menú principal).

| Elemento del GDD | Cómo quedó | Dónde está |
|---|---|---|
| Menú inicial con creadores | Jugar/Continuar, Seleccionar nivel, Opciones, Créditos, Salir | `menus/menu_principal.gd` |
| Historia (3 viñetas + 1 final) | Texto letra por letra, Espacio avanza, Esc salta | `menus/historia.gd` |
| Energía | 3 vasos de café, golpe = −1 y 1 s invulnerable, sin Game Over | `jugador/yeshua.gd` |
| Farolas (checkpoints) | Guardan el punto de reaparición, dan luz y Chicle da una pista | `objetos/farola.gd` |
| Al reaparecer | Se conservan apuntes, sellos, credencial e interruptores; los enemigos vuelven | `niveles/nivel_base.gd` |
| Habilidades por nivel | Fragmento 1 → dash, Fragmento 2 → planeo (se conservan al rejugar) | `coleccionables/fragmento.gd` |
| Apuntes y sellos | 40 apuntes y 3 sellos por nivel (1 sello necesita una habilidad de después) | cada nivel |
| Calificación 0 a 10 | Apuntes (4) + Sellos (3) + Tiempo (3), con la fórmula del GDD | `autoload/juego.gd` |
| Etiquetas | Excelente / Notable / Aprobado / Para recuperar | `autoload/juego.gd` |
| Logros | Entrega perfecta, Sin tropiezos, Coleccionista, Extraordinario | `autoload/juego.gd` |
| Guardado | Automático en `user://savegame.json` al terminar nivel y al cambiar opciones | `autoload/juego.gd` |
| Selección de nivel | Tarjetas con calificación, apuntes, mejor tiempo y sellos; bloqueados con ruido | `menus/seleccion_nivel.gd` |
| Pausa | Continuar, Reiniciar nivel, Opciones, Volver al menú | `ui/menu_pausa.gd` |
| Opciones | Volumen música/efectos, pantalla completa, controles, borrar progreso | `ui/opciones.gd` |
| Fin de nivel | Apuntes, sellos, tiempo, calificación; Siguiente / Repetir / Menú | `ui/fin_nivel.gd` |
| HUD | Energía, fragmento, apuntes, tiempo, nombre del nivel, iconos de dash y planeo, barra del jefe | `ui/hud.gd` |
| Transiciones | Fundido a negro con el título del acto | `autoload/juego.gd` → `cambiar_escena()` |
| Música (6 pistas) y 19 efectos | Provisionales generados por código | `autoload/sonido.gd` |

### Los niveles

**Nivel 1 · Plaza de Acceso (mañana, 6 pantallas, meta 2:30).** Enseña correr, salto
variable (barra de glitch que obliga a hacer salto corto), salto de pared en columnas,
palanca que abre la reja, bugs, guana y vacíos. Fragmento 1 arriba de la escalinata → **dash**.
Sello secreto que necesita dash (al rejugar).

**Nivel 2 · Biblioteca (mediodía, 8 pantallas, meta 3:30).** Rayos de luz que congelan
bugs, hueco de dash, bloque de ruido, piso mojado, carritos de libros sobre el vacío,
ventilador al piso de arriba, drones, nube de ruido, cables pelados, plataformas glitch,
credencial y puerta con candado. Fragmento 2 → **planeo**. Sello secreto que necesita planeo.

**Nivel 3 · Azotea y Núcleo (atardecer → noche, 9 pantallas + arena, meta 4:30).**
Escalera de emergencia, paneles solares basculantes, pasarela con cables y dron, ventilador
para planear lejos, torre de salto de pared, bloque de ruido, nube, plataformas glitch,
3 interruptores (2 palancas y 1 placa) que abren la puerta sellada, antesala y la arena.

**Jefe · Error 404.** Ataques: lluvia de bloques "404" (la sombra avisa), invocación de
2 bugs, **rayos** que siguen a Kin (una línea delgada avisa dónde caerán) y barrido
horizontal (sáltalo; en la última fase son dos olas, una de cada lado). Después del barrido
queda aturdido ~3.5 s junto a una terminal: acércate y presiona **E**. A la tercera terminal
se reinicia el Núcleo, aparece el Fragmento 3 y sigue la viñeta final.

**Extra · El Lago.** Cocodrilos, tótems que devuelven el salto de pared y el planeo,
y el Rey Cocodrilo (se derrota lanzándole 5 peces con **F** cuando abre la boca).

### Enemigos (modo Normal)

| Enemigo | Qué hace | Cómo se vence |
|---|---|---|
| Bug | Camina y, si Kin está a su altura y cerca, da un saltito hacia él | Pisarlo |
| Guana | Patrulla y embiste rápido si te ve enfrente | Pisarla o saltarla |
| Dron | Vuela en ondas; si pasas por debajo se detiene, parpadea y se lanza en **picada** | Pisarlo (rebotas: sirve para cruzar huecos) |
| Nube de ruido | Va y viene por un riel; no se puede derrotar | Cruzar a tiempo o con dash |
| Cable pelado | 1.2 s encendido / 1.3 s apagado | Cruzar apagado |

---

## 3b. Modo EXTRAORDINARIO (muy difícil)

Se desbloquea al terminar el nivel 3 en Normal. Tiene su propio progreso y calificaciones,
y no se puede jugar el Lago en este modo. Idea: estilo Hollow Knight / Celeste, difícil
pero justo (todo avisa antes de pegar).

| Qué cambia | Cómo |
|---|---|
| Energía | **2 vasos**, sin cafés. Las **farolas curan** cada vez que pasas por ellas |
| Pinchos | Nuevos. Te quitan 1 vaso y te regresan al **último piso firme** que pisaste. Si te quedas sin vasos, regresas a la farola |
| Vacíos | Igual que los pinchos (ya no te mandan a la farola directo) |
| Habilidades | Kin tiene dash y planeo desde el nivel 1 |
| Bug | Más rápido, salta más seguido y saca **púas** (parpadea cian antes): con púas no se puede pisar |
| Guana | **Lomo acorazado**: pisarla te lastima. Cuando te ve, tiembla y embiste sin parar: si choca con una **pared** queda **volteada** (ahí sí se pisa); si llega a una **orilla** se cae; si pasa por **pinchos** se destruye |
| Dron | Además de la picada, **dispara** proyectiles a Kin. Dentro de la **luz** se congela y no dispara, y la luz borra sus proyectiles |
| Plataformas | Glitch: parpadean solo 0.3 s. Carritos 30 % más rápidos. Paneles resbalan más. Piso mojado más resbaloso |
| Error 404 | Fase 1 → 2 → 3 (cada golpe lo enoja más). Más bloques, 4-6 rayos, **rayo a ras de piso** (salta o planea), **caída** sobre Kin con dos ondas (sáltalas), dos o tres olas de barrido y solo 2.6 s aturdido. Suelta un café después de cada golpe. Si caes, **la pelea empieza de cero** desde la farola de la antesala |

Secciones nuevas por nivel (todas probadas con un bot para asegurar que se pueden pasar):

- **Nivel 1:** pinchos bajo la repisa del sello (súbete a la repisa y bájate del otro lado),
  pinchos antes de la columna (salta + **dash** contra la pared y trepa), guana acorazada junto
  a la palanca (hazla chocar contra la columna), drones que disparan y escalones con pinchos en
  su mitad lejana (aterriza en la mitad cercana y vuelve a saltar).
- **Nivel 2:** pinchos al final del piso mojado, techo de pinchos sobre el hueco grande
  (**salto corto + dash arriba**), pinchos debajo de las plataformas glitch y la sala de lectura
  con techo y piso de pinchos (solo saltos cortos).
- **Nivel 3:** nube sobre los paneles, pinchos en la pasarela y en la torre, techo de pinchos
  sobre las plataformas glitch, guana junto a la puerta del Núcleo y pinchos en la antesala.

**Para probarlo sin terminar el juego:** en el menú principal presionen **F12** (modo prueba:
abre todos los niveles y el Extraordinario). Para quitarlo: Opciones → *Borrar progreso*.

---

## 4. Carpetas

```
campus404_juego/
├─ project.godot            configuración (640x360, escala x2, autoloads)
├─ autoload/juego.gd        DATOS DEL JUEGO: creadores, niveles, calificación, guardado, controles
├─ autoload/sonido.gd       música y efectos (se reemplazan con archivos en audio/)
├─ jugador/yeshua.gd/.tscn  Kin (el archivo conserva el nombre "yeshua")
├─ niveles/                 nivel_base.gd (herramientas) + un .gd y .tscn por nivel
├─ enemigos/                bug, guana, dron, nube, cable, error404 (jefe) y los del lago
├─ objetos/                 bloques, plataformas, puertas, farolas, ventiladores, etc.
├─ coleccionables/          apunte/sello, café, fragmento, credencial, comida
├─ fondos/                  fondos con parallax (campus y selva)
├─ ui/                      HUD, pausa, opciones, fin de nivel, estilo de menús (tema.gd)
├─ menus/                   menú principal, selección, historia, créditos, fin del juego
├─ arte/                    AQUÍ VAN SUS IMÁGENES (ver COMO_CAMBIAR_EL_ARTE.md)
└─ audio/                   AQUÍ VAN SUS SONIDOS
```

---

## 5. Cambios rápidos (recetas)

**Nombres de los creadores** → `autoload/juego.gd`, arriba:
```gdscript
const CREADORES := [
	"Brandon Alexis Castillo Hernández",
	"Integrante 2",      # ← pongan aquí sus nombres
	"Integrante 3",
	"Integrante 4",
]
const MATERIA := "Proyecto de clase · Universidad del Caribe"
```
Se actualizan solos en el menú principal y en Créditos.

**Textos de la historia** → `menus/historia.gd`, listas `INTRO` y `FINAL`.

**Mensajes de Chicle (farolas) y de la Profe Ixchel (pantallas)** → en el `construir()`
de cada nivel, el texto entre comillas de `farola(...)` y `pantalla_ixchel(...)`.

**Tiempo objetivo, nombre o premio de un nivel** → `autoload/juego.gd`, lista `NIVELES`
(`tiempo_objetivo` está en segundos: 150 = 2:30).

**Física de Kin** (velocidad, salto, dash, planeo, energía) → `jugador/yeshua.gd`, sección
*AJUSTES* (también se ven en el Inspector al abrir `jugador/yeshua.tscn`).

**Jefe** → `enemigos/error404.gd`: `vida_maxima`, `tiempo_aturdido`, `altura_vuelo`; la
cantidad de bloques y rayos está en `_iniciar_lluvia()` y `_iniciar_rayos()`.

**Dificultad del Extraordinario** → los valores están marcados con `ext` en cada script
(por ejemplo `if ext:` en `enemigos/guana.gd`) y los 2 vasos en `niveles/nivel_base.gd`
(`jugador.energia_maxima = 2`). Para que sea un poco menos difícil, cambien ese 2 por 3.

**Colores y letras de los menús** → `ui/tema.gd` (colores del GDD al inicio del archivo).

**Teclas por defecto** → `autoload/juego.gd`, `CONTROLES_DEFECTO`.

**Borrar el progreso guardado** → Opciones → *Borrar progreso*.

---

## 6. Cómo editar o rediseñar un nivel

Cada nivel se arma en su función `construir()` (por ejemplo `niveles/nivel_1_plaza.gd`)
con líneas como estas. Cada línea es UNA cosa del nivel:

```gdscript
bloque(320, 288, 64, 32, "escalon")   # x, y (esquina de arriba a la izquierda), ancho, alto, estilo
apunte(352, 262)                      # apunte en (x, y)
bug(140, 320, 60)                     # bug parado en y = 320 que camina 60 px a cada lado
farola(1960, 320, "Mensaje de Chicle")
```

**Medidas que hay que conocer** (en píxeles):

- Una pantalla mide **640 × 360**. `pantalla(3)` devuelve 1280 (donde empieza la pantalla 3).
- **x** crece a la derecha, **y** crece hacia ABAJO. El piso normal está en **y = 320**.
- Kin mide 14 × 24. Salto normal ≈ 50 de alto. Hueco que se salta fácil: **64**.
- Salto + dash: hueco de **112 a 120**. Planeo: **200 a 240**.
- Con 2 saltos de pared sube ≈ **130** (usen paredes de 80 a 110 de alto).
- Presionen **F3** jugando para ver la posición exacta de Kin y copiar los números.

**Todas las piezas disponibles** (están en `niveles/nivel_base.gd`):

| Función | Qué pone |
|---|---|
| `bloque(x, y, w, h, estilo)` | Bloque sólido. Estilos: concreto, escalon, columna, pasillo, piso, estante, mesa, azotea, metal, nucleo, tierra, piedra, tronco, hojas |
| `movil(x, y, w, h, dx, dy, vel, estilo, desfase)` | Plataforma que va y viene dx/dy píxeles (carrito de libros) |
| `glitch(x, y)` | Plataforma glitch (desaparece al pisarla) |
| `ventilador(x, y_base, ancho, alto, fuerza)` | Corriente de aire hacia arriba (x = centro, y = base) |
| `bloque_ruido(x, y, w, h)` | Bloque que solo se rompe con dash |
| `panel_solar(x, y, w)` | Panel basculante |
| `piso_mojado(x, y, ancho)` | Piso resbaloso con letrero |
| `vacio(x, y, ancho)` | Hueco glitch (pónganlo donde NO haya piso) |
| `peligro(x, y, w, h)` | Barra de glitch fija que daña |
| `luz_rayo(x, y, w, h)` | Rayo de luz que congela a los enemigos |
| `puerta(x, y, w, h, modo, necesarios)` | Modos: "interruptor", "credencial", "sellada" (necesita N interruptores) |
| `interruptor(x, y, puerta, duracion, tipo)` | "palanca" (E) o "placa" (pisar). duracion 0 = para siempre |
| `farola(x, y, mensaje)` | Checkpoint + Chicle |
| `pantalla_ixchel(x, y, mensaje)` | Mensaje de la Profe Ixchel |
| `cartel(texto, x, y)` | Letrero de ayuda |
| `flecha(x, y)` | Flecha que parpadea |
| `apunte(x, y)`, `sello(x, y)`, `cafe(x, y)` | Coleccionables (el total del HUD se cuenta solo) |
| `credencial(x, y)` | Llave de las puertas con candado |
| `fragmento(x, y)` | Fragmento del Códice (abre la salida y da la habilidad) |
| `crear_salida(x, y, estilo)` | Salida del nivel: "puerta" o "escalera" |
| `bug`, `guana`, `dron(x, y, rango)` | Enemigos |
| `nube(ax, ay, bx, by, vel)` | Nube de ruido que va de A a B |
| `cable(x, y, alto, desfase)` | Cable pelado |
| `pinchos(x, y, largo, orientacion)` | Pinchos. orientacion: "arriba" (en el piso: para un piso en y = 320 usen y = 312), "abajo" (techo), "izquierda" / "derecha" (paredes) |

**Cosas solo para el Extraordinario:** al final del `construir()` de cada nivel está
`if ext: _construir_extraordinario()`. Todo lo que pongan dentro de `_construir_extraordinario()`
aparece solo en ese modo (pinchos, enemigos extra, farolas extra). Así el modo Normal no cambia.

**Si prefieren dibujar el nivel con el mouse** (TileMap): abran el `.tscn` del nivel, agreguen
un nodo **TileMapLayer**, creen un TileSet con colisión (capa física 1) y pinten. Kin choca
con él automáticamente. Después borren del `construir()` las líneas `bloque(...)` de la parte
que ya pintaron. Se pueden mezclar las dos formas.

**Agregar un nivel nuevo:**
1. Copien `niveles/nivel_2_biblioteca.gd` y `.tscn` con otro nombre (ej. `nivel_4_cafeteria`).
2. Abran el `.tscn` nuevo con un editor de texto y cambien la ruta del script al `.gd` nuevo.
3. En el `.gd` nuevo cambien `id_nivel = "nivel_4"` y rehagan `construir()`.
4. En `autoload/juego.gd` agreguen una línea a `NIVELES` con su id, nombre, escena y tiempo.

---

## 7. Para presentarlo o pasarlo a otra computadora

- Pasen la carpeta completa en ZIP (sin la carpeta oculta `.godot`, Godot la vuelve a crear).
- Para un ejecutable: *Proyecto → Exportar → Agregar… → Windows Desktop* (la primera vez
  pide descargar las *plantillas de exportación*: *Administrar plantillas → Descargar*).
- Para la web: lo mismo con *Web*. El proyecto ya usa el renderizador *Compatibilidad*, que
  es el que funciona en navegador.
