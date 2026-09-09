extends Node
# ============================================================
# DialogueManager — Singleton (Autoload)
# Chemin : res://autoload/dialogue_manager.gd
# À déclarer dans Projet > Paramètres du projet > Autoloads
#   Nom : DialogueManager   Chemin : res://autoload/dialogue_manager.gd
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
## Retourne true si le dialogue a bien démarré, false s'il a été ignoré
## (aucune boîte enregistrée, ou dialogue déjà en cours).
func lancer(lignes: Array, id: String = "") -> bool:
	if not is_instance_valid(_boite):
		push_warning("DialogueManager : aucune DialogueBox enregistrée dans la scène.")
		return false
	if en_cours:
		# Empêche deux dialogues de se lancer simultanément (ex : double
		# interaction, spam de la touche, deux PNJ déclenchés en même temps).
		push_warning("DialogueManager : dialogue déjà en cours, requête ignorée (id=\"%s\")." % id)
		return false
	en_cours = true
	_boite.demarrer(lignes, id)
	return true

## Appelé par DialogueBox quand toutes les lignes sont lues, ou que le
## joueur a quitté le dialogue (Échap).
func finir(id: String) -> void:
	en_cours = false
	dialogue_termine.emit(id)

# Alias conservé pour compatibilité si d'autres scripts appelaient
# encore l'ancien nom.
func _on_dialogue_fini(id: String) -> void:
	finir(id)
