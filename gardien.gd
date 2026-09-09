extends CharacterBody2D
# ============================================================
# gardien.gd — PNJ Gardien du Parc National
# Chemin : res://gardien.gd
# Scène  : res://gardien.tscn
#
# AMÉLIORATIONS de cette version :
#   1. Le gardien marque une courte pause (regard idle) à chaque
#      extrémité de sa patrouille au lieu de faire demi-tour
#      instantanément → mouvement plus naturel.
#   2. La recherche de la porte à ouvrir est robuste : le gardien
#      cherche d'abord toute porte enregistrée dans le groupe
#      "porte_parc" (peu importe sa place dans l'arbre de scène),
#      puis retente l'ancienne méthode (nœud frère "PorteEntree")
#      en repli.
#   3. Nouveau signal `acces_parc_accorde` : le niveau (level.gd)
#      peut s'y connecter proprement au lieu de dépendre de
#      chemins de nœuds fragiles.
#
# Le personnage utilise un AnimatedSprite2D (GardienDessin) avec une
# animation "idle" et "marche" définies dans gardien_frames.tres.
# Il se tourne vers le joueur (flip_h) lors de l'interaction.
# ============================================================

signal acces_parc_accorde

@export var dialogue_id: String      = "gardien_entree"
@export var acces_deja_accorde: bool = false

@export_group("Patrouille")
@export var distance_patrouille: float = 70.0   # amplitude du trajet (px) de chaque côté du point de départ
@export var vitesse_patrouille:  float = 22.0    # px/sec
@export var pause_extremite:     float = 1.4     # secondes d'arrêt à chaque bout du trajet

@onready var zone_detect:     Area2D          = $ZoneDetection
@onready var label_interagir: Label           = $LabelInteragir
@onready var dessin:          AnimatedSprite2D = $GardienDessin

var joueur_dans_zone: bool = false
var dialogue_joue:    bool = false
var direction:        String = "down"   # pour orienter le sprite (flip_h)

var _pos_depart_x:    float = 0.0
var _sens_patrouille: int   = 1   # 1 = vers la droite, -1 = vers la gauche
var _pause_restante:  float = 0.0

# ── Lignes de dialogue ──────────────────────────────────────
var _lignes_dialogue: Array = [
	{ "locuteur": "Gardien",
	  "texte": "Manahoana ! Bienvenue aux abords du Parc National de Madagascar." },
	{ "locuteur": "Gardien",
	  "texte": "Je suis Rakotondrabe, gardien de cette entrée depuis quinze ans. Ce parc est un trésor vivant — l'un des derniers refuges de centaines d'espèces endémiques." },
	{ "locuteur": "Gardien",
	  "texte": "Ici vivent des lémuriens, des orchidées sauvages, des caméléons... des créatures que l'on ne trouve nulle part ailleurs sur Terre." },
	{ "locuteur": "Gardien",
	  "texte": "Respectez la faune et la flore. Ne cueillez rien, ne laissez aucun déchet. Chaque espèce que vous découvrirez compte pour la biodiversité de notre île." },
	{ "locuteur": "Vous",
	  "texte": "Je comprends. Je viens étudier et recenser les espèces du parc." },
	{ "locuteur": "Gardien",
	  "texte": "Parfait ! Vous êtes le bienvenu. Je vais ouvrir la porte pour vous. Bonne exploration !" },
	{ "locuteur": "Gardien",
	  "texte": "Mazotoa ! Bon courage !" },
]

# ════════════════════════════════════════════════════════════

func _ready() -> void:
	label_interagir.hide()
	dessin.play("idle")
	_pos_depart_x = global_position.x

	if acces_deja_accorde:
		dialogue_joue = true
		_recuperer_et_ouvrir_porte()

	zone_detect.body_entered.connect(_on_joueur_entre)
	zone_detect.body_exited.connect(_on_joueur_sort)
	DialogueManager.dialogue_termine.connect(_on_dialogue_termine)

# ── Patrouille gauche/droite avec pause naturelle aux extrémités ─

func _physics_process(delta: float) -> void:
	# Le gardien s'arrête pendant le dialogue ou quand le joueur est dans sa zone
	if dialogue_joue and DialogueManager.en_cours or joueur_dans_zone:
		velocity = Vector2.ZERO
		move_and_slide()
		if dessin.animation != "idle":
			dessin.play("idle")
		return

	# Pause en bout de patrouille : le gardien observe les alentours
	# quelques instants avant de repartir dans l'autre sens.
	if _pause_restante > 0.0:
		_pause_restante -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		if dessin.animation != "idle":
			dessin.play("idle")
		return

	if dessin.animation != "marche":
		dessin.play("marche")

	velocity = Vector2(_sens_patrouille * vitesse_patrouille, 0)
	move_and_slide()

	dessin.flip_h = _sens_patrouille < 0

	if global_position.x >= _pos_depart_x + distance_patrouille:
		_sens_patrouille = -1
		_pause_restante  = pause_extremite
	elif global_position.x <= _pos_depart_x - distance_patrouille:
		_sens_patrouille = 1
		_pause_restante  = pause_extremite

func _unhandled_input(event: InputEvent) -> void:
	if joueur_dans_zone and not dialogue_joue and not DialogueManager.en_cours:
		if event.is_action_pressed("interagir"):
			get_viewport().set_input_as_handled()
			_demarrer_dialogue()

# ── Zone de détection ────────────────────────────────────────

func _on_joueur_entre(body: Node2D) -> void:
	if body.name != "player":
		return
	joueur_dans_zone = true
	direction = "down"
	# Le gardien se tourne vers le joueur (miroir horizontal du sprite)
	dessin.flip_h = body.global_position.x < global_position.x
	if not dialogue_joue:
		label_interagir.show()
		await get_tree().create_timer(0.4).timeout
		if joueur_dans_zone and not dialogue_joue and not DialogueManager.en_cours:
			_demarrer_dialogue()

func _on_joueur_sort(body: Node2D) -> void:
	if body.name != "player":
		return
	joueur_dans_zone = false
	label_interagir.hide()

# ── Dialogue ────────────────────────────────────────────────

func _demarrer_dialogue() -> void:
	dialogue_joue = true
	label_interagir.hide()
	DialogueManager.lancer(_lignes_dialogue, dialogue_id)

func _on_dialogue_termine(id: String) -> void:
	if id != dialogue_id:
		return
	acces_deja_accorde = true
	_recuperer_et_ouvrir_porte()

func _recuperer_et_ouvrir_porte() -> void:
	acces_parc_accorde.emit()

	# Méthode robuste : toute porte enregistrée dans le groupe "porte_parc"
	# (voir porte_entree.gd), quel que soit son emplacement dans l'arbre.
	var portes: Array = get_tree().get_nodes_in_group("porte_parc")

	# Repli : ancienne méthode par nom de nœud frère, au cas où la porte
	# ne serait pas (encore) enregistrée dans le groupe.
	if portes.is_empty():
		var porte := get_parent().get_node_or_null("PorteEntree")
		if porte:
			portes = [porte]

	if portes.is_empty():
		push_warning("gardien.gd : aucune PorteEntree trouvée à ouvrir.")
		return

	for porte in portes:
		if porte.has_method("ouvrir"):
			porte.ouvrir()
		else:
			var c: Node = porte.get_node_or_null("StaticBody2D/CollisionShape2D")
			if c:
				c.set_deferred("disabled", true)
			var tw := create_tween()
			tw.tween_property(porte, "modulate:a", 0.0, 0.5)
