@tool

class_name PlayerHUD

extends MarginContainer

@export var build_mode: bool = false:
  set(v):
    build_mode = v
    _update()
@export var selected_build_index: int = 0:
  set(v):
    selected_build_index = v
    _update()

@onready var build_menu: Control = %build_menu
@onready var build_item_container: Control = %build_items

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  build_menu.visible = build_mode
  var build_items = build_item_container.get_children()
  var wrapped_index = Global.wrap_mod(selected_build_index, build_items.size())
  for i in build_items.size():
    var item = build_items[i] as BuildMenuItem
    item.hovered = (i == wrapped_index)

func _process(_delta):
  if build_mode:
    if Input.is_action_just_pressed("build_select_next"):
      selected_build_index += 1
    elif Input.is_action_just_pressed("build_select_prev"):
      selected_build_index -= 1

var _pan_delta: float = 0.0
var _last_pan = 0.0
const _pan_threshold = 5.0
const _pan_delay = 500 # milliseconds

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventPanGesture and build_mode:
    var now = Time.get_ticks_msec()
    if now - _last_pan > _pan_delay:
      _pan_delta = 0.0
    _pan_delta += event.delta.y
    if abs(_pan_delta) > _pan_threshold and now - _last_pan < _pan_delay:
      if _pan_delta > 0:
        selected_build_index += 1
      else:
        selected_build_index -= 1
      _pan_delta = 0.0
    _last_pan = now
