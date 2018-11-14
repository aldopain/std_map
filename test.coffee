GPU = require 'gpu.js'
gpu = new GPU()

a = []
b = []

matMultGpu = gpu.createKernel (a, b)->
    sum = 0
    for i in [0...512]
        sum += a[this.thread.y][i] * b[i][this.thread.x]
    return sum
.setOutput [512, 512]

matMult = (a, b)->
  sum = 0
  for i in [0...512]
      sum += a[this.thread.y][i] * b[i][this.thread.x]
  sum

init = ()->
  for i in [0...512]
    a[i] = 6
    b[i] = 7

init()
start = new Date().getTime()
console.log matMultGpu a, b
console.log (new Date().getTime() - start)
init()
start = new Date().getTime()
console.log matMult a, b
console.log (new Date().getTime() - start)