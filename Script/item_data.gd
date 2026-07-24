extends Resource
class_name ItemData

@export_group("Identité Madagascar")
@export var id: StringName
@export var nom_affiche: String # Ex: "Orchidée d'Analamanga"
@export var type: enums.ItemType = enums.ItemType.NONE

@export_group("Description Herbier")
@export_multiline var description: String # L'info après analyse

@export_group("Visuel")
@export var icone: Texture2D # L'image qui apparaîtra dans ton livre
