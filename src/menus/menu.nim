import csfml

import ../assetLoader

type
  MenuItem* = ref object of RootObj
    sprite*: Sprite

  Menu* = ref object of RootObj
    assetLoader*: AssetLoader
    items*: seq[MenuItem]

proc onClick*(self: MenuItem) =
  discard

proc newMenu*(items: seq[MenuItem], assetLoader: AssetLoader): Menu =
  result = Menu(items: items, assetLoader: assetLoader)

proc draw(self: Menu, window: RenderWindow) =
  discard

proc newMenuItem(self: Menu): MenuItem =
  result
