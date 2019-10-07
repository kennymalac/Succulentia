import times
import entity, enemy, succulent, pot
import csfml
import vector_utils
import options
import ../soundRegistry
import ../assetLoader

var window = new_RenderWindow(video_mode(800, 600), "Succulentia")
window.vertical_sync_enabled = true

var
  ant: Enemy
  spider: Enemy
  bee: Enemy
  suc: Succulent
  potInstance: Pot

spider = Spider()
bee = Bee()

let loader = newAssetLoader("../../assets")
let registry = newSoundRegistry(loader)

let sucSprite = loader.newSprite(loader.newImageAsset("succ-andro-5.png"))

let antSprite = loader.newSprite(loader.newImageAsset("ant-sprite.png"))
antSprite.position = vec2(300, 300)

var potSprite = loader.newSprite(loader.newImageAsset("pot-sprite.png"))
var potDirtSprite = loader.newSprite(loader.newImageAsset("pot-sprite-dirt.png"))

potSprite.position = vec2(80, 80)
potDirtSprite.position = vec2(80, 80)

potInstance = newPot(potSprite, potDirtSprite)

suc = newSucculent(sucSprite, registry)

var sucs: seq[Entity]
sucs = @[ (Entity) suc ]

ant = newAnt(ant_sprite, registry)
var i: int = 0
var drawSuc: bool = false

while window.open:
  window.clear(color(112, 197, 206))
  i += 1
  if i == 200:
    potInstance.placeDirt()

  if i == 500:
    suc.setPot(some(potInstance))
    drawSuc = true

  let dt = getTime()

  window.draw(potInstance.sprite)
  if drawSuc:
    window.draw(suc.sprite)

  window.display()

ant.print()
spider.print()
bee.print()
suc.print()
