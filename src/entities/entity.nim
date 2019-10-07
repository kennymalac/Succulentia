import csfml
import times

import ../assetLoader

type
  Entity* = ref object of RootObj
    sprite*: Sprite
    rect*: FloatRect
    isDead*: bool
    interRect*: FloatRect

proc initEntity*(self: Entity, sprite: Sprite) =
  self.sprite = sprite
  self.sprite.origin = vec2(cfloat(sprite.scaledSize.x / 2), cfloat(sprite.scaledSize.y) / 2)
  self.rect = rect(sprite.position.x - 5, sprite.position.y - 5, cfloat(sprite.scaledSize.x) / 2, cfloat(sprite.scaledSize.y) / 2)
  self.interRect = rect(0, 0, 0, 0)

proc initEntity*(self: Entity, sprite: Sprite, rect: FloatRect) =
 self.sprite = sprite
 self.rect = rect
 self.isDead = false

proc newEntity*(sprite: Sprite): Entity =
  new result
  initEntity(result, sprite)

proc update*(self: Entity, dt: times.Duration) =
  discard

proc draw() =
  discard

proc move*(self: Entity, position: Vector2i) =
  discard

proc updateRectPosition*(self: Entity) =
  self.rect = rect(self.sprite.position.x, self.sprite.position.y, cfloat(self.sprite.scaledSize.x) / 2, cfloat(self.sprite.scaledSize.y) / 2)

proc print*(self: Entity) =
  echo "I am an entity\n"
