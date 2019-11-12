using LeapSeconds

export insideleap, getleap

insideleap(ep::Epoch{S}) where {S} = false
getleap(ep::Epoch{S}) where {S} = 0.0

struct TAIOffset
    date::TAIEpoch{Float64}
    jd::Float64
    start::TAIEpoch{Float64}
    reference::TAIEpoch{Float64}
    leap::Float64
    offset::Float64
    slope_utc::Float64
    slope_tai::Float64
end

@inline function getoffset(t::TAIOffset, ep::Epoch)
    t.slope_tai == 0.0 && return t.offset

    t.offset + value(ep - t.reference) * t.slope_tai
end

@inline function getoffset(to::TAIOffset, d::Date, t::Time)
    days = AstroDates.julian(d) - to.jd
    fraction = secondinday(t)
    to.offset + days * (to.slope_utc * SECONDS_PER_DAY) + fraction * to.slope_utc
end

Base.isless(t::TAIOffset, ep::Epoch) = isless(ep, t.date)
Base.isless(ep::Epoch, t::TAIOffset) = isless(ep, t.date)

Base.isless(t::TAIOffset, jd::Float64) = isless(jd, t.jd)
Base.isless(jd::Float64, t::TAIOffset) = isless(jd, t.jd)

const TAI_OFFSETS = TAIOffset[]

@inline function findoffset(ep)
    idx = searchsortedlast(TAI_OFFSETS, ep)
    idx == 0 && return nothing

    TAI_OFFSETS[idx]
end

const EPOCHS = [LeapSeconds.EPOCHS; LeapSeconds.LS_EPOCHS]
const OFFSETS = [LeapSeconds.OFFSETS; LeapSeconds.LEAP_SECONDS]
const DRIFT_EPOCHS = [LeapSeconds.DRIFT_EPOCHS;
                      zeros(length(LeapSeconds.LS_EPOCHS))]
const DRIFT_RATES = [LeapSeconds.DRIFT_RATES;
                     zeros(length(LeapSeconds.LS_EPOCHS))]

for (ep, offset, dep, rate) in zip(EPOCHS, OFFSETS, DRIFT_EPOCHS, DRIFT_RATES)
    tai = TAIEpoch(ep * days, origin=:modified_julian)
    previous = isempty(TAI_OFFSETS) ? 0.0 : getoffset(last(TAI_OFFSETS), date(tai), AstroDates.H00)
    ref = TAIEpoch(TAIEpoch(dep * days, origin=:modified_julian), offset)
    start = TAIEpoch(tai, previous)
    start_offset = offset + (ep - dep) * rate
    stop = TAIEpoch(tai, start_offset)
    slope = rate / SECONDS_PER_DAY
    leap = value(stop - start) / (1 + slope)
    o = TAIOffset(start, ep + LeapSeconds.MJD_EPOCH,
                  TAIEpoch(start, leap),
                  ref,
                  leap, offset, slope, slope / (1 + slope))
    push!(TAI_OFFSETS, o)
end

@inline function insideleap(ep::UTCEpoch)
    ep = TAIEpoch(ep)
    offset = findoffset(ep)
    offset === nothing && return false

    ep < offset.start
end

@inline function getleap(ep::UTCEpoch)
    ep = TAIEpoch(ep)
    offset = findoffset(ep)
    offset === nothing && return 0.0

    offset.leap
end

