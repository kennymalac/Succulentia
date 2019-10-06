import csfml/audio

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
