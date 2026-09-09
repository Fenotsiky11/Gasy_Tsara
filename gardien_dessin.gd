extends Node2D
# ============================================================
# gardien_dessin.gd — Dessin procédural du gardien
# Chemin : res://gardien_dessin.gd
# Parent : gardien.tscn > GardienDessin
#
# Ce nœud dessine le gardien entièrement via _draw().
# Les couleurs et la pose changent selon gardien.direction
# et gardien._oeil_ouvert. Appeler queue_redraw() pour rafraîchir.
# ============================================================

# ── Palette ─────────────────────────────────────────────────
const C_PEAU    := Color(0.78, 0.63, 0.48)   # teint
const C_PEAU_S  := Color(0.69, 0.55, 0.40)   # ombre peau
const C_VESTE   := Color(0.23, 0.48, 0.23)   # vert uniforme
const C_VESTE_S := Color(0.18, 0.38, 0.18)   # vert foncé
const C_PANTALON:= Color(0.18, 0.37, 0.18)
const C_CASQ    := Color(0.23, 0.48, 0.23)
const C_VISIERE := Color(0.13, 0.28, 0.13)
const C_OR      := Color(0.78, 0.64, 0.16)   # insigne doré
const C_CEINTURE:= Color(0.35, 0.23, 0.06)
const C_CHAUSSURE:= Color(0.24, 0.17, 0.10)
const C_OEIL    := Color(0.20, 0.10, 0.05)
const C_BLANC   := Color(1, 1, 1)
const C_SOURCIL := Color(0.35, 0.22, 0.08)
const C_BOUCHE  := Color(0.55, 0.30, 0.18)

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _draw() -> void:
	# Récupère l'état depuis le parent (gardien.gd)
	var parent = get_parent()
	var dir: String     = parent.direction if parent else "down"
	var oeil: bool      = parent._oeil_ouvert if parent else true

	match dir:
		"down":  _dessiner_face(oeil)
		"up":    _dessiner_dos()
		"left":  _dessiner_profil(false, oeil)   # false = regarde à gauche
		"right": _dessiner_profil(true,  oeil)   # true  = regarde à droite

# ── POSE : face (idle_down) ──────────────────────────────────
func _dessiner_face(oeil_ouvert: bool) -> void:
	# Ombre
	dessiner_ellipse(Vector2(0, 56), Vector2(18, 4), Color(0,0,0,0.18))
	# Jambes
	draw_rect(Rect2(-10, 34, 8, 22), C_PANTALON)
	draw_rect(Rect2(2,   34, 8, 22), C_PANTALON)
	# Chaussures
	dessiner_ellipse(Vector2(-6, 56), Vector2(9, 4), C_CHAUSSURE)
	dessiner_ellipse(Vector2(6,  56), Vector2(9, 4), C_CHAUSSURE)
	# Corps
	draw_rect(Rect2(-14, 6, 28, 30), C_VESTE)
	# Épaulettes
	draw_rect(Rect2(-14, 8, 8, 4), C_OR)
	draw_rect(Rect2(6,   8, 8, 4), C_OR)
	# Ceinture
	draw_rect(Rect2(-14, 32, 28, 5), C_CEINTURE)
	draw_rect(Rect2(-4,  33,  8, 3), C_OR)
	# Bras
	draw_rect(Rect2(-21,  8, 8, 22), C_VESTE)
	draw_rect(Rect2(-21, 26, 8,  8), C_PEAU)
	draw_rect(Rect2( 13,  8, 8, 22), C_VESTE)
	draw_rect(Rect2( 13, 26, 8,  8), C_PEAU)
	# Cou
	draw_rect(Rect2(-4, -3, 8, 10), C_PEAU)
	# Tête
	dessiner_ellipse(Vector2(0, -14), Vector2(16, 18), C_PEAU)
	# Casquette bord
	draw_rect(Rect2(-18, -28, 36, 5), C_VISIERE)
	# Casquette sommet
	dessiner_ellipse(Vector2(0, -32), Vector2(14, 8), C_CASQ)
	# Insigne
	dessiner_ellipse(Vector2(0, -28), Vector2(5, 4), C_OR)
	# Yeux
	if oeil_ouvert:
		dessiner_ellipse(Vector2(-6, -14), Vector2(3, 4), C_BLANC)
		dessiner_ellipse(Vector2( 6, -14), Vector2(3, 4), C_BLANC)
		dessiner_ellipse(Vector2(-6, -13), Vector2(1.5, 2.5), C_OEIL)
		dessiner_ellipse(Vector2( 6, -13), Vector2(1.5, 2.5), C_OEIL)
	else:
		# Clignement : trait horizontal
		draw_line(Vector2(-9, -14), Vector2(-3, -14), C_OEIL, 1.5)
		draw_line(Vector2( 3, -14), Vector2( 9, -14), C_OEIL, 1.5)
	# Sourcils
	draw_rect(Rect2(-9, -19, 6, 2), C_SOURCIL)
	draw_rect(Rect2( 3, -19, 6, 2), C_SOURCIL)
	# Nez
	dessiner_ellipse(Vector2(0, -10), Vector2(2, 1.5), C_PEAU_S)
	# Bouche
	draw_arc(Vector2(0, -7), 4, 0.2, PI - 0.2, 8, C_BOUCHE, 1.5)

