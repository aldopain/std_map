Jimp = require 'Jimp'
fs = require 'fs'
Promise = require 'bluebird'

pi = Math.PI
tPi = 2 * pi

# default settings for tests
K = 1
step = 0.1
size = 500
ranges = [ 0.1, 0.3, 0.6 ]

#colors = [0xAADCFAFF, 0xE4F0DAFF, 0xE4F0BEFF, 0xE4F08CFF, 0xE4F064FF, 0xE4F04BFF, 0xE4F032FF, 0xE4F000FF]

# белый, красный, зеленый, синий, черный
colors = [0xFFFFFFFF, 0xFF0F0FFF, 0x00FF26FF, 0x2408FFFF, 0x000000FF]
itCount = 100000

arr = []
tol = 0.01

neighborAmountToSpawn = 7;
neighborAmountToDie = 5;
stepCount = 100;

xOffset = pi
yOffset = 0

# возвращает элемент по индексу [y, x], если он есть
getElement = (x, y)->
  try
    return arr[y][x]
  catch e
    return -1;

# считает количество соседей клетки [y, x]
countNeighbors = (x, y)->
  iter = [ 1, -1, 0 ];
  count = 0
  for i in [0...3]
    for j in [0...3]
      if(!(j == 0 and i == 0) and getElement(x + iter[i], y + iter[j]) == 1)
        count++
  count

# одна итерация клеточного автомата
iterationStep = ()->
  nextIterationCave = []
  for i in [0...size]
    nextIterationCave.push []
  for i in [0...size]
    for j in [0...size]
      neighbors = countNeighbors(j, i);
      if arr[i][j] == 1 and neighbors < neighborAmountToDie
        nextIterationCave[i][j] = 0;
      else if (arr[i][j] == 0 or arr[i][j] == undefined) and neighbors > neighborAmountToSpawn
        nextIterationCave[i][j] = 1;
      else
        nextIterationCave[i][j] = arr[i][j];
  arr = nextIterationCave;

# преобразует матрицу после stepCount итераций iterationStep()
getMatrix = ()->
  for i in [0...size]
    for j in [0...size]
      arr[i][j] = if arr[i][j] < tol or arr[i][j] == NaN or arr[i][j] == undefined then 1 else 0
  for i in [0...stepCount]
    iterationStep()
  null

init = ()->
  for i in [0...size]
    arr.push []

setColor = (v)->
  if v == undefined or v == 1 then return colors[0]
  else return colors[colors.length - 1]

show = (name)->
  new Promise (resolve, reject)->
    img = new Jimp size, size, (error, img)->
      if error then reject error else resolve 0
      for i in [0...size]
        for j in [0...size]
          color = setColor arr[i][j]
          img.setPixelColor color, j, i
      img.write "./files/#{name}.jpg", (error)->
        if error then reject error else resolve 0

mod2Pi = (x)->
  (x % tPi + tPi) % tPi

round = (x, t)->
  if t == "y"
    if x < yOffset then x += yOffset else x -= yOffset
  else 
    if x < xOffset then x += xOffset else x -= xOffset
  Math.round (x * (size - 1) / (tPi))

Drw1 = (x, y)->
  traectory = []
  ep = 1
  eq = 0
  lsum = 0
  i = 0
  start = [x, y]
  for i in [0...itCount]
    x = mod2Pi (x + K * Math.sin y)
    y = mod2Pi (y + x)
    dq = K * Math.cos y
    epn = ep + dq * eq
    eqn = ep + (1 + dq) * eq
    ep = epn
    eq = eqn
    dn = Math.sqrt(ep * ep + eq * eq)
    ep = ep / dn
    eq = eq / dn
    lsum += Math.log dn
    traectory.push { x: (round (mod2Pi x), "x"), y: (round (mod2Pi y), "y") }
  LLE = lsum / itCount
  for point in traectory
    if arr[point.x][point.y] == undefined then arr[point.x][point.y] = LLE

run = (t0, max, d)->
  arr = []
  init()
  while t0 <= max
    Drw1 t0, d
    Drw1 d, t0
    t0 += step

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
      resolve 0
    .catch (err)->
      console.log err

cercularAutomata = (k, st, sz, c, r, runSettings, name)->
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
    getMatrix()
    ct = new Date().getTime()
    console.log "cercular automata time = " + (ct - runEnd)
    show(name)
    .then ->
      showEnd = new Date().getTime()
      console.log "show time = " + (showEnd - ct)
      console.log "total time = " + (showEnd - start)
      resolve 0
    .catch (err)->
      console.log err



f1 0.8, 0.01, 6000, colors, ranges, { t0: 0, max: 2 * pi, d: 0}, "kekeketest"

# .then ->
#   f1 1, 0.1, 2000, colors, ranges, { t0: pi, max: 3 * pi, d: pi}, "test22"
# .then ->
#f1 1, 0.1, 2000, colors, ranges, { t0: 2 * pi, max: 4 * pi, d: 0}, "test23"