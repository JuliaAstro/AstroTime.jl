tai_offset(::InternationalAtomicTime, ep) = 0.0
tai_offset(::TerrestrialTime, ep) = OFFSET_TAI_TT
tai_offset(::CoordinatedUniversalTime, ep) = offset_tai_utc(julian(ep))
tai_offset(::UniversalTime, ep) = tai_offset(UTC, ep) + getΔUT1(julian(ep))
tai_offset(::GeocentricCoordinateTime, ep) = tai_offset(TT, ep) + LG_RATE * get(ep - EPOCH_77)
tai_offset(::BarycentricCoordinateTime, ep) = tai_offset(TT, ep) + LB_RATE * get(ep - EPOCH_77)
function tai_offset(::BarycentricDynamicalTime, ep)
    dt = get(days(ep - J2000_EPOCH))
    g = 357.53 + 0.9856003dt
    tai_offset(TT, ep) + 0.001658sind(g) + 0.000014sind(2g)
end

tai_offset(ep::Epoch{S}) where {S} = tai_offset(S, ep)

tai_offset(::InternationalAtomicTime, date, time) = 0.0

function tai_offset(scale, date, time)
    ref = Epoch{TAI}(date, time)
    offset = 0.0
    for _ in 1:8
        offset = -tai_offset(scale, Epoch{TAI}(ref, offset))
    end
    offset
end
