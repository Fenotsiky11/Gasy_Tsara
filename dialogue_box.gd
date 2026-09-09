extends CanvasLayer
# ============================================================
# dialogue_box.gd — Boîte de dialogue RPG
# Chemin : res://dialogue_box.gd
# Scène  : res://dialogue_box.tscn
#
# Affiche les lignes de dialogue une par une avec effet
# machine-à-écrire. Le joueur avance avec [E] / Espace / Entrée.
# Se ferme automatiquement après la dernière ligne et avertit
# le DialogueManager via _on_dialogue_fini().
# ============================================================

# ── Nœuds internes (définis dans dialogue_box.tscn) ──────────
@onready var panneau:       PanelContainer = $Panneau
@onready var label_locuteur: Label         = $Panneau/VBox/LabelLocuteur
@onready var label_texte:    RichTextLabel = $Panneau/VBox/LabelTexte
@onready var indicateur:     Label         = $Panneau/VBox/Indicateur

# ── Paramètres ────────────────────────────────────────────────
## Vitesse de l'effet machine à écrire (secondes par caractère)
@export var vitesse_ecriture: float = 0.03

# ── État interne ──────────────────────────────────────────────
var _lignes:   Array  = []   # liste de dicts {locuteur, texte}
var _index:    int    = 0    # ligne en cours
var _id:       String = ""   # identifiant du dialogue
var _en_ecriture: bool = false  # vrai pendant l'effet type-writer

func _ready() -> void:
	# S'enregistre auprès du singleton
	DialogueManager.register_box(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	panneau.hide()
	# Empêche le joueur d'agir pendant le dialogue
	# (le panneau est caché au départ, rien n'est bloqué)

# ── API ───────────────────────────────────────────────────────

## Démarre la séquence de dialogue.
func demarrer(lignes: Array, id: String) -> void:
	_lignes = lignes
	_index  = 0
	_id     = id
	panneau.show()
	get_tree().paused = true
	_afficher_ligne_courante()

# ── Logique interne ───────────────────────────────────────────

func _afficher_ligne_courante() -> void:
	if _index >= _lignes.size():
		_fermer()
		return

	var ligne: Dictionary = _lignes[_index]
	label_locuteur.text   = ligne.get("locuteur", "")
	label_texte.text      = ""
	indicateur.visible    = false
	_en_ecriture          = true
	_ecrire_texte(ligne.get("texte", ""))

## Effet machine à écrire : affiche les caractères un à un.
func _ecrire_texte(texte: String) -> void:
	label_texte.text = ""
	for i in texte.length():
		label_texte.text += texte[i]
		await get_tree().create_timer(vitesse_ecriture).timeout
		# Si on a demandé à sauter pendant l'écriture, on sort
		if not _en_ecriture:
			label_texte.text = texte
			break
	_en_ecriture   = false
	indicateur.visible = true   # ► montrer "Appuie sur E"

## Avance au dialogue suivant ou ferme la boîte.
func _avancer() -> void:
	if _en_ecriture:
		# Premier appui → affiche tout le texte immédiatement
		_en_ecriture = false
		return
	_index += 1
	_afficher_ligne_courante()

func _fermer() -> void:
	panneau.hide()
	get_tree().paused = false
	DialogueManager._on_dialogue_fini(_id)

# ── Input ─────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not panneau.visible:
		return
	# Accepte E, Espace et Entrée (ui_accept couvre Espace + Entrée)
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interagir"):
		get_viewport().set_input_as_handled()
		_avancer()
