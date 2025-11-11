# Helper class to setup and cleanup UPNP for easy server hosting.
extends Node

signal setup_failed(internal_port: int)
signal port_ready(external_port: int, internal_port: int)

var threads: Array[Thread] = []
var mappings: Array = []
var _upnp: UPNP = null

func _ready():
  tree_exiting.connect(_exit_tree)

func find_port(internal_port: int, protocol: String, description: String, duration_sec: int = 86400):
  var thread = Thread.new()
  threads.append(thread)
  thread.start(_thread_find_port.bind(internal_port, protocol, description, duration_sec))

func find_port_blocking(internal_port: int, protocol: String, description: String, duration_sec: int = 86400) -> int:
  return _thread_find_port(internal_port, protocol, description, duration_sec)

func _thread_find_port(internal_port: int, protocol: String, description: String, duration_sec: int):
  if _upnp == null:
    _upnp = UPNP.new()
    var err = _upnp.discover()  
    if err != OK:
      setup_failed.emit(internal_port)
      print("UPNP discovery failed with error: %d" % err)
      return -1
  if _upnp.get_gateway() and _upnp.get_gateway().is_valid_gateway():
    for port in range(1025, 65535):
      print('try port %d' % port)
      var map_err = _upnp.add_port_mapping(port, internal_port, description, protocol, duration_sec)
      if map_err == OK:
        port_ready.emit.call_deferred(port, internal_port)
        mappings.append({
          "external_port": port,
          "internal_port": internal_port,
          "protocol": protocol,
        })
        print("UPNP port mapping successful: external port %d to internal port %d" % [port, internal_port])
        return port
  setup_failed.emit(internal_port)
  print("UPNP port mapping failed")
  return -1

func cleanup():
  _exit_tree()

func _notification(what):
  if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
    _exit_tree()

func _exit_tree() -> void:
  for thread in threads:
    thread.wait_to_finish()
  threads.clear()
  if not _upnp:
    return
  for mapping in mappings:
    var err = _upnp.delete_port_mapping(mapping["external_port"], mapping["protocol"])
    if err == OK:
      print("Successfully removed UPNP port mapping for external port %d" % mapping["external_port"])
    else:
      print("Failed to remove UPNP port mapping for external port %d with error: %d" % [mapping["external_port"], err])
  mappings.clear()
