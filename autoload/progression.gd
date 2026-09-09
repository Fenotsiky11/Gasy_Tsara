extends Node
# ════════════════════════════════════════════════════════════════
# AUTOLOAD "Progression"
# À ajouter dans Project > Project Settings > Autoload
# Nom : Progression   |   Chemin : res://autoload/progression.gd
# ════════════════════════════════════════════════════════════════

signal score_change(nouveau_score: int, total: int)
signal nom_joueur_change(nouveau_nom: String)
signal avatar_change(nouvelle_texture: Texture2D)

const SAVE_PATH_PROFIL := "user://profil_joueur.cfg"

# ── Données joueur ─────────────────────────────────────────────
var nom_joueur: String = "Voyageur"

# Avatar = une seule frame extraite du sprite du personnage
# (définie dynamiquement via definir_avatar_depuis_sprite, voir player.gd)
var avatar_texture: Texture2D = null

# ── Espèces découvertes ─────────────────────────────────────────
# Liste des IDs de fleurs/espèces déjà trouvées (évite les doublons)
var especes_decouvertes: Array[String] = []
var total_especes: int = 5  # Satrokala, manguier, angraecum, flamboyant, aloe_vaombe

# ── Référence joueur (pour la minimap) ──────────────────────────
var joueur_ref: Node2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_charger_profil()

# Appelée par player.gd au démarrage de chaque niveau pour s'enregistrer
func enregistrer_joueur(joueur: Node2D) -> void:
	joueur_ref = joueur

func get_position_joueur() -> Vector2:
	if joueur_ref:
		return joueur_ref.global_position
	return Vector2.ZERO

# ── Gestion de l'avatar ───────────────────────────────────────────
# Extrait UNE SEULE frame précise (ex: "idle_down", frame 0) depuis le
# SpriteFrames du joueur, pour avoir une image fixe et propre du
# personnage plutôt que le spritesheet complet.
func definir_avatar_depuis_sprite(sprite_frames: SpriteFrames, nom_animation: String, index_frame: int = 0) -> void:
	if sprite_frames == null:
		return
	if not sprite_frames.has_animation(nom_animation):
		return
	var nb_frames := sprite_frames.get_frame_count(nom_animation)
	if nb_frames == 0:
		return
	var frame_valide := clampi(index_frame, 0, nb_frames - 1)
	var texture := sprite_frames.get_frame_texture(nom_animation, frame_valide)
	if texture:
		avatar_texture = texture
		avatar_change.emit(avatar_texture)

# ── Gestion du nom ────────────────────────────────────────────────
func definir_nom(nouveau_nom: String) -> void:
	var nom_propre := nouveau_nom.strip_edges()
	if nom_propre == "":
		return
	nom_joueur = nom_propre
	nom_joueur_change.emit(nom_joueur)
	_sauvegarder_profil()

func _sauvegarder_profil() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("profil", "nom", nom_joueur)
	cfg.save(SAVE_PATH_PROFIL)

func _charger_profil() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH_PROFIL) != OK:
		return  # Pas encore de fichier, on garde "Voyageur"
	nom_joueur = cfg.get_value("profil", "nom", "Voyageur")

# ── Gestion du score ─────────────────────────────────────────────
# Appeler ceci depuis fleur.gd quand une fleur est découverte pour la 1ère fois
# Exemple à ajouter dans fleur.gd : Progression.decouvrir_espece(data.nom)
func decouvrir_espece(id_espece: String) -> void:
	if id_espece in especes_decouvertes:
		return  # déjà découverte, pas de doublon
	especes_decouvertes.append(id_espece)
	score_change.emit(especes_decouvertes.size(), total_especes)

func get_score() -> int:
	return especes_decouvertes.size()

func get_total() -> int:
	return total_especes
