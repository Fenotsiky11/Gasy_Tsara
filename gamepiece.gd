@tool
class_name Gamepiece extends CharacterBody2D

signal arriving(remaining_distance: float)
signal arrived
signal direction_changed(new_direction: Vector2)

@export var move_speed: float = 64.0

var destination: Vector2 = Vector2.ZERO
var is_moving_to_target: bool = false

func _physics_process(delta: float) -> void:
	if not is_moving_to_target:
		return
		
	var distance = global_position.distance_to(destination)
	if distance < 2.0:
		stop()
	else:
		var direction_vec = global_position.direction_to(destination)
		velocity = direction_vec * move_speed
		move_and_slide()
		arriving.emit(distance)

func move_to(target_point: Vector2) -> void:
	destination = target_point
	is_moving_to_target = true

func stop() -> void:
	is_moving_to_target = false
	velocity = Vector2.ZERO
	arrived.emit()
