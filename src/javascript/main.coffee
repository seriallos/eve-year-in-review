React = require 'react'
$ = require 'jquery'
CharacterStats = require './character_stats'

dom = React.DOM

StatsUI = React.createClass(
  displayName: 'CharacterStatsUI'
  getInitialState: ->
    { stats: null, showZero: false }
  componentDidMount: ->
    $.get './random.json', (data) =>
      stats = new CharacterStats(data)
      @setState {stats: stats}
  onUserInput: (showZero) ->
    @setState {showZero: showZero}
  render: ->
    if @state?.stats
      panels = []
      for own key, val of @state.stats
        metadata = @state.stats.metadata[key]
        if (val != 0 or @state.showZero) and (not metadata?.disabled)
          props =
            key: key
            stat: key
            value: val
            name: metadata?.name
            description: metadata?.description
          panels.push(React.createElement(StatPanel,props))

      dom.div null,
        dom.div null, React.createElement(StatsOptions,{showZero: @state.showZero, onUserInput: @onUserInput})
        dom.div {className: 'container-fluid'},
          dom.div {className: 'row'}, panels
    else
      return null
)
StatsOptions = React.createClass(
  displayName: 'StatsOptions'
  handleChange: ->
    @props.onUserInput @refs.showZeroInput.getDOMNode().checked
  render: ->
    dom.label null,
      dom.input {
        type: 'checkbox'
        checked: @props.showZero
        ref: 'showZeroInput'
        onChange: @handleChange
      }, 'Show Stats at Zero'
)
StatPanel = React.createClass(
  displayName: 'CharacterStatPanel'
  render: ->
    name = @props.name ? @props.stat
    dom.div {className: 'col-md-3'},
      dom.div {className: 'panel panel-default'},
        dom.div {className: 'panel-heading', title: @props.description}, name
        dom.div {className: 'panel-body'},
          dom.h2 null, Intl.NumberFormat().format(@props.value)
)

React.render(React.createElement(StatsUI), document.getElementById('stats'))
