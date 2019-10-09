import strformat
import random
import options

import entity, pot
import csfml, csfml/audio

import ../soundRegistry
import ../assetLoader

type
  Succulent* = ref object of Entity
    health*: int
    hydration*: int
    deathSound*: Sound
    pot*: Option[Pot]

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
  result = Succulent(health: 100, deathSound: soundRegistry.getSound(SucculentDeathSound), pot: none(Pot))
  initEntity(result, sprite)

proc randomSuccSprite*(assetLoader: AssetLoader): Sprite =
  randomize()
  # TODO growth should give right set of 5
  return assetLoader.newSprite(
    assetLoader.newImageAsset(fmt"{sample(succVariants)}.png")
  )

proc setPot*(self: Succulent, pot: Option[Pot]) =
  self.pot = pot
  self.pot.get().hasSuc = true
  self.sprite.position = vec2(get(self.pot).sprite.position.x, get(self.pot).sprite.position.y - float(get(self.pot).sprite.scaledSize.y) - 12)
  self.rect = rect(self.sprite.position.x - 5, self.sprite.position.y - 5, cfloat(self.sprite.scaledSize.x) / 2, cfloat(self.sprite.scaledSize.y) / 2)

proc die*(self: Succulent) =
  self.pot.get().hasSuc = false
  self.isDead = true

proc setSucPosition(self: Succulent) =
  self.sprite.position = get(self.pot).sprite.position

proc print*(self: Succulent) =
  echo "I am a succulent\n"
