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
  
  func get_rarity_at_depth(depth: float) -> float:
    if depth < min_depth or depth > max_depth:
      return 0.0
    var depth_range = max_depth - min_depth
    var middle_depth = min_depth + depth_range / 2
    var dist_from_center = abs(middle_depth - depth)
    return rarity * (1.0 - (dist_from_center / (depth_range / 2)))

var drop_configs: Dictionary = {
  
  # Garbage Tier (0 - 50)

  Type.TRASH: DropConfig.new(Type.TRASH)
      .set_name("Trash")
      .set_depth_range(0, 20)
      .set_rarity(0.5)
      .set_value(0.1),
  Type.BOTTLECAP: DropConfig.new(Type.BOTTLECAP)
      .set_name("Bottlecap")
      .set_depth_range(0, 30)
      .set_rarity(0.3)
      .set_value(0.3),
  Type.PENNY: DropConfig.new(Type.PENNY)
      .set_name("Penny")
      .set_depth_range(10, 50)
      .set_rarity(0.1)
      .set_value(0.5),
  
  # Common Tier (30 - 100)

  Type.COAL: DropConfig.new(Type.COAL)
      .set_name("Coal")
      .set_depth_range(20, 100)
      .set_rarity(0.6)
      .set_value(1),
  Type.HEMATITE: DropConfig.new(Type.HEMATITE)
      .set_name("Hematite")
      .set_depth_range(30, 120)
      .set_rarity(0.5)
      .set_value(1.5),
  Type.QUARTZ: DropConfig.new(Type.QUARTZ)
      .set_name("Quartz")
      .set_depth_range(40, 140)
      .set_rarity(0.4)
      .set_value(2),

  # Uncommon Tier (80 - 200)

  Type.GYPSUM: DropConfig.new(Type.GYPSUM)
      .set_name("Gypsum")
      .set_depth_range(70, 180)
      .set_rarity(0.3)
      .set_value(4),
  Type.PYRITE: DropConfig.new(Type.PYRITE)
      .set_name("Pyrite")
      .set_depth_range(80, 200)
      .set_rarity(0.25)
      .set_value(6),
  Type.MALACHITE: DropConfig.new(Type.MALACHITE)
      .set_name("Malachite")
      .set_depth_range(90, 220)
      .set_rarity(0.2)
      .set_value(8),

  # Rare Tier (180 - 300)

  Type.CINNABAR: DropConfig.new(Type.CINNABAR)
      .set_name("Cinnabar")
      .set_depth_range(160, 280)
      .set_rarity(0.15)
      .set_value(10),
  Type.GOLD: DropConfig.new(Type.GOLD)
      .set_name("Gold")
      .set_depth_range(180, 300)
      .set_rarity(0.1)
      .set_value(15),
  Type.PLATINUM: DropConfig.new(Type.PLATINUM)
      .set_name("Platinum")
      .set_depth_range(200, 320)
      .set_rarity(0.08)
      .set_value(20),
  
  # Exotic Tier (280+)

  Type.IRIDIUM: DropConfig.new(Type.IRIDIUM)
      .set_name("Iridium")
      .set_depth_range(270, 350)
      .set_rarity(0.05)
      .set_value(30),
  Type.OBSIDIAN: DropConfig.new(Type.OBSIDIAN)
      .set_name("Obsidian")
      .set_depth_range(300, 400)
      .set_rarity(0.03)
      .set_value(40),
  Type.KIMBERLITE: DropConfig.new(Type.KIMBERLITE)
      .set_name("Kimberlite")
      .set_depth_range(320, 450)
      .set_rarity(0.01)
      .set_value(50),
}