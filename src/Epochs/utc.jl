const LEAP_J2000 = round.(Int, (LeapSeconds.LS_EPOCHS .- value(J2000_TO_MJD)) * 86400)

function from_utc(str::AbstractString;
        dateformat::Dates.DateFormat=Dates.default_format(AstroDates.DateTime),
        scale::TimeScale=TAI)
    dt = AstroDates.DateTime(str, dateformat)
    return from_utc(dt, scale)
end

function from_utc(dt::AstroDates.DateTime, scale::S=TAI) where S
    ep = TAIEpoch(dt)
    offset = LeapSeconds.LEAP_SECONDS[searchsortedlast(LEAP_J2000, ep.second)]
    offset = ifelse(second(dt) >= 60, offset - 1, offset)

    return Epoch{S}(TAIEpoch(offset, ep))
end

function to_utc end

