import strformat
import times
import sequtils
import options
import os
import random

import csfml, csfml/audio

import ../scene
import ../assetLoader
import ../soundRegistry
import ../cursor
import ../menus/gameMenu
import ../entities/entity
import ../entities/enemy
import ../entities/succulent
import ../entities/pot


import stage

type
  Stage1* = ref object of Scene
    font: Font
    score: int
    scoreText: Text
    gameMusic: Sound
    background: Sprite
    boundary: Boundary
    soundRegistry: SoundRegistry
    wateringSound: Sound
    bugClickSound: Sound
    potsNeedSuc: seq[tuple[pot: Pot, duration: times.Time]]
    plantSound: Sound
    isGameOver: bool
    gameMenu: GameMenu
    isMouseDown: bool
    waterTimer: Duration
    onlySpawnAntAndMealy: bool
    onlyAntAndMealyTimer: Duration
    chanceTimer: Duration
    potSpawnTimer: Duration
    currentCursor: GameCursor
    clickerCursor: GameCursor
    shovelCursor: GameCursor
    fullWateringCanCursor: GameCursor
    emptyWateringCanCursor: GameCursor
    chance: int

proc initCursors*(self: Stage1) =
  proc newCursor(kind: GameCursorKind, variant: string = ""): GameCursor = newGameCursor(self.assetLoader, kind, variant)

  self.currentCursor = self.clickerCursor
  self.clickerCursor = newCursor(ClickerCursor)
  self.shovelCursor = newCursor(ShovelCursor)
  self.fullWateringCanCursor = newCursor(WateringCanCursor, "full")
  self.emptyWateringCanCursor = newCursor(WateringCanCursor, "empty")

proc newStage1*(window: RenderWindow): Stage1 =
  let boundary: Boundary = (cint(100), cint(100), cint(100), cint(100))
  result = Stage1(boundary: boundary, isGameOver: false)

  initScene(
    result,
    window = window,
    title = "Stage 1 - Start From Nothing",
    origin = getOrigin(window.size),
  )

  result.initCursors()
  result.soundRegistry = newSoundRegistry(result.assetLoader)
  result.wateringSound = result.soundRegistry.getSound(RunningWaterSound)
  result.plantSound  = result.soundRegistry.getSound(SucculentPlantSound)
  result.bugClickSound = result.soundRegistry.getSound(BugClickSound)
  result.gameMusic = result.soundRegistry.getSound(StageGameMusic)
  result.waterTimer = initDuration(seconds = 0)
  result.chanceTimer = initDuration(seconds = 0)
  result.potSpawnTimer = initDuration(seconds = 0)

  result.onlyAntAndMealyTimer = initDuration(seconds = 0)
  result.onlySpawnAntAndMealy = true

  result.score = 0
  result.font = newFont(joinPath("assets", "fonts", "PressStart2P.ttf"))
  result.scoreText = newText("Score: ", result.font)
  result.scoreText.font = result.font
  result.scoreText.characterSize = 14

  result.currentCursor = result.clickerCursor
  result.chance = 4000


proc load*(self: Stage1) =
  self.gameMusic.loop = true
  self.gameMusic.play()
  self.background = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("background_1-1.png")
  )
  echo "tex size: ", self.background.texture.size.x, " ", self.background.texture.size.y

  self.background.scale = vec2(1, 1)
  self.background.position = vec2(0, 0)

  self.gameMenu = newGameMenu(self.assetLoader, self.soundRegistry, self.size)

  let pot = newPot(self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("pot-sprite.png")
  ), self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("pot-sprite-dirt.png")
  ))

  pot.setPosition(vec2(200, 200))
  pot.placeDirt()
  #pot2.placeDirt()

  self.entities.add(Entity(pot))

  let sucSprite = randomSuccSprite(self.assetLoader)
  let suc = newSucculent(suc_sprite, self.soundRegistry)
  suc.setPot(some(pot))
  self.entities.add(Entity(suc))

