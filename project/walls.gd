extends Node3D

func _ready():
  visible = not Engine.is_editor_hint()
