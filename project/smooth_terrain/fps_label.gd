extends Label

const HISTORY_LIMIT = 100

var _history = []
var _sum = 0.0

func _process(delta: float):
  _history.append(delta)
  _sum += delta

  if _history.size() > HISTORY_LIMIT:
    var removed = _history.pop_front()
    _sum -= removed
  
  var fps = 1.0 / (_sum / _history.size())
  text = "FPS: %.3f" % fps
