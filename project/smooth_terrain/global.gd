extends Node

const BuildType = preload("res://smooth_terrain/build_types.gd")

var _terrain: VoxelTerrain = null

func register_terrain(terrain: VoxelTerrain) -> void:
  _terrain = terrain

func get_terrain() -> VoxelTerrain:
  return _terrain

signal build_requested(pos: Vector3, norm: Vector3, build_type: BuildType.Type)

func build(pos: Vector3, norm: Vector3, build_type: BuildType.Type) -> void:
  do_build.rpc_id(1, pos, norm, build_type)

@rpc("any_peer", "call_local", "reliable")
func do_build(pos: Vector3, norm: Vector3, build_type: BuildType.Type) -> void:
  build_requested.emit(pos, norm, build_type)
