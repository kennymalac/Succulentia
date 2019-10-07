import options
import os

import csfml, csfml/audio

import ../scene
import ../assetLoader
import ../soundRegistry
import ../cursor
import ../menus/mainMenu

import stage
import stage1

type
  MainMenuScene* = ref object of Scene
    background: Sprite
    gameTitle: Sprite
    soundRegistry: SoundRegistry
    mainMenu: MainMenu
    currentCursor: GameCursor
    clickerCursor: GameCursor

    doNewScene: proc (scene: Scene) {.closure.}

    startedGame: bool

proc initCursors*(self: MainMenuScene) =
  proc newCursor(kind: GameCursorKind, variant: string = ""): GameCursor = newGameCursor(self.assetLoader, kind, variant)
  self.clickerCursor = newCursor(ClickerCursor)
  self.currentCursor = self.clickerCursor

proc newMainMenuScene*(window: RenderWindow, doNewScene: proc (scene: Scene) {.closure.}): MainMenuScene =
  result = MainMenuScene(startedGame: false)
  result.doNewScene = doNewScene

  initScene(
    result,
    window = window,
    title = "Main Menu",
    origin = getOrigin(window.size),
  )

  result.initCursors()
  result.soundRegistry = newSoundRegistry(result.assetLoader)

  result.currentCursor = result.clickerCursor


proc load*(self: MainMenuScene, window: RenderWindow) =
  self.background = self.assetLoader.newSprite(
     self.assetLoader.newImageAsset("menu-background_1-1.png")
  )
  self.gameTitle = self.assetLoader.newSprite(
     self.assetLoader.newImageAsset("game-logo_1-1.png")
  )
  #echo "tex size: ", self.background.texture.size.x, " ", self.background.texture.size.y

  self.background.scale = vec2(1, 1)
  self.background.position = vec2(0, 0)

  self.gameTitle.scale = vec2(2, 2)
  self.gameTitle.position = vec2(window.size.x/2 - self.gameTitle.scaledSize.x/2, 20)


  self.mainMenu = newMainMenu(self.assetLoader, self.soundRegistry, self.size)

proc handleMenuEvent(self: MainMenuScene, window: RenderWindow, kind: MainMenuItemKind) =
  self.mainMenu.clickSound.play()

  case kind:
  of Start:
    self.startedGame = true
  of Exit:
    sleep(500) # so menu sound still plays
    window.close()

proc checkMainMenuClickEvent(self: MainMenuScene, window: RenderWindow, coords: Vector2f) : bool  =
  let (doesContain, maybeKind) = self.mainMenu.contains(coords)
  if doesContain:
    assert maybeKind.isSome
    echo maybeKind.get(), " menu item clicked"

  if doesContain: self.handleMenuEvent(window, maybeKind.get())

  return doesContain

proc handleLeftMouseEvent(self: MainMenuScene, pressed: bool, window: RenderWindow, event: Event) =
  let coords = window.mapPixelToCoords(vec2(event.mouseButton.x, event.mouseButton.y), self.view)

  if pressed:
    if self.checkMainMenuClickEvent(window, coords): return

proc pollEvent*(self: MainMenuScene, window: RenderWindow) =
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
        self.handleLeftMouseEvent(true, window, event)
      else: discard
    else: discard


proc update*(self: MainMenuScene, window: RenderWindow) =
  if self.startedGame:
    self.doNewScene(newStage1(window))
    self.startedGame = false
    return

  self.Scene.update(window)

proc draw*(self: MainMenuScene, window: RenderWindow) =
  let mouseCoords = window.mapPixelToCoords(mouse_getPosition(window), self.view)
  self.currentCursor.sprite.position = mouseCoords
  self.currentCursor.updateRectPosition()

  window.draw(self.background)
  window.draw(self.gameTitle)
  self.mainMenu.draw(window)
  self.Scene.draw(window)
  window.draw(self.currentCursor.sprite)
