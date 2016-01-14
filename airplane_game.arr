import image as I
import world as W

##### WORLD STATE #####
data Pos:
  | pos(x :: Number, y :: Number)
end

type Airplane = Pos
type Balloon = Pos

data World:
  | world(airplane :: Airplane, balloon :: Balloon)
end

##### IMAGES #####
AIRPLANE-URL =
  "http://world.cs.brown.edu/1/clipart/airplane-small.png"
AIRPLANE = I.image-url(AIRPLANE-URL)

BALLOON-URL =
  "http://world.cs.brown.edu/1/clipart/balloon-small.png"
BALLOON = I.image-url(BALLOON-URL)

AIRPLANE-X-MOVE = 10
AIRPLANE-Y-MOVE = 20

BALLOON-Y-MOVE = 5

WIDTH = 800
HEIGHT = 500

BASE-HEIGHT = 50
WATER-WIDTH = 500

BLANK-SCENE = I.empty-scene(WIDTH, HEIGHT)

WATER = I.rectangle(WATER-WIDTH, BASE-HEIGHT, "solid", "blue")
LAND = I.rectangle(WIDTH - WATER-WIDTH, BASE-HEIGHT, "solid", "brown")

half-plane-length = 0.5 * I.image-width(AIRPLANE)
half-plane-height = 0.5 * I.image-height(AIRPLANE)

screen-bottom = HEIGHT - BASE-HEIGHT

BASE = I.beside(WATER, LAND)
BACKGROUND =
  I.place-image(BASE, WIDTH / 2, HEIGHT - (BASE-HEIGHT / 2), BLANK-SCENE)

##### COLLISION #####
fun check-collide(a :: Airplane, b :: Balloon) -> Boolean:
  ah = (I.image-height(AIRPLANE) / 2)
  aw = (I.image-width(AIRPLANE) / 2)
  bh = (I.image-height(BALLOON) / 2)
  bw = (I.image-width(BALLOON) / 2)
  (num-abs(a.x - b.x) <= (aw + bw)) and (num-abs(a.y - b.y) <= (ah + bh))
where: 
  check-collide(pos(5, 5), pos(5, 5)) is true
  check-collide(pos(0, 0), pos(200, 200)) is false
  check-collide(pos(10, 10), pos(8, 8)) is true
end

##### KEYS #####
fun key-world(w :: World, key :: String) -> World:
  at-bottom :: Boolean = (w.airplane.y >= (screen-bottom - half-plane-height))
  at-top :: Boolean = (w.airplane.y <= 0)
  if key == "up":
    if at-top:
      w
    else:
      world(pos(w.airplane.x, w.airplane.y - AIRPLANE-Y-MOVE), w.balloon)
    end
  else if key == "down":
    if at-bottom:
      w
    else:
      world(pos(w.airplane.x, (w.airplane.y + AIRPLANE-Y-MOVE)), w.balloon)
    end
  else: w
  end
where:
  w1 = world(pos(1, 10), pos(0, 0))
  key-world(w1, "up") is world(pos(1, (10 - AIRPLANE-Y-MOVE)), w1.balloon)

  w2 = world(pos(1, 0), pos(0, 0))
  key-world(w2, "up") is w2

  w3 = world(pos(1, 10), pos(0,0))
  key-world(w3, "down") is 
  world(pos(1, (10 + AIRPLANE-Y-MOVE)), w3.balloon)

  w4 = world(pos(1, (screen-bottom - half-plane-height)), pos(0,0))
  key-world(w4, "down") is w4
end

##### DRAW #####
fun draw-world(w :: World) -> I.Image:
  im = draw-airplane(w.airplane, draw-balloon(w.balloon, BACKGROUND))
  if check-collide(w.airplane,  w.balloon):
    gotcha = I.text("gotcha!", 50, "red")
    I.overlay(gotcha, im)
  else: 
    im
  end
end

fun draw-balloon(b :: Balloon, bknd ) -> I.Image:
  I.place-image(BALLOON, b.x, b.y, bknd)
where:
  draw-balloon(pos(0, 100), BACKGROUND) is 
  I.place-image(BALLOON, 0, 100, BACKGROUND)
end 

fun draw-airplane(a :: Airplane, bknd) -> I.Image:
  I.place-image(AIRPLANE, a.x, a.y, bknd)
where:
  draw-airplane(pos(0,0), BACKGROUND) is 
  I.place-image(AIRPLANE, 0, 0, BACKGROUND)
end

##### TICK #####
fun tick-world(w :: World) -> World:
  world(tick-airplane(w.airplane), tick-balloon(w.balloon))
end

fun tick-airplane(a :: Airplane) -> Airplane:
  past-edge :: Boolean = a.x >= (WIDTH + half-plane-length)
  if (past-edge): 
    pos(0 - half-plane-length, a.y)
  else:
    pos(a.x + AIRPLANE-X-MOVE, a.y)
  end
where:
  pos-to-just-move = pos(50, 10)
  just-moved-pos = pos((50 + AIRPLANE-X-MOVE), 10)
  tick-airplane(pos-to-just-move) is just-moved-pos

  pos-to-wrap = pos((WIDTH + (0.5 * I.image-width(AIRPLANE))), 80)
  wrapped-pos = pos((-0.5 * I.image-width(AIRPLANE)), 80)
  tick-airplane(pos-to-wrap) is wrapped-pos
end

fun tick-balloon(b :: Balloon) -> Balloon:
  at-top :: Boolean = b.y <= (0 - (0.5 * I.image-height(BALLOON)))
  if (at-top): 
    pos(b.x, HEIGHT)
  else: 
    pos(b.x, b.y - BALLOON-Y-MOVE)
  end
where:
  tick-balloon(pos(5, -100)) is pos(5, HEIGHT)
  tick-balloon(pos(0, 100)) is pos(0, 100 - BALLOON-Y-MOVE)
end

##### BIG-BANG #####
fun end-game(w :: World) -> Boolean:
  check-collide(w.airplane, w.balloon)
end

fun go():
  W.big-bang(world(pos(0,10), pos(300, 100)), 
    [list: 
      W.on-tick(tick-world), W.on-key(key-world),
      W.to-draw(draw-world), W.stop-when(end-game)])
end


