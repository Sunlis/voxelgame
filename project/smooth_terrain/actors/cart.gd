@tool

extends Node3D

@onready var container: Node3D = %container

@export var rail: Rail
@export var perc: float
@export var tilt_frequency: float = 10.0

enum State {
  IDLE,
  MOVING,
}
@export var state: State = State.IDLE
@export var move_speed: float = 1.0

func _process(_delta):
  if rail == null:
    return
  if state == State.MOVING:
    perc += move_speed * _delta / rail.get_rail_length()
    if perc > 1.0:
      perc = 0.0
  var path_length = rail.get_rail_length()
  var distance_along_path = perc * path_length
  global_transform = rail.get_transform_at_distance(distance_along_path)
  if state == State.MOVING:
    container.rotation.x = (floor(fmod(distance_along_path / tilt_frequency, 2.0)) * 2.0 - 1.0) * (PI * 0.1)
  elif state == State.IDLE:
    container.rotation.x = 0
