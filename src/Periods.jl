module Periods

import Base: *, /, get, isapprox, show

export TimeUnit, Second, Minute, Hour, Day, Year, Century,
    seconds, minutes, hours, days, years, centuries,
    Period, *, /, get

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

struct Period{U<:TimeUnit,T<:Number}
    unit::Type{U}
    Δt::T
    Period{U}(Δt::T) where {U<:TimeUnit,T<:Number} = new{U,T}(U, Δt)
end

get(p::Period) = p.Δt

show(io::IO, p::Period{Second}) = print(io, "$(get(p)) seconds")
show(io::IO, p::Period{Minute}) = print(io, "$(get(p)) minutes")
show(io::IO, p::Period{Hour}) = print(io, "$(get(p)) hours")
show(io::IO, p::Period{Day}) = print(io, "$(get(p)) days")
show(io::IO, p::Period{Year}) = print(io, "$(get(p)) years")
show(io::IO, p::Period{Century}) = print(io, "$(get(p)) centuries")

(*)(Δt::T, ::U) where {T<:Number, U<:TimeUnit} = Period{U}(Δt)

(*)(x::T, p::Period) where {T<:Number} = Period{p.unit}(p.Δt * x)
(*)(p::Period, x::T) where {T<:Number} = Period{p.unit}(p.Δt * x)
(/)(x::T, p::Period) where {T<:Number} = Period{p.unit}(x / p.Δ)
(/)(p::Period, x::T) where {T<:Number} = Period{p.unit}(p.Δt / x)

isapprox(p1::Period{U}, p2::Period{U}) where {U<:TimeUnit} = get(p1) ≈ get(p2)

(::Second)(p::Period{Second})  = p
(::Second)(p::Period{Minute})  = Period{Second}(p.Δt * SECONDS_PER_MINUTE)
(::Second)(p::Period{Hour})    = Period{Second}(p.Δt * SECONDS_PER_HOUR)
(::Second)(p::Period{Day})     = Period{Second}(p.Δt * SECONDS_PER_DAY)
(::Second)(p::Period{Year})    = Period{Second}(p.Δt * SECONDS_PER_YEAR)
(::Second)(p::Period{Century}) = Period{Second}(p.Δt * SECONDS_PER_CENTURY)

(::Minute)(p::Period{Second})  = Period{Minute}(p.Δt / SECONDS_PER_MINUTE)
(::Minute)(p::Period{Minute})  = p
(::Minute)(p::Period{Hour})    = Period{Minute}(p.Δt * MINUTES_PER_HOUR)
(::Minute)(p::Period{Day})     = Period{Minute}(p.Δt * MINUTES_PER_DAY)
(::Minute)(p::Period{Year})    = Period{Minute}(p.Δt * MINUTES_PER_YEAR)
(::Minute)(p::Period{Century}) = Period{Minute}(p.Δt * MINUTES_PER_CENTURY)

(::Hour)(p::Period{Second})  = Period{Hour}(p.Δt / SECONDS_PER_HOUR)
(::Hour)(p::Period{Minute})  = Period{Hour}(p.Δt / MINUTES_PER_HOUR)
(::Hour)(p::Period{Hour})    = p
(::Hour)(p::Period{Day})     = Period{Hour}(p.Δt * HOURS_PER_DAY)
(::Hour)(p::Period{Year})    = Period{Hour}(p.Δt * HOURS_PER_YEAR)
(::Hour)(p::Period{Century}) = Period{Hour}(p.Δt * HOURS_PER_CENTURY)

(::Day)(p::Period{Second})  = Period{Day}(p.Δt / SECONDS_PER_DAY)
(::Day)(p::Period{Minute})  = Period{Day}(p.Δt / MINUTES_PER_DAY)
(::Day)(p::Period{Hour})    = Period{Day}(p.Δt / HOURS_PER_DAY)
(::Day)(p::Period{Day})     = p
(::Day)(p::Period{Year})    = Period{Day}(p.Δt * DAYS_PER_YEAR)
(::Day)(p::Period{Century}) = Period{Day}(p.Δt * DAYS_PER_CENTURY)

(::Year)(p::Period{Second})  = Period{Year}(p.Δt / SECONDS_PER_YEAR)
(::Year)(p::Period{Minute})  = Period{Year}(p.Δt / MINUTES_PER_YEAR)
(::Year)(p::Period{Hour})    = Period{Year}(p.Δt / HOURS_PER_YEAR)
(::Year)(p::Period{Day})     = Period{Year}(p.Δt / DAYS_PER_YEAR)
(::Year)(p::Period{Year})    = p
(::Year)(p::Period{Century}) = Period{Year}(p.Δt * YEARS_PER_CENTURY)

(::Century)(p::Period{Second})  = Period{Century}(p.Δt / SECONDS_PER_CENTURY)
(::Century)(p::Period{Minute})  = Period{Century}(p.Δt / MINUTES_PER_CENTURY)
(::Century)(p::Period{Hour})    = Period{Century}(p.Δt / HOURS_PER_CENTURY)
(::Century)(p::Period{Day})     = Period{Century}(p.Δt / DAYS_PER_CENTURY)
(::Century)(p::Period{Year})    = Period{Century}(p.Δt / YEARS_PER_CENTURY)
(::Century)(p::Period{Century}) = p

end
