extends Node

enum Type {
  LANTERN,
  RAIL,
  BRIDGE
}

const NAMES = {
  Type.LANTERN: "Lantern",
  Type.RAIL: "Rail",
  Type.BRIDGE: "Bridge"
}

const ROTATABLE = {
  Type.LANTERN: false,
  Type.RAIL: true,
  Type.BRIDGE: false
}
