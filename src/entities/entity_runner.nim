import entity, enemy, succulent
import csfml

var window = new_RenderWindow(video_mode(800, 600), "Succulentia")
window.vertical_sync_enabled = true

var 
  ant: Entity
  spider: Entity
  bee: Entity
  suc: Entity

ant = Ant()
spider = Spider()
bee = Bee()

let suc_texture = new_Texture("../../assets/graphics/sample_succ_1.png")
let suc_sprite = new_Sprite(suc_texture)

suc = newEntity(suc_sprite)

while window.open:
  window.clear(color(112, 197, 206))
  window.draw(suc.sprite)
  window.display()

ant.print()
spider.print()
bee.print()
suc.print()
