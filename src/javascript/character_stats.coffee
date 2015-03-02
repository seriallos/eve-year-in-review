_ = require 'lodash'

class CharacterStats
  constructor: (stats) ->
    for key, val of stats
      @[key] = val

    @secSuffixes = [
      'HighSec'
      'LowSec'
      'NullSec'
      'Wormhole'
    ]

    @calcDerived()

  total: _.memoize (prefix) ->
    statNames = _.map @secSuffixes, (suffix) -> prefix + suffix
    return _.reduce statNames, ((sum, stat) => sum + @[stat]), 0

  percent: _.memoize (prefix, suffix) ->
    total = @total prefix
    pct = @[prefix + suffix] / total
    return pct
  # resolver
  , (prefix, suffix) -> return "#{prefix}#{suffix}"

  calcDerived: ->
    # fix a few stats
    @iskOut = -(@iskOut)
    # derive some stats
    @averageSessionLength = @characterMinutes / @characterSessionsStarted

    @combatKillsTotal = @total 'combatKills'
    @combatDeathsTotal = @total 'combatDeaths'
    @kdRatioTotal = @combatKillsTotal / @combatDeathsTotal

    @kdRatioHigh = @combatKillsHighSec / @combatDeathsHighSec
    @kdRatioLow = @combatKillsLowSec / @combatDeathsLowSec
    @kdRatioNull = @combatKillsNullSec / @combatDeathsNullSec
    @kdRatioWormhole = @combatKillsWormhole / @combatDeathsWormhole

    @travelDistanceWarpedTotal = @total 'travelDistanceWarped'

    @totalDamageDealt = @combatDamageToPlayersHybridAmount +
                        @combatDamageToPlayersProjectileAmount +
                        @combatDamageToPlayersEnergyAmount +
                        @combatDamageToPlayersMissileAmount +
                        @combatDamageToPlayersBombAmount +
                        @combatDamageToPlayersSmartBombAmount +
                        @combatDamageToPlayersFighterMissileAmount +
                        @combatDamageToPlayersSuperAmount

    @iskSpentPercent = 100 * (@iskOut / @iskIn)

  metadata:
    daysOfActivity:
      name: "Active Days"
      description: "The number of days in the period with recorded activity"
      tags: ['general']
    characterMinutes:
      name: "Minutes Logged In"
      description: "The number of minutes logged in as this character"
      tags: ['general']
    characterSessionsStarted:
      name: "Logins"
      description: "The number of times the character has logged into the game"
      tags: ['general']
    iskIn:
      name: "ISK Earned"
      description: "The total amount of positive ISK transactions in the character wallet"
      tags: ['general']
    iskOut:
      name: "ISK Spent"
      description: "The total amount of negative ISK transactions in the character wallet"
      tags: ['general']
    travelJumpsStargateHighSec:
      name: "High Sec Jumps"
      description: "The number of jumps through a gate in high security space"
      tags: ['travel']
    travelJumpsStargateLowSec:
      name: "Low Sec Jumps"
      description: "The number of jumps through a gate in low security space"
      tags: ['travel']
    travelJumpsStargateNullSec:
      name: "Null Sec Jumps"
      description: "The number of jumps through a gate in null security space"
      tags: ['travel']
    travelJumpsWormhole:
      name: "Wormhole Jumps"
      description: "The number of jumps through a wormhole"
      tags: ['travel']
    travelDocksHighSec:
      name: "Docked in High Sec"
      description: "The number of docks in high security space"
      tags: ['travel']
    travelDocksLowSec:
      name: "Docked in Low Sec"
      description: "The number of docks in low security space"
      tags: ['travel']
    travelDocksNullSec:
      name: "Docked in Null Sec"
      description: "The number of docks in null security space"
      tags: ['travel']
    pveMissionsSucceeded:
      name: "Missions Completed"
      description: "The number of missions completed"
      tags: ['pve']
    pveMissionsSucceededEpicArc:
      name: "Epic Arcs Completed"
      description: "The number of epic arc missions completed"
      tags: ['pve']
    combatKillsHighSec:
      name: "High Sec Kills"
      description: "The number of kills in high security space"
      tags: ['pvp']
    combatKillsLowSec:
      name: "Low Sec Kills"
      description: "The number of kills in low security space"
      tags: ['pvp']
    combatKillsNullSec:
      name: "Null Sec Kills"
      description: "The number of kills in null security space"
      tags: ['pvp']
    combatKillsWormhole:
      name: "Wormhole Kills"
      description: "The number of kills in wormhole space"
      tags: ['pvp']
    combatKillsPodTotal:
      name: "Pods Killed"
      description: "The total number of capsule kills (final blows)"
      tags: ['pvp']
    combatDeathsHighSec:
      name: "High Sec Deaths"
      description: "The number of deaths in high security space"
      tags: ['deaths']
    combatDeathsLowSec:
      name: "Low Sec Deaths"
      description: "The number of deaths in low security space"
      tags: ['deaths']
    combatDeathsNullSec:
      name: "Null Sec Deaths"
      description: "The number of deaths in null security space"
      tags: ['deaths']
    combatDeathsWormhole:
      name: "Wormhole Deaths"
      description: "The number of deaths in wormhole space"
      tags: ['deaths']
    combatDeathsPodTotal:
      name: "Times Podded"
      description: "The total number of capsule deaths (times podded)"
      tags: ['deaths']
    combatKillsAssists:
      name: "Assists"
      description: "The total number of kill assists"
      tags: ['pvp']
    combatCapDrainedbyPC:
      name: "Cap Drained by Players"
      description: "The amount of the characters capacitor that has been drained by other player"
      tags: ['pvp']
    combatCapDrainingPC:
      name: "Cap Drained from Players"
      description: "The amount of capacitor the character has drained from other players"
      tags: ['pvp']
    combatCriminalFlagSet:
      name: "Times Criminal Flagged"
      description: "The number of times the character has had the crimewatch criminal flag set"
      tags: ['pvp']
    combatDamageFromNPCsAmount:
      name: "Damage Taken from NPCs"
      description: "The total amount of damage taken from NPCs."
      tags: ['pve']
    combatDamageFromNPCsNumShots:
      name: "Times Shot by NPCs"
      description: "The total number of times NPCs have shot the character."
      tags: ['pve']
    combatDamageFromPlayersBombAmount:
      name: "Damage Taken from Bombs"
      description: "The total damage taken from bombs"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersBombNumShots:
      name: "Hits Taken from Bombs"
      description: "The total number of hits taken from bombs"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersEnergyAmount:
      name: "Damage Taken from Lasers"
      description: "The total damage taken from laser turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersEnergyNumShots:
      name: "Hits Taken from Lasers"
      description: "The total number of hits taken from laser turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersFighterMissileAmount:
      name: "Damage Taken from Fighter Bombers"
      description: "The total damage taken from fighter bombers"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersFighterMissileNumShots:
      name: "Hits Taken from Fighter Bombers"
      description: "The total number of hits taken from fighter bombers"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersHybridAmount:
      name: "Damage Taken from Hybrids"
      description: "The total damage taken from hybrid turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersHybridNumShots:
      name: "Hits Taken from Hybrids"
      description: "The total number of hits taken from hybrid turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersMissileAmount:
      name: "Damage Taken from Missiles"
      description: "The total damage taken from missile launchers"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersMissileNumShots:
      name: "Hits Taken from Missiles"
      description: "The total number of hits taken from missile launchers"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersProjectileAmount:
      name: "Damage Taken from Projectiles"
      description: "The total damage taken from projectile turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersProjectileNumShots:
      name: "Hits Taken from Projectiles"
      description: "The total number of hits taken from projectile turrets"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersSmartBombAmount:
      name: "Damage Taken from Smart Bombs"
      description: "The total damage taken from smart bombs"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersSmartBombNumShots:
      name: "Hits Taken from Smart Bombs"
      description: "The total number of hits taken from smart bombs"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersSuperAmount:
      name: "Damage Taken from Doomsdays"
      description: "The total damage taken from doomsday devices"
      tags: ['damageTaken','pvp']
    combatDamageFromPlayersSuperNumShots:
      name: "Hits Taken from Doomsdays"
      description: "The total number of hits taken from doomsday devices"
      tags: ['damageDone','pvp']
    combatDamageToPlayersBombAmount:
      name: "Damage Dealt with Bombs"
      description: "The total amount damage dealt to other players using bombs"
      tags: ['damageDone','pvp']
    combatDamageToPlayersBombNumShots:
      name: "Hits Dealt with Bombs"
      description: "The total number of hits made to other players using bombs"
      tags: ['damageDone','pvp']
    combatDamageToPlayersEnergyAmount:
      name: "Damage Dealt with Lasers"
      description: "The total amount damage dealt to other players using laser turrets"
      tags: []
    combatDamageToPlayersEnergyNumShots:
      name: "Number of Laser Shots"
      description: "The total number of shots made with laser turrets"
      tags: []
    combatDamageToPlayersFighterMissileAmount:
      name: "Damage Dealt with Fighter Bombers"
      description: "The total amount damage dealt to other players using fighter bombers"
      tags: []
    combatDamageToPlayersFighterMissileNumShots:
      name: "Number of Fighter Bomber Shots"
      description: "The total number of shots made with fighter bombers"
      tags: []
    combatDamageToPlayersHybridAmount:
      name: "Damage Dealt with Hybrids"
      description: "The total amount damage dealt to other players using hybrid turrets"
      tags: []
    combatDamageToPlayersHybridNumShots:
      name: "Number of Hybrid Shots"
      description: "The total number of shots made with hybrid turrets"
      tags: []
    combatDamageToPlayersMissileAmount:
      name: "Damage Dealt with Missiles"
      description: "The total amount damage dealt to other players using missile launchers"
      tags: []
    combatDamageToPlayersMissileNumShots:
      name: "Number of Missile Shots"
      description: "The total number of shots made with missile launchers"
      tags: []
    combatDamageToPlayersProjectileAmount:
      name: "Damage Dealt with Projectiles"
      description: "The total amount damage dealt to other players using projectile turrets"
      tags: []
    combatDamageToPlayersProjectileNumShots:
      name: "Number of Projectile Shots"
      description: "The total number of shots made with projectile turrets"
      tags: []
    combatDamageToPlayersSmartBombAmount:
      name: "Damage Dealth with Smart Bombs"
      description: "The total amount damage dealt to other players using smart bombs"
      tags: []
    combatDamageToPlayersSmartBombNumShots:
      name: "Number of Smart Bomb Hits"
      description: "The total number of hits made with smart bombs"
      tags: []
    combatDamageToPlayersStructureAmount:
      description: "REMOVE: Always 0...#wellshit"
      disabled: true
      tags: []
    combatDamageToPlayersStructureNumShots:
      description: "REMOVE: Always 0...#wellshit"
      disabled: true
      tags: []
    combatDamageToPlayersSuperAmount:
      name: "Damage Dealth with Doomsdays"
      description: "The total amount of damage dealt using doomsday devices"
      tags: []
    combatDamageToPlayersSuperNumShots:
      name: "Number of Doomsday Shots"
      description: "The total number of shots made with doomsday devices"
      tags: []
    combatDuelRequested:
      names: "Duel Requests"
      description: "The total number of times the character requested a duel against another player"
      tags: []
    combatNpcFlagSet:
      names: "Aggressed against NPCs"
      description: "The number of times aggression flag was set against NPCs"
      tags: []
    combatPvpFlagSet:
      name: "Aggressed against Players"
      description: "The number of times aggression flag was set against Players"
      tags: []
    combatRepairArmorByRemoteAmount:
      name: "Armor Reps Received"
      description: "The total amount received from remote armor repairers"
      tags: []
    combatRepairArmorRemoteAmount:
      name: "Armor Reps Given"
      description: "The total amount repaired using remote armor repairers"
      tags: []
    combatRepairArmorSelfAmount:
      name: "Armor Self Repped"
      description: "The total amount repaired using local armor repairers"
      tags: []
    combatRepairCapacitorByRemoteAmount:
      name: "Energy Transfer Received"
      description: "The total amount of energy received from energy transfers"
      tags: []
    combatRepairCapacitorRemoteAmount:
      name: "Energy Transfer Given"
      description: "The total amount of energy sent using energy tranfers"
      tags: []
    combatRepairHullByRemoteAmount:
      name: "Hull Reps Received"
      description: "The total amount received from remote hull repairers"
      tags: []
    combatRepairHullRemoteAmount:
      name: "Hull Reps Given"
      description: "The total amount repaired using remote hull repairers"
      tags: []
    combatRepairHullSelfAmount:
      name: "Hull Self Repped"
      description: "The total amount repaired using local hull repairers"
      tags: []
    combatRepairShieldByRemoteAmount:
      name: "Shield Reps Receieved"
      description: "The total amount received from remote shield transfers"
      tags: []
    combatRepairShieldRemoteAmount:
      name: "Shield Reps Given"
      description: "The total amount repaired using remote shield transfers"
      tags: []
    combatRepairShieldSelfAmount:
      name: "Shield Self Repped"
      description: "The total amount repaired using local shield transfers"
      tags: []
    combatSelfDestructs:
      name: "Self Destructs"
      description: "The number of successful self destructs"
      tags: []
    combatWarpScramblePC:
      name: "Scrammed Player"
      description: "The number of times warp scrambled other players"
      tags: []
    combatWarpScrambledbyNPC:
      name: "Scrammed by NPC"
      description: "The number of times warp scrambled by NPCs"
      tags: []
    combatWarpScrambledbyPC:
      name: "Scrammed by Player"
      description: "The number of times warp scrambled by other players"
      tags: []
    combatWebifiedbyNPC:
      name: "Webbed Player"
      description: "The number of times webbed other players"
      tags: []
    combatWebifiedbyPC:
      name: "Webbed by NPCs"
      description: "The number of times webbed by NPCs"
      tags: []
    combatWebifyingPC:
      name: "Webbed by Player"
      description: "The number of times webbed by other players"
      tags: []
    genericConeScans:
      name: "Times Dscanned"
      description: "The number of directional scans made"
      tags: []
    genericRequestScans:
      name: "Probe Scans"
      description: "The number of probe scans made"
      tags: []
    industryArcheologySuccesses:
      name: "Relic Cans Hacked"
      description: "The number of successful archeology attempts"
      tags: []
    industryHackingSuccesses:
      name: "Data Cans Hacked"
      description: "The number of successful hacking attempts"
      tags: []
    industryRamJobsCompletedCopyBlueprint:
      name: "Blueprints Copied"
      description: "The number of copy jobs completed"
      tags: []
    industryRamJobsCompletedInvention:
      name: "Invention Jobs"
      description: "The number of invention jobs completed"
      tags: []
    industryRamJobsCompletedManufacture:
      name: "Manufacturing Jobs"
      description: "The total number of manufacturing jobs completed"
      tags: []
    industryRamJobsCompletedManufactureAsteroidQuantity:
      name: "Mineral Compression Jobs"
      description: "The total units of"
      tags: []
    industryRamJobsCompletedManufactureChargeQuantity:
      name: "Charges Produced"
      description: "The total units of charges produced"
      tags: []
    industryRamJobsCompletedManufactureCommodityQuantity:
      name: "Commodities Produced"
      description: "The total units of commodities produced"
      tags: []
    industryRamJobsCompletedManufactureDeployableQuantity:
      name: "Deployables Produced"
      description: "The total units of deployables produced"
      tags: []
    industryRamJobsCompletedManufactureDroneQuantity:
      name: "Drones Produced"
      description: "The total units of drones produced"
      tags: []
    industryRamJobsCompletedManufactureImplantQuantity:
      name: "Implants Produced"
      description: "The total units of implants produced"
      tags: []
    industryRamJobsCompletedManufactureModuleQuantity:
      name: "Modules Produced"
      description: "The total units of modules produced"
      tags: []
    industryRamJobsCompletedManufactureShipQuantity:
      name: "Ships Produced"
      description: "The total units of ships produced"
      tags: []
    industryRamJobsCompletedManufactureStructureQuantity:
      name: "Structures Produced"
      description: "The total units of structures produced"
      tags: []
    industryRamJobsCompletedManufactureSubsystemQuantity:
      name: "Subsystems Produced"
      description: "The total units of subsystems produced"
      tags: []
    industryRamJobsCompletedMaterialProductivity:
      name: "ME Jobs"
      description: "The number of material efficiency jobs completed"
      tags: []
    industryRamJobsCompletedReverseEngineering:
      name: "Reverse Engineering Jobs"
      description: "The number of reverse engineering jobs completed (merged into invention as of ?)"
      tags: []
    industryRamJobsCompletedTimeProductivity:
      name: "TE Jobs"
      description: "The number of production efficiency jobs completed"
      tags: []
    inventoryTrashItemQuantity:
      # stack size or number of times used?
      name: "Items Trashed"
      description: "The number of items trashed"
      tags: []
    marketIskIn:
      name: "ISK Received from Sell Orders"
      description: "The amount of isk from sell-orders"
      tags: []
    marketIskOut:
      name: "ISK Spent on Buy Orders"
      description: "The amount of isk from buy-orders"
      tags: []
    marketAcceptContractsCourier:
      name: "Courier Contracts Accepted"
      description: "The number of times accepted a courier contract"
      tags: []
    marketAcceptContractsItemExchange:
      name: "Item Contracts Accepted"
      description: "The number of times accepted an item exchange contract"
      tags: []
    marketBuyOrdersPlaced:
      name: "Buy Orders Placed"
      description: "The number of buy orders placed"
      tags: []
    marketSellOrdersPlaced:
      name: "Sell Orders Placed"
      description: "The number of sell orders placed"
      tags: []
    marketCancelMarketOrder:
      name: "Orders Cancelled"
      description: "The number of orders cancelled"
      tags: []
    marketCreateContractsTotal:
      # personal only?  corp contracts as well?
      name: "Contracts Created"
      description: "The number of contracts created"
      tags: []
    marketDeliverCourierContract:
      name: "Courier Contracts Delivered"
      description: "The number of courier contracts delivered"
      tags: []
    marketISKGained:
      description: "REMOVE: historical data is bugged, supposed to take only sell orders to other players"
      disabled: true
      tags: []
    marketISKSpent:
      description: "REMOVE: historical data is bugged, supposed to take only buy orders to other players"
      disabled: true
      tags: []
    marketModifyMarketOrder:
      name: "Orders Modified"
      description: "The number of modifications made to market orders"
      tags: []
    miningOreArkonor:
      name: "Arkanor Mined"
      description: "The total amount of Arkonor mined (units)"
      tags: []
    miningOreBistot:
      name: "Bistot Mined"
      description: "The total amount of Bistot mined (units)"
      tags: []
    miningOreCrokite:
      name: "Crokite Mined"
      description: "The total amount of Crokite mined (units)"
      tags: []
    miningOreDarkOchre:
      name: "Dark Ochre Mined"
      description: "The total amount of DarkOchre mined (units)"
      tags: []
    miningOreGneiss:
      name: "Gneiss Mined"
      description: "The total amount of Gneiss mined (units)"
      tags: []
    miningOreHarvestableCloud:
      name: "Gas Huffed"
      description: "The total amount of HarvestableCloud mined (units)"
      tags: []
    miningOreHedbergite:
      name: "Hedbergite Mined"
      description: "The total amount of Hedbergite mined (units)"
      tags: []
    miningOreHemorphite:
      name: "Hemorphite Mined"
      description: "The total amount of Hemorphite mined (units)"
      tags: []
    miningOreIce:
      name: "Ice Mined"
      description: "The total amount of Ice mined (units)"
      tags: []
    miningOreJaspet:
      name: "Jaspet Mined"
      description: "The total amount of Jaspet mined (units)"
      tags: []
    miningOreKernite:
      name: "Kernite Mined"
      description: "The total amount of Kernite mined (units)"
      tags: []
    miningOreMercoxit:
      name: "Mercoxit Mined"
      description: "The total amount of Mercoxit mined (units)"
      tags: []
    miningOreOmber:
      name: "Omber Mined"
      description: "The total amount of Omber mined (units)"
      tags: []
    miningOrePlagioclase:
      name: "Plagioclase Mined"
      description: "The total amount of Plagioclase mined (units)"
      tags: []
    miningOrePyroxeres:
      name: "Pyroxeres Mined"
      description: "The total amount of Pyroxeres mined (units)"
      tags: []
    miningOreScordite:
      name: "Scordite Mined"
      description: "The total amount of Scordite mined (units)"
      tags: []
    miningOreSpodumain:
      name: "Spodumain Mined"
      description: "The total amount of Spodumain mined (units)"
      tags: []
    miningOreVeldspar:
      name: "Veldspar Mined"
      description: "The total amount of Veldspar mined (units)"
      tags: []
    moduleActivationsCloaking:
      name: "Times Cloaked"
      description: "The total number of cloak activations"
      tags: []
    moduleActivationsCyno:
      name: "Cynos Activated"
      description: "The total number of cyno activations"
      tags: []
    moduleActivationsEwarDampener:
      name: "Sensor Damps Used"
      description: "The total number of sensor dampener activations"
      tags: []
    moduleActivationsEwarECM:
      name: "ECM Activations"
      description: "The total number of ECM activations"
      tags: []
    moduleActivationsEwarTargetPainter:
      name: "Target Painter Activations"
      description: "The total number of target painter activations"
      tags: []
    moduleActivationsEwarVampire:
      name: "Energy Vampire Activations"
      description: "The total number of energy vampire activations"
      tags: []
    moduleActivationsFleetAssist:
      name: "Links Activated"
      description: "The total number of gang link module activations"
      tags: []
    moduleOverload:
      name: "Modules Overloaded"
      description: "The number of times a module was overloaded"
      tags: []
    socialAddContactBad:
      name: "Added Contact with Bad Standing"
      description: "The number of contacts added with bad standings"
      tags: []
    socialAddContactGood:
      name: "Added Contact with Good Standing"
      description: "The number of contacts added with good standings"
      tags: []
    socialAddContactHigh:
      name: "Added Contact with High Standing"
      description: "The number of contacts added with high standings"
      tags: []
    socialAddContactHorrible:
      name: "Added Contact with Horrible Standing"
      description: "The number of contacts added with horrible standings"
      tags: []
    socialAddContactNeutral:
      name: "Added Contact with Neutral Standing"
      description: "The number of contacts added with neutral standings"
      tags: []
    socialAddedAsContactBad:
      name: "Added as Bad Contact by Another Player"
      description: "The number of times added as a contact with bad standings"
      tags: []
    socialAddedAsContactGood:
      name: "Added as Good Contact by Another Player"
      description: "The number of times added as a contact with good standings"
      tags: []
    socialAddedAsContactHigh:
      name: "Added as High Contact by Another Player"
      description: "The number of times added as a contact with high standings"
      tags: []
    socialAddedAsContactHorrible:
      name: "Added as Horrible Contact by Another Player"
      description: "The number of times added as a contact with horrible standings"
      tags: []
    socialAddedAsContactNeutral:
      name: "Added as Neutral Contact by Another Player"
      description: "The number of times added as a contact with neutral standings"
      tags: []
    socialChatTotalMessageLength:
      name: "Total Length of All Chat"
      description: "The total length of all chat messages -NSA"
      tags: []
    socialDirectTrades:
      name: "Direct Trades"
      description: "The number of direct trades made"
      tags: []
    socialFleetJoins:
      name: "Fleets Joined"
      description: "The number of fleets joined"
      tags: []
    socialFleetBroadcasts:
      name: "Fleet Broadcasts"
      description: "The number of broadcasts made in fleet"
      tags: []
    socialMailsReceived:
      name: "Mails Received"
      description: "The number of mails received -NSA"
      tags: []
    socialMailsSent:
      name: "Mails Sent"
      description: "The number of mails sent -NSA"
      tags: []
    travelAccelerationGateActivations:
      name: "Acceleration Gates Activated"
      description: "The number of acceleration gates activated"
      tags: []
    travelAlignTo:
      name: "Times Aligned"
      description: "The number of times ship alignment was made"
      tags: []
    travelDistanceWarpedHighSec:
      name: "AU Traveled in High Sec"
      description: "The total distance(AU) traveled in warp while in high security space"
      tags: []
    travelDistanceWarpedLowSec:
      name: "AU Traveled in Low Sec"
      description: "The total distance(AU) traveled in warp while in low security space"
      tags: []
    travelDistanceWarpedNullSec:
      name: "AU Traveled in Null Sec"
      description: "The total distance(AU) traveled in warp while in null security space"
      tags: []
    travelDistanceWarpedWormhole:
      name: "AU Traveled in Wormholes"
      description: "The total distance(AU) traveled in warp while in wormhole space"
      tags: []
    travelWarpsHighSec:
      name: "Initiated Warp in High Sec"
      description: "The total number of warps initiated while in high security space"
      tags: []
    travelWarpsLowSec:
      name: "Initiated Warp in Low Sec"
      description: "The total number of warps initiated while in low security space"
      tags: []
    travelWarpsNullSec:
      name: "Initiated Warp in Null Sec"
      description: "The total number of warps initiated while in null security space"
      tags: []
    travelWarpsWormhole:
      name: "Initiated Warp in Wormholes"
      description: "The total number of warps initiated while in wormhole space"
      tags: []
    travelWarpsToBookmark:
      name: "Initiated Warp to Bookmark"
      description: "The total number of warps initiated to a bookmark"
      tags: []
    travelWarpsToCelestial:
      name: "Initiated Warp to Celestial"
      description: "The total number of warps initiated to a celestial"
      tags: []
    travelWarpsToFleetMember:
      name: "Initiated Warp to Fleet Member"
      description: "The total number of warps initiated to a fleet member"
      tags: []
    travelWarpsToScanResult:
      name: "Initiated Warp to Scan Result"
      description: "The total number of warps initiated to a scan result"
      tags: []

    # derived fields
    combatKillsTotal:
      name: 'Total Kills'
      tags: ['pvp']
    combatDeathsTotal:
      name: 'Total Deaths'
      tags: ['pvp']
    iskSpentPercent:
      name: 'Percent of Income Spent, Overall'
      tags: ['general']
      units: 'percent'
    kdRatioTotal:
      name: 'Kill/Death Ratio'
      tags: ['pvp']
    averageSessionLength:
      name: 'Average Session Length'
      tags: ['general']
      units: 'minutes'

module.exports = CharacterStats
