@tool

extends Node

const BuildType = preload("res://smooth_terrain/build_types.gd")

func wrap_mod(a: int, b: int) -> int:
  return ((a % b) + b) % b

func wrap_fmod(a: float, b: float) -> float:
  return fmod(fmod(a, b) + b, b)

### QUIT HANDLING

signal quit_requested

var _quit_cancelled: bool = false

func cancel_quit():
  _quit_cancelled = true

func request_quit():
  print("Requesting quit...")
  quit_requested.emit()
  await get_tree().create_timer(1.0).timeout
  if not _quit_cancelled:
    print("Quitting...")
    get_tree().quit()
  else:
    print("Quit cancelled.")
    _quit_cancelled = false

### PAUSE

signal pause_changed(paused: bool)

var _paused: bool = false

func is_paused() -> bool:
  return _paused

func set_paused(paused: bool) -> void:
  _paused = paused
  pause_changed.emit(paused)

### TERRAIN

var _terrain: VoxelTerrain = null

func register_terrain(terrain: VoxelTerrain) -> void:
  _terrain = terrain

func get_terrain() -> VoxelTerrain:
  return _terrain

### BUILD

signal build_requested(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type, player_id: int)

func build(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type, player_id: int) -> void:
  do_build.rpc_id(1, pos, norm, forward, build_type, player_id)

@rpc("any_peer", "call_local", "reliable")
func do_build(pos: Vector3, norm: Vector3, forward: Vector3, build_type: BuildType.Type, player_id: int) -> void:
  build_requested.emit(pos, norm, forward, build_type, player_id)

signal move_temp_rail(pos: Vector3, norm: Vector3, forward: Vector3)

func move_temporary_rail_point(pos: Vector3, norm: Vector3, forward: Vector3) -> void:
  do_move_temporary_rail_point.rpc_id(1, pos, norm, forward)

@rpc("any_peer", "call_local", "reliable")
func do_move_temporary_rail_point(pos: Vector3, norm: Vector3, forward: Vector3) -> void:
  move_temp_rail.emit(pos, norm, forward)

signal build_marker_moved(pos: Vector3, norm: Vector3, forward: Vector3, player_id: int)

func move_build_marker(pos: Vector3, norm: Vector3, forward: Vector3, player_id: int) -> void:
  build_marker_moved.emit(pos, norm, forward, player_id)

### PLAYER

signal player_build_mode_changed(building: bool, build_type: BuildType.Type)

func change_player_build_mode(building: bool, build_type: BuildType.Type) -> void:
  player_build_mode_changed.emit(building, build_type)

signal player_build_marker_valid_changed(valid: bool, reason: String)

func change_player_build_marker_valid(valid: bool, reason: String = "") -> void:
  player_build_marker_valid_changed.emit(valid, reason)

signal local_player_position_changed(position: Vector3)

func change_local_player_position(position: Vector3) -> void:
  local_player_position_changed.emit(position)

### COLLISIONS

signal terrain_modified(point: Vector3, radius: float, player_config: PlayerConfig)

func notify_terrain_modified(point: Vector3, radius: float, player_config: PlayerConfig) -> void:
  terrain_modified.emit(point, radius, player_config)

### DROPS

signal drop_requested(position: Vector3, drop_rate: float, force: bool)

func create_drop(position: Vector3, drop_rate: float, force: bool = false) -> void:
  drop_requested.emit(position, drop_rate, force)

### NOTIFICATIONS

signal display_message(message: String)

func notify_message(message: String) -> void:
  display_message.emit(message)


### INVENTORY

signal drop_collected(drop_type: Drops.Type, amount: int)

func collect_drop(drop_type: Drops.Type, amount: int = 1) -> void:
  drop_collected.emit(drop_type, amount)


### SPRAYS

signal spray_created(position: Vector3, forward: Vector3, spray_type: Spray.Type, color: Color, player_id: int)

func create_spray(position: Vector3, forward: Vector3, spray_type: Spray.Type, color: Color, player_id: int) -> void:
  _do_create_spray.rpc_id(1, position, forward, spray_type, color, player_id)

@rpc("any_peer", "call_local", "reliable")
func _do_create_spray(position: Vector3, forward: Vector3, spray_type: Spray.Type, color: Color, player_id: int) -> void:
  spray_created.emit(position, forward, spray_type, color, player_id)
