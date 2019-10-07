import strformat
import options

import csfml, csfml/ext
import tables

import scene
import stages/stage1
import stages/mainMenuScene

type WindowConfig = tuple[title: string, width: cint, height: cint, fps: cint]

proc setupWindow(windowConfig: WindowConfig): RenderWindow =
  let (title, width, height, fps) = windowConfig

  result = new_RenderWindow(video_mode(width, height), title)
  result.vertical_sync_enabled = true
  result.framerate_limit = fps

proc main(windowConfig: WindowConfig) =
  let window = setupWindow(windowConfig)

  var currentScene: Scene = nil
  var newScene: Option[Scene] = none(Scene)

  var doNewScene = proc (scene: Scene) {.closure.} =
    echo "newScene\n"
    newScene = some(scene)

  currentScene = Scene(newMainMenuScene(window, doNewScene))

  window.title = fmt"Succulentia - {currentScene.title}"
  MainMenuScene(currentScene).load(window)
  window.view = currentScene.view

  window.mouseCursorVisible = false
  while window.open:
    if newScene.isSome:
      window.title = fmt"Succulentia - {currentScene.title}"
      currentScene = newScene.get()
      if currentScene of Stage1:
        Stage1(currentScene).load()

      window.view = currentScene.view
      newScene = none(Scene)

    # currentScene.draw();
    window.clear color(112, 197, 206)

    # TODO refactor
    if currentScene of MainMenuScene:
      let menuScene = MainMenuScene(currentScene)
      menuScene.pollEvent(window)
      menuScene.update(window)
      menuScene.draw(window)
    elif currentScene of Stage1:
      let stageScene = Stage1(currentScene)
      stageScene.pollEvent(window)
      stageScene.update(window)
      stageScene.draw(window)

    window.display()


when isMainModule:
  var windowConfig: WindowConfig
  windowConfig = (
    title: "Succulentia",
    width: cint(640),
    height: cint(480),
    fps: cint(60)
  )
  main(windowConfig)
