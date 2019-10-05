import csfml

# A Stage is just a Scene with transition effects, etc.
# Not actually a type... yet?

type Boundary* = tuple[left: cint, right: cint, top: cint, bottom: cint]

proc getOrigin*(size: Vector2i, boundary: Boundary): Vector2f =
  return vec2(size.x/2 + boundary.left/2 + boundary.right/2, size.y/2 + boundary.top/2 + boundary.bottom/2)

