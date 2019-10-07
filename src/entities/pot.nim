import csfml
import entity, succulent

type
  Pot* = ref object of Entity
    health*: int
    suc*: Succulent
    hasDirt*: bool
    hasSuc*: bool

proc newPot*(self: Pot, sprite: Sprite): Pot =
  result = Pot(health: 100, suc: nil, hasDirt: false, hasSuc: false)
  initEntity(result, sprite)

proc newPot*(self: Pot, sprite: Sprite, suc: Succulent): Pot =
  result = Pot(health: 100)
  result.suc = suc
  initEntity(result, sprite)

proc placeSuc*(self: Pot, suc: Succulent): =
  self.suc = suc
  self.hasSuc = true

proc placeDirt*(self: Pot, sprite: Sprite): =
  self.sprite = sprite
  self.hasDirt = true

