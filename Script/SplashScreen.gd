extends CanvasLayer

var next_scene: String = "res://MainMenu.tscn"
var progress: float = 0.0
var load_speed: float = 0.4  # ⏱️ changez ici pour ralentir

@onready var logo = $Control/TextureRect
@onready var bar = $Control/ProgressBar
@onready var label = $Control/Label

func _ready():
	logo.modulate.a = 0.0
	
	# Taille et position du logo
	logo.custom_minimum_size = Vector2(400, 400)
	logo.size = Vector2(400, 400)
	logo.position = Vector2(
		get_viewport().size.x / 2 - 200,
		get_viewport().size.y / 2 - 250
	)
	
	# Position de la barre en bas
	bar.size = Vector2(400, 20)
	bar.position = Vector2(
		get_viewport().size.x / 2 - 200,
		get_viewport().size.y - 100
	)
	
	# Position du label sous la barre
	label.position = Vector2(
		get_viewport().size.x / 2 - 100,
		get_viewport().size.y - 70
	)
	
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 0
	label.text = "Initialisation..."

func _process(delta):
	# Fondu lent du logo
	if logo.modulate.a < 1.0:
		logo.modulate.a = min(logo.modulate.a + delta * 0.5, 1.0)
	
	# Progression de la barre
	progress += delta * load_speed * 10
	bar.value = clamp(progress, 0, 100)
	
	# Messages dynamiques
	if progress < 30:
		label.text = "Initialisation..."
	elif progress < 60:
		label.text = "Chargement des assets..."
	elif progress < 90:
		label.text = "Préparation du jeu..."
	elif progress < 100:
		label.text = "Presque prêt..."
	
	# Changer de scène uniquement quand tout est fini
	if progress >= 100 and logo.modulate.a >= 1.0:
		get_tree().change_scene_to_file(next_scene)
