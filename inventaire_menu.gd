extends Panel # Ou Control selon ton type

func _ready():
	# On le cache au lancement du jeu
	hide()

func _input(event):
	# Si on appuie sur la touche A (configurée comme "ouvrir_inventaire")
	if event.is_action_pressed("ouvrir_inventaire") and not event.is_echo():
		visible = !visible
		if visible:
			remplir_la_liste()

func remplir_la_liste():
	var liste = get_node("ListeItems")
	liste.clear()
	
	if ScanGlobal.plantes_decouvertes.size() == 0:
		liste.add_item("> Vide")
	else:
		for nom in ScanGlobal.plantes_decouvertes:
			liste.add_item("> " + str(nom))
	liste.grab_focus()

# Connecte le signal 'item_selected' de ta ListeItems à cette fonction
func _on_liste_items_item_selected(index):
	var label = get_node("TexteDescription")
	var liste = get_node("ListeItems")
	label.text = "Plante : " + liste.get_item_text(index).replace("> ", "")
