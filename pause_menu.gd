extends CanvasLayer

signal reprendre_jeu
signal quitter_menu_principal

# ── Profil joueur (réutilise la même scène que le HUD en jeu) ──
const HUD_PROFIL_SCENE := preload("res://hud_profil.tscn")
var _hud_profil_pause: Control = null

# ── Touches par défaut ────────────────────────────────────────
const DEFAUTS := {
	"move_up":    KEY_UP,
	"move_down":  KEY_DOWN,
	"move_left":  KEY_LEFT,
	"move_right": KEY_RIGHT,
	"interact":   KEY_E,
}
const SAVE_PATH := "user://parametres.cfg"

var est_en_pause: bool = false
var _action_en_ecoute: String = ""
var _bouton_en_ecoute: Button = null

# ── Panneau Pause ─────────────────────────────────────────────
@onready var panneau_pause      = $PanneauPause
@onready var btn_reprendre      = $PanneauPause/VBoxContainer/MarginContainer/BoutonsBox/BoutonReprendre
@onready var btn_recommencer    = $PanneauPause/VBoxContainer/MarginContainer/BoutonsBox/BoutonRecommencer
@onready var btn_parametres     = $PanneauPause/VBoxContainer/MarginContainer/BoutonsBox/BoutonParametres
@onready var btn_menu_principal = $PanneauPause/VBoxContainer/MarginContainer/BoutonsBox/BoutonMenuPrincipal
@onready var fond_assombri      = $FondAssombri

# ── Panneau Paramètres ────────────────────────────────────────
@onready var panneau_parametres  = $PanneauParametres
@onready var btn_fermer_param    = $PanneauParametres/Margin/VBox/HeaderRow/BtnFermer

# Audio
@onready var slider_musique      = $PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/SliderMusique
@onready var label_val_musique   = $PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/RowMus/LabelValMusique
@onready var slider_sons         = $PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/SliderSons
@onready var label_val_sons      = $PanneauParametres/Margin/VBox/SectionAudio/MarginAudio/ColAudio/RowSons/LabelValSons

# Langue
@onready var btn_francais        = $PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnFrancais
@onready var btn_malagasy        = $PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnMalagasy
@onready var btn_anglais         = $PanneauParametres/Margin/VBox/SectionLangue/MarginLangue/ColLangue/RowLangBtns/BtnAnglais

# Contrôles
@onready var label_ecoute        = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/LabelEcoute
@onready var btn_haut            = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowHaut/BtnHaut
@onready var btn_bas             = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowBas/BtnBas
@onready var btn_gauche          = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowGauche/BtnGauche
@onready var btn_droite          = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowDroite/BtnDroite
@onready var btn_interagir       = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowInteragir/BtnInteragir
@onready var btn_par_defaut      = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowActions/BtnParDefaut
@onready var btn_enregistrer     = $PanneauParametres/Margin/VBox/SectionControles/MarginCtrl/ColCtrl/RowActions/BtnEnregistrer

