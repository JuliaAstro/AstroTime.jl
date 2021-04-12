module AstroDates

import Dates

import ..ASTRO_ISO_FORMAT

using Dates: year, month, day, hour, minute, second, millisecond, microsecond, nanosecond
using Dates: dayofyear

const J2000 = 2.4515445e6

function findyear(calendar, j2000day)
    j2kday = Int64(j2000day)
    if calendar == :proleptic_julian
        return -((-4 * j2kday - 2920488) ÷ 1461)
    elseif calendar == :julian
        return -((-4 * j2kday - 2921948) ÷ 1461)
    end

    year = (400 * j2kday + 292194288) ÷ 146097

    # The previous estimate is one unit too high in some rare cases
    # (240 days in the 400 years gregorian cycle, about 0.16%)
    if j2kday <= last_j2000_dayofyear(:gregorian, year - 1)
        year -= 1
    end

    return year
end

function last_j2000_dayofyear(calendar, year)
    if calendar == :proleptic_julian
        return 365 * year + (year + 1) ÷ 4 - 730123
    elseif calendar == :julian
        return 365 * year + year ÷ 4 - 730122
    end

    return 365 * year + year ÷ 4 - year ÷ 100 + year ÷ 400 - 730120
end

function isleap(calendar, year)
    if calendar in (:proleptic_julian, :julian)
        return year % 4 == 0
    end

    return year % 4 == 0 && (year % 400 == 0 || year % 100 != 0)
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
    offset = ifelse(isleap, 313, 323)
    return ifelse(dayinyear < 32, 1, (10 * dayinyear + offset) ÷ 306)
end

function findday(dayinyear, month, isleap)
    (!isleap && dayinyear > 365) && throw(ArgumentError("Day of year cannot be 366 for a non-leap year."))
    previous_days = ifelse(isleap, PREVIOUS_MONTH_END_DAY_LEAP, PREVIOUS_MONTH_END_DAY)
    return dayinyear - previous_days[month]
end

function finddayinyear(month, day, isleap)
    previous_days = ifelse(isleap, PREVIOUS_MONTH_END_DAY_LEAP, PREVIOUS_MONTH_END_DAY)
    return day + previous_days[month]
end

function getcalendar(year, month, day)
    if year < 1583
        if year < 1
            return :proleptic_julian
        elseif year < 1582 || month < 10 || (month < 11 && day < 5)
            return :julian
        end
    end
    return :gregorian
end

struct Date
    calendar::Symbol
    year::Int
    month::Int
    day::Int
end

function Date(offset::Integer)
    calendar = :gregorian
    if offset < -152384
        if offset > -730122
            calendar = :julian
        else
            calendar = :proleptic_julian
        end
    end

    year = findyear(calendar, offset)
    dayinyear = offset - last_j2000_dayofyear(calendar, year - 1)

    month = findmonth(dayinyear, isleap(calendar, year))
    day = findday(dayinyear, month, isleap(calendar, year))

    return Date(calendar, year, month, day)
end

Date(epoch::Date, offset::Int) = Date(j2000(epoch) + offset)

function Date(year, month, day)
    if month < 1 || month > 12
        throw(ArgumentError("Invalid month number: $month"))
    end

    check = Date(j2000(year, month, day))
    if check.year != year || check.month != month || check.day != day
        throw(ArgumentError("Invalid date."))
    end
    return Date(calendar(check), year, month, day)
end

function Date(year, dayinyear)
    calendar = :gregorian
    if year < 1583
        if year < 1
            calendar = :proleptic_julian
        else
            calendar = :julian
        end
    end
    leap = isleap(calendar, year)
    month = findmonth(dayinyear, leap)
    day = findday(dayinyear, month, leap)

    return Date(calendar, year, month, day)
end

Dates.year(s::Date) = s.year
Dates.month(s::Date) = s.month
Dates.day(s::Date) = s.day
calendar(s::Date) = s.calendar

Base.show(io::IO, d::Date) = print(io,
                                   year(d), "-",
                                   lpad(month(d), 2, '0'), "-",
                                   lpad(day(d), 2, '0'))

Date(d::Dates.Date) = Date(Dates.year(d), Dates.month(d), Dates.day(d))
Dates.Date(d::Date) = Dates.Date(year(d), month(d), day(d))

