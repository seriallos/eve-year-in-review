
env = 'dev'

CONFIG =
  dev:
    sso_host: 'https://sisilogin.testeveonline.com'
    crest_host: 'https://api-sisi.testeveonline.com'
    clients:
      'localhost:3000':
        sso_client_id: '448241b523d24f0c947ea58a4443bb02'
        callback_url: 'http://localhost:3000'
        yir_server_url: 'http://localhost:8081'
      'disda.in':
        sso_client_id: 'be843963a3cf4ed3a5de411f1b4a84d4'
        callback_url: 'http://disda.in/eve/yir/'
      'spreadsheetsin.space':
        sso_client_id: 'ee5517f79a684842b0a5cf599d752411'
        callback_url: 'https://spreadsheetsin.space/year-in-review/'
        yir_server_url: 'http://api.spreadsheetsin.space:8081'
  live:
    sso_host: 'https://login.eveonline.com'
    sso_client_id: '67a0cc0f68d34e77b9751f8c75dd2e31'
    crest_host: 'https://crest-tq.eveonline.com'

client = CONFIG[env].clients[window.location.host]

SSO_PROTO = 'https'
SSO_CALLBACK_URL = client?.callback_url
SSO_HOST = CONFIG[env].sso_host
SSO_CLIENT_ID = client?.sso_client_id
CREST_HOST = CONFIG[env].crest_host

React = require 'react'
d3 = require 'd3'
$ = require 'jquery'
_ = require 'lodash'
numeral = require 'numeral'
ga = require 'googleanalytics'

qs = require 'querystring'
urlParse = require('url').parse

CharacterStats = require './character_stats'

dom = React.DOM

STYLES = require './styles.coffee'

HP_BAR_ORDER = ['shield','armor','hull']

styleIconUrl = (key, width = 32) ->
  return eveIconUrl(STYLES[key].iconId, width)

styleIconId = (key) ->
  return STYLES[key]?.iconId

eveIconUrl = (id, width = 32) ->
  return "https://image.eveonline.com/Type/#{id}_#{width}.png"

jrequest = (url, done) ->
  $.ajaxSetup({
    error: (xhr, status, error) ->
      done(error, null, xhr)
  })
  $.getJSON url, (data, status, xhr) ->
    done(null, data, xhr)

humanizeLargeNum = (value) ->
  suffixes = [ '', 'K', 'M', 'B', 'T' ]
  suffix = 0
  while value > 999
    value = value / 1000
    suffix++
  return d3.round(value,2) + suffixes[suffix]


humanizeMinutes = (minutes) ->
  hours = Math.floor(minutes / 60)
  minutes = minutes % 60

  days = Math.floor(hours / 24)
  hours = hours % 24

  out = ''
  if days
    out += "#{days} days, "

  if hours or days
    out += "#{hours} hours, "

  out += "#{minutes} minutes"

  return out

humanizeNumber = (number) ->
  return numeral(number).format('0,0')

# default formatter is add commas
numFmt = humanizeNumber

