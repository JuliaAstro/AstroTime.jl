import Dates

import ..AstroDates: DateTime, year, month, day,
    hour, minute, second, millisecond,
    time, date, fractionofday, yearmonthday, dayofyear

export timescale

timescale(ep::Epoch{S}) where {S} = S

function DateTime(ep::Epoch)
    if !isfinite(ep.offset)
        if ep.offset < 0
            return DateTime(AstroDates.MIN_EPOCH, AstroDates.H00)
        else
            return DateTime(AstroDates.MAX_EPOCH, Time(23, 59, 59.999))
        end
    end

    sum = ep.offset + ep.ts_offset
    o′ = sum - ep.ts_offset
    d′ = sum - o′
    Δo = ep.offset - o′
    Δd = ep.ts_offset - d′
    residual = Δo + Δd

    carry = floor(Int64, sum)
    offset2000B = (sum - carry) + residual
    offset2000A = ep.epoch + carry + Int64(43200)
    if offset2000B < 0
        offset2000A -= 1
        offset2000B += 1
    end
    time = offset2000A % Int64(86400)
    if time < 0
        time += Int64(86400)
    end
    date = Int((offset2000A - time) ÷ Int64(86400))

    date_comp = Date(AstroDates.J2000_EPOCH, date)
    time_comp = Time(time, offset2000B)

    if insideleap(ep)
        leap = getleap(ep)
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
    time(ep::Epoch)

Get the time of the epoch `ep`.
"""
time(ep::Epoch) = time(DateTime(ep))

"""
    date(ep::Epoch)

Get the date of the epoch `ep`.
"""
date(ep::Epoch) = date(DateTime(ep))

"""
    fractionofday(ep::Epoch)

Get the time of the day of the epoch `ep` as a fraction.
"""
fractionofday(ep::Epoch) = fractionofday(time(ep))

"""
    Dates.DatetTime(ep::Epoch)

Convert the epoch `ep` to a `Dates.DateTime`.
"""
Dates.DateTime(ep::Epoch) = Dates.DateTime(DateTime(ep))

