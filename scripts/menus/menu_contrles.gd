extends Control

# ── Nœuds menu principal ──────────────────────────────────────────────────────
@onready var btn_jouer      : Button = get_node_or_null("Centre/BtnJouer")
@onready var btn_parametres : Button = get_node_or_null("BtnParametres")
@onready var btn_quitter    : Button = get_node_or_null("Centre/BtnQuitter")

# ── Nœuds panneau paramètres ──────────────────────────────────────────────────
@onready var panneau_param : PanelContainer = get_node_or_null("PanneauParametres")
@onready var btn_fermer    : Button         = get_node_or_null("PanneauParametres/Margin/VBox/HeaderRow/BtnFermer")

@onready var btn_francais  : Button = get_node_or_null("PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnFrancais")
@onready var btn_malagasy  : Button = get_node_or_null("PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnMalagasy")
@onready var btn_anglais   : Button = get_node_or_null("PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnAnglais")

@onready var slider_mus    : HSlider = get_node_or_null("PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/SliderMusique")
@onready var slider_sfx    : HSlider = get_node_or_null("PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/SliderSons")
@onready var lbl_mus       : Label   = get_node_or_null("PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/RowMus/LabelValMusique")
@onready var lbl_sfx       : Label   = get_node_or_null("PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/RowSons/LabelValSons")

@onready var lbl_ecoute    : Label  = get_node_or_null("PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/LabelEcoute")

# ── Conteneur de la grille de contrôles (GridContainer 2 colonnes) ────────────
# Structure attendue dans la scène :
#   SectionControles/MarginCtrl/ColCtrl/GrilleCtrl  ← GridContainer (columns=2)
@onready var grille_ctrl : GridContainer = get_node_or_null("PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/GrilleCtrl")

@onready var son_clic : AudioStreamPlayer = get_node_or_null("SonClic")

var _action_en_attente : String = ""

# Données des actions : [action_id, libellé, icône unicode]
const ACTIONS := [
	["haut",      "Haut",      "⬆"],
	["bas",       "Bas",       "⬇"],
	["gauche",    "Gauche",    "⬅"],
	["droite",    "Droite",    "➡"],
	["interagir", "Interagir", "💬"],
]

# Dictionnaire action_id → BtnTouche (colonne droite) pour mise à jour dynamique
var _btns_touche : Dictionary = {}

# ── Prêt ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	if panneau_param:
		panneau_param.visible = false
	else:
		push_warning("menu_contrles.gd: 'PanneauParametres' introuvable, panneau ignoré.")

	# Menu principal
	if btn_jouer:
		btn_jouer.pressed.connect(_on_jouer)
	else:
		push_warning("menu_contrles.gd: 'Centre/BtnJouer' introuvable.")

	if btn_parametres:
		btn_parametres.pressed.connect(_on_ouvrir_param)
	else:
		push_warning("menu_contrles.gd: 'BtnParametres' introuvable.")

	if btn_quitter:
		btn_quitter.pressed.connect(get_tree().quit)
	else:
		push_warning("menu_contrles.gd: 'Centre/BtnQuitter' introuvable.")

	# Paramètres – fermeture & langue
	if btn_fermer:
		btn_fermer.pressed.connect(_on_fermer_param)
	if btn_francais:
		btn_francais.pressed.connect(func(): _set_langue("fr"))
	if btn_malagasy:
		btn_malagasy.pressed.connect(func(): _set_langue("mg"))
	if btn_anglais:
		btn_anglais.pressed.connect(func(): _set_langue("en"))

	# Audio
	if slider_mus:
		slider_mus.value_changed.connect(_on_mus_change)
	if slider_sfx:
		slider_sfx.value_changed.connect(_on_sfx_change)

	# Construire la grille de contrôles
	_construire_grille_ctrl()

	# Son sur les boutons fixes
	if son_clic:
		for b in [btn_jouer, btn_parametres, btn_quitter, btn_fermer,
				btn_francais, btn_malagasy, btn_anglais]:
			if b:
				b.pressed.connect(son_clic.play)

	# Fondu d'entrée
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.45)

