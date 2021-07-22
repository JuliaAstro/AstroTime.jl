# Tutorial

This tutorial will walk you through the features and functionality of AstroTime.jl.
Everything in this package revolves around the `Epoch` data type.
`Epochs` are a high-precision, time-scale aware version of the [`DateTime`](https://docs.julialang.org/en/v1.0/stdlib/Dates) type from Julia's standard library.
This means that while `DateTime` timestamps are always assumed to be based on Universal Time (UT), `Epochs` can be created in several pre-defined time scales or custom user-defined time scales.

## Creating Epochs

You construct `Epoch` instances similar to `DateTime` instance, for example by using date and time components.
The main difference is that you need to supply the time scale to be used.
Out of the box, the following time scales are defined:

- [`TAI`](@ref): [International Atomic Time](https://en.wikipedia.org/wiki/International_Atomic_Time)
- [`UT1`](@ref): [Universal Time](https://en.wikipedia.org/wiki/Universal_Time#Versions)[^1]
- [`TT`](@ref): [Terrestrial Time](https://en.wikipedia.org/wiki/Terrestrial_Time)
- [`TCG`](@ref): [Geocentric Coordinate Time](https://en.wikipedia.org/wiki/Geocentric_Coordinate_Time)
- [`TCB`](@ref): [Barycentric Coordinate Time](https://en.wikipedia.org/wiki/Barycentric_Coordinate_Time)
- [`TDB`](@ref): [Barycentric Dynamical Time](https://en.wikipedia.org/wiki/Barycentric_Dynamical_Time)

[^1]:
    Transformations to and from UT1 depend on the measured quantity ΔUT1 which is
    published in [IERS](https://www.iers.org) tables on a weekly basis. AstroTime.jl can
    automatically fetch these tables by running [`AstroTime.update()`](@ref).
    If you work with [`UT1`](@ref), you need to run this function periodically.

```julia
using AstroTime

ep = Epoch{CoordinatedUniversalTime}(2018, 2, 6, 20, 45, 0.0)

# The following shorthand syntax also works
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

# February 6 is the 37th day of the year
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

You can shift an `Epoch` in time by adding or subtracting an [`AstroPeriod`](@ref) to it.

AstroTime.jl provides a convenient way to construct periods by multiplying a value
with a time unit.

```julia
julia> 23 * seconds
23 seconds

julia> 1hours # You can use Julia's factor juxtaposition syntax and omit the `*`
1 hour
```

The following time units are available:

- `seconds`
- `minutes`
- `hours`
- `days`
- `years`
- `centuries`

To shift an `Epoch` forward in time add an `AstroPeriod` to it.

```julia
julia> ep = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> ep + 1days
2000-01-02T00:00:00.000 UTC
```

Or subtract it to shift the `Epoch` backwards.

```julia
julia> ep = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> ep - 1days
1999-12-31T00:00:00.000 UTC
```

If you subtract two epochs you will receive the time between them as an `AstroPeriod`.

```julia
julia> ep1 = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> ep2 = UTCEpoch(2000, 1, 2)
2000-01-02T00:00:00.000 UTC

julia> ep2 - ep1
86400.0 seconds
```

You can also construct an `AstroPeriod` with a different time unit from
another `AstroPeriod`.

```julia
julia> dt = 86400.0seconds
86400.0 seconds

julia> days(dt)
1.0 days
```

To access the raw value of a period, i.e. without a unit, use the `value` function.

```julia
julia> dt = 86400.0seconds
86400.0 seconds

julia> value(days(dt))
1.0
```

## Converting Between Time Scales

You convert an `Epoch` to another time scale by constructing a new `Epoch` with the
target time scale from it.

```julia
julia> utc = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC

julia> tai = TAIEpoch(utc) # Convert to TAI
2018-02-06T20:45:37.000 TAI
```

### High-Precision Conversions and Custom Offsets

Some time scale transformations depend on measured quantities which cannot be accurately
predicted (e.g. UTC to UT1) or there are different algortihms which offer variable levels
of accuracy.
For the former, AstroTime.jl can download the required data automatically from the internet.
You need to run `AstroTime.update()` periodically (weekly) to keep this data up-to-date.
For the latter, AstroTime.jl will use the alogrithm which provides the best trade-off between
accuracy and performance for most applications.

If you cannot use the internet or want to use a different data source, e.g. a time ephemeris,
to obtain the offset between time scales, you can use the following constructor for epochs
which overrides the default algorithms.

```julia
# AstroTime.jl provides a higher precision TDB<->TT transformation that is dependent on
# the position of the observer on Earth

tt = TTEpoch(2018, 2, 6, 20, 46, 9.184)
dt = getoffset(tt, TDB, elong, u, v)

# Use the custom offset for the transformation
tdb = TDBEpoch(dt, tt)
```

## Working with Julian Dates

Epochs can be converted to and from [Julian Dates](https://en.wikipedia.org/wiki/Julian_day).
Three different base epochs are supported:

- The (default) J2000 date which starts at January 1, 2000, at 12h,
- the standard Julian date which starts at January 1, 4712BC, at 12h,
- and the Modified Julian date which starts at November 17, 1858, at midnight.

You can get Julian date in days from an `Epoch` like this:

```julia
julia> ep = TTEpoch(2000,1,2)
2000-01-02T00:00:00.000 TT

julia> j2000(ep)
0.5 days

julia> julian(ep)
2.4515455e6 days

julia> modified_julian(ep)
51545.0 days
```

To construct an `Epoch` from a Julian date do this:

```julia
julia> TTEpoch(0.5days) # J2000 is the default
2000-01-02T00:00:00.000 TT

julia> TTEpoch(0.5days, origin=:j2000)
2000-01-02T00:00:00.000 TT

julia> TTEpoch(2.4515455e6days, origin=:julian)
2000-01-02T00:00:00.000 TT

julia> TTEpoch(51545.0days, origin=:modified_julian)
2000-01-02T00:00:00.000 TT

julia> TTEpoch(86400.0seconds, origin=:j2000)
2000-01-02T12:00:00.000 TT
```

Some libraries (such as [ERFA](https://github.com/JuliaAstro/ERFA.jl)) expect a two-part Julian date
as input.
You can use [`julian_twopart(ep)`](@ref) in this case.
If you need more control over the output, have a look at the [`julian_period`](@ref) function.

!!! warning
    You should not convert an `Epoch` to a Julian date to do arithmetic because this will result in a loss
    of accuracy.

## Converting to Standard Library Types

`Epoch` instances satisfy the `AbstractDateTime` interface specified in the
[Dates](https://docs.julialang.org/en/v1.0/stdlib/Dates) module of Julia's standard library. 
Thus, you should be able to pass them to other libraries which expect a standard `DateTime`.
Please open an issue on [the issue tracker](https://github.com/JuliaAstro/AstroTime.jl/issues)
if you encounter any problems with this.

It is nevertheless possible to convert an `Epoch` to a `DateTime` if it should become necessary.
Please note that the time scale information will be lost in the process.

```julia
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> import Dates; Dates.DateTime(ep)
2000-01-01T00:00:00
```

## Defining Custom Time Scales

AstroTime.jl enables you to create your own first-class time scales via the [`@timescale`](@ref) macro.
The macro will define the necessary structs and register the new time scale.

Let's start with a simple example and assume that you want to define `GMT` as an alias for `UTC`.
You need to provide the name of the time scale and optionally a "parent" time scale to which it is linked.

```julia
@timescale GMT UTC
```

At this point, you can already use the new time scale to create epochs.

```julia
julia> GMT
GMT

julia> typeof(GMT)
GMTScale

julia> gmt = GMTEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 GMT
```

Conversion to other `Epoch` types will not yet work for the newly created time
because you need to provide the necessary methods for `getoffset`.
If you are unsure which methods are needed, you can try to transform the epoch
and the resulting error message will provide a hint.

```julia
julia> UTCEpoch(gmt)
ERROR: No conversion 'GMT->UTC' available. If one of these is a custom time scale,
you may need to define `AstroTime.Epochs.getoffset(::GMTScale, ::CoordinatedUniversalTime,
second, fraction, args...)`.
```

To enable transformations between `GMT` and `UTC` in both directions you need
to define the following methods.
Since `GMT` is the same offset as `UTC`, these can just return zero.

```julia
AstroTime.Epochs.getoffset(::GMTType, ::CoordinatedUniversalTime, second, fraction) = 0.0
AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::GMTType, second, fraction) = 0.0
```

You can now use `GMTEpoch` like any other epoch type, e.g.

```julia
julia> ep = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> GMTEpoch(ep)
2000-01-01T00:00:00.000 GMT
```

For a more complex example, let's reimplement the Geocentric Coordinate
Time (TCG) scale.
It is a linear transformation from Terrestrial Time (TT), i.e. the
transformation is dependent on the point in time in the current time scale
(the `second` and `fraction` arguments to `getoffset`).

```julia
@timescale CustomTCG TT

# The reference point
const JD77_SEC = -7.25803167816e8
# The linear rate of change
const LG_RATE = 6.969290134e-10

function getoffset(::CustomTCGScale, ::TerrestrialTime, second, fraction)
    # `second` is the number of full seconds since 2000-01-01
    # `fraction` is the fraction of the current second
    dt = second - JD77_SEC + fraction
    return -LG_RATE * dt
end

function getoffset(::TerrestrialTime, ::CustomTCGScale, second, fraction)
    # The inverse rate for the backwards transformation
    rate = LG_RATE / (1.0 - LG_RATE)
    dt = second - JD77_SEC + fraction
    return rate * dt
end

```

Let's assume that you want to define a time scale that determines the
[Spacecraft Event Time](https://en.wikipedia.org/wiki/Spacecraft_Event_Time)
which takes the one-way light time into account.

You could use the following definitions adding the `distance` parameter
which is the distance of the spacecraft from Earth.

```julia
const speed_of_light = 299792458.0 # m/s

@timescale SCET UTC

function AstroTime.Epochs.getoffset(::SCETType, ::CoordinatedUniversalTime,
                                    second, fraction, distance)
    return distance / speed_of_light
end
function AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::SCETType,
                                    second, fraction, distance)
    return -distance / speed_of_light
end
```

If you want to convert another epoch to `SCET`, you now need to pass this
additional parameter.
For example, for a spacecraft that is one astronomical unit away from Earth:

```julia
julia> astronomical_unit = 149597870700.0 # m
149597870700.0

julia> ep = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> SCETEpoch(ep, astronomical_unit)
2000-01-01T00:08:19.005 SCET
```

!!! note
    At this time, custom epochs with additional parameters cannot be parsed from strings.

You can also introduce time scales that are disjoint from AstroTime.jl's
default graph of time scales by defining a time scale without a parent.

```julia
julia> @timescale Disjoint

julia> typeof(Disjoint) = DisjointScale
```

By defining additional time scales connected to this scale and the appropriate
`getoffset` methods, you can create your own graph of time scales that is
completely independent of the defaults provided by the library.

