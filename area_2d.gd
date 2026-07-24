extends Area2D

@onready var popup = $PopupPanel

func _on_area_2d_body_entered(body):
	if body.name == "player":
		popup.popup()

func _on_area_2d_body_exited(body):
	if body.name == "player":
		popup.hide()
