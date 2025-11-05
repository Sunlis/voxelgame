extends Node3D

@export var mp_id: int

@onready var player: CharacterBody3D = %player
var viewer: VoxelViewer

func _ready() -> void:
  player.mp_id = mp_id
  if Multiplayer.is_server():
    viewer = VoxelViewer.new()
    viewer.requires_visuals = false
    viewer.requires_collisions = false
    viewer.requires_data_block_notifications = true
    viewer.set_network_peer_id(mp_id)
    player.add_child(viewer)
