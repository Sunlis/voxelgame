@tool

extends HBoxContainer

@export var drop_type: Drops.Type = Drops.Type.TRASH:
  set(value):
    drop_type = value
    _update()

@export var count: int = 0:
  set(value):
    count = value
    _update()


@onready var icon: TextureRect = %icon
@onready var count_label: Label = %count
@onready var name_label: Label = %title

const ICONS = {
  Drops.Type.TRASH: preload("res://smooth_terrain/assets/ui/icons/trash.png"),
  Drops.Type.BOTTLECAP: preload("res://smooth_terrain/assets/ui/icons/bottlecap.png"),
  Drops.Type.PENNY: preload("res://smooth_terrain/assets/ui/icons/penny.png"),
  Drops.Type.COAL: preload("res://smooth_terrain/assets/ui/icons/coal.png"),
  Drops.Type.HEMATITE: preload("res://smooth_terrain/assets/ui/icons/hematite.png"),
  Drops.Type.QUARTZ: preload("res://smooth_terrain/assets/ui/icons/quartz.png"),
  Drops.Type.GYPSUM: preload("res://smooth_terrain/assets/ui/icons/gypsum.png"),
  Drops.Type.PYRITE: preload("res://smooth_terrain/assets/ui/icons/pyrite.png"),
  Drops.Type.MALACHITE: preload("res://smooth_terrain/assets/ui/icons/malachite.png"),
  Drops.Type.CINNABAR: preload("res://smooth_terrain/assets/ui/icons/cinnabar.png"),
  Drops.Type.GOLD: preload("res://smooth_terrain/assets/ui/icons/gold.png"),
  Drops.Type.PLATINUM: preload("res://smooth_terrain/assets/ui/icons/platinum.png"),
  Drops.Type.IRIDIUM: preload("res://smooth_terrain/assets/ui/icons/iridium.png"),
  Drops.Type.OBSIDIAN: preload("res://smooth_terrain/assets/ui/icons/obsidian.png"),
  Drops.Type.KIMBERLITE: preload("res://smooth_terrain/assets/ui/icons/kimberlite.png"),
}

func _ready():
  _update()

func _update():
  if not is_inside_tree():
    return
  var config = Drops.get_drop_config(drop_type)
  icon.texture = ICONS.get(drop_type, null)
  name_label.text = config.name
  count_label.text = "x%02d" % count
