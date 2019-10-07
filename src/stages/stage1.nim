import strformat
import times
import sequtils
import options
import os

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
    gameMenu: GameMenu
    isMouseDown: bool
    waterTimer: Duration
    currentCursor: GameCursor
    clickerCursor: GameCursor
    shovelCursor: GameCursor
    fullWateringCanCursor: GameCursor
    emptyWateringCanCursor: GameCursor

proc initCursors*(self: Stage1) =
  proc newCursor(kind: GameCursorKind, variant: string = ""): GameCursor = newGameCursor(self.assetLoader, kind, variant)

  self.currentCursor = self.clickerCursor
  self.clickerCursor = newCursor(ClickerCursor)
  self.shovelCursor = newCursor(ShovelCursor)
  self.fullWateringCanCursor = newCursor(WateringCanCursor, "full")
  self.emptyWateringCanCursor = newCursor(WateringCanCursor, "empty")


proc newStage1*(window: RenderWindow): Stage1 =
  let boundary: Boundary = (cint(100), cint(100), cint(100), cint(100))
  result = Stage1(boundary: boundary)

  initScene(
    result,
    window = window,
    title = "Stage 1 - Start From Nothing",
    origin = getOrigin(window.size),
  )

  result.initCursors()
  result.soundRegistry = newSoundRegistry(result.assetLoader)
  result.wateringSound = result.soundRegistry.getSound(RunningWaterSound)
  result.bugClickSound = result.soundRegistry.getSound(BugClickSound)
  result.gameMusic = result.soundRegistry.getSound(StageGameMusic)
  result.waterTimer = initDuration(seconds = 0)

  result.score = 0
  result.font = newFont(joinPath("assets", "fonts", "PressStart2P.ttf"))
  result.scoreText = newText("Score: ", result.font)
  result.scoreText.font = result.font
  result.scoreText.characterSize = 14

  result.currentCursor = result.clickerCursor


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

  let pot2 = newPot(self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("pot-sprite.png")
  ), self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("pot-sprite-dirt.png")
  ))

  pot.setPosition(vec2(200, 200))
  pot2.setPosition(vec2(400, 400))
  pot.placeDirt()
  pot2.placeDirt()

  self.entities.add(Entity(pot))
  self.entities.add(Entity(pot2))

  let sucSprite = randomSuccSprite(self.assetLoader)
  let suc = newSucculent(suc_sprite, self.soundRegistry)
  suc.setPot(some(pot))
  self.entities.add(Entity(suc))

  let sucSprite2 = randomSuccSprite(self.assetLoader)
  let suc2 = newSucculent(sucSprite2, self.soundRegistry)
  suc2.setPot(some(pot2))
  self.entities.add(Entity(suc2))

  echo suc2.sprite.position
  echo pot2.sprite.position

  let antSprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("ant-sprite.png"),
  )
  antSprite.position = vec2(500, 400)

  let ant = newAnt(ant_sprite, self.soundRegistry)
  self.entities.add(Entity(ant))

  let mealySprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("mealy-sprite.png"),
  )
  mealySprite.position = vec2(500, 400)

  let mealy = newMealy(mealy_sprite, self.soundRegistry)
  self.entities.add(Entity(mealy))

  let beetleSprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("beetle-sprite.png"),
  )
  beetleSprite.position = vec2(500, 400)

  let beetle = newBeetle(beetle_sprite, self.soundRegistry)
  self.entities.add(Entity(beetle))

  discard ant.getTargetSuc(self.entities)
  discard mealy.getTargetSuc(self.entities)
  # let ant1, ant2, ant3 = delayedCreate(Ant() ...
  #

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

proc checkPlayerWateringEvent(self: Stage1, coords: Vector2f) : bool =
  if self.currentCursor.variant == "full":
    self.wateringSound.play()
    # Hydrade plont if intersecting
  return true

proc handleLeftMouseEvent(self: Stage1, pressed: bool, window: RenderWindow, event: Event) =
  let coords = window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)

  if pressed:
    # First action to dispatch wins
    if self.checkGameMenuClickEvent(window, coords): return
    if self.currentCursor.kind == ClickerCursor and self.checkPlayerAttackEvent(coords): return
    if self.currentCursor.kind == WateringCanCursor and self.checkPlayerWateringEvent(coords): return
  # Mouse was released
  else:
    if self.currentCursor.variant == "full" and self.isMouseDown:
      if self.waterTimer >= initDuration(seconds = 3):
        self.waterTimer = initDuration(seconds = 0)
        self.currentCursor = self.emptyWateringCanCursor
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


proc update*(self: Stage1, window: RenderWindow) =
  let mouseCoords = window.mapPixelToCoords(mouse_getPosition(window), self.view)
  self.currentCursor.sprite.position = mouseCoords
  self.currentCursor.updateRectPosition()

  # Delete last round of dead succs if any
  self.entities.keepItIf(not it.isDead)

  let dt = self.Scene.update(window)

  if self.isMouseDown and self.currentCursor.kind == WateringCanCursor and self.currentCursor.variant == "full":
    self.waterTimer += dt

  if self.waterTimer >= initDuration(seconds = 3):
    self.waterTimer = initDuration(seconds = 0)
    self.currentCursor = self.emptyWateringCanCursor
    self.wateringSound.stop()

proc draw*(self: Stage1, window: RenderWindow) =
  # var mouseRect = newRectangleShape(vec2(self.currentCursor.rect.width, self.currentCursor.rect.height))
  # mouseRect.position = vec2(self.currentCursor.rect.left, self.currentCursor.rect.top)

  window.draw(self.background)
  self.gameMenu.draw(window)

  self.Scene.draw(window)

  self.scoreText = newText(fmt"Score: {self.score}", self.font)
  self.scoreText.characterSize = 18
  self.scoreText.position = vec2(window.size.x/2 - cfloat(self.scoreText.globalBounds.width/2), 20)

  window.draw(self.scoreText)

  window.draw(self.currentCursor.sprite)
  # window.draw(mouseRect)
