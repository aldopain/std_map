Promise = require 'bluebird'

size = 750
a1 = 0
a2 = 0
stop = false
heap = 0

t1 = ()->
  for i in [0...size]
    for j in [0...size]
      for k in [0...size]
        h = process.memoryUsage().heapUsed / 1024 / 1024
        if h > heap then heap = h

t2 = ->
  for i in [0...size]
    summ i

summ = (i)->
  new Promise (resolve, reject)->
    for j in [0...size]
      summ2 i, j

summ2 = (i, j)->
  new Promise (resolve, reject)->
    for k in [0...size]
      a += i + j + k
  
start1 = new Date().getTime()
t1()
console.log (new Date().getTime() - start1)
console.log heap
# start2 = new Date().getTime()
# t2()
# console.log (new Date().getTime() - start2)
# console.log a2