import csfml

import assetLoader

type
  GameCursorKind* = enum
    ClickerCursor,
    ShovelCursor,
    WaterBucketCursor

  GameCursor* = ref GameCursorObj
  GameCursorObj = object
    cursor*: Cursor
    case kind*: GameCursorKind
    of ClickerCursor: discard
    of ShovelCursor: discard
    of WaterBucketCursor: discard

proc newGameCursor*(assetLoader: AssetLoader, kind: GameCursorKind): GameCursor =
  new result

  var location = ""

  case kind:
    of ClickerCursor: location = "cursor-clicker-1.png"
    of ShovelCursor: discard
    of WaterBucketCursor: discard

  echo location
  let image = assetLoader.newImage(location);
  result.cursor = newCursor(image.pixelsPtr, image.size, vec2(cint(image.size.x/2), cint(image.size.y/2)))
