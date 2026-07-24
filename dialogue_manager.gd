extends Node
# ============================================================
# DialogueManager — Singleton (Autoload)
# Chemin : res://dialogue_manager.gd
# À déclarer dans Projet > Paramètres du projet > Autoloads
#   Nom : DialogueManager   Chemin : res://dialogue_manager.gd
#
# Gère le déclenchement et la fermeture des dialogues dans
# tout le projet. Les scènes de dialogue s'enregistrent ici
# via register_box() au moment de leur _ready().
# ============================================================

# Signal émis quand un dialogue vient de se terminer.
# Paramètre : id (String) identifiant du dialogue terminé.
signal dialogue_termine(id: String)

# Référence à la boîte de dialogue active dans la scène
var _boite: Node = null

# Indique si un dialogue est actuellement en cours
var en_cours: bool = false

# ── API publique ─────────────────────────────────────────────

## Appelé par DialogueBox._ready() pour s'enregistrer.
func register_box(boite: Node) -> void:
	_boite = boite

## Lance un dialogue. 
## lignes : Array[Dictionary] avec les clés :
##   "locuteur" : String  (nom affiché)
##   "texte"    : String  (corps du message)
## id : identifiant unique pour le signal dialogue_termine
func lancer(lignes: Array, id: String = "") -> void:
	if _boite == null:
		push_warning("DialogueManager : aucune DialogueBox enregistrée dans la scène.")
		return
	en_cours = true
	_boite.demarrer(lignes, id)

## Appelé par DialogueBox quand toutes les lignes sont lues.
func _on_dialogue_fini(id: String) -> void:
	en_cours = false
	dialogue_termine.emit(id)
