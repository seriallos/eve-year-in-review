

# Ideas
# * Damage represented by ship icon (relative EHP)
#   * Silhoette icon, standard EHP on a PVP fit
# * Stat per minute (any stat divided by active minutes)
# AU breakdown (distance to different galaxies, amount of years at speed of light)

# TODO
# * H/L/N/W colors
# * More/better raw stat formatters (minutes to H:M, etc)
# * tick marks on HP Chart

React = require 'react'
$ = require 'jquery'
CharacterStats = require './character_stats'
CharacterFacts = require './character_facts'
d3 = require 'd3'
_ = require 'lodash'

dom = React.DOM

source_json = './lowsec.json'

samples = [
  'dscan.json'
  'explorer.json'
  'industry.json'
  'lowsec.json'
  'null_pvp.json'
  'market.json'
  'miner.json'
  'missions.json'
  'random.json'
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

HP_BAR_ORDER = ['shield','armor','hull']

StatsUI = React.createClass(
  displayName: 'CharacterStatsUI'
  getInitialState: ->
    return {
      stats: null
      character:
        name: 'Bellatroix'
        id: 1412571394
      year: 2014
      source: source_json
    }
  componentDidMount: ->
    $.get @state.source, (data) =>
      stats = new CharacterStats(data)
      facts = new CharacterFacts(stats)
      @setState {stats: stats, year: data.aggregateYear}
  render: ->

    title = React.createElement(Title, {character: @state.character, year: @state.year})

    charInfoPanel = React.createElement(CharacterInfoPanel, {character: @state.character})

    travelJumpsPanel = React.createElement(TravelJumpsPanel, {stats: @state.stats})
    travelDistancePanel = React.createElement(TravelDistancePanel, {stats: @state.stats})

    weaponUsagePanel = React.createElement(WeaponUsagePanel, {stats: @state.stats})
    damageTakenPanel = React.createElement(DamageTakenPanel, {stats: @state.stats})

    selfRepPanel = React.createElement(SelfRepPanel, {stats: @state.stats})
    repsReceivedPanel = React.createElement(RepsReceivedPanel, {stats: @state.stats})
    repsGivenPanel = React.createElement(RepsGivenPanel, {stats: @state.stats})

    rawStatsList = React.createElement(RawStatsList, {stats: @state.stats})

    dom.div {className: 'container'},

      title

      charInfoPanel

      dom.div {className: 'container'},
        dom.div {className: 'col-md-6'}, travelJumpsPanel
        dom.div {className: 'col-md-6'}, travelDistancePanel

      dom.div {className: 'container'},
        dom.div {className: 'col-md-6'}, weaponUsagePanel
        dom.div {className: 'col-md-6'}, damageTakenPanel

      dom.div {className: 'container'},
        dom.div {className: 'col-md-6'}, repsGivenPanel
        dom.div {className: 'col-md-6'}, repsReceivedPanel

      dom.div {className: 'container'},
        selfRepPanel

      rawStatsList
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
        React.createElement(CharacterAvatar,{id: @props.character.id})
      dom.div {className: 'col-md-8'}
        dom.span 'bar'
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
    dom.img {src: url, width: @props.width, style: {boxShadow: '0 0 30px black'}}
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
      dom.h3 null, 'Damage Dealt'
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
      dom.h3 null, 'Damage Taken'
        React.createElement(PieDataPanel,{data: @chartData()})
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
      d.percentOfTotal = d.value / @total
      d.percentOfMax = d.value / max
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
          dom.img {src: "https://image.eveonline.com/Type/#{STYLES[d.key].iconId}_32.png"}, null
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
    dom.table {className: 'table'},
      dom.tbody null,
        rows
)

PieChart = React.createClass(
  displayName: 'PieChart'
  getDefaultProps: ->
    return {
      width: 150
      height: 150
      innerRadius: 55
    }
  componentDidUpdate: ->
    el = @getDOMNode()

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
        .attr 'fill', (d) -> STYLES[d.data.key]?.color
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
  componentDidUpdate: ->
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
