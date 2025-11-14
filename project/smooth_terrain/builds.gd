extends Node3D

const BuildType = preload("res://smooth_terrain/build_types.gd")

@export var spawner: MultiplayerSpawner

const LANTERN = "res://smooth_terrain/props/prop_lantern.tscn"

func _ready():
  spawner.add_spawnable_scene(LANTERN)
  Global.build_requested.connect(_on_build_requested)

func _on_build_requested(pos: Vector3, norm: Vector3, build_type: BuildType.Type) -> void:
  var node = null
  match build_type:
    BuildType.Type.LANTERN:
      node = preload(LANTERN).instantiate()
    _:
      Debug.print("Unknown block type: %d" % build_type)
      return
  node.name = "Build_%d" % self.get_child_count()
  node.position = pos
  node.look_at_from_position(pos, pos + norm, Vector3.UP)
  add_child(node)
