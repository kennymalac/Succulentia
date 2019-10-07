import strformat
import os

import csfml, csfml/audio

type
  ImageAsset* = ref object
    texture*: Texture
    size*: Vector2i

type
  SoundAssetKind* = enum
    ClickSound,
    BugChompSound,
    GameMusicSound,
    RunningWaterSound

  SoundAsset* = ref SoundAssetObj
  SoundAssetObj = object
    buffer*: SoundBuffer
    case kind*: SoundAssetKind
    of ClickSound: discard
    of BugChompSound: discard
    of GameMusicSound: discard
    of RunningWaterSound: discard

# even though these are static for right now, some sound assets will have round robin behavior
let ClickSoundLocation*: string = "click.wav"
let BugChompSoundLocation*: string = "bug_chomp1.wav"
let GameMusicSoundLocation*: string = "mus_game.ogg"
let RunningWaterSoundLocation*: string = "water1.ogg"

type
  AssetLoader* = ref object
    location*: string
    # Grlobal scale of all Sprites
    scale*: Vector2f

proc newAssetLoader*(location: string, scale: Vector2f = vec2(1.0, 1.0)): AssetLoader =
  result = AssetLoader(location: location, scale: scale)

proc newImage*(self: AssetLoader, location: string): Image =
  result = newImage(joinPath(self.location, "graphics", location))

proc newImageAsset*(self: AssetLoader, location: string): ImageAsset =
  result = ImageAsset(texture: new_Texture(joinPath(self.location, "graphics", location)))
  # result.size = result.texture.size

proc newImageAsset*(self: AssetLoader, location: string, size: Vector2i): ImageAsset =
  result = ImageAsset(texture: new_Texture(joinPath(self.location, "graphics", location)))
  result.size = size

proc newSprite*(self: AssetLoader, image: ImageAsset): Sprite =
  result = new_Sprite(image.texture)
  # result.origin = vec2(image.size.x/2, image.size.y/2)
  result.scale = self.scale

proc scaledSize*(self: Sprite): Vector2f =
  result = vec2(cfloat(self.texture.size.x) * self.scale.x, cfloat(self.texture.size.y) * self.scale.y)

# PLEASE don't use newSoundAsset - This is used internally by SoundRegistry!
# Initialize a Sound registry and use getSound from that so that each sound instance has a single SoundBuffer
proc newSoundAsset*(self: AssetLoader, kind: SoundAssetKind): SoundAsset =
  var location: string = ""

  case kind:
    of ClickSound: location = ClickSoundLocation
    of BugChompSound: location = BugChompSoundLocation
    of GameMusicSound: location = GameMusicSoundLocation
    of RunningWaterSound: location = RunningWaterSoundLocation

  result = SoundAsset(buffer: newSoundBuffer(joinPath(self.location, "sound", location)))

proc newSound*(self: SoundAsset): Sound =
  result = newSound()
  result.buffer = self.buffer
