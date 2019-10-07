import entity
import csfml, csfml/audio

import ../soundRegistry
import ../assetLoader

type
  Succulent* = ref object of Entity
    health*: int
    hydration*: int
    deathSound*: Sound

proc newSucculent*(sprite: Sprite, soundRegistry: SoundRegistry): Succulent =
  result = Succulent(health: 100, deathSound: soundRegistry.getSound(SucculentDeathSound))
  initEntity(result, sprite)

proc print*(self: Succulent) =
  echo "I am a succulent\n"
