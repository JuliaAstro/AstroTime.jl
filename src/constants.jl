export MJD, J2000, J1950,
    SECONDS_PER_MINUTE, SECONDS_PER_HOUR, SECONDS_PER_DAY, SECONDS_PER_YEAR, SECONDS_PER_CENTURY,
    MINUTES_PER_HOUR, MINUTES_PER_DAY, MINUTES_PER_YEAR, MINUTES_PER_CENTURY,
    HOURS_PER_DAY, HOURS_PER_YEAR, HOURS_PER_CENTURY,
    DAYS_PER_YEAR, DAYS_PER_CENTURY,
    YEARS_PER_CENTURY,
    OFFSET_TT_TAI, MOD_JD_77, ELG, fairhd, DAYS_PER_MILLENNIUM, TDB0, ELB, JD_MAX, JD_MIN,
    CHANGE, DRIFT

const MJD = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

const SECONDS_PER_MINUTE   = 60.0
const SECONDS_PER_HOUR     = 60.0 * 60.0
const SECONDS_PER_DAY      = 60.0 * 60.0 * 24.0
const SECONDS_PER_YEAR     = 60.0 * 60.0 * 24.0 * 365.25
const SECONDS_PER_CENTURY  = 60.0 * 60.0 * 24.0 * 365.25 * 100.0

const MINUTES_PER_HOUR     = 60.0
const MINUTES_PER_DAY      = 60.0 * 24.0
const MINUTES_PER_YEAR     = 60.0 * 24.0 * 365.25
const MINUTES_PER_CENTURY  = 60.0 * 24.0 * 365.25 * 100.0

const HOURS_PER_DAY        = 24.0
const HOURS_PER_YEAR       = 24.0 * 365.25
const HOURS_PER_CENTURY    = 24.0 * 365.25 * 100.0

const DAYS_PER_YEAR        = 365.25
const DAYS_PER_CENTURY     = 365.25 * 100.0

const YEARS_PER_CENTURY    = 100.0

const OFFSET_TT_TAI = 32.184

const MOD_JD_77 = 43144.0
const ELG = 6.969290134e-10
const DAYS_PER_MILLENNIUM = 365250.0

const TDB0 = -6.55e-5
const ELB = 1.550519768e-8

const JD_MIN = -68569.5
const JD_MAX = 1e9

const DRIFT = [
( 37300.0, 0.0012960 ),
( 37300.0, 0.0012960 ),
( 37300.0, 0.0012960 ),
( 37665.0, 0.0011232 ),
( 37665.0, 0.0011232 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 38761.0, 0.0012960 ),
( 39126.0, 0.0025920 ),
( 39126.0, 0.0025920 )]


struct changes
    year::Int
    month::Int
    delat::Float64
end

CHANGE = [
changes( 1960,  1,  1.4178180 ),
changes( 1961,  1,  1.4228180 ),
changes( 1961,  8,  1.3728180 ),
changes( 1962,  1,  1.8458580 ),
changes( 1963, 11,  1.9458580 ),
changes( 1964,  1,  3.2401300 ),
changes( 1964,  4,  3.3401300 ),
changes( 1964,  9,  3.4401300 ),
changes( 1965,  1,  3.5401300 ),
changes( 1965,  3,  3.6401300 ),
changes( 1965,  7,  3.7401300 ),
changes( 1965,  9,  3.8401300 ),
changes( 1966,  1,  4.3131700 ),
changes( 1968,  2,  4.2131700 )]

for i in zip(LSK_DATA.data.value.t, LSK_DATA.data.value.leapseconds)
    dt = Dates.julian2datetime(i[1])
    push!(CHANGE, changes(Dates.year(dt), Dates.month(dt), i[2]))
end

include("fairhd.jl")
