extends Node3D

func _ready():
  Multiplayer.client_connected.connect(_on_client_connected)
  Multiplayer.server_started.connect(_on_server_started)
  Multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_server_started():
  create_player(1)

func _on_client_connected(id):
  create_player(id)

func _on_connected_to_server():
  # var player = create_base_player()
  # player.position.z = 1
  pass

var players = []

func create_player(id: int):
  var player_scene = preload("res://smooth_terrain/player.tscn")
  var player = player_scene.instantiate()
  player.name = "Player_%d" % id
  player.set_multiplayer_authority(id)
  player.position = Vector3(0, 4, 0)
  add_child(player)
  players.append(player)
  player.position.x = players.size() * 2
  return player
