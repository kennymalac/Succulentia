import entity, enemy, succulent
import csfml
import vector_utils

var window = new_RenderWindow(video_mode(800, 600), "Succulentia")
window.vertical_sync_enabled = true

var
  ant: Enemy
  spider: Enemy
  bee: Enemy
  suc: Succulent

spider = Spider()
bee = Bee()

let sucTexture = new_Texture("../../assets/graphics/basic-succ.png")
let sucSprite = new_Sprite(suc_texture)
sucSprite.position = vec2(10, 10)

let antTexture = new_Texture("../../assets/graphics/ant-sprite.png")
let antSprite = new_Sprite(ant_texture)
antSprite.position = vec2(300, 300)

suc = newSucculent(sucSprite)

var sucs: seq[Entity]
sucs = @[ (Entity) suc ]

ant = Ant(sprite: ant_sprite, direction: vec2(-1.0, 1.0), damage: 10, speed: 2, health: 15)
let nearestSuc: Succulent = ant.getTargetSuc(sucs)

while window.open:
  window.clear(color(112, 197, 206))
  window.draw(suc.sprite)
  window.draw(ant.sprite)
  ant.update(sucs)
  window.display()

ant.print()
spider.print()
bee.print()
suc.print()
