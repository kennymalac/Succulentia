import times

import csfml #, csfml/ext

import entities/entity
import entities/enemy
import assetLoader

type
  Scene* = ref object of RootObj
    title*: string
    size*: Vector2i
    view*: View
    entities*: seq[Entity]
    assetLoader*: AssetLoader

    origin: Vector2f

    currentTime*: times.Time
    previousTime: times.Time

proc initScene*(self: Scene, window: RenderWindow, title: string, origin: Vector2f) =
  self.title = title
  self.origin = origin
  self.size = window.size
  self.previousTime = getTime()
  self.view = newView(origin, window.size)
  self.assetLoader = newAssetLoader("assets")

proc newScene*(window: RenderWindow, title: string, origin: Vector2f): Scene =
  new result
  initScene(result, window, title, origin)

proc load*(self: Scene) =
  # Scenes overload this to initialize all initial entities
  discard

proc pollEvent*(self: Scene, window: RenderWindow) =
  discard

proc update*(self: Scene, window: RenderWindow): Duration =
  self.previousTime = self.currentTime
  self.currentTime = getTime()
  var dt = self.currentTime - self.previousTime

  for i, entity in self.entities:
    if entity of Enemy:
      Enemy(entity).update(dt, self.entities)
    else:
      entity.update(dt)

  return dt

proc draw*(self: Scene, window: RenderWindow) =
  for i, entity in self.entities:
    # entity.draw()
    window.draw(entity.sprite)
