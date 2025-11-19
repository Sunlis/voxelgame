@tool

extends Node3D

class_name Rail

const BuildType = preload("res://smooth_terrain/build_types.gd")

@export var rail_points: Array[RailPoint] = []:
  set(v):
    rail_points = v
    _update()

@export var tie_spacing: float = 2.0:
  set(v):
    tie_spacing = max(v, 0.1)
    _update()

@export var rail_width: float = 1.0:
  set(v):
    rail_width = max(v, 0.1)
    _update()

@export var tie_length: float = 1.0:
  set(v):
    tie_length = max(v, 0.001)
    _update()

@export var tie_thickness: float = 0.06:
  set(v):
    tie_thickness = max(v, 0.001)
    _update()

@export var rail_height: float = 0.14:
  set(v):
    rail_height = max(v, 0.001)
    _update()

@export var rail_thickness: float = 0.08:
  set(v):
    rail_thickness = max(v, 0.001)
    _update()

# Independent tie width so changing rail_thickness no longer affects tie length
@export var tie_width: float = 2.5:
  set(v):
    tie_width = max(v, 0.001)
    _update()

@export var show_debug_markers: bool = false:
  set(v):
    show_debug_markers = v
    _update()

# Scales the strength/length of the in/out handles at each RailPoint.
# Higher = broader, gentler curves. Lower = tighter/straighter.
@export var handle_strength: float = 1.0:
  set(v):
    handle_strength = clamp(v, 0.0, 5.0)
    _update()

func _update():
  pass

func get_rail_length() -> float:
  return 1.0

func get_transform_at_distance(_distance: float) -> Transform3D:
  return Transform3D.IDENTITY
