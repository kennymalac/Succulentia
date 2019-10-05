import csfml
import entity
import succulent
import times
import math
import vector_utils

type
  Enemy* = ref object of Entity
    direction*: Vector2f
    speed*: float 
    damage*: int
    health*: int

type 
  Ant* = ref object of Enemy

type 
  Spider* = ref object of Enemy

type
  Bee* = ref object of Enemy

proc turn*(self: Enemy, direction: Vector2i) =
  self.direction = direction

proc attack*(self: Enemy, direction: Vector2i, succulent: Succulent) =
  # attack logic
  # attack animation
  # attack direction
  succulent.health -= self.damage

proc updatePosition*(self: Ant, dt: times.Duration) =
  discard

proc move*(self: Ant) =
  var moveVector: Vector2f = vec2(self.direction.x, self.direction.y)
  moveVector.x *= self.speed
  moveVector.y *= self.speed
  self.sprite.move(moveVector)

proc updateDirection*(self: Ant, entity: Entity) =
  self.direction = vector_utils.normalize(entity.sprite.position - self.sprite.position)

proc getNearestSuc*(self: Enemy, entities: seq[Entity]): Succulent =
  # return closest succulent from entities array
  var distance: float = high(float)
  var suc: Succulent = nil
  for entity in entities:
    if entity of Succulent:
      var sucDistance: float = abs(sqrt((pow(self.sprite.position.x - entity.sprite.position.x, 2) + pow(self.sprite.position.y - entity.sprite.position.y, 2))))
      if sucDistance < distance:
        distance = sucDistance
        suc = (Succulent) entity
  return suc

proc print*(self: Ant) =
  echo "I am an Ant\n"

proc print*(self: Spider) =
  echo "I am a Spider\n"

proc print*(self: Bee) =
  echo "I am a Bee\n"
