import csfml

import menu

import ../assetLoader

type
  GameMenuItemKind* = enum
    Clicker,
    Shovel,
    WateringCan

  GameMenuItem* = ref GameMenuItemObj
  GameMenuItemObj = object of MenuItem
    case kind*: GameMenuItemKind
    of Clicker: discard
    of Shovel: discard
    of WateringCan: discard

  GameMenu* = ref object of Menu

proc onClick*(self: GameMenuItem) =
  case self.kind:
    of Clicker: discard
    of Shovel: discard
    of WateringCan: discard

proc newGameMenuItem(self: GameMenu, kind: GameMenuItemKind): GameMenuItem =
  new result

  proc newSprite(location: string): Sprite = self.assetLoader.newSprite(self.assetLoader.newImageAsset(location))

  case kind:
    of Clicker: result = GameMenuItem(sprite: newSprite("game-button-clicker.png"))
    of Shovel: result = GameMenuItem(sprite: newSprite("game-button-shovel.png"))
    of WateringCan: result = GameMenuItem(sprite: newSprite("game-button-wattercan.png"))

proc newGameMenu*(assetLoader: AssetLoader): GameMenu =
  result = GameMenu(assetLoader: assetLoader)

  result.items = @[MenuItem(result.newGameMenuItem(Clicker)), MenuItem(result.newGameMenuItem(Shovel)), MenuItem(result.newGameMenuItem(WateringCan))]

proc draw*(self: GameMenu, window: RenderWindow) =
  discard
