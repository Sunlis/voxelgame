extends Node3D

@onready var player: CharacterBody3D = %player
var viewer: VoxelViewer

func _ready() -> void:
  player.set_multiplayer_authority(self.get_multiplayer_authority(), true)
  if Multiplayer.is_server():
    viewer = VoxelViewer.new()
    viewer.requires_visuals = false
    viewer.requires_collisions = false
    viewer.requires_data_block_notifications = true
    viewer.set_network_peer_id(self.get_multiplayer_authority())
    player.add_child(viewer)
