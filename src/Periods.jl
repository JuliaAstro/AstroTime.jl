module Periods

import Base: -, *, /, +, get, isapprox, show, zero, eltype, (:), isless

export TimeUnit, Second, Minute, Hour, Day, Year, Century,
    seconds, minutes, hours, days, years, centuries,
    Period, -, *, /, +, value, unit,
    SECONDS_PER_MINUTE,
    SECONDS_PER_HOUR,
    SECONDS_PER_DAY,
    SECONDS_PER_YEAR,
    SECONDS_PER_CENTURY,
    MINUTES_PER_HOUR,
    MINUTES_PER_DAY,
    MINUTES_PER_YEAR,
    MINUTES_PER_CENTURY,
    HOURS_PER_DAY,
    HOURS_PER_YEAR,
    HOURS_PER_CENTURY,
    DAYS_PER_YEAR,
    DAYS_PER_CENTURY,
    YEARS_PER_CENTURY

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

"""
All time units are subtypes of the abstract type `TimeUnit`.
The following time units are defined:

* `Second`
* `Minute`
* `Hour`
* `Day`
* `Year`
* `Century`
"""
abstract type TimeUnit end

struct Second <: TimeUnit end
struct Minute <: TimeUnit end
struct Hour <: TimeUnit end
struct Day <: TimeUnit end
struct Year <: TimeUnit end
struct Century <: TimeUnit end

const seconds = Second()
const minutes = Minute()
const hours = Hour()
const days = Day()
const years = Year()
const centuries = Century()

Base.broadcastable(u::TimeUnit) = Ref(u)

"""
    Period{U, T}(unit, Δt) where {U<:TimeUnit, T}

A `Period` object represents a time interval of `Δt` with a [`TimeUnit`](@ref) of `unit`.
Periods should be constructed via the shorthand syntax shown in the examples below.

### Examples ###

```jldoctest
julia> 3.0seconds
3.0 seconds

julia> 1.0minutes
1.0 minutes

julia> 12hours
12 hours

julia> days_per_year = 365
365
julia> days_per_year * days
365 days

julia> 10.0years
10.0 years

julia> 1centuries
1 century
```
"""
struct Period{U<:TimeUnit, T}
    unit::U
    Δt::T
end

value(p::Period) = p.Δt
unit(p::Period) = p.unit
zero(p::Period) = Period(unit(p), zero(value(p)))
zero(p::Type{<:Period{U}}) where {U} = Period(U(), 0.0)
zero(p::Type{<:Period{U,T}}) where {U, T} = Period(U(), zero(T))
eltype(p::Period) = typeof(value(p))
eltype(p::Type{<:Period{U,T}}) where {U, T} = T

plural(p::Period{U, T}) where {U, T} = value(p) == one(T) ? "" : "s"

function show(io::IO, p::Period{Second})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " second" : " seconds")
end

function show(io::IO, p::Period{Minute})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " minute" : " minutes")
end

function show(io::IO, p::Period{Hour})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " hour" : " hours")
end

function show(io::IO, p::Period{Day})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " day" : " days")
end

function show(io::IO, p::Period{Year})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " year" : " years")
end

function show(io::IO, p::Period{Century})
    v = value(p)
    print(io, v, v isa Integer && v == 1 ? " century" : " centuries")
end

*(Δt::T, unit::TimeUnit) where {T<:Number} = Period(unit, Δt)
*(unit::TimeUnit, Δt::T) where {T<:Number} = Period(unit, Δt)
*(A::TimeUnit, B::AbstractArray) = broadcast(*, A, B)
*(A::AbstractArray, B::TimeUnit) = broadcast(*, A, B)

(+)(p1::Period{U}, p2::Period{U}) where {U}= Period(unit(p1), p1.Δt + p2.Δt)
(-)(p1::Period{U}, p2::Period{U}) where {U}= Period(unit(p1), p1.Δt - p2.Δt)
(-)(p::Period) = Period(unit(p), -p.Δt)
(*)(x, p::Period) = Period(unit(p), p.Δt * x)
(*)(p::Period, x) = Period(unit(p), p.Δt * x)
(/)(x, p::Period) = Period(unit(p), x / p.Δ)
(/)(p::Period, x) = Period(unit(p), p.Δt / x)

