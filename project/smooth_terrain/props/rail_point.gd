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

@export var forward: Vector3 = Vector3.FORWARD:
	set(v):
		forward = v
		point_changed.emit()

@export var temporary: bool = false

func _init(pos: Vector3 = Vector3.ZERO, norm: Vector3 = Vector3.UP, fwd: Vector3 = Vector3.FORWARD):
	position = pos
	normal = norm
	forward = fwd
