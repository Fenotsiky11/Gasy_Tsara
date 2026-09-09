# Installation du profil joueur + mini-carte

## 1. Copier les fichiers dans ton projet

Place ces fichiers à la **racine** de ton dossier `projet_fixed` (au même niveau que `player.gd`, `level.tscn`, etc.) :

- `progression.gd`
- `hud_profil.gd`
- `hud_profil.tscn`
- `minimap.gd`
- `minimap.tscn`

Et **remplace** les fichiers existants par les versions modifiées :
- `player.gd`
- `pause_menu.gd`
- `level.tscn`

## 2. Étape OBLIGATOIRE dans l'éditeur Godot : ajouter l'Autoload

Le script `progression.gd` doit être déclaré comme **Autoload** (singleton global), sinon `Progression.xxx` ne fonctionnera nulle part.

1. Ouvre Godot → menu **Project > Project Settings**
2. Onglet **Autoload**
3. Dans "Path", clique sur le dossier 📁 et sélectionne `res://progression.gd`
4. Dans "Node Name", écris exactement : `Progression`
5. Clique sur **Add**

Sans cette étape, tu auras une erreur du type `Identifier "Progression" not declared`.

## 3. Relier le score à tes fleurs existantes

Je n'ai pas eu accès à ton fichier `fleur.gd`, donc il te reste **une seule ligne à ajouter toi-même**.

Ouvre `fleur.gd` et trouve l'endroit où une fleur est découverte pour la première fois (probablement dans une fonction `_on_body_entered` ou similaire, là où le popup s'affiche). Ajoute juste avant ou après :

```gdscript
Progression.decouvrir_espece(data.nom)
```

(Remplace `data.nom` par le vrai nom de la propriété qui identifie l'espèce dans ta ressource `.tres` — ça peut être `data.id`, `data.titre`, etc. selon comment tu as nommé tes champs dans `Satrokala.tres` et les autres.)

Si tu m'envoies `fleur.gd`, je peux te dire exactement où mettre la ligne.

## 4. Avatar du joueur (optionnel)

Pour l'instant, l'avatar est vide (case blanche). Pour en mettre un :

```gdscript
# Dans level.gd ou au démarrage du jeu :
Progression.avatar_texture = preload("res://asset/ton_avatar.png")
```

Ou directement dans `hud_profil.tscn`, sélectionne le nœud `Avatar` et glisse une image dans la propriété `Texture`.

## Ce que ça donne

- **HudProfil** : encadré en haut à gauche, toujours visible en jeu ET affiché en haut du menu pause, avec nom du joueur, barre de progression et compteur "🌸 X / 5 espèces"
- **Minimap** : cadre rond en haut à droite, **vraie caméra** qui suit le joueur en temps réel sur la carte (zoom réglable via `zoom_minimap` dans l'inspecteur du nœud `Minimap`)

## Réglages à ajuster selon ton goût

Dans `minimap.tscn`, sélectionne le nœud racine `Minimap` et dans l'inspecteur :
- `zoom_minimap` (défaut 0.15) → plus petit = vue plus large de la carte
- `taille_minimap` (défaut 140px) → taille du cercle à l'écran