function j2000(calendar, year, month, day)
    d1 = last_j2000_dayofyear(calendar, year - 1)
    d2 = finddayinyear(month, day, isleap(calendar, year))
    return d1 + d2
end

function j2000(year, month, day)
    calendar = getcalendar(year, month, day)
    return j2000(calendar, year, month, day)
end

j2000(d::Date) = j2000(calendar(d), year(d), month(d), day(d))

julian(d::Date) = j2000(d) + J2000

const JULIAN_EPOCH = Date(-4712,  1,  1)
const MODIFIED_JULIAN_EPOCH = Date(1858, 11, 17)
const FIFTIES_EPOCH = Date(1950, 1, 1)
const CCSDS_EPOCH = Date(1958, 1, 1)
const GALILEO_EPOCH = Date(1999, 8, 22)
const GPS_EPOCH = Date(1980, 1, 6)
const J2000_EPOCH = Date(2000, 1, 1)
const MIN_EPOCH = Date(typemin(Int32))
const MAX_EPOCH = Date(typemax(Int32))
const UNIX_EPOCH = Date(1970, 1, 1)

struct Time{T}
    hour::Int
    minute::Int
    second::Int
    fraction::T

    function Time(hour, minute, second, fraction::T) where T
        if hour < 0 || hour > 23
            throw(ArgumentError("`hour` must be an integer between 0 and 23."))
        elseif minute < 0 || minute > 59
            throw(ArgumentError("`minute` must be an integer between 0 and 59."))
        elseif second < 0 || second >= 61
            throw(ArgumentError("`second` must be an integer between 0 and 61."))
        elseif fraction < 0 || fraction > 1
            throw(ArgumentError("`fraction` must be a floating point number between 0 and 1."))
        end

        return new{T}(hour, minute, second, fraction)
    end
end

function Time(hour, minute, second::T) where T
    sec, frac = divrem(rationalize(second), 1)
    return Time(hour, minute, sec, T(frac))
end

function Time(secondinday, fraction)
    # range check
    if secondinday < 0 || secondinday > 86400
        throw(ArgumentError("Seconds are out of range"))
    end

    # extract the time components
    hour = secondinday ÷ 3600
    secondinday -= 3600 * hour
    minute = secondinday ÷ 60
    secondinday -= 60 * minute

    return Time(hour, minute, secondinday, fraction)
end

function Base.isapprox(a::Time, b::Time; kwargs...)
    return a.hour == b.hour &&
        a.minute == b.minute &&
        a.second == b.second &&
        isapprox(a.fraction, b.fraction; kwargs...)
end

Dates.hour(t::Time) = t.hour
Dates.minute(t::Time) = t.minute
Dates.second(::Type{Float64}, t::Time) = t.fraction + t.second
Dates.second(::Type{Int}, t::Time) = t.second
Dates.second(t::Time) = second(Int, t)
Dates.millisecond(t::Time) = trunc(Int, 1e3 * t.fraction)
Dates.microsecond(t::Time) = trunc(Int, 1e3 * (1e3 * t.fraction - millisecond(t)))
Dates.nanosecond(t::Time) = trunc(Int, 1e3 * (1e3 * (1e3 * t.fraction - millisecond(t)) - microsecond(t)))

fractionofday(t::Time) = (t.fraction + t.second) / 86400 + t.minute / 1440 + t.hour / 24
fractionofsecond(t::Time) = t.fraction

secondinday(t::Time) = t.fraction + t.second + 60 * t.minute + 3600 * t.hour

Time(t::Dates.Time) = Time(Dates.hour(t),
                           Dates.minute(t),
                           Dates.second(t),
                           1e-9 * Dates.nanosecond(t) +
                           1e-6 * Dates.microsecond(t) +
                           1e-3 * Dates.millisecond(t))
Dates.Time(t::Time) = Dates.Time(hour(t), minute(t), second(t), millisecond(t), microsecond(t), nanosecond(t))

const H00 = Time(0, 0, 0, 0.0)
const H12 = Time(12, 0, 0, 0.0)

