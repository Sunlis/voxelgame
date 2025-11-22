extends Node

const BuildType = preload("res://smooth_terrain/build_types.gd")

func wrap_mod(a: int, b: int) -> int:
  return ((a % b) + b) % b

func wrap_fmod(a: float, b: float) -> float:
  return fmod(fmod(a, b) + b, b)

### TERRAIN

var _terrain: VoxelTerrain = null

func register_terrain(terrain: VoxelTerrain) -> void:
  _terrain = terrain

func get_terrain() -> VoxelTerrain:
  return _terrain

### BUILD

signal build_requested(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type)

func build(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type) -> void:
  do_build.rpc_id(1, pos, norm, forward, build_type)

@rpc("any_peer", "call_local", "reliable")
func do_build(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type) -> void:
  build_requested.emit(pos, norm, forward, build_type)

signal move_temp_rail(pos: Vector3, norm: Vector3, forward: Vector3)

func move_temporary_rail_point(pos: Vector3, norm: Vector3, forward: Vector3) -> void:
  do_move_temporary_rail_point.rpc_id(1, pos, norm, forward)

@rpc("any_peer", "call_local", "reliable")
func do_move_temporary_rail_point(pos: Vector3, norm: Vector3, forward: Vector3) -> void:
  move_temp_rail.emit(pos, norm, forward)

### PLAYER

signal player_build_mode_changed(building: bool, build_type: BuildType.Type)

### COLLISIONS

signal terrain_modified(point: Vector3, radius: float)

### DROPS

signal create_drop(position: Vector3, drop_rate: float)
