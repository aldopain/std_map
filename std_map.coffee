Jimp = require 'Jimp'
fs = require 'fs'
Promise = require 'bluebird'

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
  new Promise (resolve, reject)->
    img = new Jimp size, size, (error, img)->
      if error then reject error else resolve 0
      for i in [0...size]
        for j in [0...size]
          color = setColor arr[i][j]
          img.setPixelColor color, j, i
      img.write "./files/#{name}.jpg", (error)->
        if error then reject error else resolve 0

rgbToInt = (r, g, b)->
  (r << 24) + (g << 16) + (b << 8)

fraction = (x)->
  x - Math.trunc x

mod2Pi = (x)->
  if x < 0 then x += 2 * pi
  return (fraction x/(2 * pi)) * 2 * pi

round = (x)->
  Math.round (x * (size - 1) / (2 * pi))

Drw1 = (x, y)->
  for i in [0...itCount]
    tmp = x
    x = mod2Pi (x + K * Math.sin y)
    y = mod2Pi (y + x)
    if arr[round x][round y] == undefined then arr[round x][round y] = 1
    else arr[round x][round y] += 1

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

f1 1, 0.1, 2000, colors, ranges, { t0: 0, max: 2 * pi, d: 0}, "test21"
.then ->
  f1 1, 0.1, 2000, colors, ranges, { t0: pi, max: 3 * pi, d: pi}, "test22"
.then ->
  f1 1, 0.1, 2000, colors, ranges, { t0: pi, max: pi + 0.5, d: pi}, "test23"