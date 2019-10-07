import csfml
import entity, succulent
import options

type
  Pot* = ref object of Entity
    dirtSprite*: Sprite
    health*: int
    suc*: Option[Succulent]
    hasDirt*: bool
    hasSuc*: bool

proc newPot*(sprite: Sprite, dirtSprite: Sprite): Pot =
  result = Pot(dirtSprite: dirtSprite, health: 100, suc: none(Succulent), hasDirt: false, hasSuc: false)
  initEntity(result, sprite)

proc newPot*(sprite: Sprite, suc: Option[Succulent]): Pot =
  result = Pot(health: 100)
  result.suc = suc
  initEntity(result, sprite)

proc placeSuc*(self: Pot, suc: Option[Succulent]) =
  self.suc = suc
  self.hasSuc = true

proc placeDirt*(self: Pot) =
  self.sprite = self.dirtSprite
  self.hasDirt = true

