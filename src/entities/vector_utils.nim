import csfml
import math

proc normalize*(v: Vector2f): Vector2f =
  var length: float = sqrt(pow(v.x, 2) + pow(v.y, 2))
  var v2: Vector2f = vec2(v.x / length, v.y / length)
  return v2

# euclidian distance between two vectors
proc eDistance*(v1: Vector2f, v2: Vector2f): float =
  return abs(sqrt((pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2))))

# angle between two vectors in degrees
proc vAngle*(v1: Vector2f, v2: Vector2f): float =
  var dx: float = v2.x - v1.x
  var dy: float = v2.y - v1.y
  
  var angle: float = arctan2(dy, dx)
  return 90 + angle * 180 / PI
