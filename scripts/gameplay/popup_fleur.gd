extends Panel

const VideoOverlayScene := preload("res://scenes/ui/video_overlay.tscn")

@onready var bouton_ferme: Button = $BoutonFerme
@onready var video_button: Button = $VBoxContainer/VideoButton

var _video_path: String = ""

func _ready():
	hide()
	# On s'assure que ce script RÉAGIT même pendant la pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connexion faite ici en code : plus fiable que la connexion dans l'éditeur
	# (évite les soucis de nom de méthode mal orthographié entre scène et script)
	if not bouton_ferme.pressed.is_connected(fermer_popup):
		bouton_ferme.pressed.connect(fermer_popup)
	if not video_button.pressed.is_connected(_on_video_button_pressed):
		video_button.pressed.connect(_on_video_button_pressed)

func _input(event):
	# Si la popup est visible ET qu'on appuie sur E (ou ta touche d'action)
	if is_visible_in_tree() and event.is_action_pressed("ui_accept"): 
		# "ui_accept" est souvent Entrée ou Espace par défaut. 
		# Si tu as créé une action "interagir", utilise son nom.
		get_viewport().set_input_as_handled()
		fermer_popup()
	elif is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
		# Échap ferme aussi la popup, et on consomme l'événement pour
		# qu'il ne remonte pas jusqu'au menu pause du jeu (sinon les deux
		# systèmes se marchent dessus sur le même get_tree().paused).
		get_viewport().set_input_as_handled()
		fermer_popup()

func afficher_decouverte(n, d, video_path: String = ""):
	$VBoxContainer/NomFleur.text = n
	$VBoxContainer/DescFleur.text = d

	_video_path = video_path
	video_button.visible = _video_path != ""

	show()
	get_tree().paused = true
	print("Popup ouverte. Appuie sur E (Entrée/Espace) pour fermer.")

# On crée une fonction commune pour le bouton ET la touche
func fermer_popup():
	hide()
	get_tree().paused = false
	print("Retour au jeu !")

# Si tu gardes quand même le bouton "X" à la souris :
func _on_bouton_fer_pressed():
	fermer_popup()

# Appelé quand le joueur clique sur "Voir la vidéo"
func _on_video_button_pressed():
	if _video_path == "":
		return
	var overlay = VideoOverlayScene.instantiate()
	get_tree().root.add_child(overlay)
	overlay.play(_video_path)
