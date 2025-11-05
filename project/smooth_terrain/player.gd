extends CharacterBody3D

@export var gravity = 18.0

func _physics_process(delta):
  if self.is_on_floor():
    self.velocity *= 0.9
  else:
    self.velocity *= 0.98

  var up = Vector3(0, 1, 0)
  self.velocity -= up * gravity * delta

  move_and_slide()
