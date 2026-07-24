extends Area2D

# La case pour glisser ton fichier .tres (Manguier, Orchidée, etc.)
@export var data: ItemData 

var joueur_proche = false

func _ready():
	# On branche les signaux automatiquement au démarrage
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player":
		joueur_proche = true

func _on_body_exited(_body):
	joueur_proche = false

func _input(event):
	# TOUCHE Z (ui_up) : Pour scanner la plante et l'ajouter au Pokédex
	if joueur_proche and event.is_action_pressed("ui_up"):
		scanner_la_plante()

func scanner_la_plante():
	if data:
		# 1. Garde ta ligne actuelle (pour l'inventaire/Pokédex)
		ScanGlobal.decouvrir_plante(data.id)
		
		# 2. AJOUTE CETTE LIGNE (pour la Popup)
		# On appelle la fonction qui va chercher PopupFl et afficher le texte
		ScanGlobal.scan_reussi(data)
		
		print("Plante ajoutée au Pokédex : ", data.nom_affiche)
		
		# 3. LE BONUS : Faire disparaître la fleur avec style
		# Au lieu de queue_free() direct, on la fait disparaître doucement
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.3) # Devient transparente
		tween.tween_callback(queue_free) # Puis s'efface de la mémoire
	else:
		print("Erreur : Fichier .tres manquant dans l'inspecteur !")
