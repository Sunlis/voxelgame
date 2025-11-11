extends Node

signal client_connected(id: int)
signal client_disconnected(id: int)
signal server_started()
signal connected_to_server()

var server: ENetMultiplayerPeer = null
var server_port: int = 9000
var external_port: int = -1
var client: ENetMultiplayerPeer = null

func create_server() -> int:
  var peer := ENetMultiplayerPeer.new()
  var port = UPNPHelper.find_port_blocking(server_port, "UDP", "DigSlop Game Server", 60)
  if port == -1 or port == null:
    Debug.print("Failed to find port")
    return -1
  external_port = port
  var error := peer.create_server(server_port, 128)
  if error != OK:
    Debug.print(error)
    return error
  peer.peer_connected.connect(_client_connected)
  peer.peer_disconnected.connect(_client_disconnected)
  get_tree().get_multiplayer().multiplayer_peer = peer
  server = peer
  client = null
  server_started.emit()
  return OK

func create_client(ip: String, port: int) -> int:
  var peer := ENetMultiplayerPeer.new()
  var error := peer.create_client(ip, port)
  if error != OK:
    Debug.print(error)
    return error
  get_tree().get_multiplayer().multiplayer_peer = peer
  client = peer
  server = null
  connected_to_server.emit()
  return OK

func is_server() -> bool:
  return server != null

func get_server_peer() -> ENetMultiplayerPeer:
  return server

func get_client_peer() -> ENetMultiplayerPeer:
  return client

func _client_connected(id: int) -> void:
  Debug.print("Client connected with ID: %d" % id)
  client_connected.emit(id)

func _client_disconnected(id: int) -> void:
  Debug.print("Client disconnected with ID: %d" % id)
  client_disconnected.emit(id)

func list_peer_ids() -> PackedInt32Array:
  return get_tree().get_multiplayer().get_peers()
