import times

import csfml, csfml/audio

import ../assetLoader
import ../soundRegistry

type
  MenuItem* = ref object of RootObj
    sprite*: Sprite

  Menu* = ref object of RootObj
    assetLoader*: AssetLoader
    clickSound*: Sound
    items*: seq[MenuItem]

proc onClick*(self: MenuItem) =
  discard

proc newMenu*(items: seq[MenuItem], soundRegistry: SoundRegistry, assetLoader: AssetLoader): Menu =
  result = Menu(items: items, assetLoader: assetLoader, clickSound: soundRegistry.getSound(ClickSound))

proc update(self: Menu, dt: times.Duration) =
  discard

proc draw(self: Menu, window: RenderWindow) =
  discard

proc newMenuItem(self: Menu): MenuItem =
  result