proc handleMenuEvent(self: Stage1, window: RenderWindow, kind: GameMenuItemKind) =
  case kind:
  of Clicker:
    self.currentCursor = self.clickerCursor
  of Shovel:
    self.currentCursor = self.shovelCursor
  of WateringCan:
    # TODO emptying logic
    self.currentCursor = self.fullWateringCanCursor

  self.gameMenu.clickSound.play()

proc checkGameMenuClickEvent(self: Stage1, window: RenderWindow, coords: Vector2f) : bool =
  let (doesContain, maybeKind) = self.gameMenu.contains(coords)
  if doesContain:
    assert maybeKind.isSome
    echo maybeKind.get(), " menu item clicked"

  if doesContain: self.handleMenuEvent(window, maybeKind.get())

  return doesContain


proc handlePlayerAttackEvent(self: Stage1, enemy: Enemy) =
  discard

proc checkPlayerAttackEvent(self: Stage1, coords: Vector2f) : bool =
  var maybeEnemy = none(Enemy)

  for entity in self.entities:
    if entity of Enemy:
      # TODO make Cursor have a rect because the point is too small
      if entity.rect.intersects(self.currentCursor.rect, self.currentCursor.interRect): maybeEnemy = some(Enemy(entity))

  if not maybeEnemy.isSome: return false

  let enemy = maybeEnemy.get()
  self.bugClickSound.play()
  enemy.health -= 10
  if enemy.health <= 0:
    if enemy of Ant:
      self.score += 1
    elif enemy of Mealy:
      self.score += 3
    elif enemy of Bee:
      self.score += 5
    elif enemy of Beetle:
      self.score += 15
    elif enemy of Spider:
      self.score += 8

    enemy.isDead = true
    enemy.deathSound.play()

  echo "Player attacked: DIE DIE DIE DIE\n"

  return true

proc hydrateSuc(self: Stage1) =
  var maybePot = none(Pot)

  echo "maybe hydrate suc?\n"

  for entity in self.entities:
    if entity of Pot:
      let pot = Pot(entity)
      self.currentCursor.updateRectPosition()
      echo pot.dirtSprite.globalBounds
      echo self.currentCursor.rect
      echo " intersecting: ", pot.dirtSprite.globalBounds.intersects(self.currentCursor.rect, self.currentCursor.interRect)
      if pot.hasDirt and not pot.hasSuc and pot.dirtSprite.globalBounds.intersects(self.currentCursor.rect, self.currentCursor.interRect):
        maybePot = some(pot)
        break

  if maybePot.isSome:
    let pot = maybePot.get()

    echo "growing suc...\n"
    self.potsNeedSuc.add((pot, getTime()))

proc checkPlayerWateringEvent(self: Stage1, coords: Vector2f) : bool =
  if self.currentCursor.variant == "empty":
    return true

  self.wateringSound.play()
  return true

proc checkPlayerPlantEvent(self: Stage1, coords: Vector2f) : bool =
  var maybePot = none(Pot)

  for entity in self.entities:
    if entity of Pot:
      let pot = Pot(entity)
      if not pot.hasDirt and pot.dirtSprite.globalBounds.intersects(self.currentCursor.rect, self.currentCursor.interRect): maybePot = some(pot)

  if not maybePot.isSome: return false
  let pot = maybePot.get()
  if pot.hasDirt: return false

  self.plantSound.play()

  echo "placing dirt...\n"
  pot.placeDirt()

proc handleLeftMouseEvent(self: Stage1, pressed: bool, window: RenderWindow, event: Event) =
  let coords = window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)

  if pressed:
    # First action to dispatch wins
    if self.checkGameMenuClickEvent(window, coords): return
    if self.currentCursor.kind == ClickerCursor and self.checkPlayerAttackEvent(coords): return
    if self.currentCursor.kind == WateringCanCursor and self.checkPlayerWateringEvent(coords): return
    if self.currentCursor.kind == ShovelCursor and self.checkPlayerPlantEvent(coords): return
  # Mouse was released
  else:
    if self.currentCursor.variant == "full" and self.isMouseDown:
      if self.waterTimer >= initDuration(seconds = 3):
        self.waterTimer = initDuration(seconds = 0)
        self.currentCursor = self.emptyWateringCanCursor
        self.hydrateSuc()

      self.wateringSound.stop()


    self.isMouseDown = false


