extends Node

func _notification(what: int):
  if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
    _exit_tree()

func _exit_tree():
  UPNPHelper.cleanup()
