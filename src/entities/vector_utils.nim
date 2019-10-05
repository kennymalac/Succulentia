import csfml
import math

proc normalize*(v: Vector2f): Vector2f =
  var length: float = sqrt(pow(v.x, 2) + pow(v.y, 2))
  var v2: Vector2f = vec2(v.x / length, v.y / length)
  return v2