StatsUI = React.createClass(
  displayName: 'CharacterStatsUI'
  getInitialState: ->
    return {
      ssoState: 'login'
      token: null
      stats: null
      character:
        name: null
        id: null
      year: null
      sample: false
    }
  componentDidMount: ->
    # look for access_token in the hash from the SSO redirect
    hash = window.location.hash.substring(1)
    hashParts = qs.parse(hash)
    window.location.hash = ''
    if hashParts.access_token
      token = hashParts.access_token
      @setState {ssoState: 'loading', token: token}
      # set up default ajax configurations
      $.ajaxSetup({
          accepts: "application/json, charset=utf-8"
          crossDomain: true
          type: "GET"
          dataType: "json"
          headers:
            Authorization: "Bearer #{token}"
          error: (xhr, status, error) ->
            console.error xhr.status
            console.error(status)
            console.error(error);
      })
      jrequest "#{CREST_HOST}/decode/", (error, data, xhr) =>
        if xhr.status == 401
          @setState {ssoState: 'login', token: null}
        else
          charUrlParsed = urlParse data.character.href
          [ foo, foo, characterId ] = charUrlParsed.path.split '/'
          @setState {character: {id: characterId, name: '', url: data.character.href}}

          # this will be an async call to populate name
          jrequest data.character.href, (err, data, xhr) =>
            char = @state.character
            char.name = data.name
            @setState {character: char}

          # don't wait for character data, just call and load
          @loadStatsYear(2014, false)

  getStats: (year, done) ->
    url = "#{@state.character.url}statistics/year/#{year}/"
    jrequest url, (err, data, xhr) ->
      done(err, data, xhr)

  loadStatsYear: (year, track = true) ->
    ga 'send', 'pageview', "/year-in-review/#{year}"
    @getStats year, (err, data, xhr) =>
      if err and xhr.status == 404
        @setState {stats: null, year: year, ssoState: 'loaded', noData: true}
      else
        stats = new CharacterStats(data)
        @setState {stats: stats, year: year, ssoState: 'loaded', noData: false}

  loadSampleData: ->
    ga 'send', 'pageview', '/year-in-review/sample'
    host = window.location.host
    proto = window.location.protocol
    sample = './bella.json'
    jrequest sample, (err, data, xhr) =>
      stats = new CharacterStats(data)
      @setState {
        sample: true
        stats: stats,
        year: 2014,
        ssoState: 'loaded'
        character: {
          name: 'Bellatroix'
          id: 1412571394
        }
      }

  generatePermalink: ->
    console.log "permalinking action"
    results = []
    @getStats 2013, (err, data, xhr) =>
      results.push data
      @getStats 2014, (err, data, xhr) =>
        results.push data
        @getStats 2015, (err, data, xhr) =>
          results.push data
          url = "#{client.yir_server_url}/charstats/"
          opts =
            url: url
            crossDomain: true
            type: "POST"
            error: (xhr, status, error) ->
              console.error xhr.status
              console.error(status)
              console.error(error);
            success: (data, xhr) ->
              console.log "POST success"
              console.log data
          console.log opts
          $.ajax(opts)

  renderInitialPage: ->
    return dom.div {className: 'vert-center'},
        dom.div {className: 'text-center translucent'},
          dom.h2 null, 'EVE: Year in Review'
          dom.div {className: 'whatIsThis'},
            "Your character's story told in charts and numbers based on aggregate data
            from 2013 - 2015.  A preview of CREST data coming to TQ Soon."
          dom.div null, React.createElement(SSOLoginButton)
          dom.div {className: 'noAccountText'}, "Don't want to commit just yet? "
          dom.div null,
            dom.a(
              {className: 'pointer', onClick: @loadSampleData},
              'Take a look at my stats.'
            )
          dom.div {className: 'broughtToYou'},
            "Brought to you by Bellatroix ("
            dom.a({href:'https://twitter.com/sollaires', target: '_blank'}, '@sollaires')
            ")"
          dom.div {className: 'techNotes'}, "Technical details and code available on ",
            dom.a {
              href: 'https://github.com/seriallos/eve-year-in-review'
              target: '_blank'
            }, 'GitHub'

  renderLoading: ->
      return dom.div {className: 'vert-center'},
        dom.div {className: 'text-center translucent'},
          dom.h2 null, "Verifying SSO token and loading your stats..."

  renderNoData: (header) ->
    return dom.div null,

      header

      dom.div {className: 'vert-center'},
        dom.div {className: 'text-center translucent'},
          dom.h2 null, "Looks like you won EVE in #{@state.year}.  No data available."

  renderStats: (header) ->
    charInfoPanel = React.createElement(
      CharacterInfoPanel,
      {
        character: @state.character
        stats: @state.stats
      }
    )

    travelJumpsPanel = React.createElement(TravelJumpsPanel, {stats: @state.stats})
    travelDistancePanel = React.createElement(TravelDistancePanel, {stats: @state.stats})

    distanceAnalogy = React.createElement(
      DistanceAnalogyPanel,
      {
        distance: @state.stats?.total('travelDistanceWarped')
      }
    )

    # calculate max of kills/deaths to share x axis between charts
    killDeathMax = _.max [
      @state.stats?.combatKillsHighSec
      @state.stats?.combatKillsLowSec
      @state.stats?.combatKillsNullSec
      @state.stats?.combatKillsWormhole

      @state.stats?.combatDeathsHighSec
      @state.stats?.combatDeathsLowSec
      @state.stats?.combatDeathsNullSec
      @state.stats?.combatDeathsWormhole
    ]

    killsPanel = React.createElement(KillsPanel, {
      stats: @state.stats, max: killDeathMax
    })
    deathsPanel = React.createElement(DeathsPanel, {
      stats: @state.stats, max: killDeathMax
    })

    weaponUsagePanel = React.createElement(WeaponUsagePanel, {stats: @state.stats})
    damageTakenPanel = React.createElement(DamageTakenPanel, {stats: @state.stats})

    damageAnalogy = React.createElement(DamageAnalogyPanel, {
      damage: @state.stats?.totalDamageDealt
    })

    pvpModulesUsage = React.createElement(PvpModulesUsage, {stats: @state.stats})
    pvpModulesAgainst = React.createElement(PvpModulesAgainst, {stats: @state.stats})
    miscPvpStats = React.createElement(MiscPvpStats, {stats: @state.stats})
    miscTooPvpStats = React.createElement(MiscTooPvpStats, {stats: @state.stats})

    selfRepPanel = React.createElement(SelfRepPanel, {stats: @state.stats})
    repsReceivedPanel = React.createElement(RepsReceivedPanel, {stats: @state.stats})
    repsGivenPanel = React.createElement(RepsGivenPanel, {stats: @state.stats})

    pveStats = React.createElement(PvePanel, {stats: @state.stats})

    miscModules = React.createElement(MiscModulePanel, {stats: @state.stats})

    industryJobs = React.createElement(IndustryJobsPanel, {stats: @state.stats})
    blueprints = React.createElement(IndustryBlueprintPanel, {stats: @state.stats})

    miningPanel = React.createElement(MiningPanel, {stats: @state.stats})

    # share same isk max between ISK charts
    iskMax = _.max [
      @state.stats?.iskIn
      @state.stats?.iskOut
      @state.stats?.marketIskIn
      @state.stats?.marketIskOut
    ]

    totalIskPanel = React.createElement(TotalISKPanel, {
      stats: @state.stats, max: iskMax
    })
    marketIskPanel = React.createElement(MarketISKPanel, {
      stats: @state.stats, max: iskMax
    })

    iskPerHour = @state.stats.perHour 'iskIn'
    iskPerHourPull = dom.h4 {className: 'pull-left'},
      dom.em null, "You earned #{humanizeLargeNum iskPerHour} ISK per hour."

    marketPanel = React.createElement(MarketPanel, {stats: @state.stats})

    contactsSelfPanel = React.createElement(ContactsPanel, {
      context: 'self',
      stats: @state.stats
    })
    contactsOtherPanel = React.createElement(ContactsPanel, {
      context: 'other',
      stats: @state.stats
    })

    socialMiscPanel = React.createElement(SocialMiscPanel, {stats: @state.stats})

    chatAnalogy = React.createElement(ChatAnalogyPanel, {
      chars: @state.stats.socialChatTotalMessageLength
    })

    miscStats = React.createElement(MiscStats, {stats: @state.stats})

    dscanPerHour = 60 * (@state.stats.genericConeScans / @state.stats.characterMinutes)
    dscanRate = dom.h4 {className: 'pull-right'},
      dom.em null, "You d-scanned #{numFmt dscanPerHour} times per hour"

    dom.div null,
      # header
      header

      # main content
      dom.div {className: 'container translucent main'},

        header

        charInfoPanel

        # Residence / Distance

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, travelJumpsPanel
          dom.div {className: 'col-md-6'}, travelDistancePanel

        dom.div {className: 'row'},
          dom.div {className: 'col-md-12'}, distanceAnalogy

        # PVP

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, killsPanel
          dom.div {className: 'col-md-6'}, deathsPanel

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, weaponUsagePanel
          dom.div {className: 'col-md-6'}, damageTakenPanel

        dom.div {className: 'row'},
          dom.div {className: 'col-md-12'}, damageAnalogy

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-3'}, pvpModulesUsage
          dom.div {className: 'col-md-3'}, pvpModulesAgainst
          dom.div {className: 'col-md-3'}, miscPvpStats
          dom.div {className: 'col-md-3'}, miscTooPvpStats

        # TODO: without spacer columns, things overlap for some reason.  fix that!
        dom.div {className: 'row top-buffer repRow'},
          dom.div {className: 'col-md-3'}, repsGivenPanel
          dom.div {className: 'col-md-1'}, ''
          dom.div {className: 'col-md-3'}, repsReceivedPanel
          dom.div {className: 'col-md-1'}, ''
          dom.div {className: 'col-md-3'}, selfRepPanel

        # PVE Stats

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-12'}, miscModules

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-12'}, pveStats

        # ISK / Markets
        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, totalIskPanel
          dom.div {className: 'col-md-6'}, marketIskPanel

        dom.div {className: 'row'},
          dom.div {className: 'col-md-12'}, iskPerHourPull

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-12'}, marketPanel

        # Industry
        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, miningPanel
          dom.div {className: 'col-md-6'}, industryJobs

        # Mining
        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-12'}, blueprints


        # Social
        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-6'}, contactsSelfPanel
          dom.div {className: 'col-md-6'}, contactsOtherPanel

        dom.div {className: 'row top-buffer'},
          dom.div {className: 'col-md-12'}, socialMiscPanel

        dom.div {className: 'row'},
          dom.div {className: 'col-md-12'}, chatAnalogy

        dom.div {className: 'row top-buffer'}
          dom.div {className: 'col-md-12'}, miscStats

        dom.div {className: 'row top-buffer'}
          dom.div {className: 'col-md-12'}, dscanRate

  render: ->
    if @state.ssoState == 'login'
      return @renderInitialPage()
    else if @state.ssoState == 'loading'
      return @renderLoading()
    else
      header = React.createElement(Header, {
        character: @state.character,
        year: @state.year,
        switchToYear: @loadStatsYear,
        hideSwitch: @state.sample,
        onGeneratePermalink: @generatePermalink
      })

      if @state.noData
        return @renderNoData(header)
      else
        return @renderStats(header)

)

