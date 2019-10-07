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
var sucRect = newRectangleShape(vec2(suc.rect.width, suc.rect.height))
sucRect.position = vec2(suc.rect.left, suc.rect.top)


var sucs: seq[Entity]
sucs = @[ (Entity) suc ]

ant = newAnt(ant_sprite)
var i: int = 0

while window.open:
  window.clear(color(112, 197, 206))
  i += 1
  if i == 500:
    sucSprite.position = vec2(400, 260)
    suc = newSucculent(sucSprite)
    sucRect = newRectangleShape(vec2(suc.rect.width, suc.rect.height))
    sucRect.position = vec2(suc.rect.left, suc.rect.top)
    ant.isAttacking = false

  var antRect = newRectangleShape(vec2(ant.rect.width, ant.rect.height))
  antRect.position = vec2(ant.rect.left, ant.rect.top)

  window.draw(suc.sprite)
  window.draw(ant.sprite)
  window.draw(sucRect)
  window.draw(antRect)
  ant.update(sucs)
  window.display()

ant.print()
spider.print()
bee.print()
suc.print()
