extends Node


var plantes_decouvertes = []

func decouvrir_plante(id_plante):
	if not id_plante in plantes_decouvertes:
		plantes_decouvertes.append(id_plante)
		print("Nouvelle plante scannée !
		Tu en as : ", plantes_decouvertes.size())

# On reçoit tout le fichier .tres (ItemData)
func scan_reussi(fleur_res: ItemData):
	if fleur_res:
		# 1. On cherche ta Popup dans la scène (nom exact : PopupFl)
		var popup = get_tree().current_scene.find_child("PopupFleur", true, false)
		
		if popup:
			# 2. On envoie le NOM et la DESCRIPTION de ton .tres à la popup
			# C'est ici que le lien se fait avec l'Aloe Vaombe !
			popup.afficher_decouverte(fleur_res.nom_affiche, fleur_res.description)
			print("Affichage de la popup pour : ", fleur_res.nom_affiche)
		else:
			print("ERREUR : Le code ne trouve pas le nœud PopupFleur dans l'arbre de scène !")
