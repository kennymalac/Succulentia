import times

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
    of WateringCan: result = GameMenuItem(sprite: newSprite("game-button-watercan.png"))

proc newGameMenu*(assetLoader: AssetLoader, size: Vector2i): GameMenu =
  result = GameMenu(assetLoader: assetLoader)
  result.items = @[MenuItem(result.newGameMenuItem(Clicker)), MenuItem(result.newGameMenuItem(Shovel)), MenuItem(result.newGameMenuItem(WateringCan))]

  let yOffsetFactor = 10

  let itemsLength = result.items.len

  let leftBottomCornerTop = (
    size.x - result.items[0].sprite.texture.size.x - 10,
    size.y - result.items[0].sprite.texture.size.y * itemsLength - yOffsetFactor * itemsLength
  )

  var yOffset = 0
  for item in result.items:
    item.sprite.position = vec2(leftBottomCornerTop[0], leftBottomCornerTop[1] + yOffset)
    yOffset += item.sprite.texture.size.y + yOffsetFactor

proc update*(self: GameMenu, dt: times.Duration) =
  discard

proc draw*(self: GameMenu, window: RenderWindow) =
  for item in self.items:
    window.draw(item.sprite)
