extends Node2D
# ============================================================
# LEVEL - RPG Exploration Biodiversité Madagascar
# ============================================================
# Gestion de la scène principale de jeu.
# Le menu pause est géré par pause_menu.tscn (instancié ici).
# Échap  → ouvre/ferme le menu pause (géré par PauseMenu)
#
# CORRECTIF de cette version :
#   Les anciennes références @onready $Gardien et $PorteEntree
#   provoquaient une erreur au lancement : le nœud du gardien
#   s'appelle "gardien" (minuscule) dans level.tscn, et aucun nœud
#   "PorteEntree" n'existait à la racine. On utilise maintenant
#   get_node_or_null() avec les noms réels, et surtout le nouveau
#   signal `acces_parc_accorde` émis par gardien.gd (voir
#   gardien.gd) pour ne plus dépendre d'un chemin de nœud fragile.
# ============================================================

@onready var pause_menu: Node = $PauseMenu
@onready var gardien:    Node = get_node_or_null("gardien")

func _ready() -> void:
	# Connexion : quand le dialogue du gardien se termine,
	# on peut éventuellement déclencher une logique niveau.
	DialogueManager.dialogue_termine.connect(_on_dialogue_termine)

	# Connexion directe au signal du gardien (plus robuste que de
	# chercher la porte par nom depuis level.gd).
	if gardien and gardien.has_signal("acces_parc_accorde"):
		gardien.acces_parc_accorde.connect(_on_acces_parc_accorde)

func _on_dialogue_termine(id: String) -> void:
	match id:
		"gardien_entree":
			# La porte est ouverte par le Gardien lui-même.
			# Ici on peut ajouter des logiques supplémentaires :
			# déverrouiller une zone sur la minimap, afficher
			# un message de bienvenue dans le parc, etc.
			print("[Level] Dialogue gardien terminé — accès parc accordé.")
		_:
			pass

func _on_acces_parc_accorde() -> void:
	# Ex. : déverrouiller une zone de la minimap, jouer un son,
	# afficher un message de bienvenue, sauvegarder la progression...
	print("[Level] Le gardien a autorisé l'accès au parc.")

func _process(_delta: float) -> void:
	pass
