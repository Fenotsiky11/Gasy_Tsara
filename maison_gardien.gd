extends Node2D
# ============================================================
# maison_gardien.gd — Anime le poste de garde du Parc National
# Chemin : res://maison_gardien.gd
# Scène  : res://maison_gardien.tscn
#
# Trois petites touches de vie ajoutées à la maison :
#   1. Fumée de cheminée : de petits ronds semi-transparents
#      s'élèvent et s'estompent au-dessus de la Cheminee, dessinés
#      à la main (même technique que gardien_dessin.gd), sans
#      nécessiter de texture de particule.
#   2. Lanterne : la lumière près de la porte scintille doucement
#      (variation d'opacité sinusoïdale) pour donner l'impression
#      d'une flamme vivante.
#   3. Drapeau : le fanion en haut du mât ondule légèrement grâce
#      à la propriété `skew` de Node2D.
# ============================================================

@export var intervalle_fumee: float = 1.3   # secondes entre deux bouffées

@onready var _cheminee:  Node2D  = get_node_or_null("Cheminee")
@onready var _lumiere:   Polygon2D = get_node_or_null("Lanterne/Lumiere")
@onready var _halo:      Polygon2D = get_node_or_null("Lanterne/Halo")
@onready var _drapeau:   Node2D  = get_node_or_null("Drapeau/Tissu")

var _t: float = 0.0
var _prochain_puff: float = 0.0
var _puffs: Array = []   # tableau de Dictionary {age, vie, rayon, decalage}

func _ready() -> void:
	z_index = 2
	_prochain_puff = intervalle_fumee

func _process(delta: float) -> void:
	_t += delta

	# ── Lanterne : léger scintillement ────────────────────────
	if _lumiere:
		_lumiere.modulate.a = 0.65 + 0.25 * sin(_t * 2.4)
	if _halo:
		_halo.modulate.a = 0.20 + 0.10 * sin(_t * 2.4 + 0.6)

	# ── Drapeau : ondulation douce ─────────────────────────────
	if _drapeau:
		_drapeau.skew = sin(_t * 2.6) * 0.18

	# ── Fumée : génération et mise à jour des bouffées ─────────
	if _cheminee:
		_prochain_puff -= delta
		if _prochain_puff <= 0.0:
			_prochain_puff = intervalle_fumee + randf() * 0.4
			_puffs.append({
				"age": 0.0,
				"vie": 2.0 + randf() * 0.6,
				"rayon": 3.0 + randf() * 2.0,
				"decalage": randf() * TAU,
			})

		var actifs: Array = []
		for puff in _puffs:
			puff["age"] += delta
			if puff["age"] < puff["vie"]:
				actifs.append(puff)
		_puffs = actifs

		queue_redraw()

func _draw() -> void:
	if not _cheminee or _puffs.is_empty():
		return
	var origine: Vector2 = _cheminee.position + Vector2(0, -22)
	for puff in _puffs:
		var progres: float = puff["age"] / puff["vie"]
		var decalage_x := sin(puff["age"] * 2.0 + puff["decalage"]) * 6.0
		var pos := origine + Vector2(decalage_x, -puff["age"] * 13.0)
		var rayon: float = puff["rayon"] * (1.0 + progres * 1.6)
		var alpha: float = 0.32 * (1.0 - progres)
		draw_circle(pos, rayon, Color(0.85, 0.85, 0.85, alpha))
