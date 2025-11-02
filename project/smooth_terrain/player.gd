extends CharacterBody3D

@export var base_speed = 40.0
@export var jump_force = 1000.0
@export var gravity = 18.0

func _physics_process(delta):
  var head = self

  var grounded = self.is_on_floor()
  var speed = base_speed

  if grounded:
    self.velocity *= 0.9
  else:
    self.velocity *= 0.98
    speed = base_speed * 0.5

  var forward = -head.transform.basis.z
  var right = head.transform.basis.x
  var up = Vector3(0, 1, 0)
  
  if Input.is_key_pressed(KEY_A):
    self.velocity -= right * speed * delta
  elif Input.is_key_pressed(KEY_D):
    self.velocity += right * speed * delta

  if Input.is_key_pressed(KEY_W):
    self.velocity += forward * speed * delta
  elif Input.is_key_pressed(KEY_S):
    self.velocity -= forward * speed * delta
  
  if grounded and Input.is_key_pressed(KEY_SPACE):
    self.velocity += up * jump_force * delta

  self.velocity -= up * gravity * delta

  move_and_slide()
