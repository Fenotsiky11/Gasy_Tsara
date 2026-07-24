## banniere_parc.gd
## Attache ce script à un nœud CanvasLayer > PanelContainer (nommé "BanniereParc")
## Il affiche une bannière stylisée en haut de l'écran avec le nom du parc,
## son sous-titre et les raccourcis clavier — comme dans un vrai RPG.

extends PanelContainer

# ─── Données du parc ───────────────────────────────────────────────
@export var nom_parc       : String = "Parc Illustrant la biodiversité de Madagascar"
@export var sous_titre     : String = "De nombreuses faunes et flores magnifiques à explorer"
@export var couleur_fond   : Color  = Color(0.05, 0.10, 0.05, 0.82)   # vert nuit semi-transparent
@export var couleur_titre  : Color  = Color(1.00, 0.95, 0.70)          # ivoire chaud
@export var couleur_sous   : Color  = Color(0.75, 0.90, 0.75)          # vert pâle
@export var couleur_touch  : Color  = Color(0.55, 0.80, 0.55, 0.90)   # vert clair

# ─── Nœuds internes ────────────────────────────────────────────────
@onready var label_nom      : Label = $MarginContainer/HBoxContainer/InfoZone/NomParc
@onready var label_sous     : Label = $MarginContainer/HBoxContainer/InfoZone/SousTitre
@onready var label_touches  : Label = $MarginContainer/HBoxContainer/Raccourcis

func _ready() -> void:
	_appliquer_style()
	label_nom.text     = nom_parc
	label_sous.text    = sous_titre
	label_touches.text = "[E] Scanner   [A] Liste d'espèces rencontrées [Échap] → main menu"

func _appliquer_style() -> void:
	# Fond du panneau
	var style := StyleBoxFlat.new()
	style.bg_color            = couleur_fond
	style.border_color        = Color(0.30, 0.55, 0.30, 0.60)
	style.set_border_width_all(1)
	style.set_content_margin_all(6)
	add_theme_stylebox_override("panel", style)

	# Typographies
	label_nom.add_theme_color_override("font_color", couleur_titre)
	label_nom.add_theme_font_size_override("font_size", 16)

	label_sous.add_theme_color_override("font_color", couleur_sous)
	label_sous.add_theme_font_size_override("font_size", 11)

	label_touches.add_theme_color_override("font_color", couleur_touch)
	label_touches.add_theme_font_size_override("font_size", 11)
	label_touches.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# ─── API publique ───────────────────────────────────────────────────
## Appelle cette fonction depuis level.gd (ou ton autoload) quand
## le joueur entre dans une nouvelle zone :
##   $BanniereParc.changer_parc("Parc de l'Isalo", "Forêt de pierres · canyons · piscines naturelles")
func changer_parc(nouveau_nom: String, nouveau_sous_titre: String = "") -> void:
	# Petite animation de fondu enchaîné
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	await tween.finished
	label_nom.text  = nouveau_nom
	label_sous.text = nouveau_sous_titre
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.28)
