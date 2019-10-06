import strformat

import csfml, csfml/audio

type
  ImageAsset* = ref object
    texture*: Texture
    size*: Vector2i

  SoundAsset* = ref object
    sound*: Sound

type
  AssetLoader* = ref object
    location*: string
    # Grlobal scale of all Sprites
    scale*: Vector2i

proc newAssetLoader*(location: string, scale: Vector2f = vec2(1.0, 1.0)): AssetLoader =
  result = AssetLoader(location: location)

proc newImageAsset*(self: AssetLoader, location: string): ImageAsset =
  echo fmt"{self.location}/graphics/{location}"
  result = ImageAsset(texture: new_Texture(fmt"{self.location}/graphics/{location}"))
  result.size = result.texture.size

proc newImageAsset*(self: AssetLoader, location: string, size: Vector2i): ImageAsset =
  echo fmt"{self.location}/graphics/{location}"
  result = ImageAsset(texture: new_Texture(fmt"{self.location}/graphics/{location}"))
  result.size = size

proc newSprite*(self: AssetLoader, image: ImageAsset): Sprite =
  result = new_Sprite(image.texture)
  # result.origin = vec2(image.size.x/2, image.size.y/2)
  # result.scale = self.scale

proc newSoundAsset*(self: AssetLoader, location: string): SoundAsset =
  discard
