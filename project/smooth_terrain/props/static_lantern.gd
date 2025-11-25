extends Node3D

@export var energy_min: float = 0.8
@export var energy_max: float = 1.2
@export var flicker_speed: float = 0.1
@export var flame_shake: float = 0.02

@export var noise: FastNoiseLite

@onready var light: OmniLight3D = %light

func shift(v: float) -> float:
  return (v - 0.5) * 2.0

func _ready():
  if not noise:
    noise = FastNoiseLite.new()
    noise.seed = randi()

func _process(_delta):
  var time = Time.get_ticks_msec() * flicker_speed
  var n = noise.get_noise_1d(time)
  light.light_energy = n * (energy_max - energy_min) + energy_min
  # light.position.x = shift(noise.get_noise_2dv(Vector2(-time, time))) * flame_shake
  # light.position.y = shift(noise.get_noise_2dv(Vector2(time, time))) * flame_shake
  # light.position.z = shift(noise.get_noise_2dv(Vector2(time, -time))) * flame_shake
