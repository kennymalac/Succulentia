import csfml

import assetLoader

type
  GameCursorKind* = enum
    ClickerCursor,
    ShovelCursor,
    WateringCanCursor

  GameCursor* = ref GameCursorObj
  GameCursorObj = object
    variant*: string
    cursor*: Cursor
    sprite*: Sprite
    rect*: FloatRect
    interRect*: FloatRect
    case kind*: GameCursorKind
    of ClickerCursor: discard
    of ShovelCursor: discard
    of WateringCanCursor: discard

proc newGameCursor*(assetLoader: AssetLoader, kind: GameCursorKind, variant: string = ""): GameCursor =
  result = GameCursor(kind: kind, variant: variant)

  var location = ""

  case kind:
    of ClickerCursor: location = "cursor-clicker-1.png"
    of ShovelCursor: location = "cursor-shovel-1.png"
    of WateringCanCursor:
      if variant == "empty":
        location = "cursor-watercan-empty-1.png"
      else:
        location = "cursor-watercan-full-1.png"

  let image = assetLoader.newImage(location);
  result.cursor = newCursor(image.pixelsPtr, image.size, vec2(cint(image.size.x/2), cint(image.size.y/2)))
  result.sprite = assetLoader.newSprite(assetLoader.newImageAsset(location))
  result.sprite.origin = vec2(cfloat(result.sprite.scaledSize.x)/2, cfloat(result.sprite.scaledSize.y) / 2)
  if kind == ClickerCursor:
    # Rect should be slightly smaller
    result.rect = rect(result.sprite.position.x, result.sprite.position.y, cfloat(result.sprite.texture.size.x) - 10, cfloat(result.sprite.texture.size.y)-10)
  else:
    # Rect should be larger
    result.rect = rect(result.sprite.position.x + 10, result.sprite.position.y + 10, cfloat(result.sprite.texture.size.x) + 20, cfloat(result.sprite.texture.size.y) + 20)

  result.interRect = rect(0, 0, 0, 0)

proc updateRectPosition*(self: GameCursor) =
  if self.kind == ClickerCursor:
    self.rect = rect(self.sprite.position.x, self.sprite.position.y, self.sprite.scaledSize.x-10, self.sprite.scaledSize.y-10)
  else:
    self.rect = rect(self.sprite.position.x-20, self.sprite.position.y-20, self.sprite.scaledSize.x+20, self.sprite.scaledSize.y+20)
