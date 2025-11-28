extends VoxelTerrain

func _ready() -> void:
  Global.register_terrain(self)
