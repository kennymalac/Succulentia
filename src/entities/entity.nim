import csfml
import times

type
  Entity* = ref object of RootObj
    sprite*: Sprite
    rect*: FloatRect

proc initEntity*(self: Entity, sprite: Sprite) =
  self.sprite = sprite
  self.rect = rect(sprite.position.x, sprite.position.y, cfloat(sprite.texture.size.x), cfloat(sprite.texture.size.y))

proc initEntity*(self: Entity, sprite: Sprite, rect: FloatRect) =
  self.sprite = sprite
  self.rect = rect

proc newEntity*(sprite: Sprite): Entity =
  new result
  initEntity(result, sprite)

proc update*(self: Entity, dt: times.Duration) =
  discard

proc draw() =
  discard

proc move*(self: Entity, position: Vector2i) =
  discard

proc print*(self: Entity) =
  echo "I am an entity\n"
