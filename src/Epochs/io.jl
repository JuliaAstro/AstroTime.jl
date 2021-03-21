function Dates.validargs(::Type{Epoch}, y::Int64, m::Int64, d::Int64,
                         h::Int64, mi::Int64, s::Int64, ms::Int64, ts::S) where S<:TimeScale
    err = Dates.validargs(Dates.DateTime, y, m, d, h, mi, s, ms)
    err !== nothing || return err
    return Dates.argerror()
end

abstract type DayOfYearToken end

@inline function Dates.tryparsenext(d::Dates.DatePart{'D'}, str, i, len, locale)
    next = Dates.tryparsenext_base10(str, i, len, 1, 3)
    next === nothing && return nothing
    val, i = next
    (val >= 1 && val <= 366) || throw(ArgumentError("Day number must be within 1 and 366."))
    return val, i
end

function Dates.format(io, d::Dates.DatePart{'D'}, ep)
    print(io, dayofyear(ep))
end

function Dates.format(io, d::Dates.DatePart{'t'}, ep)
    print(io, timescale(ep))
end

