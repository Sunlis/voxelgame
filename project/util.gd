@tool

extends Node

class_name Util

static func wrap_mod(a: int, b: int) -> int:
  return ((a % b) + b) % b

static func wrap_fmod(a: float, b: float) -> float:
  return fmod(fmod(a, b) + b, b)