import csfml

type
  Entity* = ref object of RootObj
    position*: Vector2i
    sprite*: Sprite

proc move*(self: Entity, position: Vector2i) =
  self.position = position

proc new_entity*(self: Entity, sprite: Sprite) =
  self.sprite = sprite

proc print*(self: Entity) =
  echo "I am an entity\n"
