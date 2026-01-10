extends Resource

class_name PlayerConfig

var scale: float = 2.0

var _base_speed = 20.0
var _jump_force = 10.0
var _gravity = 18.0

var _dig_reach = 4.0
var _pickup_reach = 8.0
var _build_reach = 12.0

var _dig_radius = 1.0
var _dig_noise: float = 0.02

var _drop_rate: float = 0.01

var _build_rotate_speed = 5.0
var _mouse_sensitivity = 0.002

func get_base_speed() -> float:
  return _base_speed * scale
func get_jump_force() -> float:
  return _jump_force * scale
func get_gravity() -> float:
  return _gravity * scale 

func get_dig_reach() -> float:
  return _dig_reach * scale
func get_pickup_reach() -> float:
  return _pickup_reach * scale
func get_build_reach() -> float:
  return _build_reach * scale

func get_dig_radius() -> float:
  return _dig_radius * scale
func get_dig_noise() -> float:
  return _dig_noise

func get_drop_rate() -> float:
  return _drop_rate

func get_build_rotate_speed() -> float:
  return _build_rotate_speed
func get_mouse_sensitivity() -> float:
  return _mouse_sensitivity