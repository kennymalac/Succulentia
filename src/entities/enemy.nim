import sequtils
import options

import csfml, csfml/audio
import entity
import succulent
import times
import math, random
import vector_utils

import ../assetLoader
import ../soundRegistry

type
  Enemy* = ref object of Entity
    direction*: Vector2f
    maybeTargetSuc*: Option[Succulent]
    speed*: float
    damage*: int
    health*: int
    isAttacking*: bool
    attackCounter*: Duration
    attackSpeed*: Duration
    attackSound*: Sound
    deathSound*: Sound

  Ant* = ref object of Enemy

  Mealy* = ref object of Enemy

  Spider* = ref object of Enemy
    hasAttacked: bool

  Bee* = ref object of Enemy

proc initEnemy*(enemy: Enemy, sprite: Sprite) =
  initEntity(enemy, sprite)

proc newAnt*(sprite: Sprite, soundRegistry: SoundRegistry): Ant =
  result = Ant(sprite: sprite, direction: vec2(-1.0, 1.0), damage: 10, speed: 0.6, health: 10, isAttacking: false, attackSound: soundRegistry.getSound(BugChompSound), attackSpeed: initDuration(seconds = 1), deathSound: soundRegistry.getSound(BugDeathSound))
  initEnemy(result, sprite)

proc newMealy*(sprite: Sprite, soundRegistry: SoundRegistry): Mealy =
  result = Mealy(sprite: sprite, direction: vec2(-1.0, 1.0), damage: 10, speed: 1.75, health: 20, isAttacking: false, attackSound: soundRegistry.getSound(BugChompSound2), attackSpeed: initDuration(seconds = 1), deathSound: soundRegistry.getSound(BugDeathSound))
  initEnemy(result, sprite)

# Returns whether or not Succulent reached 0 health
proc attack*(self: Enemy, targetSuc: Succulent): bool =
  # attack logic
  # attack animation
  # attack direction
  self.attackSound.play()

  targetSuc.health -= self.damage
  return targetSuc.health <= 0

proc resetAttackCounter(self: Enemy) =
  self.attackCounter = initDuration(seconds = 0)

proc rotate(self: Enemy) =
  assert self.maybeTargetSuc.isSome
  let targetSuc = self.maybeTargetSuc.get()
  self.sprite.rotation = vector_utils.vAngle(self.sprite.position, targetSuc.sprite.position)

proc move(self: Enemy) =
  assert self.maybeTargetSuc.isSome
  let targetSuc = self.maybeTargetSuc.get()

  # TODO: stop moving when collides and start attacking
  var moveVector: Vector2f = vec2(self.direction.x, self.direction.y)
  moveVector.x *= self.speed
  moveVector.y *= self.speed
  self.rotate()
  self.sprite.move(moveVector)
  self.updateRectPosition()
  if self.rect.intersects(targetSuc.rect, self.interRect):
    self.isAttacking = true
    self.resetAttackCounter()

proc updateDirection(self: Enemy, entity: Entity) =
  self.direction = vector_utils.normalize(entity.sprite.position - self.sprite.position)

proc updateDirection(self: Spider) =
  if self.hasAttacked:
    self.direction = vec2(0, 1)
  else:
    self.direction = vec2(0, -1)

# Retrieves succulent with minimum euclidian distance
proc getNearestSuc(self: Enemy, entities: seq[Entity]): Option[Succulent] =
  var distance: float = high(float)
  var suc: Succulent = nil
  for entity in entities:
    if entity of Succulent:
      var sucDistance: float = vector_utils.eDistance(self.sprite.position, entity.sprite.position)
      if sucDistance < distance:
        distance = sucDistance
        suc = Succulent(entity)
  if suc != nil:
    result = some(suc)
  else:
    result = none(Succulent)

# Retrieves random succulent from entity sequence
proc getRandomSuc(self: Enemy, entities: seq[Entity]): Option[Succulent] =
  var entity = entities[rand(entities.len)]
  while (not (entity of Succulent)):
    entity = entities[rand(entities.len)]
  return some(Succulent(entity))

# Retrieves and stores target succulent to move towards and attack
proc getTargetSuc*(self: Enemy, entities: seq[Entity]): Succulent =
  var suc: Succulent
  if self of Spider or self of Bee:
    suc = self.getRandomSuc(entities).get()
  else:
    suc = self.getNearestSuc(entities).get()

  return suc

proc update*(self: Enemy, dt: times.Duration, entities: seq[Entity]) =
  self.updateRectPosition()

  if self.isDead:
    return

  if not self.isAttacking:
    let hasSucculent = entities.anyIt(it of Succulent)
    if not hasSucculent:
      return

    self.maybeTargetSuc = some(self.getTargetSuc(entities))
    self.updateDirection(self.maybeTargetSuc.get())
    self.move()

  else:
    # Make sure succ is not already dead
    if self.maybeTargetSuc.get().isDead:
      self.isAttacking = false
      self.maybeTargetSuc = none(Succulent)
      return

    self.attackCounter += dt
    if self.attackCounter >= self.attackSpeed:
      self.resetAttackCounter()

      let targetSuc = self.maybeTargetSuc.get()

      let isSuccDead = self.attack(targetSuc)
      if isSuccDead:
        self.isAttacking = false
        targetSuc.isDead = true # RIP
        targetSuc.deathSound.play()

proc print*(self: Ant) =
  echo "I am an Ant\n"

proc print*(self: Mealy) =
  echo "I am a Mealy\n"

proc print*(self: Spider) =
  echo "I am a Spider\n"

proc print*(self: Bee) =
  echo "I am a Bee\n"
