import entities/entity

import times, sequtils
import csfml #, csfml/ext

type
  Scene* = ref object
    title*: string
    size*: Vector2f
    view*: View
    entities*: seq[Entity]

    origin: Vector2f

    currentTime: times.Time
    previousTime: times.Time

proc newScene*(window: RenderWindow, title: string, origin: Vector2f, size: Vector2f): Scene =
  new result
  result.title = title
  result.origin = origin
  result.size = size

  result.view = new_View(origin, size)

proc update*(self: Scene): void =
  self.currentTime = getTime()
  var dt = self.currentTime - self.previousTime

  for i, entity in self.entities:
    entity.update(dt)

proc draw*(self: Scene, window: RenderWindow): void =
  for i, entity in self.entities:
    # entity.draw()
    window.draw(entity.sprite)
