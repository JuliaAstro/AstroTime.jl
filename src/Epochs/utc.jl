const LEAP_J2000 = round.(Int, (LeapSeconds.LS_EPOCHS .- value(J2000_TO_MJD)) * 86400)
const LEAP_TAI = LEAP_J2000 .+ round.(Int, LeapSeconds.LEAP_SECONDS) .- 1
const LEAP_TAI_SET = Set(LEAP_TAI)

"""
    from_utc(str::AbstractString, dateformat::Dates.DateFormat; scale=TAI)
    from_utc(dt::Dates.DateTime; scale=TAI)
    from_utc(year, month, day, hour=0, minute=0, second=0, fraction=0.0; scale=TAI)
    from_utc(year, month, day, hour, minute, seconds; scale=TAI)

Create an `Epoch` in `scale` based on a UTC timestamp, `Dates.DateTime` or date and
time components.

### Examples ###

```jldoctest; setup = :(import Dates)
julia> from_utc(2016, 12, 31, 23, 59, 60, 0.0)
2017-01-01T00:00:36.000 TAI

julia> from_utc(2016, 12, 31, 23, 59, 60.0)
2017-01-01T00:00:36.000 TAI

julia> from_utc("2016-12-31T23:59:60.0")
2017-01-01T00:00:36.000 TAI

julia> from_utc("2016-12-31T23:59:60.0", scale=TDB)
2017-01-01T00:01:08.183 TDB
```
"""
from_utc

"""
    to_utc(ep)
    to_utc(::Type{DateTime}, ep)
    to_utc(::Type{Dates.DateTime}, ep)
    to_utc(::Type{String}, ep, dateformat=Dates.default_format(DateTime))

Create a UTC timestamp or `Dates.DateTime` from an `Epoch` `ep`.

### Examples ###

```jldoctest; setup = :(import Dates)
julia> tai = from_utc(Dates.DateTime(2018, 2, 6, 20, 45, 0, 0))
2018-02-06T20:45:37.000 TAI

julia> to_utc(tai)
"2018-02-06T20:45:00.000"

julia> to_utc(String, tai, Dates.dateformat"yyyy-mm-dd")
"2018-02-06"

julia> to_utc(Dates.DateTime, tai)
2018-02-06T20:45:00
```
"""
to_utc

function from_utc(str::AbstractString,
        dateformat::Dates.DateFormat=Dates.default_format(AstroDates.DateTime);
        scale::TimeScale=TAI)
    dt = AstroDates.DateTime(str, dateformat)
    return from_utc(dt; scale=scale)
end

function from_utc(year::Integer, month::Integer, day::Integer,
    hour::Integer=0, minute::Integer=0, second::Integer=0, fraction=0.0;
    scale::TimeScale=TAI)
    dt = DateTime(year, month, day, hour, minute, second, fraction)
    return from_utc(dt; scale=scale)
end

function from_utc(year::Integer, month::Integer, day::Integer,
    hour::Integer, minute::Integer, seconds;
    scale::TimeScale=TAI)
    dt = DateTime(year, month, day, hour, minute, seconds)
    return from_utc(dt; scale=scale)
end

from_utc(dt::Dates.DateTime; scale::S=TAI) where {S} = from_utc(DateTime(dt); scale=scale)

function from_utc(dt::DateTime; scale::S=TAI) where S
    ep = TAIEpoch(dt)
    idx = searchsortedlast(LEAP_J2000, ep.second)
    if idx == 0
        jd1, jd2 = value.(julian_twopart(ep))
        offset = -offset_utc_tai(jd1, jd2)
    else
        offset = LeapSeconds.LEAP_SECONDS[idx]
        offset = ifelse(second(dt) >= 60, offset - 1, offset)
    end

    return Epoch{S}(TAIEpoch(offset, ep))
end

function to_utc(::Type{DateTime}, ep)
    tai = TAIEpoch(ep)
    idx = searchsortedlast(LEAP_TAI, tai.second)
    if idx == 0
        jd1, jd2 = value.(julian_twopart(tai))
        offset = offset_tai_utc(jd1, jd2)
    else
        offset = LeapSeconds.LEAP_SECONDS[idx]
    end
    dt = DateTime(TAIEpoch(-offset, tai))
    d = Date(dt)
    t = Time(dt)
    if tai.second in LEAP_TAI_SET
        t = Time(hour(t), minute(t), second(t) + 1, fractionofsecond(t))
    end

    return DateTime(d, t)
end

function to_utc(::Type{Dates.DateTime}, ep)
    dt = to_utc(DateTime, ep)
    return Dates.DateTime(dt)
end

function to_utc(::Type{String}, ep, dateformat=Dates.default_format(DateTime))
    dt = to_utc(DateTime, ep)
    return Dates.format(dt, dateformat)
end

to_utc(ep, args...) = to_utc(String, ep, args...)

"""
    now(::Type{Epoch})
    now(::Type{Epoch{S}}) where S<:TimeScale

Get the current date and time as an `Epoch`. The default time scale is TAI.

# Example

```julia-repl
julia> now(Epoch)
2021-04-11T13:20:29.160 TAI

julia> now(TDBEpoch)
2021-04-11T13:21:21.518 TDB
```
"""
function Dates.now(::Type{Epoch{S}}) where S
    return from_utc(Dates.now(Dates.UTC); scale=S())
end

function Dates.now(::Type{Epoch})
    return from_utc(Dates.now(Dates.UTC); scale=TAI)
end
