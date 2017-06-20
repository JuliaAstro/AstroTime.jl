module Periods

import Base: *, /
import ..in_seconds, ..in_days

export TimeUnit, Seconds, Minutes, Hours, Days, Weeks, Years,
    seconds, minutes, hours, days, weeks, years, Period, *, /

abstract type TimeUnit end

struct Seconds <: TimeUnit end
struct Minutes <: TimeUnit end
struct Hours <: TimeUnit end
struct Days <: TimeUnit end
struct Weeks <: TimeUnit end
struct Years <: TimeUnit end

const seconds = Seconds
const minutes = Minutes
const hours = Hours
const days = Days
const weeks = Weeks
const years = Years

struct Period{U<:TimeUnit,T<:Number}
    unit::Type{U}
    Δt::T
    Period{U}(Δt::T) where {U<:TimeUnit,T<:Number} = new{U,T}(U, Δt)
end

(*)(Δt::T, ::Type{U}) where {T<:Number, U<:TimeUnit} = Period{U}(Δt)

(*)(x::T, p::Period) where {T<:Number} = Period{p.unit}(p.Δt * x)
(*)(p::Period, x::T) where {T<:Number}= Period{p.unit}(p.Δt * x)
(/)(x::T, p::Period) where {T<:Number} = Period{p.unit}(x / p.Δ)
(/)(p::Period, x::T) where {T<:Number}= Period{p.unit}(p.Δt / x)

in_days(p::Period{Seconds,T}) where {T} = p.Δt / 86400.0
in_days(p::Period{Minutes,T}) where {T} = p.Δt / 1440.0
in_days(p::Period{Hours,T}) where {T} = p.Δt / 24.0
in_days(p::Period{Days,T}) where {T} = p.Δt
in_days(p::Period{Weeks,T}) where {T} = 7p.Δt
in_days(p::Period{Years,T}) where {T} = 365p.Δt

in_seconds(p::Period{Seconds,T}) where {T} = p.Δt
in_seconds(p::Period{Minutes,T}) where {T} = p.Δt * 60.0
in_seconds(p::Period{Hours,T}) where {T} = p.Δt * 3600.0
in_seconds(p::Period{Days,T}) where {T} = p.Δt * 86400.0
in_seconds(p::Period{Weeks,T}) where {T} = p.Δt * 604800.0
in_seconds(p::Period{Years,T}) where {T} = p.Δt * 31536000.0

end
