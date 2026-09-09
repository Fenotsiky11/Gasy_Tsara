# --- À AJOUTER dans le script existant de ton InfoPanel ---
# (celui attaché à la scène qui affiche la description + le bouton X)

# 1. En haut du script, précharger la scène overlay :
const VIDEO_OVERLAY := preload("res://scenes/VideoOverlay.tscn")

# 2. Le champ video_path doit déjà exister sur ta ressource d'espèce
#    (celle qui contient le nom "Manguier sauvage" et la description).
#    Exemple si tu as une classe SpeciesData (Resource) :
#    @export var video_path: String = ""

# 3. Dans _ready() ou dans la fonction qui affiche une espèce (ex: show_species(data)) :
func show_species(data) -> void:
	$DescriptionLabel.text = data.description
	$SpeciesNameLabel.text = data.name

	# Affiche le bouton vidéo seulement si une vidéo est définie pour cette espèce
	$VideoButton.visible = data.video_path != ""
	current_video_path = data.video_path  # variable membre à ajouter en haut du script

# 4. Connecter le bouton (dans _ready(), une seule fois) :
func _ready() -> void:
	$VideoButton.pressed.connect(_on_video_button_pressed)

# 5. Fonction appelée au clic :
func _on_video_button_pressed() -> void:
	var overlay = VIDEO_OVERLAY.instantiate()
	get_tree().root.add_child(overlay)   # ou get_tree().current_scene.add_child(overlay)
	overlay.play(current_video_path)
