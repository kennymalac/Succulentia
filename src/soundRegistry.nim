import tables

import csfml/audio

import assetLoader

type SoundRegistry* = Table[SoundAssetKind, SoundAsset]

proc newSoundRegistry*(assetLoader: AssetLoader): SoundRegistry =
  result = initTable[SoundAssetKind, SoundAsset]()
  for kind in SoundAssetKind.items:
    result[kind] = assetLoader.newSoundAsset(kind)

proc getSound*(self: SoundRegistry, kind: SoundAssetKind): Sound =
  return self[kind].newSound()
