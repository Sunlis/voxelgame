@tool

extends Node3D

@onready var terrain_marker: Node3D = %terrain_marker

func _ready():
  terrain_marker.visible = Engine.is_editor_hint() and get_tree().edited_scene_root == self
