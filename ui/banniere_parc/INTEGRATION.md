# 🌿 Bannière de Parc — Guide d'intégration Godot 4

## Ce que tu obtiens

Une bannière HUD semi-transparente fixée en haut de l'écran, identique à celle
de la capture d'écran, avec :
- **Nom du parc** (texte ivoire, grand)
- **Sous-titre** (surface, hectares, particularités — texte vert pâle)
- **Raccourcis clavier** alignés à droite (`[E] Scanner [A] Pokédex [Échap]…`)

---

## 1. Ajouter la bannière à ta scène de niveau

Dans ton **niveau.tscn** (ou tout scène qui représente un parc) :

```
Niveau (Node2D)
├── CanvasLayer          ← AJOUTE CE NŒUD (layer = 1, follow_viewport = false)
│   └── BanniereParc    ← Instancie banniere_parc.tscn ici
├── TileMap
├── Player
└── ...
```

> **Pourquoi un CanvasLayer ?**  
> Le `CanvasLayer` est indépendant de la caméra : la bannière reste toujours
> collée en haut de l'écran même quand le joueur se déplace.

**Étapes dans l'éditeur Godot :**
1. Sélectionne ton nœud racine de niveau.
2. Ajoute un enfant **CanvasLayer** (mets `layer = 1`).
3. Dans ce CanvasLayer, fais **Scène instanciée** → choisis `banniere_parc.tscn`.
4. Lance le jeu : la bannière apparaît en haut à gauche, raccourcis à droite.

---

## 2. Personnaliser le texte (Inspector Godot)

Sélectionne le nœud **BanniereParc** dans l'arbre. Dans l'**Inspector** tu vois :

| Propriété | Valeur par défaut |
|---|---|
| `Nom Parc` | Parc National de la Montagne d'Ambre |
| `Sous Titre` | Forêt tropicale humide du Nord · 18 200 ha · … |
| `Couleur Fond` | vert nuit semi-transparent |
| `Couleur Titre` | ivoire chaud |
| `Couleur Sous` | vert pâle |
| `Couleur Touch` | vert clair |

Change les valeurs directement dans l'Inspector sans toucher au code !

---

## 3. Changer de parc dynamiquement (entre deux zones)

Depuis n'importe quel script (level.gd, autoload, area_body_entered…) :

```gdscript
# Récupère la bannière (adapte le chemin selon ta scène)
var banniere = $CanvasLayer/BanniereParc

# Change le parc avec un fondu enchaîné automatique
banniere.changer_parc(
    "Réserve Naturelle de l'Ankarana",
    "Forêt de tsingy · grottes · lacs souterrains · 18 225 ha"
)
```

---

## 4. Idées de parcs malgaches pour ton RPG

| Nom | Sous-titre suggéré |
|---|---|
| Parc National de l'Isalo | Forêt de pierres · canyons · piscines naturelles · 81 540 ha |
| Réserve de Nosy Mangabe | Île sacrée des Betsimisaraka · Ayes-ayes nocturnes |
| Parc National de Ranomafana | Forêt pluviale · lémuriens rares · sources chaudes |
| Parc National de l'Andasibe | Forêt primaire · Indri indri · chants au lever du soleil |
| Réserve de Tsingy de Bemaraha | Forêt de calcaire acéré · patrimoine UNESCO |

---

## 5. Structure des fichiers

```
res://
└── ui/
    └── banniere_parc/
        ├── banniere_parc.gd      ← Logique + API changer_parc()
        └── banniere_parc.tscn    ← Scène prête à instancier
```

---

*Fait avec ❤️ pour ton RPG sur la biodiversité de Madagascar 🌺*
