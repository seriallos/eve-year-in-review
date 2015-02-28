React = require 'react'
$ = require 'jquery'
CharacterStats = require './character_stats'
d3 = require 'd3'
_ = require 'lodash'

dom = React.DOM

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
    $.get './random.json', (data) =>
      stats = new CharacterStats(data)
      @setState {stats: stats}
  render: ->
    # character info
    # time played / general
    # travel / location
    # pvp (kills/deaths)
    # pve
    # weapons used / damage done
    # damage taken
    # mining
    # industry
    # market
    # exploration
    # social / contacts
    charInfoPanel = React.createElement(CharacterInfoPanel, {character: @state.character})
    weaponUsagePanel = React.createElement(WeaponUsagePanel, {stats: @state.stats})
    damageTakenPanel = React.createElement(DamageTakenPanel, {stats: @state.stats})
    selfRepPanel = React.createElement(SelfRepPanel, {stats: @state.stats})
    repsReceivedPanel = React.createElement(RepsReceivedPanel, {stats: @state.stats})
    repsGivenPanel = React.createElement(RepsGivenPanel, {stats: @state.stats})
    rawStatsList = React.createElement(RawStatsList, {stats: @state.stats})
    dom.div {className: 'container'},
      charInfoPanel
      weaponUsagePanel
      damageTakenPanel
      selfRepPanel
      repsReceivedPanel
      repsGivenPanel
      rawStatsList
)

CharacterInfoPanel = React.createClass(
  displayName: 'CharacterInfoPanel'
  render: ->
    dom.div {className: 'container'},
      dom.h2 null, "Bellatroix's Year in Review, 2014"
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
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Weapons'
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
        key: 'shield'
        value: @props.stats?.combatRepairShieldSelfAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorSelfAmount
      }
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullSelfAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Self Reps'
        React.createElement(PieDataPanel,{data: @chartData(), chartType: 'shipHp'})
)

RepsGivenPanel = React.createClass(
  displayName: 'RepsGivenPanel'
  chartData: ->
    data = [
      {
        key: 'shield'
        value: @props.stats?.combatRepairShieldRemoteAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorRemoteAmount
      }
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullRemoteAmount
      }
    ]
    return data
  render: ->
    dom.div {className: 'container'},
      dom.h3 null, 'Reps Given'
        React.createElement(PieDataPanel,{data: @chartData(), chartType: 'shipHp'})
)

RepsReceivedPanel = React.createClass(
  displayName: 'RepsReceivedPanel'
  chartData: ->
    data = [
      {
        key: 'shield'
        value: @props.stats?.combatRepairShieldByRemoteAmount
      }
      {
        key: 'armor'
        value: @props.stats?.combatRepairArmorByRemoteAmount
      }
      {
        key: 'hull'
        value: @props.stats?.combatRepairHullByRemoteAmount
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
  deriveData: ->
    tmp = _.clone @props.data
    total = 0
    {value: max} = _.max tmp, (d) -> d.value
    _.each tmp, (d) -> total += d.value
    _.each tmp, (d) ->
      d.percentOfTotal = d.value / total
      d.percentOfMax = d.value / max
    tmp.sort (a, b) -> return b.value - a.value
    return tmp
  render: ->
    data = @deriveData()
    chartElementType = switch @props.chartType
      when 'pie' then PieChart
      when 'shipHp' then ShipHPChart
    dom.div null,
      dom.div {className: 'col-md-2'},
        React.createElement(chartElementType, {data: data})
      dom.div {className: 'col-md-3'},
        React.createElement(PieDataTable,{data: data})
)

PieDataTable = React.createClass(
  displayName: 'PieDataTable'
  render: ->
    rows = _.map @props.data, (d) =>
      if STYLES[d.key]?.iconId
        iconCell = dom.td null,
          dom.img {src: "https://image.eveonline.com/Type/#{STYLES[d.key].iconId}_32.png"}, null
      else
        iconCell = null
      return dom.tr {key: d.key},
        iconCell
        dom.td null, STYLES[d.key]?.label
        dom.td null, d.value
        dom.td null, d3.round(100*d.percentOfTotal,2)+'%'
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
            .padAngle Math.PI / 100

    data = pie(@props.data)

    svg = d3.select(el).append('svg')
            .attr 'width', @props.width
            .attr 'height', @props.height

    arcs = svg.selectAll 'g.arc'
              .data data
              .enter()
              .append 'g'
              .attr 'transform', "translate(#{outerRadius},#{outerRadius})"

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
      width: 150
      height: 150
      innerRadius: 55
    }
  componentDidUpdate: ->
    el = @getDOMNode()

    outerRadius = @props.width / 2

    curOffset = 30
    arcWidth = 5
    padding = 5
    nextOffset = ->
      cur = curOffset
      curOffset += arcWidth + padding
      return cur

    arc = d3.svg.arc()
                .innerRadius (d) -> nextOffset()
                .outerRadius (d) -> curOffset - padding
                .startAngle -(Math.PI / 2)
                .endAngle (d) -> d.percentOfMax * (Math.PI / 2)

    data = @props.data
    console.log data

    svg = d3.select(el).append('svg')
            .attr 'width', @props.width
            .attr 'height', @props.height

    arcs = svg.selectAll 'g.arc'
              .data data
              .enter()
              .append 'g'
              .attr 'transform', "translate(#{outerRadius},#{outerRadius})"

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
      showZero: false
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
