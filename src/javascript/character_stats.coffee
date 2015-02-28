class CharacterStats
  constructor: (stats) ->
    for key, val of stats
      @[key] = val
    @calcDerived()

  calcDerived: ->
    @combatKillsTotal = @combatKillsHighSec + @combatKillsLowSec + @combatKillsNullSec + @combatKillsNullSec
    @combatDeathsTotal = @combatDeathsHighSec + @combatDeathsLowSec + @combatDeathsNullSec + @combatDeathsNullSec

  metadata:
    daysOfActivity:
      name: "Active Days"
      description: "The number of days in the period with recorded activity"
    characterMinutes:
      name: "Minutes Logged In"
      description: "The number of minutes logged in as this character"
    characterSessionsStarted:
      name: "Logins"
      description: "The number of times the character has logged into the game"
    iskIn:
      name: "ISK Earned"
      description: "The total amount of positive ISK transactions in the character wallet"
    iskOut:
      name: "ISK Spent"
      description: "The total amount of negative ISK transactions in the character wallet"
    travelJumpsStargateHighSec:
      name: "High Sec Jumps"
      description: "The number of jumps through a gate in high security space"
    travelJumpsStargateLowSec:
      name: "Low Sec Jumps"
      description: "The number of jumps through a gate in low security space"
    travelJumpsStargateNullSec:
      name: "Null Sec Jumps"
      description: "The number of jumps through a gate in null security space"
    travelJumpsWormhole:
      name: "Wormhole Jumps"
      description: "The number of jumps through a wormhole"
    travelDocksHighSec:
      name: "Docked in High Sec"
      description: "The number of docks in high security space"
    travelDocksLowSec:
      name: "Docked in Low Sec"
      description: "The number of docks in low security space"
    travelDocksNullSec:
      name: "Docked in Null Sec"
      description: "The number of docks in null security space"
    pveMissionsSucceeded:
      name: "Missions Completed"
      description: "The number of missions completed"
    pveMissionsSucceededEpicArc:
      name: "Epic Arcs Completed"
      description: "The number of epic arc missions completed"
    combatKillsHighSec:
      name: "High Sec Kills"
      description: "The number of kills in high security space"
    combatKillsLowSec:
      name: "Low Sec Kills"
      description: "The number of kills in low security space"
    combatKillsNullSec:
      name: "Null Sec Kills"
      description: "The number of kills in null security space"
    combatKillsWormhole:
      name: "Wormhole Kills"
      description: "The number of kills in wormhole space"
    combatKillsPodTotal:
      name: "Pods Killed"
      description: "The total number of capsule kills (final blows)"
    combatDeathsHighSec:
      name: "High Sec Deaths"
      description: "The number of deaths in high security space"
    combatDeathsLowSec:
      name: "Low Sec Deaths"
      description: "The number of deaths in low security space"
    combatDeathsNullSec:
      name: "Null Sec Deaths"
      description: "The number of deaths in null security space"
    combatDeathsWormhole:
      name: "Wormhole Deaths"
      description: "The number of deaths in wormhole space"
    combatDeathsPodTotal:
      name: "Times Podded"
      description: "The total number of capsule deaths (times podded)"
    combatKillsAssists:
      name: "Assists"
      description: "The total number of kill assists"
    combatCapDrainedbyPC:
      name: "Cap Drained by Players"
      description: "The amount of the characters capacitor that has been drained by other player"
    combatCapDrainingPC:
      name: "Cap Drained from Players"
      description: "The amount of capacitor the character has drained from other players"
    combatCriminalFlagSet:
      name: "Times Criminal Flagged"
      description: "The number of times the character has had the crimewatch criminal flag set"
    combatDamageFromNPCsAmount:
      name: "Damage Taken from NPCs"
      description: "The total amount of damage taken from NPCs."
    combatDamageFromNPCsNumShots:
      name: "Times Shot by NPCs"
      description: "The total number of times NPCs have shot the character."
    combatDamageFromPlayersBombAmount:
      name: "Damage Taken from Bombs"
      description: "The total damage taken from bombs"
    combatDamageFromPlayersBombNumShots:
      name: "Hits Taken from Bombs"
      description: "The total number of hits taken from bombs"
    combatDamageFromPlayersEnergyAmount:
      name: "Damage Taken from Lasers"
      description: "The total damage taken from laser turrets"
    combatDamageFromPlayersEnergyNumShots:
      name: "Hits Taken from Lasers"
      description: "The total number of hits taken from laser turrets"
    combatDamageFromPlayersFighterMissileAmount:
      name: "Damage Taken from Fighter Bombers"
      description: "The total damage taken from fighter bombers"
    combatDamageFromPlayersFighterMissileNumShots:
      name: "Hits Taken from Fighter Bombers"
      description: "The total number of hits taken from fighter bombers"
    combatDamageFromPlayersHybridAmount:
      name: "Damage Taken from Hybrids"
      description: "The total damage taken from hybrid turrets"
    combatDamageFromPlayersHybridNumShots:
      name: "Hits Taken from Hybrids"
      description: "The total number of hits taken from hybrid turrets"
    combatDamageFromPlayersMissileAmount:
      name: "Damage Taken from Missiles"
      description: "The total damage taken from missile launchers"
    combatDamageFromPlayersMissileNumShots:
      name: "Hits Taken from Missiles"
      description: "The total number of hits taken from missile launchers"
    combatDamageFromPlayersProjectileAmount:
      name: "Damage Taken from Projectiles"
      description: "The total damage taken from projectile turrets"
    combatDamageFromPlayersProjectileNumShots:
      name: "Hits Taken from Projectiles"
      description: "The total number of hits taken from projectile turrets"
    combatDamageFromPlayersSmartBombAmount:
      name: "Damage Taken from Smart Bombs"
      description: "The total damage taken from smart bombs"
    combatDamageFromPlayersSmartBombNumShots:
      name: "Hits Taken from Smart Bombs"
      description: "The total number of hits taken from smart bombs"
    combatDamageFromPlayersSuperAmount:
      name: "Damage Taken from Doomsdays"
      description: "The total damage taken from doomsday devices"
    combatDamageFromPlayersSuperNumShots:
      name: "Hits Taken from Doomsdays"
      description: "The total number of hits taken from doomsday devices"
    combatDamageToPlayersBombAmount:
      name: "Damage Dealt with Bombs"
      description: "The total amount damage dealt to other players using bombs"
    combatDamageToPlayersBombNumShots:
      name: "Hits Dealt with Bombs"
      description: "The total number of hits made to other players using bombs"
    combatDamageToPlayersEnergyAmount:
      name: "Damage Dealt with Lasers"
      description: "The total amount damage dealt to other players using laser turrets"
    combatDamageToPlayersEnergyNumShots:
      name: "Number of Laser Shots"
      description: "The total number of shots made with laser turrets"
    combatDamageToPlayersFighterMissileAmount:
      name: "Damage Dealt with Fighter Bombers"
      description: "The total amount damage dealt to other players using fighter bombers"
    combatDamageToPlayersFighterMissileNumShots:
      name: "Number of Fighter Bomber Shots"
      description: "The total number of shots made with fighter bombers"
    combatDamageToPlayersHybridAmount:
      name: "Damage Dealt with Hybrids"
      description: "The total amount damage dealt to other players using hybrid turrets"
    combatDamageToPlayersHybridNumShots:
      name: "Number of Hybrid Shots"
      description: "The total number of shots made with hybrid turrets"
    combatDamageToPlayersMissileAmount:
      name: "Damage Dealt with Missiles"
      description: "The total amount damage dealt to other players using missile launchers"
    combatDamageToPlayersMissileNumShots:
      name: "Number of Missile Shots"
      description: "The total number of shots made with missile launchers"
    combatDamageToPlayersProjectileAmount:
      name: "Damage Dealt with Projectiles"
      description: "The total amount damage dealt to other players using projectile turrets"
    combatDamageToPlayersProjectileNumShots:
      name: "Number of Projectile Shots"
      description: "The total number of shots made with projectile turrets"
    combatDamageToPlayersSmartBombAmount:
      name: "Damage Dealth with Smart Bombs"
      description: "The total amount damage dealt to other players using smart bombs"
    combatDamageToPlayersSmartBombNumShots:
      name: "Number of Smart Bomb Hits"
      description: "The total number of hits made with smart bombs"
    combatDamageToPlayersStructureAmount:
      description: "REMOVE: Always 0...#wellshit"
      disabled: true
    combatDamageToPlayersStructureNumShots:
      description: "REMOVE: Always 0...#wellshit"
      disabled: true
    combatDamageToPlayersSuperAmount:
      name: "Damage Dealth with Doomsdays"
      description: "The total amount of damage dealt using doomsday devices"
    combatDamageToPlayersSuperNumShots:
      name: "Number of Doomsday Shots"
      description: "The total number of shots made with doomsday devices"
    combatDuelRequested:
      names: "Duel Requests"
      description: "The total number of times the character requested a duel against another player"
    combatNpcFlagSet:
      names: "Aggressed against NPCs"
      description: "The number of times aggression flag was set against NPCs"
    combatPvpFlagSet:
      name: "Aggressed against Players"
      description: "The number of times aggression flag was set against Players"
    combatRepairArmorByRemoteAmount:
      name: "Armor Reps Received"
      description: "The total amount received from remote armor repairers"
    combatRepairArmorRemoteAmount:
      name: "Armor Reps Given"
      description: "The total amount repaired using remote armor repairers"
    combatRepairArmorSelfAmount:
      name: "Armor Self Repped"
      description: "The total amount repaired using local armor repairers"
    combatRepairCapacitorByRemoteAmount:
      name: "Energy Transfer Received"
      description: "The total amount of energy received from energy transfers"
    combatRepairCapacitorRemoteAmount:
      name: "Energy Transfer Given"
      description: "The total amount of energy sent using energy tranfers"
    combatRepairHullByRemoteAmount:
      name: "Hull Reps Received"
      description: "The total amount received from remote hull repairers"
    combatRepairHullRemoteAmount:
      name: "Hull Reps Given"
      description: "The total amount repaired using remote hull repairers"
    combatRepairHullSelfAmount:
      name: "Hull Self Repped"
      description: "The total amount repaired using local hull repairers"
    combatRepairShieldByRemoteAmount:
      name: "Shield Reps Receieved"
      description: "The total amount received from remote shield transfers"
    combatRepairShieldRemoteAmount:
      name: "Shield Reps Given"
      description: "The total amount repaired using remote shield transfers"
    combatRepairShieldSelfAmount:
      name: "Shield Self Repped"
      description: "The total amount repaired using local shield transfers"
    combatSelfDestructs:
      name: "Self Destructs"
      description: "The number of successful self destructs"
    combatWarpScramblePC:
      name: "Scrammed Player"
      description: "The number of times warp scrambled other players"
    combatWarpScrambledbyNPC:
      name: "Scrammed by NPC"
      description: "The number of times warp scrambled by NPCs"
    combatWarpScrambledbyPC:
      name: "Scrammed by Player"
      description: "The number of times warp scrambled by other players"
    combatWebifiedbyNPC:
      name: "Webbed Player"
      description: "The number of times webbed other players"
    combatWebifiedbyPC:
      name: "Webbed by NPCs"
      description: "The number of times webbed by NPCs"
    combatWebifyingPC:
      name: "Webbed by Player"
      description: "The number of times webbed by other players"
    genericConeScans:
      name: "Times Dscanned"
      description: "The number of directional scans made"
    genericRequestScans:
      name: "Probe Scans"
      description: "The number of probe scans made"
    industryArcheologySuccesses:
      name: "Relic Cans Hacked"
      description: "The number of successful archeology attempts"
    industryHackingSuccesses:
      name: "Data Cans Hacked"
      description: "The number of successful hacking attempts"
    industryRamJobsCompletedCopyBlueprint:
      name: "Blueprints Copied"
      description: "The number of copy jobs completed"
    industryRamJobsCompletedInvention:
      name: "Invention Jobs"
      description: "The number of invention jobs completed"
    industryRamJobsCompletedManufacture:
      name: "Manufacturing Jobs"
      description: "The total number of manufacturing jobs completed"
    industryRamJobsCompletedManufactureAsteroidQuantity:
      name: "Mineral Compression Jobs"
      description: "The total units of"
    industryRamJobsCompletedManufactureChargeQuantity:
      name: "Charges Produced"
      description: "The total units of charges produced"
    industryRamJobsCompletedManufactureCommodityQuantity:
      name: "Commodities Produced"
      description: "The total units of commodities produced"
    industryRamJobsCompletedManufactureDeployableQuantity:
      name: "Deployables Produced"
      description: "The total units of deployables produced"
    industryRamJobsCompletedManufactureDroneQuantity:
      name: "Drones Produced"
      description: "The total units of drones produced"
    industryRamJobsCompletedManufactureImplantQuantity:
      name: "Implants Produced"
      description: "The total units of implants produced"
    industryRamJobsCompletedManufactureModuleQuantity:
      name: "Modules Produced"
      description: "The total units of modules produced"
    industryRamJobsCompletedManufactureShipQuantity:
      name: "Ships Produced"
      description: "The total units of ships produced"
    industryRamJobsCompletedManufactureStructureQuantity:
      name: "Structures Produced"
      description: "The total units of structures produced"
    industryRamJobsCompletedManufactureSubsystemQuantity:
      name: "Subsystems Produced"
      description: "The total units of subsystems produced"
    industryRamJobsCompletedMaterialProductivity:
      name: "ME Jobs"
      description: "The number of material efficiency jobs completed"
    industryRamJobsCompletedReverseEngineering:
      name: "Reverse Engineering Jobs"
      description: "The number of reverse engineering jobs completed (merged into invention as of ?)"
    industryRamJobsCompletedTimeProductivity:
      name: "TE Jobs"
      description: "The number of production efficiency jobs completed"
    inventoryTrashItemQuantity:
      # stack size or number of times used?
      name: "Items Trashed"
      description: "The number of items trashed"
    marketIskIn:
      name: "ISK Received from Sell Orders"
      description: "The amount of isk from sell-orders"
    marketIskOut:
      name: "ISK Spent on Buy Orders"
      description: "The amount of isk from buy-orders"
    marketAcceptContractsCourier:
      name: "Courier Contracts Accepted"
      description: "The number of times accepted a courier contract"
    marketAcceptContractsItemExchange:
      name: "Item Contracts Accepted"
      description: "The number of times accepted an item exchange contract"
    marketBuyOrdersPlaced:
      name: "Buy Orders Placed"
      description: "The number of buy orders placed"
    marketSellOrdersPlaced:
      name: "Sell Orders Placed"
      description: "The number of sell orders placed"
    marketCancelMarketOrder:
      name: "Orders Cancelled"
      description: "The number of orders cancelled"
    marketCreateContractsTotal:
      # personal only?  corp contracts as well?
      name: "Contracts Created"
      description: "The number of contracts created"
    marketDeliverCourierContract:
      name: "Courier Contracts Delivered"
      description: "The number of courier contracts delivered"
    marketISKGained:
      description: "REMOVE: historical data is bugged, supposed to take only sell orders to other players"
      disabled: true
    marketISKSpent:
      description: "REMOVE: historical data is bugged, supposed to take only buy orders to other players"
      disabled: true
    marketModifyMarketOrder:
      name: "Orders Modified"
      description: "The number of modifications made to market orders"
    miningOreArkonor:
      name: "Arkanor Mined"
      description: "The total amount of Arkonor mined (units)"
    miningOreBistot:
      name: "Bistot Mined"
      description: "The total amount of Bistot mined (units)"
    miningOreCrokite:
      name: "Crokite Mined"
      description: "The total amount of Crokite mined (units)"
    miningOreDarkOchre:
      name: "Dark Ochre Mined"
      description: "The total amount of DarkOchre mined (units)"
    miningOreGneiss:
      name: "Gneiss Mined"
      description: "The total amount of Gneiss mined (units)"
    miningOreHarvestableCloud:
      name: "Gas Huffed"
      description: "The total amount of HarvestableCloud mined (units)"
    miningOreHedbergite:
      name: "Hedbergite Mined"
      description: "The total amount of Hedbergite mined (units)"
    miningOreHemorphite:
      name: "Hemorphite Mined"
      description: "The total amount of Hemorphite mined (units)"
    miningOreIce:
      name: "Ice Mined"
      description: "The total amount of Ice mined (units)"
    miningOreJaspet:
      name: "Jaspet Mined"
      description: "The total amount of Jaspet mined (units)"
    miningOreKernite:
      name: "Kernite Mined"
      description: "The total amount of Kernite mined (units)"
    miningOreMercoxit:
      name: "Mercoxit Mined"
      description: "The total amount of Mercoxit mined (units)"
    miningOreOmber:
      name: "Omber Mined"
      description: "The total amount of Omber mined (units)"
    miningOrePlagioclase:
      name: "Plagioclase Mined"
      description: "The total amount of Plagioclase mined (units)"
    miningOrePyroxeres:
      name: "Pyroxeres Mined"
      description: "The total amount of Pyroxeres mined (units)"
    miningOreScordite:
      name: "Scordite Mined"
      description: "The total amount of Scordite mined (units)"
    miningOreSpodumain:
      name: "Spodumain Mined"
      description: "The total amount of Spodumain mined (units)"
    miningOreVeldspar:
      name: "Veldspar Mined"
      description: "The total amount of Veldspar mined (units)"
    moduleActivationsCloaking:
      name: "Times Cloaked"
      description: "The total number of cloak activations"
    moduleActivationsCyno:
      name: "Cynos Activated"
      description: "The total number of cyno activations"
    moduleActivationsEwarDampener:
      name: "Sensor Damps Used"
      description: "The total number of sensor dampener activations"
    moduleActivationsEwarECM:
      name: "ECM Activations"
      description: "The total number of ECM activations"
    moduleActivationsEwarTargetPainter:
      name: "Target Painter Activations"
      description: "The total number of target painter activations"
    moduleActivationsEwarVampire:
      name: "Energy Vampire Activations"
      description: "The total number of energy vampire activations"
    moduleActivationsFleetAssist:
      name: "Links Activated"
      description: "The total number of gang link module activations"
    moduleOverload:
      name: "Modules Overloaded"
      description: "The number of times a module was overloaded"
    socialAddContactBad:
      name: "Added Contact with Bad Standing"
      description: "The number of contacts added with bad standings"
    socialAddContactGood:
      name: "Added Contact with Good Standing"
      description: "The number of contacts added with good standings"
    socialAddContactHigh:
      name: "Added Contact with High Standing"
      description: "The number of contacts added with high standings"
    socialAddContactHorrible:
      name: "Added Contact with Horrible Standing"
      description: "The number of contacts added with horrible standings"
    socialAddContactNeutral:
      name: "Added Contact with Neutral Standing"
      description: "The number of contacts added with neutral standings"
    socialAddedAsContactBad:
      name: "Added as Bad Contact by Another Player"
      description: "The number of times added as a contact with bad standings"
    socialAddedAsContactGood:
      name: "Added as Good Contact by Another Player"
      description: "The number of times added as a contact with good standings"
    socialAddedAsContactHigh:
      name: "Added as High Contact by Another Player"
      description: "The number of times added as a contact with high standings"
    socialAddedAsContactHorrible:
      name: "Added as Horrible Contact by Another Player"
      description: "The number of times added as a contact with horrible standings"
    socialAddedAsContactNeutral:
      name: "Added as Neutral Contact by Another Player"
      description: "The number of times added as a contact with neutral standings"
    socialChatTotalMessageLength:
      name: "Total Length of All Chat"
      description: "The total length of all chat messages -NSA"
    socialDirectTrades:
      name: "Direct Trades"
      description: "The number of direct trades made"
    socialFleetJoins:
      name: "Fleets Joined"
      description: "The number of fleets joined"
    socialFleetBroadcasts:
      name: "Fleet Broadcasts"
      description: "The number of broadcasts made in fleet"
    socialMailsReceived:
      name: "Mails Received"
      description: "The number of mails received -NSA"
    socialMailsSent:
      name: "Mails Sent"
      description: "The number of mails sent -NSA"
    travelAccelerationGateActivations:
      name: "Acceleration Gates Activated"
      description: "The number of acceleration gates activated"
    travelAlignTo:
      name: "Times Aligned"
      description: "The number of times ship alignment was made"
    travelDistanceWarpedHighSec:
      name: "AU Traveled in High Sec"
      description: "The total distance(AU) traveled in warp while in high security space"
    travelDistanceWarpedLowSec:
      name: "AU Traveled in Low Sec"
      description: "The total distance(AU) traveled in warp while in low security space"
    travelDistanceWarpedNullSec:
      name: "AU Traveled in Null Sec"
      description: "The total distance(AU) traveled in warp while in null security space"
    travelDistanceWarpedWormhole:
      name: "AU Traveled in Wormholes"
      description: "The total distance(AU) traveled in warp while in wormhole space"
    travelWarpsHighSec:
      name: "Initiated Warp in High Sec"
      description: "The total number of warps initiated while in high security space"
    travelWarpsLowSec:
      name: "Initiated Warp in Low Sec"
      description: "The total number of warps initiated while in low security space"
    travelWarpsNullSec:
      name: "Initiated Warp in Null Sec"
      description: "The total number of warps initiated while in null security space"
    travelWarpsWormhole:
      name: "Initiated Warp in Wormholes"
      description: "The total number of warps initiated while in wormhole space"
    travelWarpsToBookmark:
      name: "Initiated Warp to Bookmark"
      description: "The total number of warps initiated to a bookmark"
    travelWarpsToCelestial:
      name: "Initiated Warp to Celestial"
      description: "The total number of warps initiated to a celestial"
    travelWarpsToFleetMember:
      name: "Initiated Warp to Fleet Member"
      description: "The total number of warps initiated to a fleet member"
    travelWarpsToScanResult:
      name: "Initiated Warp to Scan Result"
      description: "The total number of warps initiated to a scan result"

    # derived fields
    combatKillsTotal:
      name: 'Total Kills'
    combatDeathsTotal:
      name: 'Total Deaths'

module.exports = CharacterStats
