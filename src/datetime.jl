export ScaledDate, ScaledTime, ScaledDateTime, year, month, day

struct ScaledDate{S}
    year::Int
    month::Int
    day::Int
end

function ScaledDate{S}(offset) where S
    calendar = GregorianCalendar()
    if offset < -152384
        if offset > -730122
            calendar = JulianCalendar()
        else
            calendar = ProlepticJulianCalendar()
        end
    end

    year = findyear(calendar, offset)
    dayinyear = offset - last_j2000_dayofyear(calendar, year - 1)

    month = findmonth(dayinyear, isleap(calendar, year))
    day = findday(dayinyear, month, isleap(calendar, year))

    ScaledDate{S}(year, month, day)
end

year(s::ScaledDate) = s.year
month(s::ScaledDate) = s.month
day(s::ScaledDate) = s.day

struct ScaledTime{S}
end

struct ScaledDateTime{S}
    date::ScaledDate{S}
    time::ScaledTime{S}
end

abstract type Calendar end

struct ProlepticJulianCalendar <: Calendar end

struct JulianCalendar <: Calendar end

struct GregorianCalendar <: Calendar end

function findyear(::ProlepticJulianCalendar, j2000day)
    -Int((-Int64(4) * j2000day - Int64(2920488)) ÷ Int64(1461))
end

function last_j2000_dayofyear(::ProlepticJulianCalendar, year)
    365 * year + (year + 1) ÷ 4 - 730123
end

isleap(::ProlepticJulianCalendar, year) = (year % 4) == 0

function findyear(::JulianCalendar, j2000day)
    -Int((-Int64(4) * j2000day - Int64(2921948)) ÷ Int64(1461))
end

function last_j2000_dayofyear(::JulianCalendar, year)
    365 * year + year ÷ 4 - 730122
end

isleap(::JulianCalendar, year) = (year % 4) == 0

function findyear(::GregorianCalendar, j2000day)
    year = Int((Int64(400) * j2000day + Int64(292194288)) ÷ Int64(146097))

    # The previous estimate is one unit too high in some rare cases
    # (240 days in the 400 years gregorian cycle, about 0.16%)
    if j2000day <= last_j2000_dayofyear(GregorianCalendar(), year - 1)
        year -= 1
    end

    year
end

function last_j2000_dayofyear(::GregorianCalendar, year)
    365 * year + year ÷ 4 - year ÷ 100 + year ÷ 400 - 730120
end

function isleap(::GregorianCalendar, year)
    year % 4 == 0 && (year % 400 == 0 || year % 100 != 0)
end

const PREVIOUS_MONTH_END_DAY_LEAP = (
    0,
    31,
    60,
    91,
    121,
    152,
    182,
    213,
    244,
    274,
    305,
    335,
)

const PREVIOUS_MONTH_END_DAY = (
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
)

function findmonth(dayinyear, isleap)
    offset = isleap ? 313 : 323
    dayinyear < 32 ? 1 : (10 * dayinyear + offset) ÷ 306
end

function findday(dayinyear, month, isleap)
    previous_days = isleap ? PREVIOUS_MONTH_END_DAY_LEAP : PREVIOUS_MONTH_END_DAY
    dayinyear - previous_days[month]
end

function finddayinyear(month, day, isleap)
    previous_days = isleap ? PREVIOUS_MONTH_END_DAY_LEAP : PREVIOUS_MONTH_END_DAY
    day + previous_days[month]
end

