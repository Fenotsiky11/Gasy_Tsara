extends Panel

func _ready():
	hide()
	# On s'assure que ce script RÉAGIT même pendant la pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Si la popup est visible ET qu'on appuie sur E (ou ta touche d'action)
	if is_visible_in_tree() and event.is_action_pressed("ui_accept"): 
		# "ui_accept" est souvent Entrée ou Espace par défaut. 
		# Si tu as créé une action "interagir", utilise son nom.
		fermer_popup()

func afficher_decouverte(n, d):
	$VBoxContainer/NomFleur.text = n
	$VBoxContainer/DescFleur.text = d
	show()
	get_tree().paused = true
	print("Popup ouverte. Appuie sur E (Entrée/Espace) pour fermer.")

# On crée une fonction commune pour le bouton ET la touche
func fermer_popup():
	hide()
	get_tree().paused = false
	print("Retour au jeu !")

# Si tu gardes quand même le bouton "X" à la souris :
func _on_bouton_fer_pressed():
	fermer_popup()
