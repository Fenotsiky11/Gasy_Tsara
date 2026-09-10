extends Area2D

## Nom et description affichés dans le popup quand le joueur découvre le baobab.
@export var nom_element: String = "Baobab"
@export var description_element: String = "Un immense baobab, arbre emblématique de Madagascar."


func _on_area_2d_body_entered(body):
	if body.name == "player":
		var popup_fleur = get_tree().get_first_node_in_group("popup_fleur")
		if popup_fleur:
			popup_fleur.afficher_decouverte(nom_element, description_element)
		else:
			print("area_2d.gd: aucun nœud dans le groupe 'popup_fleur' trouvé !")


func _on_area_2d_body_exited(body):
	if body.name == "player":
		var popup_fleur = get_tree().get_first_node_in_group("popup_fleur")
		if popup_fleur:
			popup_fleur.fermer_popup()
