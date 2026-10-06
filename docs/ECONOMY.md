# Economy

> **All values below are tunable starting values for Mission Zero.** Economy tuning should be judged by playtest pacing, not treated as final arithmetic.

## Economy goal

The economy should force recurring choices between:

- more income,
- military production,
- power,
- static defense,
- and expanding toward contested resources.

The player should rarely feel completely starved, but should not be able to queue every desirable option at once.

## Starting resources

- Player starting credits: **4,000**
- Enemy starting credits: **4,000**
- Currency name: **credits**
- Harvestable resource: **Flux Ore**

## Flux Ore fields

Mission Zero uses four authored fields:

| Field | Starting value | Intended use |
|---|---:|---|
| Player near field | 14,000 credits | Safe opening economy |
| West expansion field | 10,000 credits | Safer second source |
| Central rich field | 22,000 credits | Contested high-value source |
| Enemy near field | 14,000 credits | Enemy opening economy |

Total map resource value: **60,000 credits**.

A field is made of resource cells with visible remaining amount. When depleted, the cell stops being harvestable. There is no resource regeneration in Mission Zero.

## Gatherer numbers

| Parameter | Starting value |
|---|---:|
| Gatherer purchase cost | 1,200 credits |
| Build time | 18 s |
| Cargo capacity | 1,000 credits worth of Flux Ore |
| Harvest rate | 50 credits/second |
| Unload rate | 500 credits/second |
| Unload time for full cargo | 2 s |
| Move speed | 2.2 cells/second (was 3.2; ×0.7 with the 108-cell map, 2026-10-06) |

A full load therefore requires **20 seconds of harvesting**, plus travel and unloading. With a short opening route, one Gatherer should average roughly **1,600–2,000 credits per minute**. Actual income must be measured in the greybox because route distance and congestion matter. (2026-10-06 check after the speed change: the near field stays ~10 cells from each base, so a trip is ~9 s of driving + 20 s harvesting + 2 s unloading ≈ 31 s per 1,000 credits, about **1,900 credits per minute**, still inside this band.)

## Ore Works

| Parameter | Starting value |
|---|---:|
| Cost | 2,000 credits |
| Build time | 15 s |
| Power use | 30 |
| Included Gatherer | 1 on the owner's first completed Ore Works |
| Simultaneous unloading | 1 Gatherer per Ore Works |

The free first Gatherer prevents the player from paying for an economy building and then waiting through a second large purchase before the harvesting loop becomes visible.

Additional Ore Works increase unloading locations and construction radius but do not create free Gatherers in Mission Zero.

## Income flow

1. Gatherer selects the nearest reachable Flux Ore cell in its assigned field.
2. It moves to a valid harvesting position.
3. It harvests until full or the field is exhausted.
4. It returns to the nearest reachable friendly Ore Works.
5. Cargo converts to credits during unloading.
6. It repeats until no reachable Flux Ore remains.

Credits are added continuously during the 2-second unload rather than appearing as one large end-of-animation jump.

## Player control over Gatherers

Mission Zero supports:

- selecting a Gatherer,
- ordering it to a different Flux Ore field,
- ordering it back to an Ore Works,
- moving it manually when threatened.

If given no manual instruction, the Gatherer resumes its automatic harvest loop.

No repair, escort stance, resource-type choice or multi-resource economy is included.

## Spending baseline

### Buildings

| Item | Cost | Build time |
|---|---:|---:|
| Grid Plant | 800 | 8 s |
| Ore Works | 2,000 | 15 s |
| Infantry Depot | 700 | 8 s |
| Vehicle Foundry | 2,000 | 16 s |
| Guardian Turret | 900 | 10 s |

### Units

| Item | Cost | Build time |
|---|---:|---:|
| Ranger | 150 | 5 s |
| Lancer | 300 | 8 s |
| Jackal | 500 | 12 s |
| Vanguard Tank | 900 | 18 s |
| Breaker Tank | 1,400 | 28 s |
| Gatherer | 1,200 | 18 s |

## Opening affordability check

Starting with 4,000 credits:

- Grid Plant: -800 → 3,200
- Ore Works: -2,000 → 1,200
- Infantry Depot: -700 → 500

At that point the first included Gatherer is already creating income, and the player can immediately afford several Rangers or save for the 2,000-credit Vehicle Foundry.

This intentionally creates an early decision instead of allowing the entire tech path to be purchased from starting credits.

## Queue and refund rules

- Construction/unit cost is deducted when queued.
- Building cancel before placement: **75% refund**.
- Unit cancelled before production starts: **100% refund**.
- Unit cancelled after production begins: **75% refund**.
- Production building destroyed: **50% refund** of the remaining queued value.
- No selling buildings in Mission Zero.

## Economy tuning targets

During playtesting, aim for:

- First Ore Works operational by roughly **0:35–0:55** for a new player.
- First military units available before **2:00**.
- First Vanguard Tank reasonably achievable around **3:00–4:00** without halting all infantry.
- Player can afford meaningful defensive preparation before the **4:30** first AI wave.
- A second Gatherer should feel like a real investment with visible payback, not an automatic purchase.
- The opening field should begin feeling constrained during the midgame so expansion becomes attractive.
- Contesting the central field should materially accelerate a successful push.

If players spend long periods staring at empty queues, raise income or lower costs. If every queue stays full with no tradeoffs, reduce income or raise costs. Tune the loop, not individual numbers in isolation.
