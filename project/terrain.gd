extends Resource

class_name TerrainUtil

static func sphere_intersect(center: Vector3, radius: float) -> bool:
  var terrain = Global.get_terrain()
  if not terrain:
    print("No terrain registered!")
    return false
  var vt = terrain.get_voxel_tool()
  vt.channel = VoxelBuffer.CHANNEL_SDF
  var collisions = 0
  for i in Util.rangef(0, 2 * PI, PI / 4):
    for j in Util.rangef(0, 2 * PI, PI / 4):
      for r in Util.rangef(0, radius, radius / 5.0):
        var x = radius * cos(i) * sin(j)
        var y = radius * sin(i) * sin(j)
        var z = radius * cos(j)
        var offset = Vector3(x, y, z)
        var voxel = vt.get_voxel_f(center + offset)
        # in the SDF channel, negative = "inside terrain" and positive = "outside terrain"
        if voxel < 0.0:
          collisions += 1
          if collisions > 3:
            return true
  return false
