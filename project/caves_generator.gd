extends VoxelGeneratorScript

@export var noises: Array[ZN_FastNoiseLite] = []

# Change channel to SDF
const channel : int = VoxelBuffer.CHANNEL_SDF

func _get_noise(pos: Vector3) -> float:
  var out = 1.0
  for noise in noises:
    out *= noise.get_noise_3d(pos.x, pos.y, pos.z)
  return out

func _generate_block(out_buffer : VoxelBuffer, origin_in_voxels : Vector3i, lod : int) -> void:
  # We'll have to iterate every 3D voxel in the block this time
  for rz in out_buffer.get_size().z:
    for rx in out_buffer.get_size().x:
      # The following part only depends on `x` and `z`, 
      # so moving it out of the innermost loop optimizes things a little.

      # Get voxel world position.
      # To account for LOD we multiply local coordinates by 2^lod.
      # This can be done faster than `pow()` by using binary left-shift.
      # Y is left out because we'll compute it in the inner loop.
      var pos_world := Vector3(origin_in_voxels) + Vector3(rx << lod, 0, rz << lod)

      # Innermost loop
      for ry in out_buffer.get_size().y:
        pos_world.y = origin_in_voxels.y + (ry << lod)

        var noise_value = _get_noise(pos_world) * 0.03

        var height = noise_value if pos_world.y < -10 else pos_world.y

        # When outputting signed distances, use `set_voxel_f` instead of `set_voxel`
        out_buffer.set_voxel_f(height, rx, ry, rz, channel)