module Periods

import Base: *, /

export TimeUnit, Second, Minute, Hour, Day, Week, Year, Century,
    J2000, J1950, MJD,
    seconds, minutes, hours, days, weeks, years, centuries, Period, *, /

include("constants.jl")

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

(*)(Δt::T, ::U) where {T<:Number, U<:TimeUnit} = Period{U}(Δt)

(*)(x::T, p::Period) where {T<:Number} = Period{p.unit}(p.Δt * x)
(*)(p::Period, x::T) where {T<:Number}= Period{p.unit}(p.Δt * x)
(/)(x::T, p::Period) where {T<:Number} = Period{p.unit}(x / p.Δ)
(/)(p::Period, x::T) where {T<:Number}= Period{p.unit}(p.Δt / x)

(::Second)(p::Period{Second})  = p.Δt
(::Second)(p::Period{Minute})  = p.Δt * SECONDS_PER_MINUTE
(::Second)(p::Period{Hour})    = p.Δt * SECONDS_PER_HOUR
(::Second)(p::Period{Day})     = p.Δt * SECONDS_PER_DAY
(::Second)(p::Period{Year})    = p.Δt * SECONDS_PER_YEAR
(::Second)(p::Period{Century}) = p.Δt * SECONDS_PER_CENTURY

(::Minute)(p::Period{Second})  = p.Δt / SECONDS_PER_MINUTE
(::Minute)(p::Period{Minute})  = p.Δt
(::Minute)(p::Period{Hour})    = p.Δt * MINUTES_PER_HOUR
(::Minute)(p::Period{Day})     = p.Δt * MINUTES_PER_DAY
(::Minute)(p::Period{Year})    = p.Δt * MINUTES_PER_YEAR
(::Minute)(p::Period{Century}) = p.Δt * MINUTES_PER_CENTURY

(::Hour)(p::Period{Second})  = p.Δt / SECONDS_PER_HOUR
(::Hour)(p::Period{Minute})  = p.Δt / MINUTES_PER_HOUR
(::Hour)(p::Period{Hour})    = p.Δt
(::Hour)(p::Period{Day})     = p.Δt * HOURS_PER_DAY
(::Hour)(p::Period{Year})    = p.Δt * HOURS_PER_YEAR
(::Hour)(p::Period{Century}) = p.Δt * HOURS_PER_CENTURY

(::Day)(p::Period{Second})  = p.Δt / SECONDS_PER_DAY
(::Day)(p::Period{Minute})  = p.Δt / MINUTES_PER_DAY
(::Day)(p::Period{Hour})    = p.Δt / HOURS_PER_DAY
(::Day)(p::Period{Day})     = p.Δt
(::Day)(p::Period{Year})    = p.Δt * DAYS_PER_YEAR
(::Day)(p::Period{Century}) = p.Δt * DAYS_PER_CENTURY

(::Year)(p::Period{Second})  = p.Δt / SECONDS_PER_YEAR
(::Year)(p::Period{Minute})  = p.Δt / MINUTES_PER_YEAR
(::Year)(p::Period{Hour})    = p.Δt / HOURS_PER_YEAR
(::Year)(p::Period{Day})     = p.Δt / DAYS_PER_YEAR
(::Year)(p::Period{Year})    = p.Δt
(::Year)(p::Period{Century}) = p.Δt * YEARS_PER_CENTURY

(::Century)(p::Period{Second})  = p.Δt / SECONDS_PER_CENTURY
(::Century)(p::Period{Minute})  = p.Δt / MINUTES_PER_CENTURY
(::Century)(p::Period{Hour})    = p.Δt / HOURS_PER_CENTURY
(::Century)(p::Period{Day})     = p.Δt / DAYS_PER_CENTURY
(::Century)(p::Period{Year})    = p.Δt / YEARS_PER_CENTURY
(::Century)(p::Period{Century}) = p.Δt

end
