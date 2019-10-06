import csfml, csfml/ext
import tables

import stages/stage1

type WindowConfig = tuple[title: string, width: cint, height: cint, fps: cint]

proc setupWindow(windowConfig: WindowConfig): RenderWindow =
  let (title, width, height, fps) = windowConfig

  result = new_RenderWindow(video_mode(width, height), title)
  result.vertical_sync_enabled = true
  result.framerate_limit = fps

proc main(windowConfig: WindowConfig) =
  let window = setupWindow(windowConfig)

  var currentScene = newStage1(window)
  currentScene.load()
  window.view = currentScene.view

  while window.open:
    currentScene.pollEvent(window)

    # currentScene.draw();
    window.clear color(112, 197, 206)
    currentScene.update()
    currentScene.draw(window)
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
