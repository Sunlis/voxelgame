extends Node

func get_cmdline_arg(n: String):
  var args = OS.get_cmdline_args()
  for arg in args:
    if arg.begins_with("--%s=" % n):
      var split_arg = arg.split("=")
      if split_arg.size() == 2:
        return split_arg[1]
  return null

func print(message: Variant):
  var window_id = get_cmdline_arg("window_id")
  print("[%s] %s" % [window_id, message])
