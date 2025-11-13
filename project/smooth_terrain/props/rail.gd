@tool

extends Node3D

class_name Rail

@export var rail_points: Array[RailPoint] = []:
  set(v):
    rail_points = v
    _disconnect_point_signals()
    _connect_point_signals()
    _invalidate_cache()
    _update()

@export var tie_spacing: float = 2.0:
  set(v):
    tie_spacing = max(v, 0.1)
    _invalidate_cache()
    _update()

@export var rail_width: float = 1.0:
  set(v):
    rail_width = max(v, 0.1)
    _update()

@export var tie_length: float = 1.0:
  set(v):
    tie_length = max(v, 0.001)
    _update()

@export var tie_thickness: float = 0.06:
  set(v):
    tie_thickness = max(v, 0.001)
    _update()

@export var rail_height: float = 0.14:
  set(v):
    rail_height = max(v, 0.001)
    _update()

@export var rail_thickness: float = 0.08:
  set(v):
    rail_thickness = max(v, 0.001)
    _update()

# Independent tie width so changing rail_thickness no longer affects tie length
@export var tie_width: float = 2.5:
  set(v):
    tie_width = max(v, 0.001)
    _update()

@export var show_debug_markers: bool = false:
  set(v):
    show_debug_markers = v
    _update()

# Scales the strength/length of the in/out handles at each RailPoint.
# Higher = broader, gentler curves. Lower = tighter/straighter.
@export var handle_strength: float = 1.0:
  set(v):
    handle_strength = clamp(v, 0.0, 5.0)
    _invalidate_cache()
    _update()

var _cached_curve: Curve3D
var _curve_valid: bool = false
var _last_point_count: int = 0
var _point_connections: Array = []

func get_rail_length() -> float:
  _ensure_curve()
  if _cached_curve:
    return _cached_curve.get_baked_length()
  return 0.0

func get_transform_at_distance(dist: float) -> Transform3D:
  _ensure_curve()
  if _cached_curve:
    var length := _cached_curve.get_baked_length()
    dist = clamp(dist, 0.0, length)
    var pos := _cached_curve.sample_baked(dist, true)
    var ahead_pos := _cached_curve.sample_baked(min(dist + 0.1, length), true)
    var tangent := (ahead_pos - pos).normalized()
    if tangent.length() < 0.001:
      tangent = Vector3.FORWARD
    # Use interpolated normal: nearest point's normal (could be improved with weighting)
    var rp_index := int(round((dist / length) * (rail_points.size() - 1)))
    var base_normal: Vector3 = rail_points[clamp(rp_index, 0, rail_points.size() - 1)].normal.normalized()
    if base_normal.length() < 0.5:
      base_normal = Vector3.UP
    var b := Basis.looking_at(tangent, base_normal)
    var local_t := Transform3D(b, pos)
    return global_transform * local_t
  return Transform3D.IDENTITY

func _connect_point_signals():
  _point_connections.clear()
  for i in range(rail_points.size()):
    var rp = rail_points[i]
    if rp and rp.has_method("connect"):
      rp.connect("point_changed", Callable(self, "_on_point_changed"))
      _point_connections.append(rp)

func _disconnect_point_signals():
  for rp in _point_connections:
    if rp and rp.has_method("disconnect"):
      rp.disconnect("point_changed", Callable(self, "_on_point_changed"))
  _point_connections.clear()

func _on_point_changed():
  _invalidate_cache()
  _update()

func _ready():
  _update()

func _invalidate_cache():
  _curve_valid = false

func _ensure_curve():
  if _curve_valid and _cached_curve and _last_point_count == rail_points.size():
    return
  _cached_curve = Curve3D.new()
  # Automatic smooth tangents (Catmull-Rom-like converted to Bezier handles)
  var n := rail_points.size()
  for i in range(n):
    var p: Vector3 = rail_points[i].position
    var in_tangent: Vector3 = Vector3.ZERO
    var out_tangent: Vector3 = Vector3.ZERO
    if n >= 2:
      if i == 0:
        var p1: Vector3 = rail_points[1].position
        var m0 := (p1 - p)
        out_tangent = m0 * ((handle_strength) / 3.0)
        # Clamp to avoid overshoot
        var max0 := (p1 - p).length() * 0.5
        if out_tangent.length() > max0 and out_tangent.length() > 0.00001:
          out_tangent = out_tangent.normalized() * max0
      elif i == n - 1:
        var p0: Vector3 = rail_points[n - 2].position
        var mn := (p - p0)
        in_tangent = -mn * ((handle_strength) / 3.0)
        var maxn := (p - p0).length() * 0.5
        if in_tangent.length() > maxn and in_tangent.length() > 0.00001:
          in_tangent = in_tangent.normalized() * maxn
      else:
        var p_prev: Vector3 = rail_points[i - 1].position
        var p_next: Vector3 = rail_points[i + 1].position
        var m := (p_next - p_prev) * 0.5
        in_tangent = -m * ((handle_strength) / 3.0)
        out_tangent = m * ((handle_strength) / 3.0)
        # Clamp by local segment lengths to keep stability
        var max_in := (p - p_prev).length() * 0.5
        var max_out := (p_next - p).length() * 0.5
        var lin := in_tangent.length()
        if lin > max_in and lin > 0.00001:
          in_tangent = in_tangent.normalized() * max_in
        var lout := out_tangent.length()
        if lout > max_out and lout > 0.00001:
          out_tangent = out_tangent.normalized() * max_out
    # Apply per-point rotation around the point's normal to the handle vectors so rotation
    # manipulates the curve handles (affects shape) instead of only rotating ties.
    var rrot: float = 0.0
    if rail_points[i] and "rotation" in rail_points[i]:
      rrot = rail_points[i].rotation
    var base_norm: Vector3 = Vector3.UP
    if rail_points[i] and "normal" in rail_points[i]:
      base_norm = rail_points[i].normal.normalized()
    if abs(rrot) > 0.000001:
      var qrot := Quaternion(base_norm, rrot)
      in_tangent = qrot * in_tangent
      out_tangent = qrot * out_tangent

    _cached_curve.add_point(p, in_tangent, out_tangent)
  _cached_curve.bake_interval = 0.25
  _curve_valid = true
  _last_point_count = rail_points.size()

