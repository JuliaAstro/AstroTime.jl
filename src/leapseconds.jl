import Dates
using LeapSeconds

export insideleap

struct TaiOffset
    start::TAIEpoch{Float64}
    stop::TAIEpoch{Float64}
    leap::Float64
    epoch::Float64
    drift::Float64
    offset::Float64
end

isless(ep::Epoch, t::TaiOffset) = isless(ep, t.start)

const OFFSETS = TaiOffset[]

for (i, (epoch, offset, dep, rate)) in enumerate(zip(LeapSeconds.EPOCHS,
                                                     LeapSeconds.OFFSETS,
                                                     LeapSeconds.DRIFT_EPOCHS,
                                                     LeapSeconds.DRIFT_RATES))
    tai = TAIEpoch(Dates.julian2datetime(epoch))
    previous = i == 1 ? 0.0 : OFFSETS[i-1].offset
    start = TAIEpoch(tai, previous)
    start_offset = offset + (epoch - dep) * rate
    slope = rate / SECONDS_PER_DAY
end

for (epoch, offset) in zip(LeapSeconds.LS_EPOCHS, LeapSeconds.LEAP_SECONDS)
    tai = TAIEpoch(Dates.julian2datetime(epoch))
    push!(OFFSETS,
          TaiOffset(TAIEpoch(tai, offset - 1), TAIEpoch(tai, offset),
                    1.0, 0.0, 0.0, 0.0))
end

const LEAP_STARTS = TAIEpoch{Float64}[]
const LEAP_STOPS = TAIEpoch{Float64}[]

for (epoch, offset) in zip(LeapSeconds.LS_EPOCHS, LeapSeconds.LEAP_SECONDS)
    tai = TAIEpoch(Dates.julian2datetime(epoch))
    push!(LEAP_STARTS, TAIEpoch(tai, offset - 1))
    push!(LEAP_STOPS, TAIEpoch(tai, offset))
end

function insideleap(ep::UTCEpoch)
    idx = searchsortedlast(LEAP_STARTS, ep)
    if idx == 0
        return 0.0
    else
        ep < LEAP_STOPS[idx]
    end
end

insideleap(ep::Epoch{S}) where {S} = false
