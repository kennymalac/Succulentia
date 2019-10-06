import csfml/audio

import assetLoader

static:
  let soundKinds = {
    ClickSound: "clickSound",
    BugChompSound: "bugChompSound",
    GameMusicSound: "gameMusicSound",
    RunningWaterSound: "runningWaterSound"
  }

type
  SoundRegistry* = ref object
    clickSound: ClickSound
    bugChompSound: BugChompSound
    gameMusicSound: GameMusicSound
    runningWaterSound: RunningWaterSound

proc newSoundRegistry*(assetLoader: AssetLoader): SoundRegistry =
  new result
  for kind, key in kindMap.items:
    result[key] = assetLoader.newSoundAsset(kind)

proc getSound*(kind: SoundAssetKind): SoundAsset =
  return newSound(soundKinds[kind])
