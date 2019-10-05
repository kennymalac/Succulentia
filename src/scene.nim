import entities/entity
import assetLoader

import times, sequtils
import csfml #, csfml/ext

type
  Scene* = ref object
    title*: string
    size*: Vector2f
    view*: View
    entities*: seq[Entity]
    assetLoader*: AssetLoader

    origin: Vector2f

    currentTime: times.Time
    previousTime: times.Time

proc newScene*(window: RenderWindow, title: string, origin: Vector2f, size: Vector2f): Scene =
  result = Scene(
    title: title,
    origin: origin,
    size: size,
    previousTime: getTime(),
    view: new_View(origin, size),
    assetLoader: newAssetLoader("assets")
  )

proc load*(self: Scene) =
  # Scenes overload this to initialize all initial entities
  discard

proc update*(self: Scene) =
  self.currentTime = getTime()
  var dt = self.currentTime - self.previousTime

  for i, entity in self.entities:
    entity.update(dt)

proc draw*(self: Scene, window: RenderWindow) =
  for i, entity in self.entities:
    # entity.draw()
    window.draw(entity.sprite)