SSOLoginButton = React.createClass(
  displayName: 'SSOLoginButton'
  render: ->
    ssoLoginImage =  'https://images.contentful.com/idjq7aai9ylm/4PTzeiAshqiM8osU2giO0Y'
    ssoLoginImage += '/5cc4cb60bac52422da2e45db87b6819c/'
    ssoLoginImage += 'EVE_SSO_Login_Buttons_Large_White.png?w=270&h=45'
    ssoParams =
      response_type: 'token'
      redirect_uri: SSO_CALLBACK_URL
      client_id: SSO_CLIENT_ID
      scope: 'publicData characterStatisticsRead'
      state: ''

    ssoUrl = "#{SSO_HOST}/oauth/authorize/?#{qs.stringify ssoParams}"

    if @props.linkText
      content = @props.linkText
    else
      content = dom.img {src: ssoLoginImage}

    return dom.a {href: ssoUrl}, content
)

Header = React.createClass(
  displayName: 'Header'
  onYearClick: (year) ->
    return (event) =>
      @props.switchToYear year
  render: ->
    years = [ 2015, 2014, 2013 ]
    yearLis = []
    for year in years
      yearLis.push dom.li(null, dom.a({key: year, onClick: @onYearClick(year)}, year))
    yearDropdown = dom.li {className: 'dropdown'},
              dom.a {
                className: 'dropdown-toggle',
                'data-toggle': 'dropdown',
                role: 'button',
                'aria-expanded': false
              }, "Year ", dom.span({className: 'caret'})
              dom.ul {className: 'dropdown-menu', role: 'menu'},
                yearLis

    return dom.nav {className: 'navbar navbar-default navbar-fixed-bottom yir-nav'},
      dom.div {className: 'container'},
        dom.div {className: 'collapse navbar-collapse'},
          dom.a {className: 'navbar-brand'},
            React.createElement(CharacterAvatar, {id: @props.character.id, width: 32})
          dom.p {className: 'navbar-link navbar-text'},
            @props.character.name, ', ', @props.year
          dom.ul {className: 'nav navbar-nav'},
            dom.li null,
              yearDropdown unless @props.hideSwitch
            dom.li null,
              dom.a({onClick: @props.onGeneratePermalink}, "Generate Permalink") unless @props.hideSwitch
          dom.ul {className: 'nav navbar-nav navbar-right'},
            dom.li null,
              React.createElement(SSOLoginButton, {linkText: 'Change Character'})
)