function Base.show(io::IO, t::Time)
    h = lpad(hour(t), 2, '0')
    m = lpad(minute(t), 2, '0')
    s = lpad(second(Int, t), 2, '0')
    f = lpad(millisecond(t), 3, '0')
    return print(io, h, ":", m, ":", s, ".", f)
end

struct DateTime{T} <: Dates.AbstractDateTime
    date::Date
    time::Time{T}
end

Dates.default_format(::Type{DateTime}) = ASTRO_ISO_FORMAT[]

function Base.:(==)(a::DateTime, b::DateTime)
    return a.date == b.date && a.time == b.time
end

function Base.isapprox(a::DateTime, b::DateTime; kwargs...)
    return a.date == b.date && isapprox(a.time, b.time; kwargs...)
end

Date(dt::DateTime) = dt.date
Time(dt::DateTime) = dt.time

Base.show(io::IO, dt::DateTime) = print(io, Date(dt), "T", Time(dt))

function DateTime(str::AbstractString, df::Dates.DateFormat=Dates.default_format(DateTime))
    return Dates.parse(DateTime{Float64}, str, df)
end

function DateTime(year::Integer, month::Integer, day::Integer,
                  hour::Integer=0, minute::Integer=0, second::Integer=0, fraction=0.0)
    return DateTime(Date(year, month, day), Time(hour, minute, second, fraction))
end

function DateTime(year::Integer, month::Integer, day::Integer, hour::Integer, minute::Integer, second)
    return DateTime(Date(year, month, day), Time(hour, minute, second))
end

function DateTime(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
                  hour::Int64, minute::Int64, second::Int64, milliseconds::Int64,
                  fractionofsecond::T) where T
    return DateTime{T}(year, month, day, dayofyear,
                      hour, minute, second, milliseconds,
                      fractionofsecond)
end

function DateTime{T}(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
                  hour::Int64, minute::Int64, second::Int64, milliseconds::Int64,
                  fractionofsecond::T) where T
    if dayofyear != 0
        date = Date(year, dayofyear)
    else
        date = Date(year, month, day)
    end

    if !iszero(fractionofsecond)
        time = Time(hour, minute, second, fractionofsecond)
    else
        time = Time(hour, minute, second, 1e-3milliseconds)
    end

    return DateTime{T}(date, time)
end

Dates.year(dt::DateTime) = year(Date(dt))
Dates.month(dt::DateTime) = month(Date(dt))
Dates.day(dt::DateTime) = day(Date(dt))
Dates.yearmonthday(dt::DateTime) = year(Date(dt)), month(Date(dt)), day(Date(dt))
Dates.hour(dt::DateTime) = hour(Time(dt))
Dates.minute(dt::DateTime) = minute(Time(dt))
Dates.second(typ, dt::DateTime) = second(typ, Time(dt))
Dates.second(dt::DateTime) = second(Int, Time(dt))
Dates.millisecond(dt::DateTime) = millisecond(Time(dt))
Dates.microsecond(dt::DateTime) = microsecond(Time(dt))
Dates.nanosecond(dt::DateTime) = nanosecond(Time(dt))
fractionofsecond(dt::DateTime) = fractionofsecond(Time(dt))
calendar(dt::DateTime) = calendar(dt.date)

function Dates.dayofyear(dt::DateTime)
    leap = isleap(calendar(dt), year(dt))
    return finddayinyear(month(dt), day(dt), leap)
end

julian(dt::DateTime) = fractionofday(Time(dt)) + julian(Date(dt))
j2000(dt::DateTime) = fractionofday(Time(dt)) + j2000(Date(dt))
julian_twopart(dt::DateTime) = julian(Date(dt)), fractionofday(Time(dt))

DateTime(dt::Dates.DateTime) = DateTime(Dates.year(dt), Dates.month(dt), Dates.day(dt),
                                        Dates.hour(dt), Dates.minute(dt),
                                        1e-3Dates.millisecond(dt) + Dates.second(dt))
function Dates.DateTime(dt::DateTime)
    y = year(dt)
    m = month(dt)
    d = day(dt)
    h = hour(dt)
    mi = minute(dt)
    s = second(Int, dt)
    ms = millisecond(dt)
    return Dates.DateTime(y, m, d, h, mi, s, ms)
end

end

