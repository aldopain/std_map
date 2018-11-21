Jimp = require 'Jimp'
fs = require 'fs'
Promise = require 'bluebird'

pi = Math.PI

# default settings for tests
K = 1
step = 0.1
size = 500
ranges = [ 0.1, 0.3, 0.6 ]

stepLog = 0


#colors = [0xAADCFAFF, 0xE4F0DAFF, 0xE4F0BEFF, 0xE4F08CFF, 0xE4F064FF, 0xE4F04BFF, 0xE4F032FF, 0xE4F000FF]

# белый, красный, зеленый, синий, черный
colors = [0xFFFFFFFF, 0xFF0F0FFF, 0x00FF26FF, 0x2408FFFF, 0x000000FF]
itCount = 100000

arr = []
#tol = 0.1

init = ()->
  for i in [0...size]
    arr.push []

setColor = (v)->
  if v == undefined or v == NaN then return colors[0]
  for i in [0...ranges.length]
    if v < ranges[i] then return colors[i + 1]
  return colors[colors.length - 1]

setColor2 = (v)->
  if v == undefined or v < tol then return colors[0]
  else return colors[colors.length - 1]

show = (name)->
  new Promise (resolve, reject)->
    img = new Jimp size, size, (error, img)->
      if error then reject error else resolve 0
      for i in [0...size]
        for j in [0...size]
          color = if needLyap then setColor arr[i][j] else setColor arr[i][j]
          img.setPixelColor color, j, i
      img.write "./files/#{name}.jpg", (error)->
        if error then reject error else resolve 0

rgbToInt = (r, g, b)->
  (r << 24) + (g << 16) + (b << 8)

fraction = (x)->
  x - Math.trunc x

mod2Pi = (x)->
  if x < 0 then x += tPi
  return (fraction x/(tPi)) * tPi

round = (x)->
  Math.round (x * (size - 1) / (tPi))

comparePoints = (p1, p2)->
  p1.x == p2.x and p1.y == p2.y

findPointInTraectory = (point, traectory)->
  for tp in traectory
    if comparePoints tp, point then return true
  false

Drw1 = (x, y)->
  traectory = []
  ep = 1
  eq = 0
  lsum = 0
  i = 0
  start = [x, y]
  for i in [0...itCount]
    stepLog++
    x = mod2Pi (x + K * Math.sin y)
    y = mod2Pi (y + x)
    if needLyap
      dq = -K * Math.cos y
      epn = ep + dq * eq
      eqn = ep + (1 + dq) * eq
      ep = epn
      eq = eqn
      dn = Math.sqrt(ep * ep + eq * eq)
      ep = ep / dn
      eq = eq / dn
      lsum += Math.log dn
      traectory.push { x: x, y: y }
    else
      if arr[round x][round y] == undefined then arr[round x][round y] = 1
      else arr[round x][round y] += 1
  if needLyap
    LLE = lsum / itCount
    for point in traectory
      if arr[round point.x][round point.y] == undefined then arr[round point.x][round point.y] = LLE

run = (t0, max, d)->
  arr = []
  init()
  while t0 <= max
    Drw1 t0, d
    Drw1 d, t0
    t0 += step

frun = (t0, max, d)->
  arr = []
  init()
  Drw1 0, 3.4

module.exports = f1 = (k, st, sz, c, r, runSettings, name)->
  new Promise (resolve)->
    K = k
    step = st
    size = sz
    colors = c
    ranges = r
    if !(K > 0) or !(step > 0) or !(size > 0) then return "error"
    start = new Date().getTime()
    run(runSettings.t0, runSettings.max, runSettings.d)
    runEnd = new Date().getTime()
    console.log "run time = " + (runEnd - start)
    show(name)
    .then ->
      showEnd = new Date().getTime()
      console.log "show time = " + (showEnd - runEnd)
      console.log "total time = " + (showEnd - start)
      console.log "steps = #{stepLog}"
      resolve 0
    .catch (err)->
      console.log err

tPi = 2 * pi
needLyap = true

f1 1, 0.1, 1000, colors, ranges, { t0: 0, max: 2 * pi, d: 0}, "test32145"

# .then ->
#   f1 1, 0.1, 2000, colors, ranges, { t0: pi, max: 3 * pi, d: pi}, "test22"
# .then ->
#f1 1, 0.1, 2000, colors, ranges, { t0: 2 * pi, max: 4 * pi, d: 0}, "test23"