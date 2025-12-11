@tool

extends Node3D

class_name Spray

@onready var decal: Decal = %decal

enum Type {
  ARROW
}

const TEXTURES = {
  Type.ARROW: preload("res://smooth_terrain/assets/ui/drawing_brush.png")
}

@export var type: Type = Type.ARROW
@export var color: Color = Color.WHITE

func _ready():
  decal.texture_albedo = TEXTURES[type]
  decal.modulate = color
