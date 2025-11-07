extends Node3D

func _ready():
  Multiplayer.client_connected.connect(_on_client_connected)
  Multiplayer.client_disconnected.connect(_on_client_disconnected)
  Multiplayer.server_started.connect(_on_server_started)

func _on_server_started():
  create_player(1)

func _on_client_connected(id):
  create_player(id)

func _on_client_disconnected(id):
  remove_player(id)

var players = {}

func create_player(id: int):
  var player_scene = preload("res://smooth_terrain/player.tscn")
  var player = player_scene.instantiate()
  player.name = "Player_%d" % id
  player.position = Vector3(players.size() * 2, 10, 0)
  Debug.print("add new player %s at %s" % [player.name, str(player.position)])
  add_child(player)
  players[id] = player
  return player

func remove_player(id: int):
  Debug.print('remove player %s' % id)
  if players.has(id):
    var player = players[id]
    player.queue_free()
    players.erase(id)
