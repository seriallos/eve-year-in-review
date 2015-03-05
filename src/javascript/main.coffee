
# Ideas
# * Damage represented by ship icon (relative EHP)
#   * Silhoette icon, standard EHP on a PVP fit
# * Stat per minute (any stat divided by active minutes)
# AU breakdown (distance to different galaxies, amount of years at speed of light)

# TODO
# * Less intense H/L/N/W colors
# * More/better raw stat formatters (minutes to H:M, etc)
# * tick marks on HP Chart (shield armor hull half circle)
# * Fix 1 column layout, test on phone/tablet
# * Partial analogy icons (0.6 of an avatar)
# * More ships, auto select ship that has a couple hundred kills
# * Empty charts/tables, don't proper empty message
# * Format numbers to 1M, 1B, 1T instead of lots of digits?

# Data requests / questions
# * Drone damage (also, are fighters drones?) (PC vs NPC)
# * PVE
#   * Incursions?
#   * Rat kills
#   * DED/explo plexes
#   * ECM/Damp/TP/Vamp - PC vs NPC?
# * Pods contained in the kill data or separate?
# * Self cap boosting (to supplement cap transfers)
# * Wormhole docking (Thera)
# * PI Stats?
# * Industry stats - number of runs, not quantity of output (charges throw off the stats)

React = require 'react'
$ = require 'jquery'
d3 = require 'd3'
_ = require 'lodash'

# polyfill for safari
if not Intl
  Intl = require 'intl'

CharacterStats = require './character_stats'
CharacterFacts = require './character_facts'

dom = React.DOM

samples = [
  'dscan'
  'explorer'
  'industry'
  'lowsec'
  'null_pvp'
  'market'
  'miner'
  'missions'
]


# sources of sampled colors
#   * subcap weapons: http://i.imgur.com/c08RJ.jpg
STYLES =
  hybrid:
    label: 'Hybrid'
    color: '#4E815F'
    iconId: 238
  missile:
    label: 'Missile'
    color: '#5379AB'
    iconId: 203
  projectile:
    label: 'Projectile'
    color: '#B4633C'
    iconId: 201
  laser:
    label: 'Laser'
    color: '#A69A31'
    iconId: 262
  bomb:
    label: 'Bomb'
    color: 'red'
    iconId: 27920
  smartbomb:
    label: 'Smart Bomb'
    color: 'purple'
    iconId: 3993
  fighter:
    label: 'Fighter Bomber'
    color: 'orange'
    iconId: 1
  dd:
    label: 'Doomsday'
    color: 'black'
    iconId: 24550
  shield:
    label: 'Shield'
    color: 'white'
    iconId: 10838
  web:
    label: 'Stasis Webifier'
    iconId: 526
  scram:
    label: 'Warp Scrambler'
    iconId: 3242
  neut:
    label: 'Energy Neutralizer'
    iconId: 12269
  armor:
    label: 'Armor'
    color: 'white'
    iconId: 3538
  hull:
    label: 'Hull'
    color: 'white'
    iconId: 3663
  high:
    label: 'High Sec'
    color: '#11ee11'
  low:
    label: 'Low Sec'
    color: '#dfdf00'
  null:
    label: 'Null Sec'
    color: '#df0000'
  wormhole:
    label: 'Wormholes'
    color: '#0000df'
  charge:
    label: 'Charges'
  commodity:
    label: 'Commodity'
  deployable:
    label: 'Deployable'
  drone:
    label: 'Drone'
  implant:
    label: 'Implant'
  module:
    label: 'Module'
  ship:
    label: 'Ship'
  structure:
    label: 'Structure'
  subsystem:
    label: 'Subsystem'

  arkonor:
    label: 'Arkonor'
    iconId: 22
  bistot:
    label: 'Bistot'
    iconId: 1223
  crokite:
    label: 'Crokite'
    iconId: 1225
  darkochre:
    label: 'Dark Ochre'
    iconId: 1232
  gneiss:
    label: 'Gneiss'
    iconId: 1229
  gas:
    label: 'Harvestable Cloud'
    iconId: 30372
  hedbergite:
    label: 'Hedbergite'
    iconId: 21
  hemoprphite:
    label: 'Hemorphite'
    iconId: 1231
  ice:
    label: 'Ice'
    iconId: 16264
  jaspet:
    label: 'Jaspet'
    iconId: 1226
  kernite:
    label: 'Kernite'
    iconId: 20
  mercoxit:
    label: 'Mercoxit'
    iconId: 11396
  omber:
    label: 'Omber'
    iconId: 1227
  plagioclase:
    label: 'Plagioclase'
    iconId: 18
  pyroxeres:
    label: 'Pyroxeres'
    iconId: 1224
  scordite:
    label: 'Scordite'
    iconId: 1228
  spodumain:
    label: 'Spodumain'
    iconId: 19
  veldspar:
    label: 'Veldspar'
    iconId: 1230

  great:
    label: 'Excellent'
    color: '#0C2174'
    icon: 'images/standingsExcellent.png'
  good:
    label: 'Good'
    color: '#3E5FBF'
    icon: 'images/standingsGood.png'
  neutral:
    label: 'Neutral'
    color: '#868786'
    icon: 'images/standingsNeutral.png'
  bad:
    label: 'Bad'
    color: '#A94700'
    icon: 'images/standingsBad.png'
  horrible:
    label: 'Terrible'
    color: '#7C0000'
    icon: 'images/standingsTerrible.png'

