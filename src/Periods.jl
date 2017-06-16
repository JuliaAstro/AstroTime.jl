module Periods

import Base: *

export TimeUnit, Seconds, Minutes, Hours, Days, Weeks, Years,
    seconds, minutes, hours, days, weeks, years, Period

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

Δt(p::Period{Seconds,T}) where T = p.Δt / 86400.0
Δt(p::Period{Minutes,T}) where T = p.Δt / 1440.0
Δt(p::Period{Hours,T}) where T = p.Δt / 24.0
Δt(p::Period{Days,T}) where T = p.Δt
Δt(p::Period{Weeks,T}) where T = 7p.Δt
Δt(p::Period{Years,T}) where T = 365p.Δt

end
