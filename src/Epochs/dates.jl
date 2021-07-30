function Epoch{S}(date::Date, time::Time, args...) where S
    daysec = round(Int64, (j2000(date) - 0.5) * SECONDS_PER_DAY)
    horsec = round(Int64, hour(time) * SECONDS_PER_HOUR)
    minsec = round(Int64, minute(time) * SECONDS_PER_MINUTE)
    sec = daysec + horsec + minsec + second(time)

    return Epoch{S}(sec, time.fraction)
end

Dates.default_format(::Type{<:Epoch}) = EPOCH_ISO_FORMAT[]

"""
    Epoch(str[, format])

Construct an `Epoch` from a string `str`. Optionally a `format` definition can
be passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
object or as a string. In addition to the character codes supported by `DateFormat` the character
code `D` is supported which is parsed as "day of year" (see the example below) and the character
code `t` which is parsed as the time scale.  The default format is `yyyy-mm-ddTHH:MM:SS.sss ttt`.

**Note:** Please be aware that this constructor requires that the time scale is part of `str`, e.g.
`2018-02-06T00:00 TAI`. Otherwise use an explicit constructor, e.g. `Epoch{TAI}`.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> Epoch("2018-02-06T20:45:00.0 TAI")
2018-02-06T20:45:00.000 TAI

julia> Epoch("2018-037T00:00 TAI", "yyyy-DDDTHH:MM ttt")
2018-02-06T00:00:00.000 TAI
```
"""
Epoch(str::AbstractString, format::Dates.DateFormat=Dates.default_format(Epoch)) = parse(Epoch, str, format)

Epoch(str::AbstractString, format::AbstractString) = Epoch(str, Dates.DateFormat(format))

"""
    Epoch{S}(str[, format]) where S

Construct an `Epoch` with time scale `S` from a string `str`. Optionally a `format` definition can
be passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
object or as a string. In addition to the character codes supported by `DateFormat` the code `D` can
be used which is parsed as "day of year" (see the example below).  The default format is
`yyyy-mm-ddTHH:MM:SS.sss`.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> Epoch{InternationalAtomicTime}("2018-02-06T20:45:00.0")
2018-02-06T20:45:00.000 TAI

julia> Epoch{InternationalAtomicTime}("February 6, 2018", "U d, y")
2018-02-06T00:00:00.000 TAI

julia> Epoch{InternationalAtomicTime}("2018-037T00:00", "yyyy-DDDTHH:MM")
2018-02-06T00:00:00.000 TAI
```
"""
function Epoch{S}(str::AbstractString, format::Dates.DateFormat=Dates.default_format(Epoch{S})) where S
    return Dates.parse(Epoch{S}, str, format)
end

Epoch{S}(str::AbstractString, format::AbstractString) where {S} = Epoch{S}(str, Dates.DateFormat(format))

Epoch{S}(d::Date) where {S} = Epoch{S}(d, AstroDates.H00)

Epoch{S}(dt::DateTime) where {S} = Epoch{S}(Date(dt), Time(dt))
Epoch{S}(dt::Dates.DateTime) where {S} = Epoch{S}(DateTime(dt))

"""
    Epoch{S}(year, month, day, hour=0, minute=0, second=0.0) where S

Construct an `Epoch` with time scale `S` from date and time components.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> Epoch{InternationalAtomicTime}(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 TAI

julia> Epoch{InternationalAtomicTime}(2018, 2, 6)
2018-02-06T00:00:00.000 TAI
```
"""
function Epoch{S}(year::Int, month::Int, day::Int, hour::Int=0,
                  minute::Int=0, second::Float64=0.0, args...) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second), args...)
end

function Epoch{S}(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
                  hour::Int64, minute::Int64, second::Int64, milliseconds::Int64,
                  fractionofsecond::Float64) where S
    dt = AstroDates.DateTime(year, month, day, dayofyear, hour, minute, second,
                             milliseconds, fractionofsecond)
    return Epoch{S}(dt)
end

function Epoch(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
               hour::Int64, minute::Int64, second::Int64, milliseconds::Int64,
               fractionofsecond::Float64, scale::S) where S<:TimeScale
    if scale === TimeScales.NotATimeScale()
        throw(ArgumentError("Could not parse the provided string as an `Epoch`." *
                            " No time scale was provided."))
    end

    return Epoch{S}(year, month, day, dayofyear,
                    hour, minute, second, milliseconds,
                    fractionofsecond)
end

