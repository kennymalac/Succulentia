import entity
import csfml

type
  Succulent* = ref object of Entity
    health*: int
    hydration*: int

proc newSucculent*(sprite: Sprite): Succulent =
  result = Succulent(health: 100)
  initEntity(result, sprite)

proc print*(self: Succulent) =
  echo "I am a succulent\n"