CharacterInfoPanel = React.createClass(
  displayName: 'CharacterInfoPanel'
  render: ->
    onlineMinutes = @props.stats.characterMinutes
    thisIsEveLength = 3 + (42 / 60)
    timesWatched = Math.floor(onlineMinutes / thisIsEveLength)
    avgSession = Math.round(onlineMinutes/ @props.stats.characterSessionsStarted)

    dom.div {className: 'row'},
      dom.div {className: 'col-md-3 avatar'},
        React.createElement(CharacterAvatar, {id: @props.character.id})
      dom.div {className: 'col-md-9'},
        dom.div {className: 'row'},
          dom.div {className: 'col-md-8'},
            React.createElement CalloutStat, {
              value: @props.stats.characterMinutes,
              description: 'Time Played',
              formatter: humanizeMinutes
            }
            React.createElement CalloutStat, {
              value: avgSession,
              description: 'Average Session Length',
              formatter: humanizeMinutes
            }
          dom.div {className: 'col-md-4'},
            React.createElement CalloutStat, {
              value: @props.stats.characterSessionsStarted,
              description: 'Logins'
            }
            React.createElement CalloutStat, {
              value: @props.stats.daysOfActivity,
              description: 'Active Days'
            }
        dom.div {className: 'row'},
          dom.h4 {className: 'pull-left'},
            dom.em null,
              "You could have watched "
              dom.a {
                href: 'https://www.youtube.com/watch?v=AdfFnTt2UT0'
                target: '_blank'
                }, "This is EVE"
              " #{numFmt timesWatched} times instead of playing."
)

CharacterAvatar = React.createClass(
  displayName: 'CharacterAvatar'
  getDefaultProps: ->
    return {
      id: null
      width: 200
    }
  render: ->
    url = "https://image.eveonline.com/Character/#{@props.id}_256.jpg"
    dom.img {
      src: url,
      width: @props.width,
      height: @props.width,
    }
)

CalloutStat = React.createClass(
  displayName: 'CalloutStat'
  getDefaultProps: ->
    return {
      formatter: numFmt
    }
  render: ->
    icon = null
    iconWrap = null
    if @props.iconId
      icon = dom.img {src: eveIconUrl(@props.iconId, 64), width: 64, height: 64}
    else if @props.icon
      icon = dom.img {src: STYLES[@props.icon].icon}
    if icon
      iconWrap = dom.span {className: 'iconWrap'}, icon

    if @props.formatter
      value = @props.formatter(@props.value)
    else
      value = @props.value

    dom.div {className: 'callout'},
      dom.div {className: 'value'}, iconWrap, value
      dom.div {className: 'description'}, @props.description
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
    dom.div {className: ''},
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
    dom.div {className: ''},
      dom.h3 null, 'Warp Distance Traveled ', dom.small(null,'AU')
      React.createElement(PieDataPanel,{data: @chartData(), chartType: 'pie'})
)

DistanceAnalogyPanel = React.createClass(
  displayName: 'DistanceAnalogyPanel'
  # in meters per second
  vehicles:
    # light:
    #   name: 'The speed of light'
    #   speed: 299792458
    walker:
      name: 'Walking on foot'
      speed: 1.4
    cyclist:
      name: 'Riding a bicycle'
      speed: 6.5
    mph60:
      name: 'A car travelling at 60 MPH'
      speed: 26.8224
    ferrari:
      name: 'A Ferrari F50 GT1'
      speed: 105.5
    concord:
      name: 'The Concorde'
      speed: 605.292
    iss:
      name: 'The International Space Station orbiting the Earth'
      speed: 7700
    voyagerOne:
      name: 'Voyager 1'
      speed: 17260.2

  render: ->
    if @props.distance > 0
      vehicle = _.sample @vehicles
      speedKmPerS = vehicle.speed / 1000
      speedAuPerS = speedKmPerS / 149597871
      totalAu = @props.distance
      travelSeconds = totalAu / speedAuPerS
      years = numFmt(d3.round(travelSeconds / 60 / 60 / 24/ 365, 1))
      distanceText = "#{vehicle.name} would take #{years} years
                      to cover your total distance."
      return dom.h4 {className: 'pull-right'},
        dom.em(null,distanceText)
    else
      return null
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
        'Killing Blows'
        ' '
        dom.small null, 'Player Ships'
      React.createElement(BarChart, {data: @chartData(), max: @props.max})
      dom.div null, "Assisted on #{numFmt @props.stats?.combatKillsAssists} ship 
                     killmails, popped #{numFmt @props.stats?.combatKillsPodTotal} pods."
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
        'Losses'
        ' '
        dom.small null, 'Ships Lost in PVP'
      React.createElement(BarChart, {data: @chartData(), max: @props.max})
      dom.div null, "Podded #{@props.stats?.combatDeathsPodTotal} times"
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
    dom.div {className: ''},
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
    dom.div {className: ''},
      dom.h3 null,
        'Damage Taken'
        ' '
        dom.small null, 'PVP'
      React.createElement(PieDataPanel,{data: @chartData()})
)

