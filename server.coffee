express = require 'express'
app = express();
std_map = require './std_map.js'

app.use express.static 'files'

app.get '/', (req, res)->
  K = req.query.K
  Step = req.query.Step
  Size = req.query.Size
  colors = [ req.query.Color1, req.query.Color2, req.query.Color3, req.query.Color4, req.query.Color5, req.query.Color6, req.query.Color7, req.query.Color8 ]
  intervals = [ (parseInt req.query.Range1), (parseInt req.query.Range2), (parseInt req.query.Range3), (parseInt req.query.Range4), (parseInt req.query.Range5), (parseInt req.query.Range6) ]
  if K == undefined or Size == undefined or Step == undefined or !(parseRanges intervals) then res.sendFile __dirname + '/index.html'
  else
    answ = std_map((parseFloat K), (parseFloat Step), (parseInt Size), (parseColors colors), intervals)
    if answ != "error"
      console.log answ
      res.sendFile __dirname + '/result.html'
    else res.sendFile __dirname + '/index.html'

app.listen 3000, ->
  console.log 'Example app listening on port 3000!'

parseColors = (colors)->
  ret = []
  for color in colors
    ret.push parseInt ("0x" + color + "FF")
  ret

parseRanges = (ranges)->
  for i in [0...ranges.length]
    range = ranges[i]
    if !(range > 0)
      console.log "#{range} ##{i} is not valid"
      return false
  true