fs = require 'fs'

out = {}

raw = fs.readFileSync('./fields.json',{encoding: 'utf8'})
data = JSON.parse(raw)
for field, bounds of data
  out[field] = bounds.min + Math.round(bounds.max * Math.random())

console.log JSON.stringify(out)
