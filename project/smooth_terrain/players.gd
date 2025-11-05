extends Node3D

func _ready():
  # Multiplayer.client_connected.connect(_on_client_connected)
  Multiplayer.server_started.connect(_on_server_started)
  Multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_server_started():
  create_base_player()
  # create_local_player()

func _on_client_connected(id):
  create_remote_player(id)

func _on_connected_to_server():
  var player = create_base_player()
  player.position.z = 1
  # create_local_player()
  # create_remote_player(1)
  # for id in Multiplayer.list_peer_ids():
  #   create_remote_player(id)

func create_base_player():
  var id = get_tree().get_multiplayer().get_unique_id()
  var player_scene = preload("res://smooth_terrain/player.tscn")
  var player = player_scene.instantiate()
  player.name = "Player_%d" % id
  add_child(player)
  player.set_multiplayer_authority(id)
  player.position = Vector3(0, 10, 0)
  return player

func create_local_player() -> Node:
  var local_player_scene = preload("res://smooth_terrain/local_player.tscn")
  var local_player = local_player_scene.instantiate()
  var id = 1
  if not Multiplayer.is_server():
    id = Multiplayer.get_tree().get_multiplayer().get_unique_id()
  print('create local player with id %d' % id)
  local_player.set_multiplayer_authority(id, true)
  add_child(local_player)
  local_player.position = Vector3(0, 10, 0)
  return local_player

func create_remote_player(id: int) -> Node3D:
  var remote_player_scene = preload("res://smooth_terrain/remote_player.tscn")
  var remote_player = remote_player_scene.instantiate()
  remote_player.set_multiplayer_authority(id, true)
  print('create remote player with id %d' % id)
  add_child(remote_player)
  remote_player.position = Vector3(0, 10, 0)
  return remote_player
