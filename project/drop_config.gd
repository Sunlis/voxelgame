@tool

extends Resource

class_name Drops

enum Type {
  TRASH,
  BOTTLECAP,
  PENNY,

  COAL,
  HEMATITE,
  QUARTZ,

  GYPSUM,
  PYRITE,
  MALACHITE,

  CINNABAR,
  GOLD,
  PLATINUM,

  IRIDIUM,
  OBSIDIAN,
  KIMBERLITE
}

static func get_random_type() -> Type:
  var types = Type.values()
  return types[randi() % types.size()]

class DropConfig:
  var type: Type
  var name: String
  var min_depth: float
  var max_depth: float
  var rarity: float
  var value: float

  func _init(t: Type):
    self.type = t
  
  func set_name(n: String) -> DropConfig:
    self.name = n
    return self
  
  func set_depth_range(min_d: float, max_d: float) -> DropConfig:
    self.min_depth = min_d
    self.max_depth = max_d
    return self
  
  func set_rarity(r: float) -> DropConfig:
    self.rarity = r
    return self
  
  func set_value(v: float) -> DropConfig:
    self.value = v
    return self
  
  func drop_at_depth(depth: float) -> bool:
    return depth >= min_depth and depth <= max_depth
  
  func get_rarity_at_depth(depth: float) -> float:
    if depth < min_depth or depth > max_depth:
      return 0.0
    var depth_range = max_depth - min_depth
    var middle_depth = min_depth + depth_range / 2
    var dist_from_center = abs(middle_depth - depth)
    return rarity * (1.0 - (dist_from_center / (depth_range / 2)))
  
  func _to_string() -> String:
    return "DropConfig(type=%s, name=%s, depth=[%.1f, %.1f], rarity=%.3f, value=%.2f)" % [
      str(type), name, min_depth, max_depth, rarity, value
    ]

static var drop_configs: Array[DropConfig] = [
  
  # Garbage Tier (0 - 50)

  DropConfig.new(Type.TRASH)
      .set_name("Trash")
      .set_depth_range(0, 20)
      .set_rarity(0.5)
      .set_value(0.1),
  DropConfig.new(Type.BOTTLECAP)
      .set_name("Bottlecap")
      .set_depth_range(0, 30)
      .set_rarity(0.3)
      .set_value(0.3),
  DropConfig.new(Type.PENNY)
      .set_name("Penny")
      .set_depth_range(10, 50)
      .set_rarity(0.1)
      .set_value(0.5),
  
  # Common Tier (30 - 100)

  DropConfig.new(Type.COAL)
      .set_name("Coal")
      .set_depth_range(20, 100)
      .set_rarity(0.6)
      .set_value(1),
  DropConfig.new(Type.HEMATITE)
      .set_name("Hematite")
      .set_depth_range(30, 120)
      .set_rarity(0.5)
      .set_value(1.5),
  DropConfig.new(Type.QUARTZ)
      .set_name("Quartz")
      .set_name("Quartz")
      .set_depth_range(40, 140)
      .set_rarity(0.4)
      .set_value(2),

  # Uncommon Tier (80 - 200)

  DropConfig.new(Type.GYPSUM)
      .set_name("Gypsum")
      .set_depth_range(70, 180)
      .set_rarity(0.3)
      .set_value(4),
  DropConfig.new(Type.PYRITE)
      .set_name("Pyrite")
      .set_depth_range(80, 200)
      .set_rarity(0.25)
      .set_value(6),
  DropConfig.new(Type.MALACHITE)
      .set_name("Malachite")
      .set_depth_range(90, 220)
      .set_rarity(0.2)
      .set_value(8),

  # Rare Tier (180 - 300)

  DropConfig.new(Type.CINNABAR)
      .set_name("Cinnabar")
      .set_depth_range(160, 280)
      .set_rarity(0.15)
      .set_value(10),
  DropConfig.new(Type.GOLD)
      .set_name("Gold")
      .set_depth_range(180, 300)
      .set_rarity(0.1)
      .set_value(15),
  DropConfig.new(Type.PLATINUM)
      .set_name("Platinum")
      .set_depth_range(200, 320)
      .set_rarity(0.08)
      .set_value(20),
  
  # Exotic Tier (280+)

  DropConfig.new(Type.IRIDIUM)
      .set_name("Iridium")
      .set_depth_range(270, 350)
      .set_rarity(0.05)
      .set_value(30),
  DropConfig.new(Type.OBSIDIAN)
      .set_name("Obsidian")
      .set_depth_range(300, 400)
      .set_rarity(0.03)
      .set_value(40),
  DropConfig.new(Type.KIMBERLITE)
      .set_name("Kimberlite")
      .set_depth_range(320, 450)
      .set_rarity(0.01)
      .set_value(50),
]

static func get_drop_config(drop_type: Type) -> DropConfig:
  for config in drop_configs:
    if config.type == drop_type:
      return config
  return null

class DepthDrop:
  var type: Type
  var depth: float
  var should_drop: bool
  func _init(t: Type, d: float, s: bool):
    self.type = t
    self.depth = d
    self.should_drop = s

static func select_drop_at_depth(depth: float, drop_rate: float) -> DepthDrop:
  var total_rarity = 0.0
  var valid_drops = []
  for config in drop_configs:
    if config.drop_at_depth(depth):
      total_rarity += config.get_rarity_at_depth(depth)
      valid_drops.append(config)
  
  if total_rarity == 0.0:
    return DepthDrop.new(Type.TRASH, depth, false)

  var pick = randf() * total_rarity
  var cumulative = 0.0
  for config in valid_drops:
    cumulative += config.get_rarity_at_depth(depth)
    if pick <= cumulative:
      if randf() <= drop_rate:
        return DepthDrop.new(config.type, depth, true)
      break
  return DepthDrop.new(Type.TRASH, depth, false)
