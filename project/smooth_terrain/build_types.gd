extends Node

enum Type {
  LANTERN,
  RAIL
}

const NAMES = {
  Type.LANTERN: "Lantern",
  Type.RAIL: "Rail"
}

const ROTATABLE = {
  Type.LANTERN: false,
  Type.RAIL: true
}
