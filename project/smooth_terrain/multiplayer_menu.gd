extends VBoxContainer

@onready var address_input: LineEdit = %address
@onready var join_button: Button = %join_button
@onready var host_button: Button = %host_button
@onready var container: Control = %container
@onready var status_label: Label = %status

func _ready() -> void:
  join_button.pressed.connect(_on_join_button_pressed)
  host_button.pressed.connect(_on_host_button_pressed)

func _on_join_button_pressed() -> void:
  var address: String = address_input.text.strip_edges()
  if address == "":
    status_label.text = "Please enter a valid address."
    return
  var ip = address.split(":")[0]
  var port = 9000
  if address.find(":") != -1:
    port = int(address.split(":")[1])
  address = "%s:%s" % [ip, port]
  status_label.text = "Connecting to %s..." % address
  var error = Multiplayer.create_client(ip, port)
  if error != OK:
    status_label.text = "Failed to connect to %s." % address
    print(error)
    return
  status_label.text = "Connected to %s." % address
  print('Joined multiplayer session at %s' % address)
  container.visible = false

func _on_host_button_pressed() -> void:
  status_label.text = "Hosting multiplayer session..."
  var error = Multiplayer.create_server()
  if error != OK:
    status_label.text = "Failed to host session."
    print(error)
    return
  status_label.text = "Hosting on port %s." % Multiplayer.server_port
  print('Hosting multiplayer session on port %s' % Multiplayer.server_port)
  container.visible = false
