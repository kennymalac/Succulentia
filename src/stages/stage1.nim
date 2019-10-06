import options

import csfml, csfml/audio

import ../scene
import ../assetLoader
import ../soundRegistry
import ../entities/entity
import ../menus/gameMenu
import ../cursor

import ../entities/enemy
import ../entities/succulent

import stage

type
  Stage1* = ref object of Scene
    background: Sprite
    boundary: Boundary
    soundRegistry: SoundRegistry
    gameMenu: GameMenu
    clickerCursor: GameCursor

proc newStage1*(window: RenderWindow): Stage1 =
  let boundary: Boundary = (cint(100), cint(100), cint(100), cint(100))
  result = Stage1(boundary: boundary)

  initScene(
    result,
    window = window,
    title = "Stage 1 - Start From Nothing",
    origin = getOrigin(window.size),
  )

  result.clickerCursor = newGameCursor(result.assetLoader, ClickerCursor)
  result.soundRegistry = newSoundRegistry(result.assetLoader)

proc load*(self: Stage1) =
  self.background = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("background_1-1.png")
  )
  echo "tex size: ", self.background.texture.size.x, " ", self.background.texture.size.y

  self.background.scale = vec2(1, 1)
  self.background.position = vec2(0, 0)

  self.gameMenu = newGameMenu(self.assetLoader, self.soundRegistry, self.size)

  let sucSprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("basic-succ.png"),
  )
  sucSprite.position = vec2(338, 240)
  let suc = newSucculent(suc_sprite)
  self.entities.add(Entity(suc))

  let antSprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("ant-sprite.png"),
  )
  antSprite.position = vec2(500, 400)

  let ant = Ant(sprite: ant_sprite, direction: vec2(-1.0, 1.0), damage: 10, speed: 2, health: 15)
  self.entities.add(Entity(ant))

  let nearestSuc: Succulent = ant.getTargetSuc(self.entities)
  # let ant1, ant2, ant3 = delayedCreate(Ant() ...
  #

proc handleMenuEvent(self: Stage1, window: RenderWindow, kind: GameMenuItemKind) =
  case kind:
  of Clicker:
    window.mouseCursor = self.clickerCursor.cursor
  else: discard

  self.gameMenu.clickSound.play()

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
        echo "Mouse button event coords: "
        echo window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)
        let (doesContain, maybeKind) = self.gameMenu.contains(window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view))
        if doesContain:
          assert maybeKind.isSome
          echo maybeKind.get(), " menu item clicked"
          self.handleMenuEvent(window, maybeKind.get())
      else: discard
    else: discard


proc update*(self: Stage1) =
  self.Scene.update()

proc draw*(self: Stage1, window: RenderWindow) =
  window.draw(self.background)
  self.gameMenu.draw(window)
  self.Scene.draw(window)
