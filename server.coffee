express = require 'express'
app = express();
std_map = require './std_map.js'

app.use express.static 'files'

app.get '/', (req, res)->
  K = req.query.K
  Step = req.query.Step
  Size = req.query.Size
  if K == undefined or Size == undefined or Step == undefined then res.sendFile __dirname + '/index.html'
  else
    if std_map((parseFloat K), (parseFloat Step), (parseInt Size)) != "error" then res.sendFile __dirname + '/result.html'
    else res.sendFile __dirname + '/index.html'

app.listen 3000, ->
  console.log 'Example app listening on port 3000!'