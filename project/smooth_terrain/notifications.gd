extends VBoxContainer

func _ready():
  Global.display_message.connect(_on_display_message)

func _on_display_message(message: String) -> void:
  var label = Label.new()
  label.text = message
  add_child(label)
  await get_tree().create_timer(5.0).timeout
  var tween = get_tree().create_tween()
  tween.tween_property(label, "modulate:a", 0.0, 1.0)
  await tween.finished
  remove_child(label)
  label.queue_free()