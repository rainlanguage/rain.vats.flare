# rain.vats.flare

Flare-specific price oracles for [rain.vats](https://github.com/rainlanguage/rain.vats).

`rain.vats` is chain-agnostic and depends on neither Flare nor rainlang. The
oracles that read Flare's FTSOv2 feeds and Sceptre staked-FLR rate live here
instead, so the Flare dependency (and everything it pulls in transitively) is
isolated to the repo that actually needs it.

## Contracts

- `FtsoV2LTSFeedOracle` — a `PriceOracleV2` backed by a Flare FTSOv2 long-term
  support feed.
- `SceptreStakedFlrOracle` — a `PriceOracleV2` reporting the sFLR/FLR rate.

Both extend `PriceOracleV2` from `rain-vats`, so they are usable anywhere a
`rain.vats` price oracle is expected.