isless(p1::Period{U}, p2::Period{U}) where {U} = isless(value(p1), value(p2))
isapprox(p1::Period{U}, p2::Period{U}) where {U} = value(p1) ≈ value(p2)

(:)(start::Period{U,T}, stop::Period{U,T}) where {U,T} = (:)(start, one(T) * U(), stop)

function (:)(start::Period{U}, step::Period{U}, stop::Period{U}) where {U}
    step = start < stop ? step : -step
    StepRangeLen(start, step, floor(Int, value(stop-start)/value(step))+1)
end

Period{U,T}(p::Period{U,T}) where {U,T} = p

Base.step(r::StepRangeLen{<:Period}) = r.step

(::Second)(p::Period{Second})   = p
(::Second)(p::Period{Minute})   = Period(seconds, p.Δt * SECONDS_PER_MINUTE)
(::Second)(p::Period{Hour})     = Period(seconds, p.Δt * SECONDS_PER_HOUR)
(::Second)(p::Period{Day})      = Period(seconds, p.Δt * SECONDS_PER_DAY)
(::Second)(p::Period{Year})     = Period(seconds, p.Δt * SECONDS_PER_YEAR)
(::Second)(p::Period{Century})  = Period(seconds, p.Δt * SECONDS_PER_CENTURY)

(::Minute)(p::Period{Second})   = Period(minutes, p.Δt / SECONDS_PER_MINUTE)
(::Minute)(p::Period{Minute})   = p
(::Minute)(p::Period{Hour})     = Period(minutes, p.Δt * MINUTES_PER_HOUR)
(::Minute)(p::Period{Day})      = Period(minutes, p.Δt * MINUTES_PER_DAY)
(::Minute)(p::Period{Year})     = Period(minutes, p.Δt * MINUTES_PER_YEAR)
(::Minute)(p::Period{Century})  = Period(minutes, p.Δt * MINUTES_PER_CENTURY)

(::Hour)(p::Period{Second})     = Period(hours, p.Δt / SECONDS_PER_HOUR)
(::Hour)(p::Period{Minute})     = Period(hours, p.Δt / MINUTES_PER_HOUR)
(::Hour)(p::Period{Hour})       = p
(::Hour)(p::Period{Day})        = Period(hours, p.Δt * HOURS_PER_DAY)
(::Hour)(p::Period{Year})       = Period(hours, p.Δt * HOURS_PER_YEAR)
(::Hour)(p::Period{Century})    = Period(hours, p.Δt * HOURS_PER_CENTURY)

(::Day)(p::Period{Second})      = Period(days, p.Δt / SECONDS_PER_DAY)
(::Day)(p::Period{Minute})      = Period(days, p.Δt / MINUTES_PER_DAY)
(::Day)(p::Period{Hour})        = Period(days, p.Δt / HOURS_PER_DAY)
(::Day)(p::Period{Day})         = p
(::Day)(p::Period{Year})        = Period(days, p.Δt * DAYS_PER_YEAR)
(::Day)(p::Period{Century})     = Period(days, p.Δt * DAYS_PER_CENTURY)

(::Year)(p::Period{Second})     = Period(years, p.Δt / SECONDS_PER_YEAR)
(::Year)(p::Period{Minute})     = Period(years, p.Δt / MINUTES_PER_YEAR)
(::Year)(p::Period{Hour})       = Period(years, p.Δt / HOURS_PER_YEAR)
(::Year)(p::Period{Day})        = Period(years, p.Δt / DAYS_PER_YEAR)
(::Year)(p::Period{Year})       = p
(::Year)(p::Period{Century})    = Period(years, p.Δt * YEARS_PER_CENTURY)

(::Century)(p::Period{Second})  = Period(centuries, p.Δt / SECONDS_PER_CENTURY)
(::Century)(p::Period{Minute})  = Period(centuries, p.Δt / MINUTES_PER_CENTURY)
(::Century)(p::Period{Hour})    = Period(centuries, p.Δt / HOURS_PER_CENTURY)
(::Century)(p::Period{Day})     = Period(centuries, p.Δt / DAYS_PER_CENTURY)
(::Century)(p::Period{Year})    = Period(centuries, p.Δt / YEARS_PER_CENTURY)
(::Century)(p::Period{Century}) = p

end
