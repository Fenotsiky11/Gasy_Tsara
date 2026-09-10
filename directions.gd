## Utility class defining movement/facing directions for gamepieces on a grid.
## Place this file anywhere in your scripts folder (e.g. alongside gamepiece.gd).
class_name Directions
extends RefCounted


## The four cardinal directions a gamepiece can face or move toward.
enum Points { NORTH, SOUTH, EAST, WEST }


## Converts an angle (in radians, as returned by e.g. a rotation or
## Vector2.angle()) into the closest cardinal Points direction.
static func angle_to_direction(angle: float) -> Points:
	var degrees: float = rad_to_deg(angle)

	# Normalize to the range [0, 360) to simplify the comparisons below.
	degrees = fmod(degrees + 360.0, 360.0)

	if degrees >= 315.0 or degrees < 45.0:
		return Points.EAST
	elif degrees >= 45.0 and degrees < 135.0:
		return Points.SOUTH
	elif degrees >= 135.0 and degrees < 225.0:
		return Points.WEST
	else:
		return Points.NORTH


## Converts a Points direction into a unit Vector2, useful for movement.
static func direction_to_vector(direction: Points) -> Vector2:
	match direction:
		Points.NORTH:
			return Vector2.UP
		Points.SOUTH:
			return Vector2.DOWN
		Points.EAST:
			return Vector2.RIGHT
		Points.WEST:
			return Vector2.LEFT
	return Vector2.ZERO


## Converts a plain movement Vector2 into the closest cardinal Points direction.
static func vector_to_direction(vector: Vector2) -> Points:
	if vector == Vector2.ZERO:
		return Points.SOUTH
	return angle_to_direction(vector.angle())
