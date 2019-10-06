import csfml
import math

proc normalize*(v: Vector2f): Vector2f =
  var length: float = sqrt(pow(v.x, 2) + pow(v.y, 2))
  var v2: Vector2f = vec2(v.x / length, v.y / length)
  return v2

# euclidian distance between two vectors
proc eDistance*(v1: Vector2f, v2: Vector2f): float =
  return abs(sqrt((pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2))))
