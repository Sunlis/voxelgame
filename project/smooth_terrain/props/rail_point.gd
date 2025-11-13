@tool
extends Resource
class_name RailPoint

signal point_changed

@export var position: Vector3 = Vector3.ZERO:
	set(v):
		position = v
		point_changed.emit()

@export var normal: Vector3 = Vector3.UP:
	set(v):
		normal = v
		point_changed.emit()

@export var rotation: float = 0.0: # rotation around normal in radians
	set(v):
		rotation = v
		point_changed.emit()