# alias styles
STYLES.HighSec = STYLES.high
STYLES.LowSec = STYLES.low
STYLES.NullSec = STYLES.null
STYLES.Wormhole = STYLES.wormhole

HP_BAR_ORDER = ['shield','armor','hull']

styleIconUrl = (key, width = 32) ->
  return eveIconUrl(STYLES[key].iconId, width)

eveIconUrl = (id, width = 32) ->
  return "https://image.eveonline.com/Type/#{id}_#{width}.png"

StatsUI = React.createClass(
  displayName: 'CharacterStatsUI'
  getInitialState: ->
    return {
      stats: null
      character:
        name: 'Bellatroix'
        id: 1412571394
      year: 2014
    }
  componentDidMount: ->
    @loadData()
  loadData: ->
    if window.location.hash
      source = "#{window.location.hash.substring(1)}"
    else
      source = "null_pvp"
      source = _.sample samples
    $.get "./sampledata/#{source}.json", (data) =>
      stats = new CharacterStats(data)
      @setState {stats: stats, year: data.aggregateYear}
  render: ->
    if not @state.stats
      return dom.div null, "Loading..."

    facts = new CharacterFacts(@state.stats).getFacts()

    title = React.createElement(Title, {character: @state.character, year: @state.year})

    charInfoPanel = React.createElement(CharacterInfoPanel, {character: @state.character, facts: facts})

    travelJumpsPanel = React.createElement(TravelJumpsPanel, {stats: @state.stats})
    travelDistancePanel = React.createElement(TravelDistancePanel, {stats: @state.stats})

    distanceAnalogy = React.createElement(DistanceAnalogyPanel, {distance: @state.stats?.total 'travelDistanceWarped'})

    max = _.max [
      @state.stats?.combatKillsHighSec
      @state.stats?.combatKillsLowSec
      @state.stats?.combatKillsNullSec
      @state.stats?.combatKillsWormhole

      @state.stats?.combatDeathsHighSec
      @state.stats?.combatDeathsLowSec
      @state.stats?.combatDeathsNullSec
      @state.stats?.combatDeathsWormhole
    ]

    killsPanel = React.createElement(KillsPanel, {stats: @state.stats, max: max})
    deathsPanel = React.createElement(DeathsPanel, {stats: @state.stats, max: max})

    weaponUsagePanel = React.createElement(WeaponUsagePanel, {stats: @state.stats})
    damageTakenPanel = React.createElement(DamageTakenPanel, {stats: @state.stats})

    damageAnalogy = React.createElement(DamageAnalogyPanel, {damage: @state.stats?.totalDamageDealt})

    pvpModulesUsage = React.createElement(PvpModulesUsage, {stats: @state.stats})
    pvpModulesAgainst = React.createElement(PvpModulesAgainst, {stats: @state.stats})

    miscPvpStats = React.createElement(MiscPvpStats, {stats: @state.stats})

    selfRepPanel = React.createElement(SelfRepPanel, {stats: @state.stats})
    repsReceivedPanel = React.createElement(RepsReceivedPanel, {stats: @state.stats})
    repsGivenPanel = React.createElement(RepsGivenPanel, {stats: @state.stats})

    pveStats = React.createElement(PvePanel, {stats: @state.stats})

    industryJobs = React.createElement(IndustryJobsPanel, {stats: @state.stats})
    blueprints = React.createElement(IndustryBlueprintPanel, {stats: @state.stats})

    miningPanel = React.createElement(MiningPanel, {stats: @state.stats})

    iskPanel = React.createElement(ISKPanel, {stats: @state.stats})
    marketPanel = React.createElement(MarketPanel, {stats: @state.stats})

    contactsSelfPanel = React.createElement(ContactsPanel, {context: 'self', stats: @state.stats})
    contactsOtherPanel = React.createElement(ContactsPanel, {context: 'other', stats: @state.stats})

    rawStatsList = React.createElement(RawStatsList, {stats: @state.stats})

    dom.div {className: 'container'},

      title

      charInfoPanel

      # Residence / Distance

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, travelJumpsPanel
        dom.div {className: 'col-md-6'}, travelDistancePanel

      dom.div {className: 'row'},
        dom.div {className: 'col-md-12'}, distanceAnalogy

      # PVP

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, killsPanel
        dom.div {className: 'col-md-6'}, deathsPanel

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, weaponUsagePanel
        dom.div {className: 'col-md-6'}, damageTakenPanel

      dom.div {className: 'row'},
        dom.div {className: 'col-md-12'}, damageAnalogy

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, pvpModulesUsage
        dom.div {className: 'col-md-6'}, pvpModulesAgainst

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, miscPvpStats

      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, repsGivenPanel
        dom.div {className: 'col-md-6'}, repsReceivedPanel

      dom.div {className: 'row'},
        dom.div {className: 'col-md-12'}, selfRepPanel

      # PVE Stats

      dom.div {className: 'row'},
        dom.div {className: 'col-md-12'}, pveStats

      # Industry
      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, industryJobs
        dom.div {className: 'col-md-6'}, blueprints

      # Mining
      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, miningPanel

      # Markets
      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, iskPanel
        dom.div {className: 'col-md-6'}, marketPanel

      # Social
      dom.div {className: 'row'},
        dom.div {className: 'col-md-6'}, contactsSelfPanel
        dom.div {className: 'col-md-6'}, contactsOtherPanel

      # Misc

      #rawStatsList
)

