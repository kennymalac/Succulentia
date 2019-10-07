import csfml
import entity

type
  Pot* = ref object of Entity
    dirtSprite*: Sprite
    health*: int
    hasDirt*: bool
    hasSuc*: bool

proc newPot*(sprite: Sprite, dirtSprite: Sprite): Pot =
  result = Pot(dirtSprite: dirtSprite, health: 100, hasDirt: false, hasSuc: false)
  initEntity(result, sprite)
  result.dirtSprite.origin = sprite.origin

proc placeDirt*(self: Pot) =
  self.sprite = self.dirtSprite
  self.hasDirt = true

proc setPosition*(self: Pot, v: Vector2f) =
  self.sprite.position = v
  self.dirtSprite.position = v
