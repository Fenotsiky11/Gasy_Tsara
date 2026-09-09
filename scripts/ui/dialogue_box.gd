extends CanvasLayer
# ============================================================
# dialogue_box.gd — Boîte de dialogue RPG
# Chemin : res://scripts/ui/dialogue_box.gd
# Scène  : res://scenes/ui/dialogue_box.tscn
#
# Affiche les lignes de dialogue une par une avec effet
# machine-à-écrire (piloté par _process, compatible BBCode via
# RichTextLabel.visible_characters — pas de coroutines qui se
# chevauchent en cas de spam).
#
# Commandes :
#   Espace / Entrée / [E] / Clic gauche → avancer / tout afficher
#   Maintenir une de ces touches         → accélérer l'écriture
#   Échap                                → quitter le dialogue immédiatement
# ============================================================

# ── Nœuds internes (définis dans dialogue_box.tscn) ──────────
@onready var panneau:        PanelContainer = $Panneau
@onready var label_locuteur: Label          = $Panneau/VBox/LabelLocuteur
@onready var label_texte:    RichTextLabel  = $Panneau/VBox/LabelTexte
@onready var indicateur:     Label          = $Panneau/VBox/Indicateur

# ── Paramètres (réglables en Inspecteur, ou par un futur menu Options) ──
## Vitesse de l'effet machine à écrire (secondes par caractère).
@export var vitesse_ecriture: float = 0.03
## Facteur d'accélération quand la touche d'avancée est maintenue.
@export var multiplicateur_rapide: float = 6.0

# ── État interne ──────────────────────────────────────────────
var _lignes: Array = []       # liste de dicts {locuteur, texte}
var _index: int = 0           # ligne en cours
var _id: String = ""          # identifiant du dialogue

var _actif: bool = false      # un dialogue est-il en cours (protège contre le spam / relance)
var _typing: bool = false     # vrai pendant l'effet machine-à-écrire
var _texte_complet: String = ""
var _car_visible: int = 0
var _accum_ecriture: float = 0.0

var _tween_indicateur: Tween = null


func _ready() -> void:
	# S'enregistre auprès du singleton
	DialogueManager.register_box(self)
	# Permet au dialogue de continuer à fonctionner (input, timers, tween)
	# alors que get_tree().paused = true bloque le reste du jeu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	panneau.hide()


# ── API publique ─────────────────────────────────────────────

## Démarre la séquence de dialogue. Appelé par DialogueManager.lancer().
func demarrer(lignes: Array, id: String) -> void:
	if _actif:
		push_warning("DialogueBox : demarrer() appelé alors qu'un dialogue est déjà en cours, ignoré.")
		return
	if lignes.is_empty():
		push_warning("DialogueBox : tentative de démarrer un dialogue vide.")
		DialogueManager.finir(id)
		return

	_lignes = lignes
	_index = 0
	_id = id
	_actif = true

	panneau.show()
	get_tree().paused = true
	_afficher_ligne_courante()

## Ferme le dialogue immédiatement, quelle que soit la ligne en cours
## (utilisé par Échap). Sans danger si aucun dialogue n'est actif.
func quitter_immediatement() -> void:
	if not _actif:
		return
	_fermer()


# ── Logique interne ───────────────────────────────────────────

func _afficher_ligne_courante() -> void:
	if _index >= _lignes.size():
		_fermer()
		return

	var ligne: Dictionary = _lignes[_index]
	label_locuteur.text = str(ligne.get("locuteur", ""))

	_texte_complet = str(ligne.get("texte", ""))
	label_texte.text = _texte_complet          # texte complet posé une fois
	label_texte.visible_characters = 0         # ... mais rien n'est visible au départ
	_car_visible = 0
	_accum_ecriture = 0.0
	_typing = true

	indicateur.visible = false
	_arreter_anim_indicateur()

func _process(delta: float) -> void:
	if not _actif or not _typing:
		return

	var vitesse: float = max(vitesse_ecriture, 0.0001)
	if _touche_rapide_maintenue():
		vitesse /= max(multiplicateur_rapide, 1.0)

	var total := _texte_complet.length()
	_accum_ecriture += delta
	while _accum_ecriture >= vitesse and _car_visible < total:
		_car_visible += 1
		_accum_ecriture -= vitesse

	label_texte.visible_characters = _car_visible

	if _car_visible >= total:
		_terminer_ecriture()

## Vrai si une touche d'avancée (E / ui_accept) est maintenue, OU si une
## action dédiée "dialogue_rapide" a été ajoutée au projet (facultatif :
## si tu ajoutes cette action dans Projet > Input Map, elle est détectée
## automatiquement sans autre modification de code).
func _touche_rapide_maintenue() -> bool:
	if InputMap.has_action("dialogue_rapide") and Input.is_action_pressed("dialogue_rapide"):
		return true
	if Input.is_action_pressed("ui_accept"):
		return true
	if InputMap.has_action("interagir") and Input.is_action_pressed("interagir"):
		return true
	return false

## Affiche instantanément le reste de la ligne en cours.
func _terminer_ecriture() -> void:
	_typing = false
	_car_visible = _texte_complet.length()
	label_texte.visible_characters = -1   # -1 = tout afficher
	indicateur.visible = true
	_lancer_anim_indicateur()

## Avance au dialogue suivant, ou ferme la boîte si c'était la dernière ligne.
func _avancer() -> void:
	if not _actif:
		return
	if _typing:
		# Premier appui pendant l'écriture → affiche tout le texte immédiatement
		_terminer_ecriture()
		return
	_index += 1
	_afficher_ligne_courante()

func _fermer() -> void:
	_actif = false
	_typing = false
	_arreter_anim_indicateur()
	panneau.hide()
	get_tree().paused = false

	var id_termine := _id
	_id = ""
	_lignes = []
	_index = 0

	DialogueManager.finir(id_termine)


# ── Petite animation du chevron "continuer" (facultatif, purement cosmétique) ──

func _lancer_anim_indicateur() -> void:
	_arreter_anim_indicateur()
	indicateur.position.y = 0.0
	_tween_indicateur = create_tween().set_loops()
	_tween_indicateur.tween_property(indicateur, "position:y", -4.0, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_indicateur.tween_property(indicateur, "position:y", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _arreter_anim_indicateur() -> void:
	if _tween_indicateur and _tween_indicateur.is_valid():
		_tween_indicateur.kill()
	indicateur.position.y = 0.0


# ── Input ─────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not _actif:
		return

	# Échap : quitte le dialogue immédiatement, quoi qu'il arrive.
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		quitter_immediatement()
		return

	var demande_avancer := false

	if event.is_action_pressed("ui_accept"):
		demande_avancer = true
	elif InputMap.has_action("interagir") and event.is_action_pressed("interagir"):
		demande_avancer = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		demande_avancer = true

	if demande_avancer:
		get_viewport().set_input_as_handled()
		_avancer()
