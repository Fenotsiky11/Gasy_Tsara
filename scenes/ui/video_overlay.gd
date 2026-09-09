extends CanvasLayer

@onready var lecteur: VideoStreamPlayer = $Fond/Lecteur
@onready var bouton_fermer: Button = $Fond/BoutonFermer


func _ready() -> void:
	# Doit continuer à fonctionner même si le jeu est en pause (popup fleur)
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not bouton_fermer.pressed.is_connected(fermer):
		bouton_fermer.pressed.connect(fermer)
	if not lecteur.finished.is_connected(fermer):
		lecteur.finished.connect(fermer)


# Charge et lance la vidéo à partir d'un chemin (ex: "res://Video/manguier_demo.ogv")
func play(video_path: String) -> void:
	if video_path == "":
		fermer()
		return

	var stream: VideoStream = load(video_path)
	if stream == null:
		push_warning("VideoOverlay: impossible de charger la vidéo : %s" % video_path)
		fermer()
		return

	lecteur.stream = stream
	lecteur.play()


func fermer() -> void:
	if lecteur.is_playing():
		lecteur.stop()
	queue_free()