DamageAnalogyPanel = React.createClass(
  displayName: 'DamageAnalogyPanel'
  ships:
    venture:
      pluralName: 'Ventures'
      id: 32880
      ehp: 3770
      fit: 'https://o.smium.org/loadout/private/24585/6674104450400911360'
      image: 'images/ships/venture.png'
      width: 43
      height: 48
    #caracal:
    #  pluralName: 'Caracals'
    #  id: 621
    #  ehp: 18000
    #  fit: 'https://o.smium.org/loadout/private/24584/5861380819909607424'
    #  image: 'images/ships/caracal.png'
    #  height: 32
    vexor:
      pluralName: 'Vexors'
      ehp: 24000
      fit: 'https://o.smium.org/loadout/private/24682/7359747123954319360'
      image: 'images/ships/vexor.png'
      width: 57
      height: 48
    #proteus:
    #  pluralName: 'Proteii'
    #  id: 29988
    #  ehp: 150000
    #  fit: 'https://o.smium.org/loadout/private/23324/6303219387142766592'
    #  image: 'images/ships/proteus.png'
    #  height: 32
    #abaddon:
    #  pluralName: 'Abaddons'
    #  ehp: 140000
    #  fit: ''
    #  image: 'images/ships/abaddon.png'
    #  height: 32
    #  width: 90
    apocalypse:
      pluralName: 'Apocalypses Navy Issue'
      ehp: 140000
      fit: 'https://o.smium.org/loadout/private/24684/6057995995994652672'
      image: 'images/ships/apocalypse.png'
      height: 32
      width: 92
    #legion:
    #  pluralName: 'Legions'
    #  ehp: 140000
    #  fit: 'https://o.smium.org/loadout/private/24683/477339014555238400'
    #  image: 'images/ships/legion.png'
    #  height: 32
    naglfar:
      pluralName: 'Naglfars'
      id: 19722
      ehp: 1500000
      fit: 'https://o.smium.org/loadout/private/24661/3437198039918313472'
      image: 'images/ships/naglfar.png'
      width: 32
      height: 113
    avatar:
      pluralName: 'Avatars'
      id: 11567
      ehp: 22600000
      fit: 'https://o.smium.org/loadout/private/23322/7459269642280763392'
      image: 'images/ships/avatar.png'
      width: 96
      height: 48
  numShips: (shipKey) ->
    return d3.round(@props.damage / @ships[shipKey].ehp, 2)
  getInitialState: ->
    return {
      ship: null
    }
  determineShipToUse: ->
    shipToUse = null
    numShips = 0
    # find a good candidate ship to show, first ship that results in less than 100
    # stamps
    for name, ship of @ships
      shipToUse = name
      numShips = @numShips(name)
      if numShips < 100
        break
    @setState {ship: shipToUse}
  componentDidMount: ->
    @determineShipToUse()
  render: ->
    if @props.damage == 0
      return null
    else
      if not @state.ship
        return null

      shipToUse = @state.ship

      ship = @ships[shipToUse]
      numShips = @numShips(shipToUse)
      wholeShips = Math.floor(numShips)
      partial = numShips - wholeShips

      stamps = []
      imgOpts =
        src: ship.image,
        width: ship.width,
        height: ship.height,
        className: 'stamp'

      for i in [0...Math.floor(numShips)]
        stamps.push dom.div({className: 'pull-left'}, dom.img(imgOpts))
      # handle partial stamp by hiding overflow and explicitly setting width
      if partial
        width = Math.round(partial * ship.width)
        divOpts =
          className: 'pull-left'
          style:
            height: ship.height
            width: width
            overflow: 'hidden'
        stamps.push dom.div(divOpts, dom.img(imgOpts))

      return dom.div {className: 'row damageAnalogy'},
        dom.div {className: 'dropdown'},
          dom.button {
            id: 'shipDropdown'
            className: 'btn btn-xs btn-default dropdown-toggle'
            type: 'button'
            'data-toggle': 'dropdown'
            'aria-expanded': false
          }, 'More Ships', ' ', dom.span({className: 'caret'})
          dom.ul {
            className: 'dropdown-menu',
            role: 'menu',
            'aria-labelledby': 'shipDropdown'
          }, _.map @ships, (ship, name) =>
            return dom.li {role: 'presentation'},
              dom.a {
                role: 'menuitem',
                tabindex: '-1',
                onClick: =>
                  @setState {ship: name}
              }, ship.pluralName
        dom.h4 {className: 'pull-left'},
          dom.em null,
            "You dealt enough damage to kill #{numShips} "
            dom.a {href: ship.fit, target: '_blank'}, ship.pluralName
        dom.div {className: 'clearfix'}, ''
        dom.div {className: ''}, stamps

)

CalloutPanel = React.createClass(
  displayName: 'CalloutPanel'
  getDefaultProps: ->
    return {
      columns: 1 # 1, 2, 3, 4, 6, 12
    }
  render: ->
    if @props.callouts
      calloutElements = @props.callouts.map (callout) ->
        opts = _.merge(callout, {key: callout.description})
        return React.createElement(CalloutStat, opts)
      # figure out number of items per column
      # this is a naive method that doesn't balance
      itemsPerCol = Math.ceil(calloutElements.length / @props.columns)
      columns = []
      colSize = 12 / @props.columns
      for i in [0...@props.columns]
        divOpts =
          className: "col-md-#{colSize}",
          key: i
        col = dom.div divOpts, _.take(calloutElements, itemsPerCol)
        calloutElements.splice(0, itemsPerCol)
        columns.push col
      dom.div null,
        dom.h3 null, @props.title
        dom.div {className: 'row'},
          columns
    else
      null
)

PvpModulesUsage = React.createClass(
  displayName: 'PvpModulesUsage'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.combatWebifyingPC
          description: 'Times You Webbed Players'
          iconId: styleIconId 'web'
        }
        {
          value: @props.stats.combatWarpScramblePC
          description: 'Times You Pointed Players'
          iconId: styleIconId 'scram'
        }
        {
          value: @props.stats.combatCapDrainingPC
          description: 'GJ Drained from Players'
          iconId: styleIconId 'neut'
        }
      ]
      return React.createElement(CalloutPanel, {callouts: callouts})
    else
      null
)

PvpModulesAgainst = React.createClass(
  displayName: 'PvpModulesAgainst'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.combatWebifiedbyPC
          description: 'Times Webbed by Players'
          iconId: styleIconId 'web'
        }
        {
          value: @props.stats.combatWarpScrambledbyPC
          description: 'Times Pointed by Players'
          iconId: styleIconId 'scram'
        }
        {
          value: @props.stats.combatCapDrainedbyPC
          description: 'GJ Drained by Players'
          iconId: styleIconId 'neut'
        }
      ]
      return React.createElement(CalloutPanel, {callouts: callouts})
    else
      return null
)

