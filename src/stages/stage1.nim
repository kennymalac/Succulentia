import sequtils
import options

import csfml, csfml/audio

import ../scene
import ../assetLoader
import ../soundRegistry
import ../cursor
import ../menus/gameMenu
import ../entities/entity
import ../entities/enemy
import ../entities/succulent


import stage

type
  Stage1* = ref object of Scene
    background: Sprite
    boundary: Boundary
    soundRegistry: SoundRegistry
    wateringSound: Sound
    gameMenu: GameMenu
    isMouseDown: bool
    currentCursor: GameCursorKind
    clickerCursor: GameCursor
    shovelCursor: GameCursor
    fullWateringCanCursor: GameCursor
    emptyWateringCanCursor: GameCursor

proc initCursors*(self: Stage1) =
  proc newCursor(kind: GameCursorKind, variant: string = ""): GameCursor = newGameCursor(self.assetLoader, kind, variant)

  self.currentCursor = ClickerCursor
  self.clickerCursor = newCursor(ClickerCursor)
  self.shovelCursor = newCursor(ShovelCursor)
  self.fullWateringCanCursor = newCursor(WateringCanCursor)
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

  window.mouseCursor = result.clickerCursor.cursor

proc load*(self: Stage1) =
  self.background = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("background_1-1.png")
  )
  echo "tex size: ", self.background.texture.size.x, " ", self.background.texture.size.y

  self.background.scale = vec2(1, 1)
  self.background.position = vec2(0, 0)

  self.gameMenu = newGameMenu(self.assetLoader, self.soundRegistry, self.size)

  let sucSprite = randomSuccSprite(self.assetLoader)
  sucSprite.position = vec2(338, 240)
  let suc = newSucculent(suc_sprite, self.soundRegistry)
  self.entities.add(Entity(suc))

  let sucSprite2 = randomSuccSprite(self.assetLoader)
  sucSprite2.position = vec2(538, 180)
  let suc2 = newSucculent(sucSprite2, self.soundRegistry)
  self.entities.add(Entity(suc2))


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

  discard ant.getTargetSuc(self.entities)
  discard mealy.getTargetSuc(self.entities)
  # let ant1, ant2, ant3 = delayedCreate(Ant() ...
  #

proc handleMenuEvent(self: Stage1, window: RenderWindow, kind: GameMenuItemKind) =
  case kind:
  of Clicker:
    self.currentCursor = ClickerCursor
    window.mouseCursor = self.clickerCursor.cursor
  of Shovel:
    self.currentCursor = ShovelCursor
    window.mouseCursor = self.shovelCursor.cursor
  of WateringCan:
    # TODO emptying logic
    self.currentCursor = WateringCanCursor
    window.mouseCursor = self.fullWateringCanCursor.cursor

  self.gameMenu.clickSound.play()

proc checkGameMenuClickEvent(self: Stage1, window: RenderWindow, coords: Vector2f) : bool  =
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
      if entity.rect.contains(coords): maybeEnemy = some(Enemy(entity))

  if not maybeEnemy.isSome: return false

  let enemy = maybeEnemy.get()
  enemy.health -= 10
  if enemy.health <= 0:
    enemy.isDead = true
    enemy.deathSound.play()

  echo "Player attacked: DIE DIE DIE DIE\n"

  return true

proc checkPlayerWateringEvent(self: Stage1, coords: Vector2f) : bool =
  self.wateringSound.play()
  return true

proc handleLeftMouseEvent(self: Stage1, pressed: bool, window: RenderWindow, event: Event) =
  let coords = window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)

  if pressed:
    # First action to dispatch wins
    if self.checkGameMenuClickEvent(window, coords): return
    if self.currentCursor == ClickerCursor and self.checkPlayerAttackEvent(coords): return
    if self.currentCursor == WateringCanCursor and self.checkPlayerWateringEvent(coords): return
  # Mouse was released
  else:
    self.wateringSound.stop()

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
        self.isMouseDown = false
        self.handleLeftMouseEvent(false, window, event)
      else: discard
    else: discard


proc update*(self: Stage1) =
  # Delete last round of dead succs if any
  self.entities.keepItIf(not it.isDead)

  self.Scene.update()

proc draw*(self: Stage1, window: RenderWindow) =
  window.draw(self.background)
  self.gameMenu.draw(window)
  self.Scene.draw(window)
