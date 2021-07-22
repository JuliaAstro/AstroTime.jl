module Periods

using ..AccurateArithmetic: apply_offset, handle_infinity

export AstroPeriod, TimeUnit,
    seconds, minutes, hours, days, years, centuries,
    -, *, /, +, value, unit,
    SECONDS_PER_MINUTE,
    SECONDS_PER_HOUR,
    SECONDS_PER_DAY,
    SECONDS_PER_YEAR,
    SECONDS_PER_CENTURY

const SECONDS_PER_MINUTE   = 60.0
const SECONDS_PER_HOUR     = 60.0 * 60.0
const SECONDS_PER_DAY      = 60.0 * 60.0 * 24.0
const SECONDS_PER_YEAR     = 60.0 * 60.0 * 24.0 * 365.25
const SECONDS_PER_CENTURY  = 60.0 * 60.0 * 24.0 * 365.25 * 100.0

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

factor(::Second) = 1.0
factor(::Minute) = SECONDS_PER_MINUTE
factor(::Hour) = SECONDS_PER_HOUR
factor(::Day) = SECONDS_PER_DAY
factor(::Year) = SECONDS_PER_YEAR
factor(::Century) = SECONDS_PER_CENTURY

"""
    AstroPeriod{U, T}(unit, Δt) where {U<:TimeUnit, T}

An `AstroPeriod` object represents a time interval of `Δt` with a [`TimeUnit`](@ref) of
`unit`.  Periods should be constructed via the shorthand syntax shown in the examples below.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> 3.0seconds
3.0 seconds

julia> 1.0minutes
1.0 minutes

julia> 12hours
12.0 hours

julia> days_per_year = 365
365
julia> days_per_year * days
365.0 days

julia> 10.0years
10.0 years

julia> 1centuries
1.0 centuries
```
"""
struct AstroPeriod{U<:TimeUnit, T}
    unit::U
    second::Int64
    fraction::T
    error::T
end

function AstroPeriod(unit, dt)
    isfinite(dt) || return AstroPeriod(unit, handle_infinity(dt)...)

    seconds = dt * factor(unit)
    int_seconds = floor(Int64, seconds)
    fraction = seconds - int_seconds
    return AstroPeriod(unit, int_seconds, fraction, zero(fraction))
end


(u::TimeUnit)(p::AstroPeriod) = AstroPeriod(u, p.second, p.fraction, p.error)

"""
    unit(p::AstroPeriod)

Return the unit of the period `p`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> unit(3.0seconds)
Second()
```
"""
unit(p::AstroPeriod) = p.unit

"""
    value(p::AstroPeriod)

Return the unitless value of the period `p`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> value(3.0seconds)
3.0
```
"""
value(p::AstroPeriod) = (p.fraction + p.second) / factor(unit(p))

Base.zero(p::AstroPeriod) = AstroPeriod(unit(p), zero(value(p)))
Base.zero(p::Type{<:AstroPeriod{U}}) where {U} = AstroPeriod(U(), 0.0)
Base.zero(p::Type{<:AstroPeriod{U,T}}) where {U, T} = AstroPeriod(U(), zero(T))
Base.eltype(p::AstroPeriod) = typeof(value(p))
Base.eltype(p::Type{<:AstroPeriod{U,T}}) where {U, T} = T

name(::Second) = "seconds"
name(::Minute) = "minutes"
name(::Hour) = "hours"
name(::Day) = "days"
name(::Year) = "years"
name(::Century) = "centuries"

function Base.show(io::IO, p::AstroPeriod)
    u = unit(p)
    v = value(p)
    print(io, v, " ", name(u))
end

Base.:*(dt::Number, unit::TimeUnit) = AstroPeriod(unit, dt)
Base.:*(unit::TimeUnit, dt::Number) = AstroPeriod(unit, dt)
Base.:*(A::TimeUnit, B::AbstractArray) = broadcast(*, A, B)
Base.:*(A::AbstractArray, B::TimeUnit) = broadcast(*, A, B)

Base.:-(p::AstroPeriod) = AstroPeriod(unit(p), -p.second, -p.fraction, -p.error)

function Base.:+(p1::AstroPeriod{U}, p2::AstroPeriod{U}) where U
    second, fraction, error = apply_offset(p1.second, p1.fraction, p1.error, p2.second, p2.fraction, p2.error)
    return AstroPeriod(U(), second, fraction, error)
end

Base.:-(p1::AstroPeriod, p2::AstroPeriod) = p1 + (-p2)
Base.:*(x, p::AstroPeriod) = AstroPeriod(unit(p), value(p) * x)
Base.:*(p::AstroPeriod, x) = AstroPeriod(unit(p), value(p) * x)
Base.:/(p::AstroPeriod, x) = AstroPeriod(unit(p), value(p) / x)

Base.isless(p1::AstroPeriod{U}, p2::AstroPeriod{U}) where {U} = isless(value(p1), value(p2))
Base.:(==)(p1::AstroPeriod{U}, p2::AstroPeriod{U}) where {U} = value(p1) == value(p2)
function Base.isapprox(p1::AstroPeriod{U}, p2::AstroPeriod{U}; kwargs...) where {U}
    return isapprox(value(p1), value(p2); kwargs...)
end

(::Base.Colon)(start::AstroPeriod{U,T}, stop::AstroPeriod{U,T}) where {U,T} = (:)(start, one(T) * U(), stop)

function (::Base.Colon)(start::AstroPeriod{U}, step::AstroPeriod{U}, stop::AstroPeriod{U}) where {U}
    step = start < stop ? step : -step
    StepRangeLen(start, step, floor(Int, value(stop-start)/value(step))+1)
end

AstroPeriod{U,T}(p::AstroPeriod{U,T}) where {U,T} = p

Base.step(r::StepRangeLen{<:AstroPeriod}) = r.step

end