proc pollEvent*(self: Stage1, window: RenderWindow) =
  var event: Event
  while window.poll_event(event):
    case event.kind
    of EventType.Closed:
      window.close()
    of EventType.KeyPressed:
      case event.key.code
      of KeyCode.Escape:
        window.close()
      else: discard
    of EventType.MouseButtonPressed:
      if self.isGameOver:
        return

      case event.mouseButton.button:
      of MouseButton.Left:
        self.isMouseDown = true
        echo "Mouse button event coords: "
        echo window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)
        self.handleLeftMouseEvent(true, window, event)
      else: discard
    of EventType.MouseButtonReleased:
      case event.mouseButton.button:
      of MouseButton.Left:
        self.handleLeftMouseEvent(false, window, event)
      else: discard
    else: discard


proc spawn*(self: Stage1, chance: int) =
  # TODO refactor to use timers
  # ant frequency: 15%?
  # mealy frequency: 5%?
  # spider frequency: 4%?
  # beetle frequency: 1%?
  randomize()
  let bugRand = rand(chance)
  if (self.onlySpawnAntAndMealy and bugRand < 30) or bugRand < 20:
    let antSprite = self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("ant-sprite.png")
    )
    antSprite.position = vec2(rand(640), 480)
    let ant = newAnt(antSprite, self.soundRegistry)
    self.entities.add(Entity(ant))
  elif (self.onlySpawnAntAndMealy and bugRand > 30 and bugRand < 40) or (bugRand > 20 and bugRand < 28):
    let mealySprite = self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("mealy-sprite.png")
    )
    mealySprite.position = vec2(rand(640), 480)

    let mealy = newMealy(mealy_sprite, self.soundRegistry)
    self.entities.add(Entity(mealy))

  if self.onlySpawnAntAndMealy:
    discard
  elif bugRand > 28 and bugRand < 30:
    let spiderSprite = self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("spider-sprite.png")
    )
    spiderSprite.position = vec2(rand(640), 480)
    let spider = newSpider(spiderSprite, self.soundRegistry)
    self.entities.add(Entity(spider))

  elif bugRand > 30 and bugRand < 32:
    let beeSprite = self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("bee-sprite.png")
    )
    beeSprite.position = vec2(rand(640), 480)
    let bee = newBee(beeSprite, self.soundRegistry)
    self.entities.add(Entity(bee))

  elif bugRand == 32:
    let beetleSprite = self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("beetle-sprite.png")
    )
    beetleSprite.position = vec2(rand(640), 480)
    let beetle = newBeetle(beetleSprite, self.soundRegistry)
    self.entities.add(Entity(beetle))

  #elif bugRand > 29 and bugRand <= 30:

 # elif bugRand > 25 and bugRand < 30:
 #   let spiderSprite = self.assetLoader.newSprite(
 #     self.assetLoader.newImageAsset("spider-sprite.png")
 #   )
 #   let spider = newSpider(spiderSprite, self.soundRegistry)
 #   spiderSprite.position = vec2(rand(640), 480)
 #   self.entities.add((Entity(spider))

proc addPot(self: Stage1, pot: Pot): Vector2f =
  randomize()
  var randVec: Vector2f = vec2(rand(600), rand(100) + 200)
  var done = false

  while not done:
    for entity in self.entities:
      if entity of Succulent:
        # Check if randVec intersects with this pot
        var intRect = rect(0.0,0.0,0.0,0.0)
        if entity.rect.intersects(rect(randVec.x, randVec.y, cfloat(entity.sprite.scaledSize.x), cfloat(entity.sprite.scaledSize.y) + cfloat(pot.sprite.scaledSize.y)), intRect):
          randVec = vec2(rand(600), rand(100) + 200)
          break

      pot.setPosition(randVec)
      done = true
      break

    if done:
      break

    echo "There was no other succulent somehow? this should not happen\n"
    pot.setPosition(randVec)
    done = true

  echo "Adding pot!"
  self.entities.add(Entity(pot))

  return randVec

