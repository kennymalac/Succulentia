import strformat
import os

import csfml, csfml/audio

type
  ImageAsset* = ref object
    texture*: Texture
    size*: Vector2i

  SoundAssetKind* = enum
    MainMenuMusic,
    StageGameMusic,
    ClickSound,
    BugChompSound,
    BugChompSound2,
    BugChompSound3,
    BugChompSound4,
    BugChompSound5,
    BugChompSound6,
    SucculentPlantSound,
    SucculentDeathSound,
    BugDeathSound,
    GameMusicSound,
    RunningWaterSound

  SoundAsset* = ref SoundAssetObj
  SoundAssetObj = object
    buffer*: SoundBuffer
    case kind*: SoundAssetKind
    of MainMenuMusic: discard
    of StageGameMusic: discard
    of ClickSound: discard
    of SucculentPlantSound: discard
    of SucculentDeathSound: discard
    of BugChompSound: discard
    of BugChompSound2: discard
    of BugDeathSound: discard
    of GameMusicSound: discard
    of RunningWaterSound: discard

    # type RoundRobinAsset =

# even though these are static for right now, some sound assets will have round robin behavior
let MainMenuMusicLocation*: string = "mus_mainmenu.ogg"
let StageGameMusicLocation*: string = "mus_game.ogg"
let ClickSoundLocation*: string = "click.wav"
let SucculentPlantSoundLocation*: string = "succ_plant1.wav"
let SucculentDeathSoundLocation*: string = "succ_death.wav"
let BugChompSoundLocation*: string = "bug_chomp1.wav"
let BugChompSound2Location*: string = "bug_chomp2.wav"
let BugChompSound3Location*: string = "bug_chomp3.wav"
let BugChompSound4Location*: string = "bug_chomp4.wav"
let BugChompSound5Location*: string = "bug_chomp5.wav"
let BugChompSound6Location*: string = "bug_chomp6.wav"
let BugDeathSoundLocation*: string = "bug_die1.wav"
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
    of MainMenuMusic: location = MainMenuMusicLocation
    of StageGameMusic: location = StageGameMusicLocation
    of ClickSound: location = ClickSoundLocation
    of SucculentPlantSound: location = SucculentPlantSoundLocation
    of SucculentDeathSound: location = SucculentDeathSoundLocation
    of BugChompSound: location = BugChompSoundLocation
    of BugChompSound2: location = BugChompSound2Location
    of BugChompSound3: location = BugChompSound3Location
    of BugChompSound4: location = BugChompSound4Location
    of BugChompSound5: location = BugChompSound5Location
    of BugChompSound6: location = BugChompSound6Location
    of BugDeathSound: location = BugDeathSoundLocation
    of GameMusicSound: location = GameMusicSoundLocation
    of RunningWaterSound: location = RunningWaterSoundLocation

  result = SoundAsset(buffer: newSoundBuffer(joinPath(self.location, "sound", location)))

proc newSound*(self: SoundAsset): Sound =
  result = newSound()
  result.buffer = self.buffer
