import strformat
import csfml

type
  ImageAsset* = ref object
    texture*: Texture
    size*: Vector2i

type
  AssetLoader* = ref object
    location*: string
    # Grlobal scale of all Sprites
    scale*: Vector2i

proc newAssetLoader*(location: string, scale: Vector2f = vec2(1.0, 1.0)): AssetLoader =
  result = AssetLoader(location: location)

proc newImageAsset*(self: AssetLoader, location: string, size: Vector2i): ImageAsset =
  result = ImageAsset(texture: new_Texture(fmt"{self.location}/graphics/{location}"), size: size)

proc newSprite*(self: AssetLoader, image: ImageAsset): Sprite =
  result = new_Sprite(image.texture)
  result.origin = vec2(image.size.x/2, image.size.y/2)
  result.scale = self.scale