# ═════════════════════════════════════════════════════════════
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panneau_pause.hide()
	fond_assombri.hide()
	panneau_parametres.hide()

	# Ajoute le profil joueur (avatar + score) en haut du panneau pause
	_hud_profil_pause = HUD_PROFIL_SCENE.instantiate()
	_hud_profil_pause.permettre_renommage = true
	panneau_pause.add_child(_hud_profil_pause)
	panneau_pause.move_child(_hud_profil_pause, 0)
	# On le positionne en haut, centré, au lieu du coin écran (contexte menu)
	_hud_profil_pause.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_hud_profil_pause.position.y = 16

	# Chargement des paramètres sauvegardés
	_charger_parametres()

	# Boutons pause
	btn_reprendre.pressed.connect(_sur_reprendre)
	btn_recommencer.pressed.connect(_sur_recommencer)
	btn_parametres.pressed.connect(_sur_parametres)
	btn_menu_principal.pressed.connect(_sur_quitter_menu)
	btn_fermer_param.pressed.connect(_fermer_parametres)

	# Audio
	slider_musique.value_changed.connect(_sur_musique_change)
	slider_sons.value_changed.connect(_sur_sons_change)

	# Langue
	btn_francais.pressed.connect(func(): _changer_langue("fr"))
	btn_malagasy.pressed.connect(func(): _changer_langue("mg"))
	btn_anglais.pressed.connect(func(): _changer_langue("en"))

	# Contrôles — rebinding
	btn_haut.pressed.connect(func(): _ecouter_touche("move_up", btn_haut))
	btn_bas.pressed.connect(func(): _ecouter_touche("move_down", btn_bas))
	btn_gauche.pressed.connect(func(): _ecouter_touche("move_left", btn_gauche))
	btn_droite.pressed.connect(func(): _ecouter_touche("move_right", btn_droite))
	btn_interagir.pressed.connect(func(): _ecouter_touche("interact", btn_interagir))

	# Boutons Par défaut / Enregistrer
	btn_par_defaut.pressed.connect(_sur_par_defaut)
	btn_enregistrer.pressed.connect(_sur_enregistrer)

	_rafraichir_labels_controles()

# ═════════════════════════════════════════════════════════════
# INPUT
# ═════════════════════════════════════════════════════════════
func _input(event: InputEvent) -> void:
	# Mode écoute clavier pour rebinding — UNIQUEMENT quand le panneau est affiché
	if _action_en_ecoute != "" and panneau_parametres.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			# Échap annule sans changer la touche
			if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
				_annuler_ecoute()
			else:
				_appliquer_touche(_action_en_ecoute, event)
			get_viewport().set_input_as_handled()
			return
		# Bloquer aussi la souris/manette pendant l'écoute
		if event is InputEventKey:
			get_viewport().set_input_as_handled()
			return

	# Hors mode écoute : gérer Échap pour pause/fermer
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if panneau_parametres.visible:
			_fermer_parametres()
		else:
			basculer_pause()
		get_viewport().set_input_as_handled()

# ═════════════════════════════════════════════════════════════
# PAUSE
# ═════════════════════════════════════════════════════════════
func basculer_pause() -> void:
	if est_en_pause:
		_reprendre()
	else:
		_mettre_en_pause()

func _mettre_en_pause() -> void:
	est_en_pause = true
	get_tree().paused = true
	fond_assombri.show()
	panneau_pause.show()
	btn_reprendre.grab_focus()

func _reprendre() -> void:
	est_en_pause = false
	panneau_pause.hide()
	panneau_parametres.hide()
	fond_assombri.hide()
	get_tree().paused = false
	emit_signal("reprendre_jeu")

func _sur_reprendre() -> void:
	_reprendre()

func _sur_recommencer() -> void:
	get_tree().paused = false
	est_en_pause = false
	get_tree().change_scene_to_file("res://level.tscn")

func _sur_parametres() -> void:
	panneau_pause.hide()
	panneau_parametres.show()

func _fermer_parametres() -> void:
	_annuler_ecoute()
	panneau_parametres.hide()
	panneau_pause.show()
	btn_reprendre.grab_focus()

func _sur_quitter_menu() -> void:
	get_tree().paused = false
	est_en_pause = false
	emit_signal("quitter_menu_principal")
	get_tree().change_scene_to_file("res://main_menu.tscn")

# ═════════════════════════════════════════════════════════════
# AUDIO
# ═════════════════════════════════════════════════════════════
func _sur_musique_change(valeur: float) -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(valeur))
	label_val_musique.text = str(int(valeur * 100)) + "%"

func _sur_sons_change(valeur: float) -> void:
	var bus := AudioServer.get_bus_index("SFX")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(valeur))
	label_val_sons.text = str(int(valeur * 100)) + "%"

# ═════════════════════════════════════════════════════════════
# LANGUE
# ═════════════════════════════════════════════════════════════
func _changer_langue(locale: String) -> void:
	TranslationServer.set_locale(locale)

