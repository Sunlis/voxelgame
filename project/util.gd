@tool

extends Node

class_name Util

static func wrap_mod(a: int, b: int) -> int:
  return ((a % b) + b) % b

static func wrap_fmod(a: float, b: float) -> float:
  return fmod(fmod(a, b) + b, b)

static func rangef(start: Variant, end: Variant, step: Variant):
  var res = Array()
  var i = start
  while i < end:
    res.push_back(i)
    i += step
  return res
