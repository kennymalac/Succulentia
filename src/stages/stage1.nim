import csfml

import ../scene
import ../assetLoader
import ../entities/entity
import ../menus/gameMenu
import ../cursor

import stage

type
  Stage1* = ref object of Scene
    boundary: Boundary
    gameMenu: GameMenu
    cursor: GameCursor

proc newStage1*(window: RenderWindow): Stage1 =
  let boundary: Boundary = (cint(100), cint(100), cint(100), cint(100))
  result = Stage1(boundary: boundary)

  initScene(
    result,
    window = window,
    title = "Stage 1 - Start From Nothing",
    origin = getOrigin(window.size, boundary),
    size = vec2(window.size.x + boundary.left + boundary.right, window.size.y + boundary.top + boundary.bottom)
  )

  result.cursor = newGameCursor(result.assetLoader, ClickerCursor)
  window.mouseCursor = result.cursor.cursor

proc load*(self: Stage1) =
  self.gameMenu = newGameMenu(self.assetLoader, self.size)

  let sucSprite = self.assetLoader.newSprite(
    self.assetLoader.newImageAsset("basic-succ.png"),
  )
  sucSprite.position = vec2(0, 0)
  let suc = newEntity(suc_sprite)

  self.entities.add(suc)
  # let ant1, ant2, ant3 = delayedCreate(Ant() ...
  #

proc update*(self: Stage1) =
  self.Scene.update()

proc draw*(self: Stage1, window: RenderWindow) =
  self.gameMenu.draw(window)
  self.Scene.draw(window)
