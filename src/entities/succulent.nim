import entity

type
  Succulent* = ref object of Entity
    health*: int

proc print*(self: Succulent) =
  echo "I am a succulent\n"
