Jimp = require 'Jimp'
fs = require 'fs'
Promise = require 'bluebird'
# gpu = new GPU()

pi = Math.PI

# default settings for tests
K = 1
step = 0.1
size = 500
ranges = [10, 20, 50, 100, 250, 500]
colors = [0xAADCFAFF, 0xE4F0DAFF, 0xE4F0BEFF, 0xE4F08CFF, 0xE4F064FF, 0xE4F04BFF, 0xE4F032FF, 0xE4F000FF]
itCount = 100000

arr = []

init = ()->
  for i in [0...size]
    arr.push []

setColor = (v)->
  if v == undefined then return colors[0]
  for i in [0...ranges.length]
    if v < ranges[i] then return colors[i + 1]
  return colors[colors.length - 1]

show = (name)->
  img = new Jimp size, size, (error, img)->
    if error then throw error
    for i in [0...size]
      for j in [0...size]
        color = setColor arr[i][j]
        img.setPixelColor color, j, i
    img.write "./files/#{name}.jpg", (error)->
      console.log if error then error else "done"
    arr = []
    console.log "erased"

rgbToInt = (r, g, b)->
  (r << 24) + (g << 16) + (b << 8)

fraction = (x)->
  x - Math.trunc x

mod2Pi = (x)->
  if x < 0 then x += 2 * pi
  return (fraction x/(2 * pi)) * 2 * pi

round = (x)->
  Math.round (x * (size - 11) / (2 * pi)) + 10

Drw1 = (x, y)->
  for i in [0...itCount]
    tmp = x
    x = mod2Pi (x + K * Math.sin y)
    y = mod2Pi (y + x)
    if arr[round x][round y] == undefined then arr[round x][round y] = 1
    else arr[round x][round y] += 1

pDrw1 = (x, y)->
  new Promise (resolve, reject)->
    for i in [0...itCount]
      tmp = x
      x = mod2Pi (x + K * Math.sin y)
      y = mod2Pi (y + tmp)
      if arr[round x][round y] == undefined then arr[round x][round y] = 1
      else arr[round x][round y] += 1

run = (t0, max, d)->
  init()
  while t0 <= max
    Drw1 t0, d
    Drw1 d, t0
    t0 += step

pRun = ()->
  init()
  t0 = -pi
  while t0 <= pi
    pDrw1 t0, 0
    pDrw1 0, t0
    t0 += step

module.exports = f1 = (k, st, sz, c, r, runSettings, name)->
  K = k
  step = st
  size = sz
  #colors = c
  ranges = r
  if !(K > 0) or !(step > 0) or !(size > 0) then return "error"
  start = new Date().getTime()
  run(runSettings.t0, runSettings.max, runSettings.d)
  runEnd = new Date().getTime()
  console.log "run time = " + (runEnd - start)
  show(name)
  showEnd = new Date().getTime()
  console.log "show time = " + (showEnd - runEnd)
  console.log "total time = " + (showEnd - start)
  null

f2 = (k, st, sz, c, r)->
  K = k
  step = st
  size = sz
  colors = c
  ranges = r
  if !(K > 0) or !(step > 0) or !(size > 0) then return "error"
  start = new Date().getTime()
  pRun()
  runEnd = new Date().getTime()
  console.log "run time = " + (runEnd - start)
  show("pRun")
  showEnd = new Date().getTime()
  console.log "show time = " + (showEnd - runEnd)
  console.log "total time = " + (showEnd - start)
  null

# lyap = (points)->

f1 1, 0.1, 2000, colors, ranges, { t0: 0, max: 2 * pi, d: 0}, "test1"
f1 1, 0.1, 2000, colors, ranges, { t0: pi, max: 2 * pi, d: pi}, "test2"
f1 1, 0.1, 2000, colors, ranges, { t0: -pi, max: 0, d: 0}, "test3"
f1 1, 0.1, 2000, colors, ranges, { t0: 0, max: 2 * pi, d: 0.5}, "test4"