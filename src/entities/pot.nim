import csfml
import entity, succulent

type
  Pot* = ref object of Entity
    health*: int
    suc*: Succulent

proc newPot*(self: Pot, sprite: Sprite): Pot =
  result = Pot(health: 100)
  initEntity(result, sprite)

# pre-planted pot
proc newPot*(self: Pot, sprite: Sprite, suc: Succulent): Pot =
  result = Pot(health: 100)
  result.suc = suc
  initEntity(result, sprite)

