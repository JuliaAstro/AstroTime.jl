```@meta
DocTestSetup = quote
    using Dates
    using AstroTime
end
```
# Tutorial

This tutorial will walk you through the features and functionality of AstroTime.jl.
Everything in this package revolves around the `Epoch` data type.
`Epochs` are a high-precision, time-scale aware version of the
[`DateTime`](https://docs.julialang.org/en/v1.0/stdlib/Dates) type from Julia's standard
library.
This means that while `DateTime` timestamps are always assumed to be based on Universal
Time (UT), `Epochs` can be created in several pre-defined time scales or custom user-defined
time scales.

## Creating Epochs

You construct `Epoch` instances similar to `DateTime` instances, for example by using date
and time components.
The main difference is that you need to supply the time scale to be used.
Out of the box, the following time scales are defined:

- [`TAI`](@ref): [International Atomic Time](https://en.wikipedia.org/wiki/International_Atomic_Time)
- [`UT1`](@ref): [Universal Time](https://en.wikipedia.org/wiki/Universal_Time#Versions)[^1]
- [`TT`](@ref): [Terrestrial Time](https://en.wikipedia.org/wiki/Terrestrial_Time)
- [`TCG`](@ref): [Geocentric Coordinate Time](https://en.wikipedia.org/wiki/Geocentric_Coordinate_Time)
- [`TCB`](@ref): [Barycentric Coordinate Time](https://en.wikipedia.org/wiki/Barycentric_Coordinate_Time)
- [`TDB`](@ref): [Barycentric Dynamical Time](https://en.wikipedia.org/wiki/Barycentric_Dynamical_Time)

Conspicuously missing from this list is [Coordinated Universal Time (UTC)](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).
While AstroTime.jl does support UTC, it requires special treatment due to the discontinuities
in the time scale from the introduction of leap seconds.
See [UTC and Leap Seconds](@ref) for more details.

[^1]:
    Transformations to and from UT1 depend on the measured quantity ΔUT1 which is
    published in [IERS](https://www.iers.org) tables on a weekly basis. AstroTime.jl can
    automatically fetch these tables by running [`AstroTime.update()`](@ref).
    If you work with [`UT1`](@ref), you need to run this function periodically.

```julia
using AstroTime

ep = Epoch{InternationalAtomicTime}(2018, 2, 6, 20, 45, 0.0)

# The following shorthand syntax also works
ep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)

# Or in another time scale
ep = TTEpoch(2018, 2, 6, 20, 45, 0.0)

# Or use UTC with leap second handling
ep = from_utc(2018, 2, 6, 20, 45, 0.0)
```

You can also parse an `Epoch` from a string. AstroTime.jl uses the
[`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
type and specification language from the `Dates` module from Julia's standard
library. For example:

```jldoctest
julia> ep = TAIEpoch("2018-02-06T20:45:00.000", "yyyy-mm-ddTHH:MM:SS.fff")
2018-02-06T20:45:00.000 TAI
```

The format string above `yyyy-mm-ddTHH:MM:SS.fff` is also the default format.
Thus, this also works:
```jldoctest
julia> ep = TAIEpoch("2018-02-06T20:45:00.000")
2018-02-06T20:45:00.000 TAI
```

You can also reuse the format string
```jldoctest
julia> import Dates

julia> df = Dates.dateformat"dd.mm.yyyy HH:MM"
dateformat"dd.mm.yyyy HH:MM"

julia> utc = from_utc("06.02.2018 20:45", df)
2018-02-06T20:45:37.000 TAI

julia> tai = TAIEpoch("06.02.2018 20:45", df)
2018-02-06T20:45:00.000 TAI
```

There are three additional character codes supported.

- `f`: This character code is parsed as the fraction of the current second and
       supports an arbitrary number of decimal places.
- `t`: This character code is parsed as the time scale.
- `D`: This character code is parsed as the day number within a year.

The time scale can be omitted from the constructor in the first example because
it is already defined in the input string
```jldoctest
julia> Epoch("2018-02-06T20:45:00.000 TAI", "yyyy-mm-ddTHH:MM:SS.fff ttt")
2018-02-06T20:45:00.000 TAI

julia> TAIEpoch("2018-037T20:45:00.000", "yyyy-DDDTHH:MM:SS.fff") # February 6 is the 37th day of the year
2018-02-06T20:45:00.000 TAI
```

When printing `Epochs`, you can format the output in the same way.

```jldoctest
julia> ep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 TAI

julia> AstroTime.format(ep, "dd.mm.yyyy HH:MM ttt")
"06.02.2018 20:45 TAI"
```

## Working with Epochs and Periods

You can shift an `Epoch` in time by adding or subtracting an [`AstroPeriod`](@ref) to it.

AstroTime.jl provides a convenient way to construct periods by multiplying a value
with a time unit.

```jldoctest
julia> 23 * seconds
23.0 seconds

julia> 1hours # You can use Julia's factor juxtaposition syntax and omit the `*`
1.0 hours
```

The following time units are available:

- `seconds`
- `minutes`
- `hours`
- `days`
- `years`
- `centuries`

To shift an `Epoch` forward in time add an `AstroPeriod` to it.

```jldoctest
julia> ep = TAIEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TAI

julia> ep + 1days
2000-01-02T00:00:00.000 TAI
```

Or subtract it to shift the `Epoch` backwards.

```jldoctest
julia> ep = TAIEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TAI

julia> ep - 1days
1999-12-31T00:00:00.000 TAI
```

If you subtract two epochs you will receive the time between them as an `AstroPeriod`.

```jldoctest
julia> ep1 = TAIEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TAI

julia> ep2 = TAIEpoch(2000, 1, 2)
2000-01-02T00:00:00.000 TAI

julia> ep2 - ep1
86400.0 seconds
```

You can also construct an `AstroPeriod` with a different time unit from
another `AstroPeriod`.

```jldoctest
julia> dt = 86400.0seconds
86400.0 seconds

julia> days(dt)
1.0 days
```

To access the raw value of a period, i.e. without a unit, use the `value` function.

```jldoctest
julia> dt = 86400.0seconds
86400.0 seconds

julia> value(days(dt))
1.0
```

## Ranges

You can also construct ranges of `Epoch`s. The default step size one second.

```jldoctest
julia> TAIEpoch(2021, 7, 30, 17, 34, 30.0):TAIEpoch(2021, 7, 30, 17, 34, 31.0)
2021-07-30T17:34:30.000 TAI:1.0 seconds:2021-07-30T17:34:31.000 TAI
```

Or you can adjust the step size with any of the units supported.

```jldoctest
julia> collect(TAIEpoch(2000, 1, 1):1days:TAIEpoch(2000, 1, 5))
5-element Vector{TAIEpoch{Float64}}:
 2000-01-01T00:00:00.000 TAI
 2000-01-02T00:00:00.000 TAI
 2000-01-03T00:00:00.000 TAI
 2000-01-04T00:00:00.000 TAI
 2000-01-05T00:00:00.000 TAI
```

## Converting Between Time Scales

You convert an `Epoch` to another time scale by constructing a new `Epoch` with
the target time scale from it.

```jldoctest
julia> tai = TAIEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 TAI

julia> tt = TTEpoch(tai) # Convert to TT
2018-02-06T20:45:32.184 TT
```

### UTC and Leap Seconds

UTC is the primary civil time standard and aims to provide a time scale based on TAI and
uniform SI seconds that is at the same time aligned with UT1 which is based on solar time
and governed by the rotation of the Earth. The problem is that Earth's rotation speed is
much more irregular compared to atomic clocks which define the SI second.
Over the past decades, Earth's rotation has continuously slowed and thus TAI has
been running ahead of UT1.

Leap seconds are inserted into the UTC time scale to keep it within 0.9 seconds of UT1.
This introduces ambiguities in AstroTime.jl's data model (see [#50](@ref)).
As a consequence, `UTCEpoch`s are not supported.
Nevertheless, UTC is supported as an I/O format for timestamps through the
[`from_utc`](@ref) and [`to_utc`](@ref) functions.

The last leap second was introduced at the end of December 31, 2016. You can create
a `TAIEpoch` (or other `Epoch`s) from a UTC date with proper leap second handling:

```jldoctest
julia> from_utc(2016, 12, 31, 23, 59, 60.0)
2017-01-01T00:00:36.000 TAI

julia> from_utc("2016-12-31T23:59:60.0")
2017-01-01T00:00:36.000 TAI

julia> from_utc("2016-12-31T23:59:60.0", scale=TDB)
2017-01-01T00:01:08.183 TDB
```

You can also use `Dates.DateTime` but note that you cannot represent a leap second
date with it.

```jldoctest tai2utc
julia> tai = from_utc(Dates.DateTime(2018, 2, 6, 20, 45, 0, 0))
2018-02-06T20:45:37.000 TAI
```

And go back to UTC:

```jldoctest tai2utc
julia> to_utc(tai)
"2018-02-06T20:45:00.000"

julia> to_utc(String, tai, Dates.dateformat"yyyy-mm-dd")
"2018-02-06"

julia> to_utc(Dates.DateTime, tai)
2018-02-06T20:45:00
```

### High-Precision Conversions and Custom Offsets

Some time scale transformations depend on measured quantities which cannot be
accurately predicted (e.g. UT1) or there are different algorithms which offer
variable levels of accuracy.
For the former, AstroTime.jl can download the required data automatically from the internet.
You need to run `AstroTime.update()` periodically (weekly) to keep this data up-to-date.
For the latter, AstroTime.jl will use the alogrithm which provides the best trade-off
between accuracy and performance for most applications.

If you cannot use the internet or want to use a different data source, e.g. a
time ephemeris, to obtain the offset between time scales, you can use the
following constructor for epochs which overrides the default algorithms.

```julia
# AstroTime.jl provides a higher precision TDB<->TT transformation that
# is dependent on the position of the observer on Earth

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

```jldoctest
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

```jldoctest
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

Some libraries (such as [ERFA](https://github.com/JuliaAstro/ERFA.jl)) expect a
two-part Julian date as input. You can use [`julian_twopart(ep)`](@ref) in this case.
If you need more control over the output, have a look at the [`julian_period`](@ref) function.

!!! warning
    You should not convert an `Epoch` to a Julian date to do arithmetic because
    this will result in a loss of accuracy.

## Converting to Standard Library Types

`Epoch` instances satisfy the `AbstractDateTime` interface specified in the
[Dates](https://docs.julialang.org/en/v1.0/stdlib/Dates) module of Julia's standard library.
Thus, you should be able to pass them to other libraries which expect a standard `DateTime`.
Please open an issue on [the issue tracker](https://github.com/JuliaAstro/AstroTime.jl/issues)
if you encounter any problems with this.

It is nevertheless possible to convert an `Epoch` to a `DateTime` if it should become necessary.
Please note that the time scale information will be lost in the process.

```jldoctest
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> import Dates; Dates.DateTime(ep)
2000-01-01T00:00:00
```

## Defining Custom Time Scales

AstroTime.jl enables you to create your own first-class time scales via the [`@timescale`](@ref) macro.
The macro will define the necessary structs and register the new time scale.

Let's start with a simple example and assume that you want to define `EphemerisTime` as an alias for `TDB`.
You need to provide the name of the time scale and optionally a "parent" time scale to which it is linked.

```jldoctest custom_timescale
julia> @timescale EphemerisTime TDB
```

At this point, you can already use the new time scale to create epochs.

```jldoctest custom_timescale
julia> EphemerisTime
EphemerisTime

julia> typeof(EphemerisTime)
EphemerisTimeScale

julia> et = EphemerisTimeEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 EphemerisTime
```

Conversion to other `Epoch` types will not yet work for the newly created time
because you need to provide the necessary methods for `getoffset`.
If you are unsure which methods are needed, you can try to transform the epoch
and the resulting error message will provide a hint.

```jldoctest custom_timescale
julia> TDBEpoch(et)
ERROR: No conversion 'EphemerisTime->TDB' available. If one of these is a custom time scale, you may need to define `AstroTime.Epochs.getoffset(::EphemerisTimeScale, ::BarycentricDynamicalTime, second, fraction, args...)`.
[...]
```

To enable transformations between `EphemerisTime` and `TDB` in both directions you need
to define the following methods.
Since `EphemerisTime` and `TDB` are identical, the offset between them is zero.

```jldoctest custom_timescale
julia> function AstroTime.Epochs.getoffset(
               ::EphemerisTimeScale, ::BarycentricDynamicalTime,
               second, fraction)
           return 0.0
       end

julia> function AstroTime.Epochs.getoffset(
               ::BarycentricDynamicalTime, ::EphemerisTimeScale,
               second, fraction)
           return 0.0
       end
```

You can now use `EphemerisTimeEpoch` like any other epoch type, e.g.

```jldoctest custom_timescale
julia> ep = TDBEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TDB

julia> EphemerisTimeEpoch(ep)
2000-01-01T00:00:00.000 EphemerisTime
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

```@example scet
using AstroTime # hide
const speed_of_light = 299792458.0 # m/s

@timescale SCET TAI

function AstroTime.Epochs.getoffset(::SCETScale, ::InternationalAtomicTime,
                                    second, fraction, distance)
    return distance / speed_of_light
end

function AstroTime.Epochs.getoffset(::InternationalAtomicTime, ::SCETScale,
                                    second, fraction, distance)
    return -distance / speed_of_light
end
nothing # hide
```

If you want to convert another epoch to `SCET`, you now need to pass this
additional parameter.
For example, for a spacecraft that is one astronomical unit away from Earth:

```@repl scet
astronomical_unit = 149597870700.0 # m
ep = TAIEpoch(2000, 1, 1)
SCETEpoch(ep, astronomical_unit)
```

!!! note
    At this time, custom epochs with additional parameters cannot be parsed from strings.

You can also introduce time scales that are disjoint from AstroTime.jl's
default graph of time scales by defining a time scale without a parent.

```jldoctest
julia> @timescale Disjoint

julia> typeof(Disjoint)
DisjointScale
```

By defining additional time scales connected to this scale and the appropriate
`getoffset` methods, you can create your own graph of time scales that is
completely independent of the defaults provided by the library.