# ── Construction de la grille 2 colonnes ──────────────────────────────────────
func _construire_grille_ctrl() -> void:
	if not grille_ctrl:
		push_warning("menu_contrles.gd: 'GrilleCtrl' introuvable, grille de contrôles ignorée.")
		return

	# Vider la grille au cas où
	for child in grille_ctrl.get_children():
		child.queue_free()
	_btns_touche.clear()

	for entree in ACTIONS:
		var action_id : String = entree[0]
		var libelle   : String = entree[1]
		var icone     : String = entree[2]

		# ── Colonne gauche : icône + nom de l'action ──────────────────────────
		var btn_role := Button.new()
		btn_role.text         = "%s  %s" % [icone, libelle]
		btn_role.disabled     = true          # pas cliquable, juste informatif
		btn_role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_role.add_theme_color_override("font_disabled_color", Color(0.75, 0.88, 0.75))

		# Style : fond semi-transparent, bords arrondis
		var style_role := StyleBoxFlat.new()
		style_role.bg_color            = Color(0.13, 0.22, 0.13, 1.0)
		style_role.border_color        = Color(0.23, 0.40, 0.23, 1.0)
		style_role.set_border_width_all(1)
		style_role.set_corner_radius_all(6)
		style_role.content_margin_left   = 10
		style_role.content_margin_right  = 10
		style_role.content_margin_top    = 8
		style_role.content_margin_bottom = 8
		btn_role.add_theme_stylebox_override("disabled", style_role)

		grille_ctrl.add_child(btn_role)

		# ── Colonne droite : badge de la touche assignée ───────────────────────
		var btn_touche := Button.new()
		btn_touche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_touche.add_theme_color_override("font_color",        Color(0.48, 0.87, 0.48))
		btn_touche.add_theme_color_override("font_hover_color",  Color(0.70, 1.00, 0.70))
		btn_touche.add_theme_color_override("font_pressed_color",Color(1.00, 0.88, 0.40))

		# Style normal : badge vert sombre
		var style_n := StyleBoxFlat.new()
		style_n.bg_color     = Color(0.10, 0.18, 0.10, 1.0)
		style_n.border_color = Color(0.30, 0.50, 0.30, 1.0)
		style_n.set_border_width_all(1)
		style_n.set_corner_radius_all(7)
		style_n.content_margin_left   = 12
		style_n.content_margin_right  = 12
		style_n.content_margin_top    = 8
		style_n.content_margin_bottom = 8
		btn_touche.add_theme_stylebox_override("normal", style_n)

		# Style hover
		var style_h := style_n.duplicate() as StyleBoxFlat
		style_h.bg_color     = Color(0.16, 0.28, 0.16, 1.0)
		style_h.border_color = Color(0.42, 0.68, 0.42, 1.0)
		btn_touche.add_theme_stylebox_override("hover", style_h)

		grille_ctrl.add_child(btn_touche)
		_btns_touche[action_id] = btn_touche

		# Connecter le clic pour démarrer l'écoute
		btn_touche.pressed.connect(func(): _attendre_touche(action_id))
		if son_clic:
			btn_touche.pressed.connect(son_clic.play)

	# Afficher les touches initiales
	_maj_labels_ctrl()

# ── Menu ──────────────────────────────────────────────────────────────────────
func _on_jouer() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/gameplay/level.tscn"))

func _on_ouvrir_param() -> void:
	if not panneau_param: return
	panneau_param.visible  = true
	panneau_param.modulate = Color(1, 1, 1, 0)
	panneau_param.scale    = Vector2(0.94, 0.94)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panneau_param, "modulate:a", 1.0, 0.20)
	tw.parallel().tween_property(panneau_param, "scale", Vector2(1.0, 1.0), 0.22)

func _on_fermer_param() -> void:
	if not panneau_param: return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(panneau_param, "modulate:a", 0.0, 0.16)
	tw.tween_callback(func(): panneau_param.visible = false)

# ── Langue ────────────────────────────────────────────────────────────────────
func _set_langue(code: String) -> void:
	TranslationServer.set_locale(code)

# ── Audio ─────────────────────────────────────────────────────────────────────
func _on_mus_change(v: float) -> void:
	if lbl_mus:
		lbl_mus.text = "%d%%" % int(v * 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))

func _on_sfx_change(v: float) -> void:
	if lbl_sfx:
		lbl_sfx.text = "%d%%" % int(v * 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))

# ── Rebinding ─────────────────────────────────────────────────────────────────
func _attendre_touche(action: String) -> void:
	_action_en_attente = action
	if lbl_ecoute:
		lbl_ecoute.visible = true
	_maj_badge_ecoute(action, true)
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if _action_en_attente.is_empty(): return
	if event is InputEventKey and event.pressed and not event.echo:
		InputMap.action_erase_events(_action_en_attente)
		InputMap.action_add_event(_action_en_attente, event)
		_maj_badge_ecoute(_action_en_attente, false)
		_maj_labels_ctrl()
		_action_en_attente = ""
		if lbl_ecoute:
			lbl_ecoute.visible = false
		set_process_unhandled_input(false)
		get_viewport().set_input_as_handled()

func _maj_badge_ecoute(action: String, en_ecoute: bool) -> void:
	if not _btns_touche.has(action): return
	var btn : Button = _btns_touche[action]
	if en_ecoute:
		btn.text = "[  …  ]"
		btn.add_theme_color_override("font_color", Color(0.88, 0.63, 0.15))
		var style_l := StyleBoxFlat.new()
		style_l.bg_color     = Color(0.18, 0.14, 0.06, 1.0)
		style_l.border_color = Color(0.70, 0.50, 0.10, 1.0)
		style_l.set_border_width_all(1)
		style_l.set_corner_radius_all(7)
		style_l.content_margin_left   = 12
		style_l.content_margin_right  = 12
		style_l.content_margin_top    = 8
		style_l.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", style_l)
	else:
		btn.add_theme_color_override("font_color", Color(0.48, 0.87, 0.48))
		var style_n := StyleBoxFlat.new()
		style_n.bg_color     = Color(0.10, 0.18, 0.10, 1.0)
		style_n.border_color = Color(0.30, 0.50, 0.30, 1.0)
		style_n.set_border_width_all(1)
		style_n.set_corner_radius_all(7)
		style_n.content_margin_left   = 12
		style_n.content_margin_right  = 12
		style_n.content_margin_top    = 8
		style_n.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", style_n)

func _maj_labels_ctrl() -> void:
	for entree in ACTIONS:
		var action_id : String = entree[0]
		if not _btns_touche.has(action_id): continue
		var btn : Button = _btns_touche[action_id]
		var key : String = "?"
		if InputMap.has_action(action_id):
			for ev in InputMap.action_get_events(action_id):
				if ev is InputEventKey:
					key = OS.get_keycode_string(ev.physical_keycode)
					break
		btn.text = "[ %s ]" % key
