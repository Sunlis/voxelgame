extends Node3D

func _ready():
  Multiplayer.client_connected.connect(_on_client_connected)
  Multiplayer.server_started.connect(_on_server_started)

func _on_server_started():
  create_local_player()

func create_local_player() -> Node:
  var local_player_scene = preload("res://smooth_terrain/local_player.tscn")
  var local_player = local_player_scene.instantiate()
  add_child(local_player)
  local_player.position = Vector3(0, 10, 0)
  return local_player

func _on_client_connected(id):
  print('players._on_client_connected')
