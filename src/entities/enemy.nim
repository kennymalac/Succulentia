import csfml
import entity
import succulent
import times
import math, random
import vector_utils

type
  Enemy* = ref object of Entity
    direction*: Vector2f
    targetSuc*: Succulent
    speed*: float 
    damage*: int
    health*: int
    isAttacking*: bool

type 
  Ant* = ref object of Enemy

type 
  Spider* = ref object of Enemy
    hasAttacked: bool

type
  Bee* = ref object of Enemy

proc attack*(self: Enemy, direction: Vector2i, succulent: Succulent) =
  # attack logic
  # attack animation
  # attack direction
  succulent.health -= self.damage

proc move(self: Enemy) =
  # TODO: stop moving when collides and start attacking 
  var moveVector: Vector2f = vec2(self.direction.x, self.direction.y)
  moveVector.x *= self.speed
  moveVector.y *= self.speed
  self.sprite.move(moveVector)
  if self.rect.intersects(self.targetSuc.rect, self.interRect):
    self.isAttacking = true

proc updateDirection(self: Enemy, entity: Entity) =
  self.direction = vector_utils.normalize(entity.sprite.position - self.sprite.position)

proc updateDirection(self: Spider) =
  if self.hasAttacked:
    self.direction = vec2(0, 1)
  else:
    self.direction = vec2(0, -1)

# Retrieves succulent with minimum euclidian distance
proc getNearestSuc(self: Enemy, entities: seq[Entity]): Succulent =
  var distance: float = high(float)
  var suc: Succulent = nil
  for entity in entities:
    if entity of Succulent:
      var sucDistance: float = vector_utils.eDistance(self.sprite.position, entity.sprite.position)
      if sucDistance < distance:
        distance = sucDistance
        suc = (Succulent) entity
  return suc

# Retrieves random succulent from entity sequence
proc getRandomSuc(self: Enemy, entities: seq[Entity]): Succulent =
  var entity = entities[rand(entities.len)]
  while (not (entity of Succulent)):
    entity = entities[rand(entities.len)]
  return (Succulent) entity

# Retrieves and stores target succulent to move towards and attack
proc getTargetSuc*(self: Enemy, entities: seq[Entity]): Succulent =
  var suc: Succulent = nil
  if self of Spider or self of Bee:
    suc = self.getRandomSuc(entities)
  else:
    suc = self.getNearestSuc(entities)
  self.targetSuc = suc
  return self.targetSuc

proc update*(self: Enemy, entities: seq[Entity]) =
  self.rect = rect(self.sprite.position.x, self.sprite.position.y, cfloat(self.sprite.texture.size.x), cfloat(self.sprite.texture.size.y))
  if not self.isAttacking:
    var suc: Succulent = self.getTargetSuc(entities)
    self.targetSuc = suc
    self.updateDirection(self.targetSuc)
    self.move()
  else:
    discard

proc print*(self: Ant) =
  echo "I am an Ant\n"

proc print*(self: Spider) =
  echo "I am a Spider\n"

proc print*(self: Bee) =
  echo "I am a Bee\n"
