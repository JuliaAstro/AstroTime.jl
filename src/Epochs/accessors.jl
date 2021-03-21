"""
    timescale(ep)

Return the time scale of epoch `ep`.

# Example

```jldoctest; setup = :(using AstroTime)
julia> ep = TTEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TT

julia> timescale(ep)
TT
```
"""
timescale(ep::Epoch) = ep.scale

"""
    DateTime(ep::Epoch)

Convert the epoch `ep` to an `AstroDates.DateTime`.
"""
function DateTime(ep::Epoch)
    if !isfinite(ep.fraction)
        if ep.fraction < 0
            return DateTime(AstroDates.MIN_EPOCH, AstroDates.H00)
        else
            return DateTime(AstroDates.MAX_EPOCH, Time(23, 59, 59.999))
        end
    end

    sec = ep.second + Int64(43200)
    time = sec % Int64(86400)
    if time < 0
        time += Int64(86400)
    end
    date = Int((sec - time) ÷ Int64(86400))

    date_comp = Date(AstroDates.J2000_EPOCH, date)
    time_comp = Time(time, ep.fraction)

    leap = getleap(ep)
    hr = hour(time_comp)
    mn = minute(time_comp)
    leap = ifelse(hr == 23 && mn == 59 && abs(leap) == 1.0, leap, 0.0)
    if !iszero(leap)
        h = hour(time_comp)
        m = minute(time_comp)
        s = second(Float64, time_comp) + leap
        time_comp = Time(h, m, s)
    end

    DateTime(date_comp, time_comp)
end

"""
    year(ep::Epoch)

Get the year of the epoch `ep`.
"""
year(ep::Epoch) = year(DateTime(ep))

"""
    month(ep::Epoch)

Get the month of the epoch `ep`.
"""
month(ep::Epoch) = month(DateTime(ep))

"""
    day(ep::Epoch)

Get the day of the epoch `ep`.
"""
day(ep::Epoch) = day(DateTime(ep))

"""
    yearmonthday(ep::Epoch)

Get the year, month, and day of the epoch `ep` as a tuple.
"""
yearmonthday(ep::Epoch) = yearmonthday(DateTime(ep))

"""
    dayofyear(ep::Epoch)

Get the day of the year of the epoch `ep`.
"""
dayofyear(ep::Epoch) = dayofyear(DateTime(ep))

"""
    hour(ep::Epoch)

Get the hour of the epoch `ep`.
"""
hour(ep::Epoch) = hour(DateTime(ep))

"""
    minute(ep::Epoch)

Get the minute of the epoch `ep`.
"""
minute(ep::Epoch) = minute(DateTime(ep))

"""
    second(type, ep::Epoch)

Get the second of the epoch `ep` as a `type`.
"""
second(typ, ep::Epoch) = second(typ, DateTime(ep))

"""
    second(ep::Epoch) -> Int

Get the second of the epoch `ep` as an `Int`.
"""
second(ep::Epoch) = second(Int, DateTime(ep))

"""
    millisecond(ep::Epoch)

Get the number of milliseconds of the epoch `ep`.
"""
millisecond(ep::Epoch) = millisecond(DateTime(ep))

"""
    Time(ep::Epoch)

Get the `Time` of the epoch `ep`.
"""
Time(ep::Epoch) = Time(DateTime(ep))

"""
    Date(ep::Epoch)

Get the `Date` of the epoch `ep`.
"""
Date(ep::Epoch) = Date(DateTime(ep))

"""
    fractionofday(ep::Epoch)

Get the time of the day of the epoch `ep` as a fraction.
"""
fractionofday(ep::Epoch) = fractionofday(Time(ep))

"""
    Dates.DateTime(ep::Epoch)

Convert the epoch `ep` to a `Dates.DateTime`.
"""
Dates.DateTime(ep::Epoch) = Dates.DateTime(DateTime(ep))

"""
    Dates.Date(ep::Epoch)

Convert the date of epoch `ep` to a `Dates.Date`.
"""
Dates.Date(ep::Epoch) = Dates.Date(Date(ep))

"""
    Dates.Time(ep::Epoch)

Convert the time of epoch `ep` to a `Dates.Time`.
"""
Dates.Time(ep::Epoch) = Dates.Time(Time(ep))

