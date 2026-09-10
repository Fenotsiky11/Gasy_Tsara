extends Node


var plantes_decouvertes = []

func decouvrir_plante(id_plante):
	if not id_plante in plantes_decouvertes:
		plantes_decouvertes.append(id_plante)
		print("Nouvelle plante scannée ! Tu en as : ", plantes_decouvertes.size())

# On reçoit tout le fichier .tres (ItemData)
func scan_reussi(fleur_res: ItemData):
	if fleur_res:
		# 1. On cherche ta Popup dans la scène (nom exact : PopupFleur)
		var popup = get_tree().current_scene.find_child("PopupFleur", true, false)

		if popup:
			# 2. On envoie le NOM, la DESCRIPTION et la VIDEO du .tres à la popup
			popup.afficher_decouverte(fleur_res.nom_affiche, fleur_res.description, fleur_res.video_path)
			print("Affichage de la popup pour : ", fleur_res.nom_affiche)
		else:
			print("ERREUR : Le code ne trouve pas le nœud PopupFleur dans l'arbre de scène !")
