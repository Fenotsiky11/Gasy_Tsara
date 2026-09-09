extends CharacterBody2D

@export var vitesse = 150.0
@export var distance_arrivee = 4.0  # distance en pixels considérée comme "arrivé"
var derniere_direction = "down"

# ── Déplacement à la souris ───────────────────────────────────────
var destination_clic: Vector2 = Vector2.ZERO
var en_marche_vers_clic: bool = false

@onready var anim = $AnimatedSprite2D

func _ready():
	# Enregistre ce joueur auprès du système de progression
	# pour que la minimap (et tout autre HUD) puisse suivre sa position.
	Progression.enregistrer_joueur(self)
	# Donne au profil une image fixe et propre du personnage
	# (une seule frame "idle_down", pas tout le spritesheet)
	Progression.definir_avatar_depuis_sprite(anim.sprite_frames, "idle_down")

func _unhandled_input(event: InputEvent) -> void:
	# Clic gauche sur la carte -> on définit une destination à atteindre
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		destination_clic = get_global_mouse_position()
		en_marche_vers_clic = true

func _physics_process(_delta):
	# 1. RÉCUPÉRER LA DIRECTION (Via les touches physiques configurées)
	# "gauche", "droite", "haut", "bas" correspondent aux actions de ton Input Map
	var direction = Input.get_vector("gauche", "droite", "haut", "bas")

	# 2. PRIORITÉ AU CLAVIER : si une touche est pressée, on annule la marche vers le clic
	if direction != Vector2.ZERO:
		en_marche_vers_clic = false
		velocity = direction * vitesse
		choisir_animation_marche(direction)
	elif en_marche_vers_clic:
		# 3. DÉPLACEMENT VERS LE POINT CLIQUÉ
		var vers_destination = destination_clic - global_position
		if vers_destination.length() <= distance_arrivee:
			en_marche_vers_clic = false
			velocity = Vector2.ZERO
			jouer_idle()
		else:
			var dir_clic = vers_destination.normalized()
			velocity = dir_clic * vitesse
			choisir_animation_marche(dir_clic)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, vitesse)
		jouer_idle()

	move_and_slide()

# --- GESTION DES ANIMATIONS ---

func choisir_animation_marche(dir):
	# On regarde si le mouvement est plus horizontal que vertical
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim.play("walk_right")
			derniere_direction = "right"
		else:
			anim.play("walk_left")
			derniere_direction = "left"
	else:
		if dir.y > 0:
			anim.play("walk_down")
			derniere_direction = "down"
		else:
			anim.play("walk_up")
			derniere_direction = "up"

func jouer_idle():
	# Joue l'animation d'attente selon la dernière direction regardée
	anim.play("idle_" + derniere_direction)
