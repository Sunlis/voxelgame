extends Label

func _ready():
  Global.local_player_position_changed.connect(func(pos):
    self.text = "Pos: (%.2f, %.2f, %.2f)" % [pos.x, pos.y, pos.z]
  )
