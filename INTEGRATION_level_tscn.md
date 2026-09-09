# Instructions d'intégration dans level.tscn
# Ajoutez ces lignes à la fin de votre level.tscn existant,
# AVANT la ligne [connection ...] finale.

# ────────────────────────────────────────────────────────────
# 1. Références aux nouvelles scènes (à ajouter en tête de fichier
#    dans la section [ext_resource])
# ────────────────────────────────────────────────────────────

# [ext_resource type="PackedScene" path="res://dialogue_box.tscn" id="50_dlgbox"]
# [ext_resource type="PackedScene" path="res://gardien.tscn"      id="51_gardien"]
# [ext_resource type="PackedScene" path="res://porte_entree.tscn" id="52_porte"]
# [ext_resource type="PackedScene" path="res://maison_gardien.tscn" id="53_maison"]

# ────────────────────────────────────────────────────────────
# 2. Nœuds à ajouter dans la hiérarchie de level.tscn
#    (à coller avant [node name="PauseMenu" ...])
# ────────────────────────────────────────────────────────────

# DialogueBox — s'affiche par-dessus tout (CanvasLayer layer=10)
# [node name="DialogueBox" parent="." instance=ExtResource("50_dlgbox")]

# Grande porte d'entrée — positionnée devant le Parc National
# Ajustez position selon votre carte (devant la grande entrée visible)
# [node name="PorteEntree" parent="." instance=ExtResource("52_porte")]
# position = Vector2(400, 200)   ← à adapter à votre carte

# Gardien — juste devant la porte
# [node name="Gardien" parent="." instance=ExtResource("51_gardien")]
# position = Vector2(400, 280)   ← à adapter (légèrement en dessous de la porte)

# Maison du gardien — à droite de la porte
# [node name="MaisonGardien" parent="." instance=ExtResource("53_maison")]
# position = Vector2(520, 240)   ← à adapter

# ────────────────────────────────────────────────────────────
# 3. Autoload à déclarer dans Projet > Paramètres > Autoloads
# ────────────────────────────────────────────────────────────
# Nom    : DialogueManager
# Chemin : res://dialogue_manager.gd
# ✅ Activer