# ═════════════════════════════════════════════════════════════
# CONTRÔLES — REBINDING
# ═════════════════════════════════════════════════════════════
func _ecouter_touche(action: String, bouton: Button) -> void:
	# Annule l'écoute précédente si besoin
	if _bouton_en_ecoute != null:
		_bouton_en_ecoute.text = _nom_touche(_action_en_ecoute)
	_action_en_ecoute = action
	_bouton_en_ecoute = bouton
	label_ecoute.show()
	bouton.text = "..."

func _annuler_ecoute() -> void:
	_action_en_ecoute = ""
	_bouton_en_ecoute = null
	label_ecoute.hide()
	_rafraichir_labels_controles()

func _appliquer_touche(action: String, event: InputEventKey) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_action_en_ecoute = ""
	_bouton_en_ecoute = null
	label_ecoute.hide()
	_rafraichir_labels_controles()

func _rafraichir_labels_controles() -> void:
	btn_haut.text      = _nom_touche("move_up")
	btn_bas.text       = _nom_touche("move_down")
	btn_gauche.text    = _nom_touche("move_left")
	btn_droite.text    = _nom_touche("move_right")
	btn_interagir.text = _nom_touche("interact")

func _nom_touche(action: String) -> String:
	if not InputMap.has_action(action):
		return "?"
	var events := InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey:
			return e.as_text_physical_keycode()
	return "?"

# ── Par défaut ────────────────────────────────────────────────
func _sur_par_defaut() -> void:
	_annuler_ecoute()
	for action in DEFAUTS:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			var ev := InputEventKey.new()
			ev.physical_keycode = DEFAUTS[action]
			InputMap.action_add_event(action, ev)
	# Audio par défaut
	slider_musique.value = 0.8
	slider_sons.value    = 1.0
	_rafraichir_labels_controles()
	_feedback_bouton(btn_par_defaut, "✔ Réinitialisé")

# ── Enregistrer ───────────────────────────────────────────────
func _sur_enregistrer() -> void:
	_annuler_ecoute()
	var cfg := ConfigFile.new()

	# Audio
	cfg.set_value("audio", "musique", slider_musique.value)
	cfg.set_value("audio", "sons",    slider_sons.value)

	# Langue
	cfg.set_value("langue", "locale", TranslationServer.get_locale())

	# Contrôles
	for action in DEFAUTS:
		cfg.set_value("controles", action, _nom_touche(action))

	var err := cfg.save(SAVE_PATH)
	if err == OK:
		_feedback_bouton(btn_enregistrer, "✔ Sauvegardé !")
	else:
		_feedback_bouton(btn_enregistrer, "✖ Erreur")

# ── Charger au démarrage ──────────────────────────────────────
func _charger_parametres() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return  # Pas encore de fichier, valeurs par défaut du .tscn

	# Audio
	var vol_mus : float = cfg.get_value("audio", "musique", 0.8)
	var vol_son : float = cfg.get_value("audio", "sons",    1.0)
	slider_musique.value = vol_mus
	slider_sons.value    = vol_son
	_sur_musique_change(vol_mus)
	_sur_sons_change(vol_son)

	# Langue
	var locale : String = cfg.get_value("langue", "locale", "fr")
	TranslationServer.set_locale(locale)

	# Contrôles — on mappe le nom de touche vers InputEventKey
	for action in DEFAUTS:
		var nom : String = cfg.get_value("controles", action, "")
		if nom == "":
			continue
		# Cherche le keycode par nom
		var kc := OS.find_keycode_from_string(nom)
		if kc == KEY_NONE:
			continue
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			var ev := InputEventKey.new()
			ev.physical_keycode = kc
			InputMap.action_add_event(action, ev)

# ── Feedback visuel temporaire sur un bouton ──────────────────
func _feedback_bouton(bouton: Button, texte: String) -> void:
	var texte_original := bouton.text
	bouton.text = texte
	bouton.disabled = true
	await get_tree().create_timer(1.5).timeout
	bouton.text = texte_original
	bouton.disabled = false
