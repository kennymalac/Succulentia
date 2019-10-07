import csfml

import assetLoader

type
  GameCursorKind* = enum
    ClickerCursor,
    ShovelCursor,
    WateringCanCursor

  GameCursor* = ref GameCursorObj
  GameCursorObj = object
    cursor*: Cursor
    sprite*: Sprite
    case kind*: GameCursorKind
    of ClickerCursor: discard
    of ShovelCursor: discard
    of WateringCanCursor: discard

proc newGameCursor*(assetLoader: AssetLoader, kind: GameCursorKind, variant: string = ""): GameCursor =
  new result

  var location = ""

  case kind:
    of ClickerCursor: location = "cursor-clicker-1.png"
    of ShovelCursor: location = "cursor-shovel-1.png"
    of WateringCanCursor:
      if variant == "empty":
        location = "cursor-watercan-empty-1.png"
      else:
        location = "cursor-watercan-full-1.png"

  echo location
  let image = assetLoader.newImage(location);
  result.cursor = newCursor(image.pixelsPtr, image.size, vec2(cint(image.size.x/2), cint(image.size.y/2)))
  result.sprite = assetLoader.newSprite(assetLoader.newImageAsset(location))
  result.sprite.origin = vec2(result.sprite.texture.size.x/2, result.sprite.texture.size.y/2)
