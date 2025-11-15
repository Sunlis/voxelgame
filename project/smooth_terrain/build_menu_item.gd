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
@export var hovered: bool = false:
  set(v):
    hovered = v
    _update()

@onready var texture: TextureRect = %texture
@onready var label: Label = %label
@onready var color_rect: ColorRect = %color

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  texture.texture = ICONS.get(build_type, null)
  label.text = BuildType.NAMES.get(build_type, "Unknown")
  color_rect.visible = hovered
  if hovered:
    texture.modulate = Color(1, 1, 1, 1)
  else:
    texture.modulate = Color(0.5, 0.5, 0.5, 1)
