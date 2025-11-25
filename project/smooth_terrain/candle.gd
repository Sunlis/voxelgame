@tool

extends Light3D

@export var energy_min: float = 0.8
@export var energy_max: float = 1.2
@export var flicker_speed: float = 0.1

var _noise: FastNoiseLite

func _ready():
  _noise = FastNoiseLite.new()
  _noise.seed = randi()

func _process(_delta):
  var noise = _noise.get_noise_1d(Time.get_ticks_msec() * flicker_speed)
  self.light_energy = noise * (energy_max - energy_min) + energy_min