MiscPvpStats = React.createClass(
  displayName: 'MiscPvpStats'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.combatPvpFlagSet
          description: 'PVP Flags'
          icon: 'pvpFlag'
        }
        {
          value: @props.stats.combatCriminalFlagSet
          description: 'Criminal Flags'
          icon: 'criminalFlag'
        }
      ]
      return React.createElement(CalloutPanel, {callouts: callouts})
    else
      return null
)

MiscTooPvpStats = React.createClass(
  displayName: 'MiscTooPvpStats'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.moduleOverload
          description: 'Overheated Modules'
          icon: 'overheat'
        }
        {
          value: @props.stats.combatDuelRequested
          description: 'Duel Requests'
          icon: 'duel'
        }
      ]
      return React.createElement(CalloutPanel, {callouts: callouts})
    else
      return null
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
    dom.div {className: 'row'},
      dom.h3 null, 'Local Reps'
        React.createElement(PieDataPanel,{
          data: @chartData(),
          chartType: 'shipHp',
          layout: 'vertical',
          showZero: true
        })
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
    dom.div {className: 'row'},
      dom.h3 null, 'Remote Reps Given'
        React.createElement(PieDataPanel,{
          data: @chartData(),
          chartType: 'shipHp',
          layout: 'vertical',
          showZero: true
        })
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
    dom.div {className: 'row'},
      dom.h3 null, 'Reps Received'
        React.createElement(PieDataPanel,{
          data: @chartData(),
          chartType: 'shipHp',
          layout: 'vertical',
          showZero: true
        })
)

PvePanel = React.createClass(
  displayName: 'PvePanel'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.combatNpcFlagSet
          description: 'NPC Combat Flags'
          iconId: styleIconId 'npcFlag'
        }
        {
          value: @props.stats.combatDamageFromNPCsAmount
          description: 'Damage Taken from NPCs'
          iconId: styleIconId 'npcDamage'
        }
        {
          value: @props.stats.combatWarpScrambledbyNPC
          description: 'Times Scrammed by NPC'
          iconId: styleIconId 'scram'
        }
        {
          value: @props.stats.combatWebifiedbyNPC
          description: 'Times Webbed by NPC'
          iconId: styleIconId 'web'
        }
        {
          value: @props.stats.pveMissionsSucceeded
          description: 'Missions Completed'
          iconId: styleIconId 'mission'
        }
        {
          value: @props.stats.pveMissionsSucceededEpicArc
          description: 'Epic Arcs Completed'
          iconId: styleIconId 'epicArc'
        }
        {
          value: @props.stats.industryHackingSuccesses
          description: 'Data Cans Hacked'
          iconId: styleIconId 'dataCan'
        }
      ]
      return React.createElement(CalloutPanel, {
        title: 'PVE',
        callouts: callouts,
        columns: 4
      })
    else
      return null
)

MiscModulePanel = React.createClass(
  displayName: 'MiscModulePanelOne'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.moduleActivationsCloaking
          description: 'Activated Cloak'
          iconId: styleIconId 'cloak'
        }
        {
          value: @props.stats.moduleActivationsCyno
          description: 'Cynos Lit'
          iconId: styleIconId 'cyno'
        }
        {
          value: @props.stats.moduleActivationsFleetAssist
          description: 'Activated Gang Link'
          iconId: styleIconId 'gangLink'
        }
        {
          value: @props.stats.moduleActivationsEwarECM
          description: 'Violated Space Bushido'
          iconId: styleIconId 'ecm'
        }
        {
          value: @props.stats.moduleActivationsEwarDampener
          description: 'Activated Sensor Damp'
          iconId: styleIconId 'damp'
        }
        {
          value: @props.stats.moduleActivationsEwarTargetPainter
          description: 'Activated Target Painter'
          iconId: styleIconId 'painter'
        }
        {
          value: @props.stats.moduleActivationsEwarVampire
          description: 'Activated NOS'
          iconId: styleIconId 'nos'
        }
      ]
      return React.createElement(CalloutPanel, {callouts: callouts, columns: 4})
    else
      return null
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
    dom.div {className: 'row'},
      dom.h3 null, 'Manufacturing Jobs', ' ', dom.small(null, 'Units Produced')
        React.createElement(PieDataPanel,{data: @chartData()})
)

IndustryBlueprintPanel = React.createClass(
  displayName: 'IndustryBlueprintPanel'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.industryRamJobsCompletedCopyBlueprint
          description: 'Blueprints Copied'
          icon: 'jobCopy'
        }
        {
          value: @props.stats.industryRamJobsCompletedMaterialProductivity
          description: 'ME Jobs'
          icon: 'jobMe'
        }
        {
          value: @props.stats.industryRamJobsCompletedTimeProductivity
          description: 'TE Jobs'
          icon: 'jobTe'
        }
        {
          value: @props.stats.industryRamJobsCompletedInvention
          description: 'Invention Jobs'
          icon: 'jobInvention'
        }
      ]
      return React.createElement(CalloutPanel, {
        title: 'Blueprints',
        callouts: callouts,
        columns: 4
      })
    else
      return null
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
    dom.div {className: ''},
      dom.h3 null, 'Mining'
      React.createElement(PieDataPanel,{data: @chartData()})
)

TotalISKPanel = React.createClass(
  displayName: 'TotalISKPanel'
  chartData: ->
    return [
      {
        key: 'iskIn'
        value: @props.stats?.iskIn
      }
      {
        key: 'iskOut'
        value: @props.stats?.iskOut
      }
    ]
  render: ->
    margin =
      top: 20
      right: 100
      bottom: 20
      left: 100
    hoursPlayed = @props.stats?.characterMinutes / 60
    iskPerHour = Math.round(@props.stats?.iskIn / hoursPlayed)
    iskSpentPerHour = Math.round(@props.stats?.iskOut / hoursPlayed)
    return dom.div null,
      dom.h3 null,
        'ISK'
        ' '
        dom.small null, 'All Sources'
      React.createElement(BarChart, {
        data: @chartData(),
        margin: margin,
        max: @props.max,
        formatter: humanizeLargeNum
      })
)


