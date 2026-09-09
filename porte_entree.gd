extends Node2D
# ============================================================
# porte_entree.gd — Grande porte d'entrée du Parc National
# Chemin : res://porte_entree.gd
# Scène  : res://porte_entree.tscn
#
# La porte est fermée par défaut.
# Elle s'ouvre via la méthode publique ouvrir() appelée
# par le Gardien une fois le dialogue terminé.
#
# AMÉLIORATIONS de cette version :
#   1. La porte s'enregistre dans le groupe "porte_parc" afin que
#      n'importe quel gardien (ou autre script) puisse la retrouver
#      facilement avec get_tree().get_nodes_in_group("porte_parc"),
#      sans dépendre d'un chemin de nœud fixe.
#   2. Une petite zone de détection affiche un message
#      "🔒 Parlez au gardien pour entrer" quand le joueur s'approche
#      alors que la porte est encore fermée — ça guide clairement le
#      joueur vers l'étape du dialogue avant d'explorer le parc.
# ============================================================

@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite:    Sprite2D         = $Sprite2D
@onready var zone_message: Area2D        = get_node_or_null("ZoneMessage")
@onready var label_message: Label        = get_node_or_null("ZoneMessage/LabelMessage")

# Durée de l'animation d'ouverture en secondes
const DUREE_OUVERTURE := 0.6

var _est_ouverte: bool = false

func _ready() -> void:
	add_to_group("porte_parc")

	# La porte commence fermée
	collision.disabled = false
	sprite.modulate    = Color.WHITE

	if label_message:
		label_message.hide()
	if zone_message:
		zone_message.body_entered.connect(_on_zone_message_entree)
		zone_message.body_exited.connect(_on_zone_message_sortie)

## Méthode publique appelée par gardien.gd
func ouvrir() -> void:
	if _est_ouverte:
		return
	_est_ouverte = true

	if label_message:
		label_message.hide()

	# Désactive la collision pour laisser passer le joueur
	collision.set_deferred("disabled", true)

	# Animation : glissement vers la gauche + légère transparence
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position:x", sprite.position.x - 80.0, DUREE_OUVERTURE) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.3, DUREE_OUVERTURE) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

## Referme la porte (utile pour reset de niveau)
func fermer() -> void:
	if not _est_ouverte:
		return
	_est_ouverte = false
	collision.set_deferred("disabled", false)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position:x", 0.0, DUREE_OUVERTURE) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, DUREE_OUVERTURE)

## Renvoie l'état actuel de la porte (utile pour d'autres scripts)
func est_ouverte() -> bool:
	return _est_ouverte

# ── Message d'invite "parlez au gardien" ─────────────────────

func _on_zone_message_entree(body: Node2D) -> void:
	if body.name != "player":
		return
	if not _est_ouverte and label_message:
		label_message.show()

func _on_zone_message_sortie(body: Node2D) -> void:
	if body.name != "player":
		return
	if label_message:
		label_message.hide()
