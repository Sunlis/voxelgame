extends Node3D

const BuildType = preload("res://smooth_terrain/build_types.gd")

@export var spawner: MultiplayerSpawner

const LANTERN_PATH = "res://smooth_terrain/props/prop_lantern.tscn"
const LANTERN = preload(LANTERN_PATH)
const BRIDGE_PATH = "res://bridge.tscn"
const BRIDGE = preload(BRIDGE_PATH)

var _build_mode = false
var _selected_build_type = BuildType.Type.LANTERN

var _pending_bridge: BridgeProp = null

var _build_count = 0

func _ready():
  spawner.add_spawnable_scene(LANTERN_PATH)
  spawner.add_spawnable_scene(BRIDGE_PATH)
  Global.build_requested.connect(_on_build_requested)
  Global.player_build_mode_changed.connect(_build_mode_changed)
  Global.build_marker_moved.connect(_on_build_marker_moved)

func _on_build_marker_moved(
    pos: Vector3, _norm: Vector3, _forward: Vector3) -> void:
  if _build_mode and _selected_build_type == BuildType.Type.BRIDGE and _pending_bridge:
    _pending_bridge.end_point = pos

func _build_mode_changed(building: bool, build_type: BuildType.Type) -> void:
  _build_mode = building
  _selected_build_type = build_type
  if _pending_bridge and (not building or build_type != BuildType.Type.BRIDGE):
    _pending_bridge.queue_free()
    _pending_bridge = null

func _on_build_requested(
    pos: Vector3, norm: Vector3, _forward: Vector3, build_type: BuildType.Type):
  var node = null
  if build_type == BuildType.Type.LANTERN:
    node = LANTERN.instantiate()
    node.look_at_from_position(pos, pos + norm, Vector3.UP)
  elif build_type == BuildType.Type.BRIDGE:
    print('bridge. pending? ', not not _pending_bridge)
    if not _pending_bridge:
      _pending_bridge = BRIDGE.instantiate() as BridgeProp
      _pending_bridge.name = "PendingBridge"
      add_child(_pending_bridge)
      _pending_bridge.start_point = pos
      _pending_bridge.preview = true
      return
    else:
      node = BRIDGE.instantiate() as BridgeProp
      node.start_point = _pending_bridge.start_point
      node.end_point = pos
      node.preview = false
      _pending_bridge.queue_free()
      _pending_bridge = null
  else:
    # RAIL handled elsewhere
    return
  node.name = "Build_%d" % _build_count
  _build_count += 1
  add_child(node)
