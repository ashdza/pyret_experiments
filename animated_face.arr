import image as I
import world as W
import image-structs as C

#world state is time since program has started, and mood
data World:
    world(t :: Number, m :: Number)
end

fun draw-world(w :: World) -> I.Image:
  r-face = 10 + num-abs(30 * num-sin(w.t))
  r-eye = r-face / 7
  eye1 = I.circle(r-eye, "solid", "black")
  eye2 = I.circle(r-eye, "solid", "black")
  mood-color = C.color(200, 100, w.m * 10, 1)
  face = I.circle(r-face, "solid", mood-color)
  f1 = I.underlay-xy(face, r-face / 2, r-face / 3, eye1)
  I.underlay-xy(f1, 3 * (r-face / 2), r-face / 3, eye2) 
end

fun tick-world(w :: World) ->  World:
  world(w.t + 0.05, w.m)
end

fun key-world(w :: World, k :: String) -> World:
  if (k == "up"):
    world(w.t, w.m + 5)
  else if (k == "down"):
    world(w.t, w.m - 5)
  else: w
  end
end

#c = I.circle(r, "solid", "red")

fun go():
  W.big-bang(world(0, 0), [list: 
      W.to-draw(draw-world), 
      W.on-tick(tick-world), 
      W.on-key(key-world)])
end