import strformat
import random

import entity
import csfml, csfml/audio

import ../soundRegistry
import ../assetLoader

type
  Succulent* = ref object of Entity
    health*: int
    hydration*: int
    deathSound*: Sound

let succVariants = @[
  "succ-aloe-5",
  "succ-aloe-5-v1",
  "succ-aloe-5-v2",
  "succ-andro-5",
  "succ-andro-5-v1",
  "succ-andro-5-v2",
  "succ-sene-5",
  "succ-sene-5-v1",
  "succ-sene-5-v2"
]

proc newSucculent*(sprite: Sprite, soundRegistry: SoundRegistry): Succulent =
  result = Succulent(health: 100, deathSound: soundRegistry.getSound(SucculentDeathSound))
  initEntity(result, sprite)

proc randomSuccSprite*(assetLoader: AssetLoader): Sprite =
  randomize()
  # TODO growth should give right set of 5
  return assetLoader.newSprite(
    assetLoader.newImageAsset(fmt"{succVariants[rand(succVariants.len)]}.png")
  )

proc print*(self: Succulent) =
  echo "I am a succulent\n"