MarketISKPanel = React.createClass(
  displayName: 'MarketISKPanel'
  chartData: ->
    return [
      {
        key: 'iskIn'
        value: @props.stats?.marketIskIn
      }
      {
        key: 'iskOut'
        value: @props.stats?.marketIskOut
      }
    ]
  render: ->
    margin =
      top: 20
      right: 100
      bottom: 20
      left: 100
    return dom.div null,
      dom.h3 null,
        'ISK'
        ' '
        dom.small null, 'Market Only'
      React.createElement(BarChart, {
        data: @chartData(),
        margin: margin,
        max: @props.max,
        formatter: humanizeLargeNum
      })
)

MarketPanel = React.createClass(
  displayName: 'MarketPanel'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.marketBuyOrdersPlaced
          description: 'Buy Orders'
          iconId: styleIconId 'buyOrders'
        }
        {
          value: @props.stats.marketSellOrdersPlaced
          description: 'Sell Orders'
          iconId: styleIconId 'sellOrders'
        }
        {
          value: @props.stats.marketModifyMarketOrder
          description: 'Orders Modified'
          iconId: styleIconId 'ordersModified'
        }
        {
          value: @props.stats.marketCancelMarketOrder
          description: 'Orders Cancelled'
          iconId: styleIconId 'ordersCancelled'
        }
        {
          value: @props.stats.marketCreateContractsTotal
          description: 'Contracts Created'
          iconId: styleIconId 'contractCreate'
        }
        {
          value: @props.stats.marketAcceptContractsItemExchange
          description: 'Item Contracts Accepted'
          iconId: styleIconId 'contractAccept'
        }
        {
          value: @props.stats.marketAcceptContractsCourier
          description: 'Courier Contracts Accepted'
          iconId: styleIconId 'courierAccept'
        }
        {
          value: @props.stats.marketDeliverCourierContract
          description: 'Courier Contracts Delivered'
          iconId: styleIconId 'courierDeliver'
        }
      ]
      return React.createElement(CalloutPanel, {
        title: 'Market and Contracts',
        callouts: callouts,
        columns: 4
      })
    else
      return null
)

ContactsPanel = React.createClass(
  displayName: 'ContactsPanel'
  render: ->
    if @props.context == 'self'
      str = 'Add'
      title = 'How You See Others'
      subtitle = 'Your Contacts'
    else
      str = 'AddedAs'
      title = 'How Others See You'
      subtitle = 'Others Contacts'
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
    dom.div {className: ''},
      dom.h3 null,
        title
      # override sort with a function that doesn't change order
      React.createElement(PieDataPanel, {
        data: data,
        showZero: true,
        sort: (a, b) -> 0
      })

)

SocialMiscPanel = React.createClass(
  displayName: 'SocialMiscPanel'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.socialChatTotalMessageLength
          description: 'Total Length of Chat (characters)'
          icon: 'chat'
        }
        {
          value: @props.stats.socialDirectTrades
          description: 'Direct Trades'
          icon: 'trades'
        }
        {
          value: @props.stats.socialMailsSent
          description: 'Mails Sent'
          icon: 'mailSent'
        }
        {
          value: @props.stats.socialMailsReceived
          description: 'Mails Received'
          icon: 'mailReceived'
        }
        {
          value: @props.stats.socialFleetJoins
          description: 'Fleets Joined'
          icon: 'fleetJoins'
        }
        {
          value: @props.stats.socialFleetBroadcasts
          description: 'Fleets Broadcasts'
          icon: 'fleetBroadcasts'
        }
      ]
      return React.createElement(CalloutPanel, {
        title: 'Social / Fleets',
        callouts: callouts,
        columns: 3
      })
    else
      return null
)

ChatAnalogyPanel = React.createClass(
  displayName: 'ChatAnalogyPanel'
  # in number of characters
  charsPerWord: 6
  books:
    greeneggs:
      name: 'Green Eggs and Ham'
      words: 812
    modestproposal:
      name: 'A Modest Proposal'
      words: 3147
    theprince:
      name: 'Machiavelli\'s Il Principe'
      words: 32174
    bravenewworld:
      name: 'Brave New World'
      words: 63766
    mobydick:
      name: 'Crime and Punishment'
      words: 211591
    atlasshrugged:
      name: 'Atlas Shrugged'
      words: 561996

  render: ->
    if @props.chars > 0
      book = _.sample @books
      numCopies = d3.round((@props.chars / @charsPerWord) / book.words, 2)
      chatText = "Your total chat is roughly the same length as #{numCopies} copies
                  of #{book.name}"
      return dom.h4 {className: 'pull-left'}, dom.em(null,chatText)
    else
      return null
)

