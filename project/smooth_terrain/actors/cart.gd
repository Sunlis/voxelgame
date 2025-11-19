@tool

extends Node3D

@onready var container: Node3D = %container

@export var rail: Rail
@export var tilt_frequency: float = 10.0
@export var distance: float = 0.0

enum State {
  IDLE,
  MOVING,
}
@export var state: State = State.IDLE
@export var move_speed: float = 1.0

func _process(delta: float) -> void:
  if state == State.MOVING:
    distance += move_speed * delta
  _update()

func _update():
  if rail == null:
    return
  var wrapped = Util.wrap_fmod(distance, rail.get_rail_length())
  global_transform = rail.get_transform_at_distance(wrapped)
  if state == State.MOVING:
    container.rotation.x = (floor(fmod(wrapped / tilt_frequency, 2.0)) * 2.0 - 1.0) * (PI * 0.1)
  elif state == State.IDLE:
    container.rotation.x = 0
