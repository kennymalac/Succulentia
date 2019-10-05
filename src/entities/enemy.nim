import csfml
import entity
import succulent
import times

type
  Enemy* = ref object of Entity
    direction: Vector2i
    damage: int
    speed: int
    health: int

type 
  Ant* = ref object of Enemy

type 
  Spider* = ref object of Enemy

type
  Bee* = ref object of Enemy

proc update*(self: Enemy, dt: times.Time) = 
  #self.position = self.speed * dt
  discard

proc turn*(self: Enemy, direction: Vector2i) =
  self.direction = direction

proc attack*(self: Enemy, direction: Vector2i, succulent: Succulent) =
  # attack logic
  # attack animation
  # attack direction
  succulent.health -= self.damage

proc print*(self: Ant) =
  echo "I am an Ant\n"

proc print*(self: Spider) =
  echo "I am a Spider\n"

proc print*(self: Bee) =
  echo "I am a Bee\n"