Title = React.createClass(
  displayName: 'Title'
  render: ->
    dom.h2 null, "#{@props.character.name}'s Year in Review, #{@props.year}"
)

CharacterInfoPanel = React.createClass(
  displayName: 'CharacterInfoPanel'
  render: ->
    dom.div {className: 'container'},
      dom.div {className: 'col-md-4'},
        React.createElement(CharacterAvatar, {id: @props.character.id})
      dom.div {className: 'col-md-8'},
        dom.ul null,
          dom.li null, 'Prefers ' + STYLES[@props.facts?.preferredSec]?.label
)

CharacterAvatar = React.createClass(
  displayName: 'CharacterAvatar'
  getDefaultProps: ->
    return {
      id: null
      width: 256
    }
  render: ->
    url = "https://image.eveonline.com/Character/#{@props.id}_#{@props.width}.jpg"
    dom.img {src: url, width: @props.width, height: @props.width, style: {boxShadow: '0 0 30px black'}}
)

TravelJumpsPanel = React.createClass(
  displayName: 'TravelJumpsPanel'
  chartData: ->
    data = [
      {
        key: 'high'
        value: @props.stats?.travelJumpsStargateHighSec
      }
      {
        key: 'low'
        value: @props.stats?.travelJumpsStargateLowSec
      }
      {
        key: 'null'
        value: @props.stats?.travelJumpsStargateNullSec
      }
      {
        key: 'wormhole'
        value: @props.stats?.travelJumpsWormhole
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Stargate / Wormhole Jumps'
      React.createElement(PieDataPanel,{data: @chartData(), chartType: 'pie'})
)

TravelDistancePanel = React.createClass(
  displayName: 'TravelDistancePanel'
  chartData: ->
    data = [
      {
        key: 'high'
        value: @props.stats?.travelDistanceWarpedHighSec
      }
      {
        key: 'low'
        value: @props.stats?.travelDistanceWarpedLowSec
      }
      {
        key: 'null'
        value: @props.stats?.travelDistanceWarpedNullSec
      }
      {
        key: 'wormhole'
        value: @props.stats?.travelDistanceWarpedWormhole
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Warp Distance Traveled (AU)'
      React.createElement(PieDataPanel,{data: @chartData(), chartType: 'pie'})
)

DistanceAnalogyPanel = React.createClass(
  displayName: 'DistanceAnalogyPanel'
  # in meters per second
  vehicles:
    light:
      name: 'The speed of light'
      speed: 299792458
    voyagerOne:
      name: 'Voyager 1'
      speed: 17260.2
    mph60:
      name: 'A car travelling at 60 MPH'
      speed: 26.8224
    concord:
      name: 'The Concorde'
      speed: 605.292
    walker:
      name: 'Walking on foot'
      speed: 1.4
    cyclist:
      name: 'Riding a bicycle'
      speed: 6.5
    ferrari:
      name: 'A Ferrari F50 GT1'
      speed: 105.5
    iss:
      name: 'The International Space Station orbiting the Earth'
      speed: 7700

  getInitialState: ->
    return {
      vehicle: _.sample @vehicles
    }
  render: ->
    speedKmPerS = @state.vehicle.speed / 1000
    speedOfLightAu = speedKmPerS / 149597871
    totalAu = @props.distance
    travelSeconds = totalAu / speedOfLightAu
    lightSpeedYears = Intl.NumberFormat().format(d3.round(travelSeconds / 60 / 60 / 24/ 365, 1))
    distanceText = "#{@state.vehicle.name} would take #{lightSpeedYears} years to cover your total distance travelled."
    dom.h4 {className: 'pull-right'}, dom.em(null,distanceText)
)

KillsPanel = React.createClass(
  displayName: 'KillsPanel'
  chartData: ->
    return [
      {
        key: 'high'
        value: @props.stats?.combatKillsHighSec
      }
      {
        key: 'low'
        value: @props.stats?.combatKillsLowSec
      }
      {
        key: 'null'
        value: @props.stats?.combatKillsNullSec
      }
      {
        key: 'wormhole'
        value: @props.stats?.combatKillsWormhole
      }
    ]
  render: ->
    dom.div null,
      dom.h3 null,
        'Kills'
        ' '
        dom.small null, 'PVP'
      React.createElement(BarChart, {data: @chartData(), max: @props.max})
)

DeathsPanel = React.createClass(
  displayName: 'DeathsPanel'
  chartData: ->
    return [
      {
        key: 'high'
        value: @props.stats?.combatDeathsHighSec
      }
      {
        key: 'low'
        value: @props.stats?.combatDeathsLowSec
      }
      {
        key: 'null'
        value: @props.stats?.combatDeathsNullSec
      }
      {
        key: 'wormhole'
        value: @props.stats?.combatDeathsWormhole
      }
    ]
  render: ->
    dom.div null,
      dom.h3 null,
        'Deaths'
        ' '
        dom.small null, 'PVP'
      React.createElement(BarChart, {data: @chartData(), max: @props.max})
)

WeaponUsagePanel = React.createClass(
  displayName: 'WeaponUsagePanel'
  chartData: ->
    data = [
      {
        key: 'hybrid'
        value: @props.stats?.combatDamageToPlayersHybridAmount
      }
      {
        key: 'missile'
        value: @props.stats?.combatDamageToPlayersMissileAmount
      }
      {
        key: 'projectile'
        value: @props.stats?.combatDamageToPlayersProjectileAmount
      }
      {
        key: 'laser'
        value: @props.stats?.combatDamageToPlayersEnergyAmount
      }
      {
        key: 'bomb'
        value: @props.stats?.combatDamageToPlayersBombAmount
      }
      {
        key: 'smartbomb'
        value: @props.stats?.combatDamageToPlayersSmartBombAmount
      }
      {
        key: 'fighter'
        value: @props.stats?.combatDamageToPlayersFighterMissileAmount
      }
      {
        key: 'dd'
        value: @props.stats?.combatDamageToPlayersSuperAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null,
        'Damage Dealt'
        ' '
        dom.small null, "Total"
      React.createElement(PieDataPanel,{data: @chartData()})
)

DamageTakenPanel = React.createClass(
  displayName: 'DamageTakenPanel'
  chartData: ->
    data = [
      {
        key: 'hybrid'
        value: @props.stats?.combatDamageFromPlayersHybridAmount
      }
      {
        key: 'missile'
        value: @props.stats?.combatDamageFromPlayersMissileAmount
      }
      {
        key: 'projectile'
        value: @props.stats?.combatDamageFromPlayersProjectileAmount
      }
      {
        key: 'laser'
        value: @props.stats?.combatDamageFromPlayersEnergyAmount
      }
      {
        key: 'bomb'
        value: @props.stats?.combatDamageFromPlayersBombAmount
      }
      {
        key: 'smartbomb'
        value: @props.stats?.combatDamageFromPlayersSmartBombAmount
      }
      {
        key: 'fighter'
        value: @props.stats?.combatDamageFromPlayersFighterMissileAmount
      }
      {
        key: 'dd'
        value: @props.stats?.combatDamageFromPlayersSuperAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null,
        'Damage Taken'
        ' '
        dom.small null, 'PVP'
      React.createElement(PieDataPanel,{data: @chartData()})
)

DamageAnalogyPanel = React.createClass(
  displayName: 'DamageAnalogyPanel'
  ships:
    proteus:
      pluralName: 'Proteii'
      id: 29988
      ehp: 150000
      fit: 'https://o.smium.org/loadout/private/23324/6303219387142766592'
    # avatar:
    #   pluralName: 'Avatars'
    #   id: 11567
    #   ehp: 22600000
    #   fit: 'https://o.smium.org/loadout/private/23322/7459269642280763392'
  render: ->
    ship = _.sample @ships
    numShips = d3.round(@props.damage / ship.ehp, 1)
    stamps = []
    for i in [0...Math.floor(numShips)]
      stamps.push dom.img {key: i, src: eveIconUrl(ship.id), width: 32, height: 32, className: 'pull-right'}

    dom.div null,
      dom.h4 {className: 'pull-right'},
        dom.em null,"You have dealt enough damage to kill #{numShips} "
          dom.a {href: ship.fit}, ship.pluralName
      dom.div {className: 'container'}, stamps

)

PvpModulesUsage = React.createClass(
  displayName: 'PvpModulesUsage'
  render: ->
    if @props.stats
      dom.div null,
        dom.ul null,
          dom.li null,
            dom.img {src: styleIconUrl('web', 64), width: 64, height: 64}, null
            "Webbed #{@props.stats.combatWebifyingPC} players"
          dom.li null,
            dom.img {src: styleIconUrl('scram', 64), width: 64, height: 64}, null
            "Warp scrambled #{@props.stats.combatWarpScramblePC} players"
          dom.li null,
            dom.img {src: styleIconUrl('neut', 64), width: 64, height: 64}, null
            "#{@props.stats.combatCapDrainingPC} GJ drained from players"
    else
      null
)

PvpModulesAgainst = React.createClass(
  displayName: 'PvpModulesAgainst'
  render: ->
    dom.div null,
      dom.ul null,
        dom.li null,
          dom.img {src: styleIconUrl 'web', 64}, null
          "Webbed #{@props.stats.combatWebifiedbyPC} times by other players"
        dom.li null,
          dom.img {src: styleIconUrl 'scram', 64}, null
          "Warp scrambled #{@props.stats.combatWarpScrambledbyPC} times by other players"
        dom.li null,
          dom.img {src: styleIconUrl 'neut', 64}, null
          "Other players have drained #{@props.stats.combatCapDrainedbyPC} GJ from you"
)

MiscPvpStats = React.createClass(
  displayName: 'MiscPvpStats'
  render: ->
    dom.div null,
      dom.ul null,
        dom.li null,
          dom.img {src: 'images/pvpFlag.png'}
          ' '
          "PVP flagged #{@props.stats.combatPvpFlagSet} times"
        dom.li null,
          dom.img {src: 'images/criminalFlag.png'}
          ' '
          "Criminally flagged #{@props.stats.combatCriminalFlagSet} times"
        dom.li null,
          dom.img {src: 'images/duel.png'}
          ' '
          "Requested #{@props.stats.combatDuelRequested} duels"
        dom.li null,
          dom.img {src: 'images/overheat.png'}
          ' '
          "Overloaded #{@props.stats.moduleOverload} modules"
)

SelfRepPanel = React.createClass(
  displayName: 'SelfRepPanel'
  chartData: ->
    data = [
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullSelfAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorSelfAmount
      }
      {
        key: 'shield'
        value: @props.stats?.combatRepairShieldSelfAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Local Reps'
        React.createElement(PieDataPanel,{data: @chartData(), chartType: 'shipHp'})
)

RepsGivenPanel = React.createClass(
  displayName: 'RepsGivenPanel'
  chartData: ->
    data = [
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullRemoteAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorRemoteAmount
      }
      {
        key: 'shield'
        value: @props.stats?.combatRepairShieldRemoteAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Remote Reps Given'
        React.createElement(PieDataPanel,{data: @chartData(), chartType: 'shipHp'})
)

RepsReceivedPanel = React.createClass(
  displayName: 'RepsReceivedPanel'
  chartData: ->
    data = [
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullByRemoteAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorByRemoteAmount
      }
      {
        key: 'shield'
        value: @props.stats?.combatRepairShieldByRemoteAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Reps Received'
        React.createElement(PieDataPanel,{data: @chartData(), chartType: 'shipHp'})
)

PvePanel = React.createClass(
  displayName: 'PvePanel'
  render: ->
    dom.div null,
      dom.h3 null, 'PVE'
      dom.ul null,
        dom.li null, "Completed #{@props.stats.pveMissionsSucceeded} missions"
        dom.li null, "Completed #{@props.stats.pveMissionsSucceededEpicArc} epic arcs"
        dom.li null, "Hacked #{@props.stats.industryArcheologySuccesses} relic cans"
        dom.li null, "Hacked #{@props.stats.industryHackingSuccesses} data cans"
        dom.li null, "NPC Combat flagged #{@props.stats.combatNpcFlagSet} times"
        dom.li null, "Taken #{@props.stats.combatDamageFromNPCsAmount} damage from NPCs"
        dom.li null, "Scrammed #{@props.stats.combatWarpScrambledbyNPC} times by NPCs"
        dom.li null, "Webbed #{@props.stats.combatWebifiedbyNPC} times by NPCs"
)

IndustryJobsPanel = React.createClass(
  displayName: 'IndustryJobsPanel'
  chartData: ->
    data = [
      {
        key: 'charge'
        value: @props.stats?.industryRamJobsCompletedManufactureChargeQuantity
      }
      {
        key: 'commodity'
        value: @props.stats?.industryRamJobsCompletedManufactureCommodityQuantity
      }
      {
        key: 'deployable'
        value: @props.stats?.industryRamJobsCompletedManufactureDeployableQuantity
      }
      {
        key: 'drone'
        value: @props.stats?.industryRamJobsCompletedManufactureDroneQuantity
      }
      {
        key: 'implant'
        value: @props.stats?.industryRamJobsCompletedManufactureImplantQuantity
      }
      {
        key: 'module'
        value: @props.stats?.industryRamJobsCompletedManufactureModuleQuantity
      }
      {
        key: 'ship'
        value: @props.stats?.industryRamJobsCompletedManufactureShipQuantity
      }
      {
        key: 'structure'
        value: @props.stats?.industryRamJobsCompletedManufactureStructureQuantity
      }
      {
        key: 'subsystem'
        value: @props.stats?.industryRamJobsCompletedManufactureSubsystemQuantity
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Manufacturing Jobs'
        React.createElement(PieDataPanel,{data: @chartData()})
)

IndustryBlueprintPanel = React.createClass(
  displayName: 'IndustryBlueprintPanel'
  render: ->
    dom.div null,
      dom.h3 null, "Blueprints"
      dom.ul null,
        dom.li null,
          dom.img {src: 'images/icons/UI/Industry/copying.png'}
          ' '
          "Copied #{@props.stats.industryRamJobsCompletedCopyBlueprint} blueprints"
        dom.li null,
          dom.img {src: 'images/icons/UI/Industry/researchMaterial.png'}
          ' '
          "#{@props.stats.industryRamJobsCompletedMaterialProductivity} ME jobs"
        dom.li null, 
          dom.img {src: 'images/icons/UI/Industry/researchTime.png'}
          ' '
          "#{@props.stats.industryRamJobsCompletedTimeProductivity} TE jobs"
        dom.li null,
          dom.img {src: 'images/icons/UI/Industry/invention.png'}
          ' '
          "#{@props.stats.industryRamJobsCompletedInvention} invention jobs"
        dom.li null,
          dom.img {src: 'images/icons/UI/Industry/manufacturing.png'}
          ' '
          "#{@props.stats.industryRamJobsCompletedReverseEngineering} reverse engineering jobs"
)

MiningPanel = React.createClass(
  displayName: 'MiningPanel'
  chartData: ->
    data = [
      {
        key: 'arkonor'
        value: @props.stats?.miningOreArkonor
      }
      {
        key: 'bistot'
        value: @props.stats?.miningOreBistot
      }
      {
        key: 'crokite'
        value: @props.stats?.miningOreCrokite
      }
      {
        key: 'darkochre'
        value: @props.stats?.miningOreDarkOchre
      }
      {
        key: 'gneiss'
        value: @props.stats?.miningOreGneiss
      }
      {
        key: 'gas'
        value: @props.stats?.miningOreHarvestableCloud
      }
      {
        key: 'hedbergite'
        value: @props.stats?.miningOreHedbergite
      }
      {
        key: 'hemoprphite'
        value: @props.stats?.miningOreHemorphite
      }
      {
        key: 'ice'
        value: @props.stats?.miningOreIce
      }
      {
        key: 'jaspet'
        value: @props.stats?.miningOreJaspet
      }
      {
        key: 'kernite'
        value: @props.stats?.miningOreKernite
      }
      {
        key: 'mercoxit'
        value: @props.stats?.miningOreMercoxit
      }
      {
        key: 'omber'
        value: @props.stats?.miningOreOmber
      }
      {
        key: 'plagioclase'
        value: @props.stats?.miningOrePlagioclase
      }
      {
        key: 'pyroxeres'
        value: @props.stats?.miningOrePyroxeres
      }
      {
        key: 'scordite'
        value: @props.stats?.miningOreScordite
      }
      {
        key: 'spodumain'
        value: @props.stats?.miningOreSpodumain
      }
      {
        key: 'veldspar'
        value: @props.stats?.miningOreVeldspar
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Mining'
        React.createElement(PieDataPanel,{data: @chartData()})
)

ISKPanel = React.createClass(
  displayName: 'ISKPanel'
  render: ->
    dom.div null,
      dom.ul null,
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.iskIn)} ISK earned total"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.iskOut)} ISK spent total"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketISKGained)} ISK earned from the market"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketISKSpent)} ISK spent on the market"
)

MarketPanel = React.createClass(
  displayName: 'MarketPanel'
  render: ->
    dom.div null,
      dom.ul null,
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketBuyOrdersPlaced)} buy orders placed"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketSellOrdersPlaced)} sell orders placed"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketCreateContractsTotal)} contacts created"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketAcceptContractsItemExchange)} item contracts accepted"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketAcceptContractsCourier)} courier contracts accepted"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketDeliverCourierContract)} courier contracts delivered"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketModifyMarketOrder)} market orders modified"
        dom.li null, "#{Intl.NumberFormat().format(@props.stats.marketCancelMarketOrder)} market orders cancelled"
)

ContactsPanel = React.createClass(
  displayName: 'ContactsPanel'
  render: ->
    if @props.context == 'self'
      str = 'Add'
      title = 'Contacts You\'ve Added'
    else
      str = 'AddedAs'
      title = 'How You Have Been Added'
    data = [
      {
        key: 'great'
        value: @props.stats["social#{str}ContactHigh"]
      }
      {
        key: 'good'
        value: @props.stats["social#{str}ContactGood"]
      }
      {
        key: 'neutral'
        value: @props.stats["social#{str}ContactNeutral"]
      }
      {
        key: 'bad'
        value: @props.stats["social#{str}ContactBad"]
      }
      {
        key: 'horrible'
        value: @props.stats["social#{str}ContactHorrible"]
      }
    ]
    dom.div {className: 'container'},
      dom.h3 null, title
      React.createElement(PieDataPanel, {data: data})

)

PieDataPanel = React.createClass(
  displayName: 'PieDataPanel'
  getDefaultProps: ->
    return {
      chartType: 'pie'
    }
  deriveData: (sortFn) ->
    tmp = _.clone @props.data
    @total = 0
    {value: max} = _.max tmp, (d) -> d.value
    _.each tmp, (d) => @total += d.value
    _.each tmp, (d) =>
      d.percentOfTotal = if @total then d.value / @total else 0
      d.percentOfMax = if max then d.value / max else 0
    if sortFn
      tmp.sort sortFn
    return tmp
  render: ->
    switch @props.chartType
      when 'pie'
        chartElementType = PieChart
        sortFn = (a, b) -> return b.value - a.value
      when 'shipHp'
        chartElementType = ShipHPChart
        sortFn = (a, b) -> return HP_BAR_ORDER.indexOf(a.key) - HP_BAR_ORDER.indexOf(b.key)
    data = @deriveData(sortFn)
    dom.div null,
      dom.div {className: 'col-md-2'},
        React.createElement(chartElementType, {data: data})
      dom.div {className: 'col-md-3'},
        React.createElement(PieDataTable,{data: data, total: @total})
)

PieDataTable = React.createClass(
  displayName: 'PieDataTable'
  render: ->
    rows = _.map @props.data, (d) =>
      if STYLES[d.key]?.iconId
        iconCell = dom.td null,
          dom.img {src: eveIconUrl(STYLES[d.key].iconId), width: 32, height: 32}, null
      else if STYLES[d.key]?.icon
        iconCell = dom.td null,
          dom.img {src: STYLES[d.key].icon}, null
      else
        iconCell = dom.td null, null
      return dom.tr {key: d.key},
        iconCell
        dom.td null, STYLES[d.key]?.label
        dom.td null, Intl.NumberFormat().format(d.value)
        dom.td null, d3.round(100*d.percentOfTotal,0)+'%'
    rows.push dom.tr {key: '_total_'},
      dom.td null, ''
      dom.td null, 'Total'
      dom.td null, Intl.NumberFormat().format(@props.total)
      dom.td null, ''
    dom.table {className: 'table table-condensed'},
      dom.tbody null,
        rows
)

BarChart = React.createClass(
  displayName: 'BarChart'
  getDefaultProps: ->
    return {
      max: null
      width: 300
      height: 150
      padding: 30
      margin:
        top: 20
        right: 40
        bottom: 20
        left: 100
    }
  componentDidMount: ->
    @renderChart()
  componentDidUpdate: ->
    @renderChart()
  renderChart: ->
    if @props.data.length == 0
      return
    el = @getDOMNode()

    if not @props.max
      max = _.max @props.data, (d) -> d.value
      max = max.value
    else
      max = @props.max

    x = d3.scale.linear()
          .domain [0, max]
          .range [0, @props.width]

    y = d3.scale.ordinal()
          .domain(_.map(@props.data, (d) -> d.key))
          .rangeRoundBands [0, @props.height], .1

    yAxis = d3.svg.axis()
              .scale y
              .orient 'left'
              .tickFormat (d) ->
                STYLES[d].label

    svg = d3.select(el).append('svg')
              .attr 'width', @props.width + @props.margin.left + @props.margin.right
              .attr 'height', @props.height + @props.margin.top + @props.margin.top
            .append 'g'
              .attr 'transform', "translate(#{@props.margin.left},#{@props.margin.top})"

    svg.append 'g'
        .attr 'class', 'y axis'
        .call yAxis

    bar = svg.selectAll '.bar'
                  .data @props.data
                .enter().append('g')
                  .attr 'class', 'bar'
                  .attr 'transform', (d, i) => "translate(0,#{y(d.key)})"

    bar.append 'rect'
        .attr 'width', (d) -> x(d.value)
        .attr 'height', y.rangeBand()
        .attr 'fill', (d, i) ->
          if STYLES[d.key].color
            return STYLES[d.key].color

    bar.append 'text'
        .attr 'x', (d) -> x(d.value) + 3
        .attr 'y', y.rangeBand() / 2
        .attr 'dy', '.35em'
        .attr 'fill', 'white'
        .text (d) -> Intl.NumberFormat().format(d.value)


  render: ->
    dom.div null, ''
)

PieChart = React.createClass(
  displayName: 'PieChart'
  getDefaultProps: ->
    return {
      width: 150
      height: 150
      innerRadius: 55
    }
  componentDidMount: ->
    @renderChart()
  componentDidUpdate: ->
    @renderChart()
  renderChart: ->
    if @props.data.length == 0
      return

    el = @getDOMNode()

    color = d3.scale.category20()

    outerRadius = @props.width / 2

    arc = d3.svg.arc()
                .innerRadius @props.innerRadius
                .outerRadius outerRadius

    pie = d3.layout.pie()
            .value (d) -> d.value

    data = pie(@props.data)

    svg = d3.select(el).append('svg')
            .attr 'width', @props.width
            .attr 'height', @props.height

    arcs = svg.selectAll 'g.arc'
              .data data
              .enter()
              .append 'g'
              .attr 'transform', "translate(#{outerRadius},#{outerRadius})"
              .attr 'stroke', '#333'

    arcs.append 'path'
        .attr 'fill', (d) ->
          if STYLES[d.data.key]?.color
            STYLES[d.data.key]?.color
          else
            color(d.data.key)
        .attr 'd', arc

  render: ->
    # placeholder div, will get updated on component update
    dom.div null, ''
)

ShipHPChart = React.createClass(
  displayName: 'ShipHPChart'
  getDefaultProps: ->
    return {
      width: 200
      height: 200
    }
  componentDidMount: ->
    @renderChart()
  componentDidUpdate: ->
    @renderChart()
  renderChart: ->
    if @props.data.length == 0
      return

    el = @getDOMNode()

    radius = 90
    arcWidth = 7
    padding = 1

    getOffset = (i) ->
      return radius - (i * (arcWidth + padding))

    arc = d3.svg.arc()
                .innerRadius (d, i) -> getOffset(i) - arcWidth
                .outerRadius (d, i) -> getOffset(i)
                .startAngle -(Math.PI/2)
                .endAngle (d) -> (d.percentOfMax * (Math.PI)) - (Math.PI/2)
    hullArc = d3.svg.arc()
                .innerRadius (d, i) -> getOffset(i) - arcWidth
                .outerRadius (d, i) -> getOffset(i)
                .startAngle -(Math.PI/2)
                .endAngle (d) -> Math.PI/2

    data = @props.data

    svg = d3.select(el).append('svg')
            .attr 'width', @props.width
            .attr 'height', @props.height

    arcs = svg.selectAll 'g.arc'
              .data data
              .enter()
              .append 'g'
              .attr 'transform', "translate(#{radius},#{radius})"

    arcs.append 'path'
        .attr 'fill', 'red'
        .attr 'd', hullArc

    arcs.append 'path'
        .attr 'fill', (d) -> STYLES[d.key]?.color
        .attr 'd', arc
  render: ->
    dom.div null, ''
)

RawStatsList = React.createClass(
  displayName: 'RawStatsList'
  getInitialState: ->
    return {
      showZero: true
      tag: ''
    }
  onUserInput: (option) ->
    return (checked) =>
      state = {}
      state[option] = checked
      @setState state
  render: ->
    if @props?.stats
      panels = []
      for own key, val of @props.stats
        show = true
        metadata = @props.stats.metadata[key]
        if val == 0 and not @state.showZero
          show = false
        if metadata?.disabled
          show = false
        if @state.tag != '' and metadata?.tags and @state.tag not in metadata.tags
          show = false
        if show
          props =
            key: key
            stat: key
            value: val
            name: metadata?.name
            description: metadata?.description
            units: metadata?.units
          panels.push(React.createElement(StatPanel,props))

      options = [
        {
          name: 'Show Stats at Zero'
          state: 'showZero'
        }
      ]

      optionElements = []
      for option in options
        elementOptions =
          key: option.state
          name: option.name
          checked: @state[option.state]
          onUserInput: @onUserInput(option.state)
        el = React.createElement(Checkbox, elementOptions)
        optionElements.push el

      dom.div {className: 'container'},
        dom.h2 null, 'Raw Stats'
        dom.div {className: 'container'}, optionElements
        dom.div {className: 'container-fluid'},
          dom.div {className: 'row'}, panels
    else
      return null

)

Checkbox = React.createClass(
  displayName: 'Checkbox'
  handleChange: (event) ->
    @props.onUserInput event.target.checked
  render: ->
    dom.label null,
      dom.input {
        type: 'checkbox'
        checked: @props.checked
        onChange: @handleChange
      }, ' ' + @props.name
)

StatPanel = React.createClass(
  displayName: 'CharacterStatPanel'
  render: ->
    name = @props.name ? @props.stat
    value = switch @props.units
      when 'percent' then Intl.NumberFormat().format(@props.value) + '%'
      else Intl.NumberFormat().format(@props.value)
    dom.div {className: 'col-md-3'},
      dom.div {className: 'panel panel-default'},
        dom.div {className: 'panel-heading', title: @props.description}, name
        dom.div {className: 'panel-body'},
          dom.h2 null, value
)

React.render(React.createElement(StatsUI), document.getElementById('stats'))
