import times

import options

import csfml, csfml/audio

import menu

import ../assetLoader
import ../soundRegistry

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
  result = GameMenuItem(kind: kind)

  proc newSprite(location: string): Sprite = self.assetLoader.newSprite(self.assetLoader.newImageAsset(location))

  case kind:
    of Clicker: result.sprite = newSprite("game-button-clicker.png")
    of Shovel: result.sprite = newSprite("game-button-shovel.png")
    of WateringCan: result.sprite = newSprite("game-button-watercan.png")

  result.sprite.scale = vec2(1.5 * result.sprite.scale.x, 1.5 * result.sprite.scale.y)

proc newGameMenu*(assetLoader: AssetLoader, soundRegistry: SoundRegistry, size: Vector2i): GameMenu =
  result = GameMenu(assetLoader: assetLoader, clickSound: soundRegistry.getSound(ClickSound))
  result.items = @[MenuItem(result.newGameMenuItem(Clicker)), MenuItem(result.newGameMenuItem(Shovel)), MenuItem(result.newGameMenuItem(WateringCan))]

  let yOffsetFactor = cfloat(10)

  let itemsLength = result.items.len

  # Draw menu in bottom left of screen
  let leftBottomCornerTop = (
    cfloat(size.x) - result.items[0].sprite.scaledSize.x - cfloat(10),
    cfloat(size.y) - result.items[0].sprite.scaledSize.y * cfloat(itemsLength) - yOffsetFactor * cfloat(itemsLength)
  )

  var yOffset = cfloat(0.0)
  for item in result.items:
    item.sprite.position = vec2(leftBottomCornerTop[0], leftBottomCornerTop[1] + cfloat(yOffset))
    yOffset += item.sprite.scaledSize.y + yOffsetFactor

proc update*(self: GameMenu, dt: times.Duration) =
  discard

proc draw*(self: GameMenu, window: RenderWindow) =
  for item in self.items:
    window.draw(item.sprite)

type containsResult = tuple[doesContain: bool, maybeKind: Option[GameMenuItemKind]]

proc contains*(self: GameMenu, point: Vector2f): containsResult =
  for item in self.items:
    if item.sprite.globalBounds.contains(point):
      return (true, some(GameMenuItem(item).kind))

  return (false, none(GameMenuItemKind))
