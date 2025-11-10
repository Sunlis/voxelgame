extends Node

var _terrain: VoxelTerrain = null

func register_terrain(terrain: VoxelTerrain) -> void:
  _terrain = terrain

func get_terrain() -> VoxelTerrain:
  return _terrain

signal build_requested(pos: Vector3, norm: Vector3, block_type: int)

func build(pos: Vector3, norm: Vector3, block_type: int) -> void:
  do_build.rpc_id(1, pos, norm, block_type)

@rpc("any_peer", "call_local", "reliable")
func do_build(pos: Vector3, norm: Vector3, block_type: int) -> void:
  build_requested.emit(pos, norm, block_type)
