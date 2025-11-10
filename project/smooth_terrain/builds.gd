extends Node3D

@export var spawner: MultiplayerSpawner

const LANTERN = "res://smooth_terrain/props/prop_lantern.tscn"

func _ready():
  spawner.add_spawnable_scene(LANTERN)
  Global.build_requested.connect(_on_build_requested)

func _on_build_requested(pos: Vector3, norm: Vector3, block_type: int):
  var node = null
  match block_type:
    1:
      node = preload(LANTERN).instantiate()
    _:
      Debug.print("Unknown block type: %d" % block_type)
      return
  node.position = pos
  node.look_at(pos + norm, Vector3.UP)
  add_child(node)
