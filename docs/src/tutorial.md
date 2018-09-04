# Tutorial

This tutorial will walk you through the features and functionality of AstroTime.jl.
Everything in this package revolves around the `Epoch` data type.
`Epochs` are basically a high-precision, time scale-aware version of the [`DateTime`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates-1) type from Julia's standard library.
This means that while `DateTime` timestamps are always assumed to be based on Universal Time (UT), `Epochs` can be created in several pre-defined time scales or custom user-defined time scales.

## Creating Epochs

You construct `Epoch` instances similar to `DateTime` instance, for example by using date and time components.
The main difference is that you need to supply the time scale to be used.
Out of the box, the following time scales are defined:

- `TAI`: [International Atomic Time](https://en.wikipedia.org/wiki/International_Atomic_Time)
- `UTC`: [Coordinated Universal Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time)
- `UT1`: [Universal Time](https://en.wikipedia.org/wiki/Universal_Time#Versions)
- `TT`: [Terrestrial Time](https://en.wikipedia.org/wiki/Terrestrial_Time)
- `TCG`: [Geocentric Coordinate Time](https://en.wikipedia.org/wiki/Geocentric_Coordinate_Time)
- `TCB`: [Barycentric Coordinate Time](https://en.wikipedia.org/wiki/Barycentric_Coordinate_Time)
- `TDB`: [Barycentric Dynamical Time](https://en.wikipedia.org/wiki/Barycentric_Dynamical_Time)

```julia
using AstroTime

ep = Epoch{UTC}(2018, 2, 6, 20, 45, 0.0)

# The following shorthand also works
ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)

# Or in another time scale
ep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)
```

You can also parse an `Epoch` from a string.
AstroTime.jl uses the [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat) type and specification language from the `Dates` module from Julia's standard library.
For example:

```julia
ep = UTCEpoch("2018-02-06T20:45:00.000", "yyyy-mm-ddTHH:MM:SS.sss")

# The format string above `yyyy-mm-ddTHH:MM:SS.sss` is also the default format.
# Thus, this also works...
ep = UTCEpoch("2018-02-06T20:45:00.000")

import Dates

# You can also reuse the format string
df = Dates.dateformat"dd.mm.yyyy HH:MM"

utc = UTCEpoch("06.02.2018 20:45", df)
tai = TAIEpoch("06.02.2018 20:45", df)
```

There are two additional character codes supported.

- `t`: This character code is parsed as the time scale.
- `D`: This character code is parsed as the day number within a year.

```julia
# The time scale can be omitted from the constructor because it is already
# defined in the input string
julia> Epoch("2018-02-06T20:45:00.000 UTC", "yyyy-mm-ddTHH:MM:SS.sss ttt")
2018-02-06T20:45:00.000 UTC

# February 6 is day number 37
julia> UTCEpoch("2018-037T20:45:00.000", "yyyy-DDDTHH:MM:SS.sss")
2018-02-06T20:45:00.000 UTC
```

When printing `Epochs`, you can format the output in the same way.

```julia
julia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC
julia> AstroTime.format(ep, "dd.mm.yyyy HH:MM ttt")
06.02.2018 20:45 UTC
```

## Working with Epochs and Periods

## Converting Between Time Scales

## Working with Julian Dates

## Converting to Standard Library Types

## Defining Custom Time Scales
