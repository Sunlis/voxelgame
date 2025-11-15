@tool

extends PanelContainer

const BuildType = preload("res://smooth_terrain/build_types.gd")

const ICONS = {
  BuildType.Type.LANTERN: preload("res://smooth_terrain/assets/ui/lantern.png"),
  BuildType.Type.RAIL: preload("res://smooth_terrain/assets/ui/railroad.png")
}

@export var build_type: BuildType.Type = BuildType.Type.LANTERN:
  set(v):
    build_type = v
    _update()

@onready var texture: TextureRect = %texture
@onready var label: Label = %label

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  texture.texture = ICONS.get(build_type, null)
  label.text = BuildType.NAMES.get(build_type, "Unknown")
