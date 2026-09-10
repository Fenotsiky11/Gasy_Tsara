extends Area2D

# La case pour glisser ton fichier .tres (Manguier, Orchidée, etc.)
@export var data: ItemData

var joueur_proche = false
var deja_scanne = false

func _ready():
	# On branche les signaux automatiquement au démarrage
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player":
		joueur_proche = true
		# Scan automatique dès que le joueur entre dans la zone.
		scanner_la_plante()

func _on_body_exited(_body):
	joueur_proche = false

func scanner_la_plante():
	# Empêche un double scan si le signal se déclenche plusieurs fois
	# pendant le court instant avant que la plante ne disparaisse.
	if deja_scanne:
		return

	if data:
		deja_scanne = true

		# 1. Garde ta ligne actuelle (pour l'inventaire/Pokédex)
		ScanGlobal.decouvrir_plante(data.id)

		# 2. Pour la Popup (nom + description + vidéo si dispo)
		ScanGlobal.scan_reussi(data)

		print("Plante ajoutée au Pokédex : ", data.nom_affiche)

		# 3. LE BONUS : Faire disparaître la fleur avec style
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.3) # Devient transparente
		tween.tween_callback(queue_free) # Puis s'efface de la mémoire
	else:
		print("Erreur : Fichier .tres manquant dans l'inspecteur !")
