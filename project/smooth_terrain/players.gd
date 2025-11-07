extends Node3D

func _ready():
  Multiplayer.client_connected.connect(_on_client_connected)
  Multiplayer.server_started.connect(_on_server_started)

func _on_server_started():
  create_player(1)

func _on_client_connected(id):
  create_player(id)

var players = []

func create_player(id: int):
  var player_scene = preload("res://smooth_terrain/player.tscn")
  var player = player_scene.instantiate()
  player.name = "Player_%d" % id
  player.position = Vector3(players.size() * 2, 10, 0)
  Debug.print("add new player %s at %s" % [player.name, str(player.position)])
  add_child(player)
  players.append(player)
  return player
