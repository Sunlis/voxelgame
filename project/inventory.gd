extends MarginContainer

const InvRow = preload("res://inventory_row.tscn")

@onready var item_container: Control = %items

func _ready():
  clear_inventory()
  Global.drop_collected.connect(add_drop)
  _update_visibility()

func add_drop(drop_type: Drops.Type, amount: int) -> void:
  for child in item_container.get_children():
    if child.drop_type == drop_type:
      child.count += amount
      _sort_inventory()
      return
  add_new_drop(drop_type, amount)
  _sort_inventory()
  _update_visibility()

func add_new_drop(drop_type: Drops.Type, amount: int) -> void:
  var row = InvRow.instantiate()
  row.drop_type = drop_type
  row.count = amount
  item_container.add_child(row)

func clear_inventory() -> void:
  for child in item_container.get_children():
    child.queue_free()
  _update_visibility()

func _sort_inventory():
  var items = item_container.get_children()
  items.sort_custom(func(a, b):
    return int(a.count) > int(b.count)
  )
  for item in items:
    item_container.move_child(item, item_container.get_child_count() - 1)

func _update_visibility():
  visible = item_container.get_child_count() > 0
