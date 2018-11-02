Jimp = require 'Jimp'
fs = require 'fs'

K = 1

t0 = 0
pi = Math.PI
step = 0.1

size = 500

arr = []

init = ()->
  for i in [0...size]
    arr.push []

setColor = (v)->
  switch
    when v == undefined then return 0xAADCFAFF
    when v < 10 then return 0xE4F0DAFF
    when v < 20 then return 0xE4F0BEFF
    when v < 50 then return 0xE4F08CFF
    when v < 100 then return 0xE4F064FF
    when v < 250 then return 0xE4F04BFF
    when v < 500 then return 0xE4F032FF
    else return 0xE4F000FF

show = ()->
  img = new Jimp size, size, (error, img)->
    if error then throw error
    for i in [0...size]
      for j in [0...size]
        img.setPixelColor setColor(arr[i][j]), j, i
    img.write './files/test1.jpg', (error)->
      arr = []
      console.log if error then error else "done"

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
  for i in [0...100000]
    tmp = x
    x = mod2Pi (x + K * Math.sin y)
    y = mod2Pi (y + x)
    if arr[round x][round y] == undefined then arr[round x][round y] = 1
    else arr[round x][round y] += 1

run = ()->
  init()
  while t0 <= 2 * pi
    Drw1 t0, 0
    Drw1 0, t0
    t0 += step

module.exports = (k, st, sz)->
  K = k
  step = st
  size = sz
  if !(K > 0) or !(step > 0) or !(size > 0) then return "error"
  run()
  show()
  null