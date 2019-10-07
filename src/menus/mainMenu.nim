import times

import options

import csfml, csfml/audio

import menu

import ../assetLoader
import ../soundRegistry

type
  MainMenuItemKind* = enum
    Start,
    Exit

  MainMenuItem* = ref MainMenuItemObj
  MainMenuItemObj = object of MenuItem
    case kind*: MainMenuItemKind
    of Start: discard
    of Exit: discard

  MainMenu* = ref object of Menu

proc onClick*(self: MainMenuItem) =
  case self.kind:
    of Start: discard
    of Exit: discard

proc newMainMenuItem(self: MainMenu, kind: MainMenuItemKind): MainMenuItem =
  result = MainMenuItem(kind: kind)

  proc newSprite(location: string): Sprite = self.assetLoader.newSprite(self.assetLoader.newImageAsset(location))

  case kind:
    of Start: result.sprite = newSprite("menu-button-start.png")
    of Exit: result.sprite = newSprite("menu-button-exit.png")

  result.sprite.scale = vec2(2.0 * result.sprite.scale.x, 2.0 * result.sprite.scale.y)

proc newMainMenu*(assetLoader: AssetLoader, soundRegistry: SoundRegistry, size: Vector2i): MainMenu =
  result = MainMenu(assetLoader: assetLoader, clickSound: soundRegistry.getSound(ClickSound))
  result.items = @[MenuItem(result.newMainMenuItem(Start)), MenuItem(result.newMainMenuItem(Exit))]

  let yOffsetFactor = cfloat(10)

  let itemsLength = result.items.len

  # Draw menu in center of screen
  let center = (
    cfloat(size.x) / 2 - result.items[0].sprite.scaledSize.x/2,
    cfloat(size.y) / 2 - result.items[0].sprite.scaledSize.y/2
  )

  var yOffset = cfloat(0.0)
  for item in result.items:
    item.sprite.position = vec2(center[0], center[1] + cfloat(yOffset))
    yOffset += item.sprite.scaledSize.y + yOffsetFactor

proc update*(self: MainMenu, dt: times.Duration) =
  discard

proc draw*(self: MainMenu, window: RenderWindow) =
  for item in self.items:
    window.draw(item.sprite)

type containsResult = tuple[doesContain: bool, maybeKind: Option[MainMenuItemKind]]

proc contains*(self: MainMenu, point: Vector2f): containsResult =
  for item in self.items:
    if item.sprite.globalBounds.contains(point):
      return (true, some(MainMenuItem(item).kind))

  return (false, none(MainMenuItemKind))
