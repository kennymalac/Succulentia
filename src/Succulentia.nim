import csfml, csfml/ext
import tables

type WindowConfig = tuple[title: string, width: cint, height: cint, fps: cint]

proc setupWindow(windowConfig: WindowConfig): RenderWindow =
  let (title, width, height, fps) = windowConfig

  result = new_RenderWindow(video_mode(width, height), title)
  result.vertical_sync_enabled = true
  result.framerate_limit = fps

proc main(windowConfig: WindowConfig): void =
  let window = setupWindow(windowConfig)

  while window.open:
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
        else: discard

    # currentScene.draw();
    window.clear color(112, 197, 206)
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