func _clear_children():
  for c in get_children():
    c.queue_free()

func _update():
  if not is_inside_tree():
    return
  _clear_children()
  if rail_points.size() < 2:
    return
  _ensure_curve()

  var curve := _cached_curve
  var length := curve.get_baked_length()
  if length <= 0.001:
    return

  var step_dist := tie_spacing
  var dist := 0.0
  var previous_tie: Node3D = null
  while dist <= length + 0.001:
    var pos := curve.sample_baked(dist, true)
    var ahead_pos := curve.sample_baked(min(dist + 0.1, length), true)
    var tangent := (ahead_pos - pos).normalized()
    if tangent.length() < 0.001 and previous_tie:
      tangent = previous_tie.global_transform.basis.z
    # Use interpolated normal: nearest point's normal (could be improved with weighting)
    var rp_index := int(round((dist / length) * (rail_points.size() - 1)))
    var base_normal: Vector3 = rail_points[clamp(rp_index, 0, rail_points.size() - 1)].normal.normalized()
    if base_normal.length() < 0.5:
      base_normal = Vector3.UP
    # Note: per-point rotation is applied to curve handles in _ensure_curve so
    # it affects the curve shape; don't rotate the sampled tangent here.

    # Tie
    var tie := CSGBox3D.new()
    tie.material = StandardMaterial3D.new()
    tie.material.albedo_color = Color.SANDY_BROWN
    tie.position = pos
    tie.scale = Vector3(tie_length, tie_thickness, tie_width)
    tie.look_at_from_position(pos, pos + tangent, base_normal)
    add_child(tie)

    # Rails between ties
    if previous_tie != null:
      _add_rails_between(previous_tie, tie, rail_width * 0.5)
    previous_tie = tie
    dist += step_dist

  if show_debug_markers:
    _add_debug_markers()

func _add_rails_between(a: Node3D, b: Node3D, offset: float):
  var dir_a := a.global_transform.basis.z.normalized()
  var dir_b := b.global_transform.basis.z.normalized()
  var up_a := a.global_transform.basis.y.normalized()
  var up_b := b.global_transform.basis.y.normalized()
  var side_a := dir_a.cross(up_a).normalized()
  var side_b := dir_b.cross(up_b).normalized()

  var a_left := a.position + side_a * offset
  var b_left := b.position + side_b * offset
  var a_right := a.position - side_a * offset
  var b_right := b.position - side_b * offset

  var up_avg_left := (up_a + up_b).normalized()
  var up_avg_right := up_avg_left
  if up_avg_left.length() < 0.001:
    up_avg_left = Vector3.UP
    up_avg_right = Vector3.UP
  _create_rail_segment(a_left, b_left, up_avg_left)
  _create_rail_segment(a_right, b_right, up_avg_right)

func _create_rail_segment(start_pos: Vector3, end_pos: Vector3, up: Vector3):
  var length := (end_pos - start_pos).length()
  if length < 0.001:
    return
  var mid := (start_pos + end_pos) * 0.5
  var dir := (end_pos - start_pos).normalized()
  var seg := CSGBox3D.new()
  seg.material = StandardMaterial3D.new()
  seg.material.albedo_color = Color.SILVER
  seg.position = mid
  seg.scale = Vector3(rail_thickness, rail_height, length)
  seg.look_at_from_position(mid, mid + dir, up)
  add_child(seg)

func _add_debug_markers():
  for i in range(rail_points.size()):
    var rp = rail_points[i]
    var m := CSGSphere3D.new()
    m.radius = 0.25
    m.material = StandardMaterial3D.new()
    var t := float(i) / float(max(rail_points.size() - 1, 1))
    m.material.albedo_color = Color(1.0 - t, t, 0.2)
    m.position = rp.position
    add_child(m)

    # Add a Label3D above the point showing its index
    var lbl := Label3D.new()
    lbl.text = str(i)
    # billboard so it faces the camera (1 = enabled in .tscn usage)
    lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    # render on top / ignore depth so the label renders through geometry
    lbl.no_depth_test = true
    lbl.fixed_size = true
    lbl.pixel_size = 0.001
    lbl.position = rp.position + Vector3(0, 0.45, 0)
    lbl.modulate = Color(1, 1, 1)
    add_child(lbl)