MiscStats = React.createClass(
  displayName: 'MiscStats'
  render: ->
    if @props.stats
      callouts = [
        {
          value: @props.stats.genericConeScans
          description: 'Directional Scans'
          icon: 'dscan'
        }
        {
          value: @props.stats.genericRequestScans
          description: 'Probe Scans'
          icon: 'probeScan'
        }
        {
          value: @props.stats.travelWarpsToCelestial
          description: 'Warps to Celestial'
          icon: 'warpCelestial'
        }
        {
          value: @props.stats.travelWarpsToBookmark
          description: 'Warps to Bookmark'
          icon: 'warpBookmark'
        }
        {
          value: @props.stats.travelWarpsToFleetMember
          description: 'Warps to Fleet Member'
          icon: 'warpFleetmate'
        }
        {
          value: @props.stats.travelWarpsToScanResult
          description: 'Warps to Scan Result'
          icon: 'warpScanResult'
        }
        {
          value: @props.stats.travelAlignTo
          description: 'Aligns'
          icon: 'aligns'
        }
        {
          value: @props.stats.travelAccelerationGateActivations
          description: 'Activated Acceleration Gate'
          icon: 'accelGate'
        }
        {
          value: @props.stats.combatSelfDestructs
          description: 'Self Destructs'
          icon: 'selfDestruct'
        }
        {
          value: @props.stats.inventoryTrashItemQuantity
          description: 'Items Trashed'
          icon: 'trash'
        }
      ]
      return React.createElement(CalloutPanel, {
        title: 'The Rest',
        callouts: callouts,
        columns: 4
      })
    else
      null
)

PieDataPanel = React.createClass(
  displayName: 'PieDataPanel'
  getDefaultProps: ->
    return {
      chartType: 'pie'
      layout: 'horizontal'
      showZero: false
      sort: null
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
        showColor = true
      when 'shipHp'
        chartElementType = ShipHPChart
        sortFn = (a, b) ->
          return HP_BAR_ORDER.indexOf(a.key) - HP_BAR_ORDER.indexOf(b.key)
        showColor = false

    if @props.sort
      sortFn = @props.sort

    data = @deriveData(sortFn)

    if @total == 0
      return dom.div null, "No activity this year"

    chart = React.createElement(chartElementType, {
      data: data,
      total: @total
    })
    table = React.createElement(PieDataTable,{
      data: data,
      total: @total,
      showZero: @props.showZero,
      showColor: showColor
    })

    if @props.layout is 'horizontal'
      return dom.div {className: 'row'},
        dom.div {className: 'col-sm-4'}, chart
        dom.div {className: 'col-sm-6'}, table
    else
      return dom.div null,
        dom.div {className: 'row'}, chart
        dom.div {className: 'row'}, table
)

PieDataTable = React.createClass(
  displayName: 'PieDataTable'
  getDefaultProps: ->
    return {
      showZero: false
      showColor: true
    }
  render: ->
    colors = d3.scale.category20b()
    rows = _.map @props.data, (d) =>
      if d.value == 0 and not @props.showZero
        return null
      color = STYLES[d.key].color ? colors(d.key)
      if @props.showColor
        iconCell = dom.td null,
          dom.div {className: "circle", style: {backgroundColor: color}}, null
      else
        iconCell = null
      #if STYLES[d.key]?.iconId
      #  iconCell = dom.td null,
      #    dom.img {src: eveIconUrl(STYLES[d.key].iconId), width: 32, height: 32}, null
      #else if STYLES[d.key]?.icon
      #  iconCell = dom.td null,
      #    dom.img {src: STYLES[d.key].icon}, null
      #else
      return dom.tr {key: d.key},
        iconCell
        dom.td null, STYLES[d.key]?.label
        dom.td {className: 'number'}, numFmt(d.value)
        dom.td {className: 'number'}, d3.round(100*d.percentOfTotal,0)+'%'
    rows.push dom.tr {key: '_total_'},
      if @props.showColor then dom.td(null, '') else null
      dom.td null, 'Total'
      dom.td {className: 'number'}, numFmt(@props.total)
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
      formatter: numFmt
      width: 300
      height: 140
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
    el = @getDOMNode()

    d3.select(el).selectAll('svg').remove()

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
          .rangeRoundBands [0, @props.height], .4

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
        .text (d) => @props.formatter(d.value)


  render: ->
    dom.div null, ''
)

PieChart = React.createClass(
  displayName: 'PieChart'
  getDefaultProps: ->
    return {
      width: 150
      height: 150
      innerRadius: 60
    }
  componentDidMount: ->
    @renderChart()
  componentDidUpdate: ->
    @renderChart()
  renderChart: ->

    el = @getDOMNode()

    d3.select(el).selectAll('svg').remove()

    if @props.total == 0
      return

    color = d3.scale.category20b()

    outerRadius = @props.width / 2

    arc = d3.svg.arc()
                .innerRadius @props.innerRadius
                .outerRadius outerRadius

    pie = d3.layout.pie()
            .value (d) -> d.value

    data = pie(@props.data)

    svg = d3.select(el).selectAll('svg').data [data]

    svg.enter().append('svg')
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
      height: 125
    }
  componentDidMount: ->
    @renderChart()
  componentDidUpdate: ->
    @renderChart()
  renderChart: ->

    el = @getDOMNode()

    d3.select(el).selectAll('svg').remove()

    if @props.data.length == 0
      return

    radius = 90
    arcWidth = 10
    padding = 2

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

    svg = d3.select(el).selectAll('svg').data [data]

    svg.enter().append('svg')
            .attr 'width', @props.width
            .attr 'height', @props.height

    arcs = svg.selectAll 'g.arc'
              .data data
              .enter()
              .append 'g'
              .attr 'transform', "translate(#{radius},#{radius})"

    arcs.append 'path'
        .attr 'fill',STYLES.null.color
        .attr 'd', hullArc

    arcs.append 'path'
        .attr 'fill', (d) -> STYLES[d.key]?.color
        .attr 'd', arc
  render: ->
    dom.div {className: 'chart'}, ''
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
      when 'percent' then numFmt(@props.value) + '%'
      else numFmt(@props.value)
    dom.div {className: 'col-md-3'},
      dom.div {className: 'panel panel-default'},
        dom.div {className: 'panel-heading', title: @props.description}, name
        dom.div {className: 'panel-body'},
          dom.h2 null, value
)

React.render(React.createElement(StatsUI), document.getElementById('body'))
