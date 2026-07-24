extends PanelContainer
# ════════════════════════════════════════════════════════════════
# hud_profil.gd — Petit profil joueur (avatar + score), coin haut-gauche
# Réutilisable aussi dans le menu pause (même scène, instanciée 2x)
# ════════════════════════════════════════════════════════════════

# Active le bouton crayon ✎ pour renommer (à activer seulement
# sur l'instance utilisée dans le menu pause, pas celle du HUD en jeu)
@export var permettre_renommage: bool = false

@onready var avatar: TextureRect = $Marge/HBox/Avatar
@onready var label_nom: Label = $Marge/HBox/Infos/LigneNom/NomJoueur
@onready var label_score: Label = $Marge/HBox/Infos/Score
@onready var barre_progression: ProgressBar = $Marge/HBox/Infos/BarreProgression
@onready var btn_renommer: Button = $Marge/HBox/Infos/LigneNom/BtnRenommer
@onready var ligne_edition: LineEdit = $Marge/HBox/Infos/LigneNom/EditionNom

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rafraichir()
	Progression.score_change.connect(_sur_score_change)
	Progression.nom_joueur_change.connect(_sur_nom_change)
	Progression.avatar_change.connect(_sur_avatar_change)

	btn_renommer.visible = permettre_renommage
	ligne_edition.visible = false
	if permettre_renommage:
		btn_renommer.pressed.connect(_sur_clic_renommer)
		ligne_edition.text_submitted.connect(_sur_nom_valide)
		ligne_edition.focus_exited.connect(_sur_edition_terminee)

func _sur_avatar_change(nouvelle_texture: Texture2D) -> void:
	avatar.texture = nouvelle_texture

func _sur_clic_renommer() -> void:
	label_nom.visible = false
	btn_renommer.visible = false
	ligne_edition.visible = true
	ligne_edition.text = Progression.nom_joueur
	ligne_edition.grab_focus()
	ligne_edition.select_all()

func _sur_nom_valide(nouveau_texte: String) -> void:
	Progression.definir_nom(nouveau_texte)
	_fermer_edition()

func _sur_edition_terminee() -> void:
	# Si l'utilisateur clique ailleurs sans valider, on sauvegarde quand même
	if ligne_edition.visible:
		Progression.definir_nom(ligne_edition.text)
		_fermer_edition()

func _fermer_edition() -> void:
	ligne_edition.visible = false
	label_nom.visible = true
	btn_renommer.visible = true

func _sur_nom_change(nouveau_nom: String) -> void:
	label_nom.text = nouveau_nom

func _rafraichir() -> void:
	label_nom.text = Progression.nom_joueur
	var score := Progression.get_score()
	var total := Progression.get_total()
	label_score.text = "🌸 %d / %d espèces" % [score, total]
	barre_progression.max_value = total
	barre_progression.value = score
	if Progression.avatar_texture:
		avatar.texture = Progression.avatar_texture

func _sur_score_change(nouveau_score: int, total: int) -> void:
	label_score.text = "🌸 %d / %d espèces" % [nouveau_score, total]
	barre_progression.max_value = total
	barre_progression.value = nouveau_score
	# Petit effet de pop quand le score augmente
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