proc update*(self: Stage1, window: RenderWindow) =

  for cursor in @[self.clickerCursor,
                 self.shovelCursor,
                 self.fullWateringCanCursor,
                 self.emptyWateringCanCursor]:
    let mouseCoords = window.mapPixelToCoords(mouse_getPosition(window), self.view)
    cursor.sprite.position = mouseCoords
    cursor.updateRectPosition()

  if not self.isGameOver:
    self.isGameOver = not self.entities.anyIt(it of Succulent)

  if self.isGameover:
    return

  self.spawn(self.chance)

  # Delete last round of dead succs if any
  self.entities.keepItIf(not it.isDead)

  let dt = self.Scene.update(window)

  if self.onlyAntAndMealyTimer > initDuration(minutes = 2):
    self.onlySpawnAntAndMealy = false
  else:
    # only spawn ants and mealies for first couple minutes
    self.onlyAntAndMealyTimer += dt
    self.onlySpawnAntAndMealy = true

  self.chanceTimer += dt
  if self.chanceTimer >= initDuration(seconds = 1):
    self.chanceTimer = initDuration(seconds = 0)
    echo self.chance
    if self.chance > 3000:
      self.chance -= 10
    # Decrease the chance decrement significantly
    elif self.chance > 2000:
      self.chance -= 2
    elif self.chance > 500:
      self.chance -= 1

  self.potSpawnTimer += dt

  if self.potSpawnTimer >= initDuration(seconds = 30):
    self.potSpawnTimer = initDuration(seconds = 0)
    let pot = newPot(self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("pot-sprite.png")
    ), self.assetLoader.newSprite(
      self.assetLoader.newImageAsset("pot-sprite-dirt.png")
    ))
    discard self.addPot(pot)

  # Add sucs to pots that need it
  for it in self.potsNeedSuc:
    let (pot, timeAdded) = it
    if self.currentTime - timeAdded >= initDuration(seconds = 3):
      let sucSprite = randomSuccSprite(self.assetLoader)
      let suc = newSucculent(suc_sprite, self.soundRegistry)
      suc.setPot(some(pot))
      self.entities.add(Entity(suc))

  # if pot had time to be added, delete it
  self.potsNeedSuc.keepItIf(self.currentTime - it[1] <= initDuration(seconds = 3))

  if self.isMouseDown and self.currentCursor.kind == WateringCanCursor and self.currentCursor.variant == "full":
    self.waterTimer += dt

  if self.waterTimer >= initDuration(seconds = 3):
    self.waterTimer = initDuration(seconds = 0)
    self.currentCursor = self.emptyWateringCanCursor
    self.wateringSound.stop()
    self.hydrateSuc()

proc draw*(self: Stage1, window: RenderWindow) =
  # var mouseRect = newRectangleShape(vec2(self.currentCursor.rect.width, self.currentCursor.rect.height))
  # mouseRect.position = vec2(self.currentCursor.rect.left, self.currentCursor.rect.top)

  window.draw(self.background)

  self.Scene.draw(window)

  self.scoreText = newText(fmt"Score: {self.score}", self.font)
  self.scoreText.characterSize = 18
  self.scoreText.position = vec2(window.size.x/2 - cfloat(self.scoreText.globalBounds.width/2), 20)

  window.draw(self.scoreText)

  self.gameMenu.draw(window)

  window.draw(self.currentCursor.sprite)

  if self.isGameOver:
    let gameOverText = newText("GAME OVER", self.font)
    gameOverText.characterSize = 72
    gameOverText.position = vec2(window.size.x/2 - cfloat(gameOverText.globalBounds.width/2), window.size.y/2 - cfloat(gameOverText.globalBounds.height/2))
    window.draw(gameOverText)

  # var mouseRect = newRectangleShape(vec2(self.currentCursor.rect.width, self.currentCursor.rect.height))
  # mouseRect.position = vec2(self.currentCursor.rect.left, self.currentCursor.rect.top)

  # window.draw(mouseRect)
