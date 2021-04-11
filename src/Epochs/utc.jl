const LEAP_J2000 = round.(Int, (LeapSeconds.LS_EPOCHS .- value(J2000_TO_MJD)) * 86400)

function from_utc(str::AbstractString;
        dateformat::Dates.DateFormat=Dates.default_format(AstroDates.DateTime),
        scale::TimeScale=TAI)
    dt = AstroDates.DateTime(str, dateformat)
    return from_utc(dt, scale)
end

function from_utc(dt::DateTime, scale::S=TAI) where S
    ep = TAIEpoch(dt)
    offset = LeapSeconds.LEAP_SECONDS[searchsortedlast(LEAP_J2000, ep.second)]
    offset = ifelse(second(dt) >= 60, offset - 1, offset)

    return Epoch{S}(TAIEpoch(offset, ep))
end

function from_utc(dt::Dates.DateTime, scale::S=TAI) where S
    ep = TAIEpoch(DateTime(dt))
    offset = LeapSeconds.LEAP_SECONDS[searchsortedlast(LEAP_J2000, ep.second)]
    offset = ifelse(second(dt) >= 60, offset - 1, offset)

    return Epoch{S}(TAIEpoch(offset, ep))
end

function to_utc end

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
