const LEAP_J2000 = round.(Int, (LeapSeconds.LS_EPOCHS .- value(J2000_TO_MJD)) * 86400)
const LEAP_TAI = LEAP_J2000 .+ round.(Int, LeapSeconds.LEAP_SECONDS) .- 1
const LEAP_TAI_SET = Set(LEAP_TAI)

function from_utc(str::AbstractString;
        dateformat::Dates.DateFormat=Dates.default_format(AstroDates.DateTime),
        scale::TimeScale=TAI)
    dt = AstroDates.DateTime(str, dateformat)
    return from_utc(dt, scale)
end

function from_utc(year::Integer, month::Integer, day::Integer,
    hour::Integer=0, minute::Integer=0, second::Integer=0, fraction=0.0;
    scale::TimeScale=TAI)
    dt = DateTime(year, month, day, hour, minute, second, fraction)
    return from_utc(dt, scale)
end

function from_utc(year::Integer, month::Integer, day::Integer,
    hour::Integer, minute::Integer, second;
    scale::TimeScale=TAI)
    dt = DateTime(year, month, day, hour, minute, second)
    return from_utc(dt, scale)
end

from_utc(dt::Dates.DateTime, scale::S=TAI) where {S} = from_utc(DateTime(dt), scale)

function from_utc(dt::DateTime, scale::S=TAI) where S
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

```julia
julia> now(Epoch)
2021-04-11T13:20:29.160 TAI

julia> now(TDBEpoch)
2021-04-11T13:21:21.518 TDB
```
"""
function Dates.now(::Type{Epoch{S}}) where S
    return from_utc(Dates.now(Dates.UTC), S())
end

function Dates.now(::Type{Epoch})
    return from_utc(Dates.now(Dates.UTC), TAI)
end