# ── POSE : dos (idle_up) ─────────────────────────────────────
func _dessiner_dos() -> void:
	dessiner_ellipse(Vector2(0, 56), Vector2(18, 4), Color(0,0,0,0.18))
	draw_rect(Rect2(-10, 34, 8, 22), C_PANTALON)
	draw_rect(Rect2(2,   34, 8, 22), C_PANTALON)
	dessiner_ellipse(Vector2(-6, 56), Vector2(9, 4), C_CHAUSSURE)
	dessiner_ellipse(Vector2(6,  56), Vector2(9, 4), C_CHAUSSURE)
	# Corps dos (légèrement plus sombre)
	draw_rect(Rect2(-14, 6, 28, 30), C_VESTE_S)
	# Couture dos
	draw_line(Vector2(0, 8), Vector2(0, 34), C_VESTE, 1.5)
	draw_rect(Rect2(-14, 32, 28, 5), C_CEINTURE)
	draw_rect(Rect2(-4,  33,  8, 3), C_OR)
	draw_rect(Rect2(-21, 8,  8, 30), C_VESTE_S)
	draw_rect(Rect2( 13, 8,  8, 30), C_VESTE_S)
	# Cou
	draw_rect(Rect2(-4, -3, 8, 10), C_PEAU)
	# Tête dos
	dessiner_ellipse(Vector2(0, -14), Vector2(16, 18), C_PEAU)
	# Cheveux nuque
	dessiner_ellipse(Vector2(0, -2), Vector2(12, 5), C_SOURCIL)
	# Casquette
	draw_rect(Rect2(-18, -28, 36, 5), C_CASQ)
	dessiner_ellipse(Vector2(0, -32), Vector2(14, 8), C_CASQ)

# ── POSE : profil (idle_left / idle_right) ───────────────────
# miroir = true → regarde à droite
func _dessiner_profil(miroir: bool, oeil_ouvert: bool) -> void:
	var s := -1.0 if miroir else 1.0   # sens de la face

	dessiner_ellipse(Vector2(0, 56), Vector2(18, 4), Color(0,0,0,0.18))
	# Jambes profil
	draw_rect(Rect2(-8, 34, 8, 22), C_PANTALON)
	draw_rect(Rect2(1,  34, 7, 16), C_VESTE_S)
	dessiner_ellipse(Vector2(0, 56), Vector2(10, 4), C_CHAUSSURE)
	# Corps
	draw_rect(Rect2(-13, 6, 26, 30), C_VESTE)
	draw_rect(Rect2(-13, 32, 26, 5), C_CEINTURE)
	# Bras avant
	draw_rect(Rect2(int(s * 11), 8,  8, 24), C_VESTE)
	draw_rect(Rect2(int(s * 11), 28, 8,  8), C_PEAU)
	# Bras arrière (plus sombre)
	draw_rect(Rect2(int(s * -17), 8, 7, 20), C_VESTE_S)
	# Cou
	draw_rect(Rect2(-4, -3, 8, 10), C_PEAU)
	# Tête
	dessiner_ellipse(Vector2(int(s * -2), -14), Vector2(14, 18), C_PEAU)
	# Casquette bord + visière côté face
	draw_rect(Rect2(int(s * -16), -28, 32, 5), C_CASQ)
	draw_rect(Rect2(int(s * -16), -28, 16, 4), C_VISIERE)
	# Sommet casquette
	dessiner_ellipse(Vector2(int(s * -2), -32), Vector2(13, 7), C_CASQ)
	# Œil (un seul, côté visible)
	var ex := int(s * -8)
	if oeil_ouvert:
		dessiner_ellipse(Vector2(ex, -14), Vector2(3, 4), C_BLANC)
		dessiner_ellipse(Vector2(ex, -13), Vector2(1.5, 2.5), C_OEIL)
	else:
		draw_line(Vector2(ex - 3, -14), Vector2(ex + 3, -14), C_OEIL, 1.5)
	# Sourcil
	draw_rect(Rect2(ex - 3, -19, 6, 2), C_SOURCIL)
	# Nez profil
	var nx := int(s * -14)
	draw_arc(Vector2(nx, -10), 4, PI * 0.6 * s + PI * 0.5, PI * 0.6 * s + PI * 0.5 + 1.2, 6, C_PEAU_S, 1.5)
	# Bouche
	draw_arc(Vector2(int(s * -12), -6), 3, 0.3, PI - 0.3, 6, C_BOUCHE, 1.5)

# ── Utilitaire : ellipse pleine ──────────────────────────────
func dessiner_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var steps := 24
	for i in steps:
		var a := TAU * i / steps
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
