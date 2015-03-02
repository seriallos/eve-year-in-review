_ = require 'lodash'

class CharacterFacts
  constructor: (@stats) ->

  preferredSecurity: ->
    # TODO: report on near splits
    travelStats = []
    for sec in @stats.secSuffixes
      travelStats.push({
        sec: sec
        pct: @stats.percent 'travelDistanceWarped', sec
      })
    mostTravelled = _.max travelStats, (ts) -> ts.pct
    return mostTravelled.sec

  getFacts: ->
    return {
      preferredSec: @preferredSecurity()
    }


module.exports = CharacterFacts
