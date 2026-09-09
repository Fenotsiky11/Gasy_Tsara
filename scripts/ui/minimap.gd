extends Control
# ════════════════════════════════════════════════════════════════
# minimap.gd — Mini-carte qui suit le joueur en temps réel
# ════════════════════════════════════════════════════════════════
# Fonctionnement :
# - Un SubViewport contient une 2e caméra qui regarde la même "map"
#   que la caméra principale du joueur, mais dézoomée.
# - Cette caméra suit Progression.get_position_joueur() chaque frame.
# - Le SubViewport est affiché dans un TextureRect rond en haut à droite.
# - Un point fixe au centre représente le joueur (puisque la caméra
#   minimap est toujours centrée sur lui).
# ════════════════════════════════════════════════════════════════

@export var zoom_minimap: float = 0.15   # plus petit = vue plus large
@export var taille_minimap: int = 140    # diamètre en pixels à l'écran

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera_minimap: Camera2D = $SubViewportContainer/SubViewport/CameraMinimap
@onready var point_joueur: Control = $PointJoueur
@onready var nom_lieu: Label = $NomLieu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera_minimap.zoom = Vector2(zoom_minimap, zoom_minimap)
	sub_viewport.size = Vector2i(taille_minimap, taille_minimap)
	# CLÉ : on partage le même monde 2D que l'écran principal.
	# Ainsi la minimap affiche réellement ta carte (map, fleurs, joueur...)
	# sans qu'on ait besoin de la dupliquer.
	sub_viewport.world_2d = get_viewport().world_2d

func _process(_delta: float) -> void:
	# La caméra de la minimap suit toujours la position réelle du joueur
	camera_minimap.global_position = Progression.get_position_joueur()

# Permet d'afficher dynamiquement le nom du lieu où se trouve le joueur
# (appel optionnel depuis level.gd via une Area2D, par ex. quand on entre dans une zone)
func definir_nom_lieu(texte: String) -> void:
	nom_lieu.text = texte
