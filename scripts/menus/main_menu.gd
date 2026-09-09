extends Control

# ============================================================
# MAIN MENU - Menu principal du jeu
# Gère : Jouer, Quitter, Paramètres, Langue, Audio
# Le menu PAUSE est géré par pause_menu.gd (dans pause_menu.tscn)
# ============================================================

@onready var btn_jouer         = $Centre/BtnJouer
@onready var btn_quitter       = $Centre/BtnQuitter
@onready var btn_parametres    = $BtnParametres
@onready var panneau_parametres = $PanneauParametres
@onready var btn_fermer        = $PanneauParametres/Margin/VBox/HeaderRow/BtnFermer
@onready var musique_menu      = $MusiqueMenu
@onready var son_clic          = $SonClic

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false

	btn_jouer.pressed.connect(_sur_jouer)
	btn_quitter.pressed.connect(_sur_quitter)
	btn_parametres.pressed.connect(_sur_parametres)
	btn_fermer.pressed.connect(_fermer_parametres)

func _sur_jouer() -> void:
	son_clic.play()
	get_tree().change_scene_to_file("res://scenes/gameplay/level.tscn")

func _sur_quitter() -> void:
	son_clic.play()
	get_tree().quit()

func _sur_parametres() -> void:
	son_clic.play()
	panneau_parametres.show()

func _fermer_parametres() -> void:
	son_clic.play()
	panneau_parametres.hide()
