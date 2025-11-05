extends Node

signal client_connected(id: int)
signal server_started()

var server: ENetMultiplayerPeer = null
var server_port: int = 9000
var client: ENetMultiplayerPeer = null

func create_server() -> int:
  var peer := ENetMultiplayerPeer.new()
  # TODO: upnp
  var error := peer.create_server(server_port, 128)
  if error != OK:
    print(error)
    return error
  peer.peer_connected.connect(_client_connected)
  get_tree().get_multiplayer().multiplayer_peer = peer
  server = peer
  client = null
  server_started.emit()
  return OK

func create_client(ip: String, port: int) -> int:
  var peer := ENetMultiplayerPeer.new()
  var error := peer.create_client(ip, port)
  if error != OK:
    print(error)
    return error
  get_tree().get_multiplayer().multiplayer_peer = peer
  client = peer
  server = null
  return OK

func is_server() -> bool:
  return server != null

func get_server_peer() -> ENetMultiplayerPeer:
  return server

func get_client_peer() -> ENetMultiplayerPeer:
  return client

func _client_connected(id: int) -> void:
  var window_id = 0
  var args = OS.get_cmdline_user_args()
  for arg in args:
    if arg.begins_with("--window-id="):
      var split_arg = arg.split("=")
      if split_arg.size() == 2:
        window_id = int(split_arg[1])
        break
  print("[%s] Client connected with ID: %d" % [window_id, id])
  client_connected.emit(id)
