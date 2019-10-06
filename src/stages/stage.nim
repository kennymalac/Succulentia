import csfml

# A Stage is just a Scene with transition effects, etc.
# Not actually a type... yet?

type Boundary* = tuple[left: cint, right: cint, top: cint, bottom: cint]

proc getOrigin*(size: Vector2i): Vector2f =
  return vec2(size.x/2, size.y/2)

