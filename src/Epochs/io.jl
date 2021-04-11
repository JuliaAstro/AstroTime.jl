function Dates.format(io, d::Dates.DatePart{'t'}, ep)
    print(io, timescale(ep))
end

abstract type DayOfYearToken end

@inline function Dates.tryparsenext(d::Dates.DatePart{'D'}, str, i, len, locale)
    next = Dates.tryparsenext_base10(str, i, len, 1, 3)
    next === nothing && return nothing
    val, idx = next
    (val >= 1 && val <= 366) || throw(ArgumentError("Day number must be within 1 and 366."))
    return val, idx
end

function Dates.format(io, d::Dates.DatePart{'D'}, ep)
    print(io, dayofyear(ep))
end

abstract type FractionOfSecondToken end

@inline function Dates.tryparsenext(d::Dates.DatePart{'f'}, str, i, len, locale)
    next = Dates.tryparsenext_base10(str, i, len)
    next === nothing && return nothing
    val, idx = next
    val /= 10^(idx - i)
    return val, idx
end

function Dates.format(io, d::Dates.DatePart{'f'}, ep)
    str = last(split(string(fractionofsecond(ep)), "."))
    n = length(str)
    len = d.width < n ? d.width : n
    print(io, rpad(str[1:len], d.width, '0'))
end

