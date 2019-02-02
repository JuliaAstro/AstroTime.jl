# Tutorial

This tutorial will walk you through the features and functionality of AstroTime.jl.
Everything in this package revolves around the `Epoch` data type.
`Epochs` are a high-precision, time-scale aware version of the [`DateTime`](https://docs.julialang.org/en/v1.0/stdlib/Dates) type from Julia's standard library.
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

You can shift an `Epoch` in time by adding or subtracting a [`Period`](@ref) to it.

AstroTime.jl provides a convenient way to construct periods by multiplying a value
with a time unit.

```julia
julia> 23 * seconds
23 seconds

julia> 1hour # You can use Julia's factor juxtaposition syntax and omit the `*`
1 hour
```

The following time units are available:

- `seconds`
- `minutes`
- `hours`
- `days`
- `years`
- `centuries`

To shift an `Epoch` forward in time add a `Period` to it.

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

If you subtract two epochs you will receive the time between them as a `Period`.

```julia
julia> ep1 = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC

julia> ep2 = UTCEpoch(2000, 1, 2)
2000-01-02T00:00:00.000 UTC

julia> ep2 - ep1
86400.0 seconds
```

You can also construct a `Period` with a different time unit from
another `Period`.

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

Internally, epochs are defined with respect to Internation Atomic Time (TAI).
Which makes comparisons and other operations across time scales possible.

```julia
# These two epoch correspond to the same point on the TAI time scale
utc = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
tt = TTEpoch(2018, 2, 6, 20, 46, 9.184)

utc == tt
# true
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
dtai = tai_offset(TDB, tt, elong, u, v)

# Use the custom offset for the transformation
tdb = TDBEpoch(dtai, tt)
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
julia> TTEpoch(0.5) # J2000 is the default
2000-01-02T00:00:00.000 TT

julia> TTEpoch(0.5, origin=:j2000)
2000-01-02T00:00:00.000 TT

julia> TTEpoch(2.4515455e6, origin=:julian)
2000-01-02T00:00:00.000 TT

julia> TTEpoch(51545.0, origin=:modified_julian)
2000-01-02T00:00:00.000 TT
```

Some libraries (such as [ERFA](https://github.com/JuliaAstro/ERFA.jl)) expect a two-part Julian date
as input.
You can use `julian_twopart(ep)` in this case.

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
The `@timescale` macro will define the necessary structs and a method for [`tai_offset`](@ref) that
will determine the offset between atomic time and the newly defined time scale.

You need to provide at least three parameters to the macro: The name of the time scale, an epoch type
parameter for the offset function, and the body of the offset function.

Let's start with a simple example and assume that you want to define `GMT` as an alias for `UTC`.

```julia
@timescale GMT ep begin
    tai_offset(UTC, ep)
end
```

Here `GMT` is the name of the new time scale and `ep` is the required epoch parameter that is passed
to the new `tai_offset` method (you could actually call anything you want).
The `begin` block at the end is the body of the new `tai_offset` method.
Since `GMT` has the same offset as `UTC`, you can just return the value from the `tai_offset` method
for `UTC` here.
The resulting method will look like this:

```julia
function AstroTime.Epochs.tai_offset(::typeof(GMT), ep)
    tai_offset(UTC, ep)
end
```

You can now use `GMTEpoch` like any other epoch type, e.g.

```julia
julia> ep = UTCEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 UTC
julia> GMTEpoch(ep)
2000-01-01T00:00:00.000 GMT
```

The `@timescale` macro also accepts additional parameters for offset calculation.
Let's assume that you want to define a time scale that determines the
[Spacecraft Event Time](https://en.wikipedia.org/wiki/Spacecraft_Event_Time) which
takes the one-way light time into account.

You can use the following definition which takes another parameter `distance` into
account which is the distance of the spacecraft from Earth.

```julia
const speed_of_light = 299792458.0 # m/s

@timescale SCET ep distance begin
    # Add the one-way light time to UTC offset
    tai_offset(UTC, ep) + distance / speed_of_light
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

