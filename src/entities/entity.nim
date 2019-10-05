import csfml

type
  Entity* = ref object of RootObj
    sprite*: Sprite

proc newEntity*(self: Entity, sprite: Sprite, ) =
  self.sprite = sprite

proc update*(self: Entity) =
  discard

proc draw() =
  discard

proc move*(self: Entity, position: Vector2i) =
  discard

proc print*(self: Entity) =
  echo "I am an entity\n"
