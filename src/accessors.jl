import Dates

import ..AstroDates: DateTime, year, month, day,
    hour, minute, second, millisecond, secs

export julian, j2000, timescale

timescale(ep::Epoch{S}) where {S} = S

julian(ep::Epoch) = get(days(ep - JULIAN_EPOCH))
j2000(ep::Epoch) = get(days(ep - J2000_EPOCH))

function DateTime(ep::Epoch)
    if !isfinite(ep.offset)
        if ep.offset < 0
            return DateTime(AstroDates.MIN_EPOCH, AstroDates.H00)
        else
            return DateTime(AstroDates.MAX_EPOCH, Time(23, 59, 59.999))
        end
    end

    ts_offset = tai_offset(ep)
    sum = ep.offset + ts_offset
    o′ = sum - ts_offset
    d′ = sum - o′
    Δo = ep.offset - o′
    Δd = ts_offset - d′
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
        time_comp = Time(hour(time_comp), minute(time_comp), secs(time_comp) + leap)
    end

    DateTime(date_comp, time_comp)
end

year(ep::Epoch) = year(DateTime(ep))
month(ep::Epoch) = month(DateTime(ep))
day(ep::Epoch) = day(DateTime(ep))
hour(ep::Epoch) = hour(DateTime(ep))
minute(ep::Epoch) = minute(DateTime(ep))
second(ep::Epoch) = second(DateTime(ep))
millisecond(ep::Epoch) = millisecond(DateTime(ep))

secs(ep::Epoch) = secs(DateTime(ep))

Dates.DateTime(ep::Epoch) = Dates.DateTime(DateTime(ep))
Epoch{S}(dt::Dates.DateTime) where {S} = Epoch{S}(DateTime(dt))

