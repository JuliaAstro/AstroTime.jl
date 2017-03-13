isless{T<:Timescale}(ep1::Epoch{T}, ep2::Epoch{T}) = juliandate(ep1) < juliandate(ep2)
(-){T<:Timescale}(ep1::Epoch{T}, ep2::Epoch{T}) = EpochDelta(ep1.jd-ep2.jd, ep1.jd1-ep2.jd1)
(-){T<:Timescale}(ep::Epoch{T}, ed::EpochDelta) = Epoch(T, ep.jd-ed.jd, ep.jd1-ed.jd1)
(+){T<:Timescale}(ep::Epoch{T}, ed::EpochDelta) = Epoch(T, ep.jd+ed.jd, ep.jd1+ed.jd1)

function Epoch{T<:Timescale}(scale::Type{T}, jd::Float64, jd1::Float64=0.0)
    ΔUT1 = interpolate(DATA.dut1, jd - MJD + jd1, true, false)[1]
    Epoch(scale, jd, jd1, leapseconds(jd+jd1), ΔUT1)
end

function Epoch{T<:Timescale}(scale::Type{T}, year::Int, month::Int, day::Int,
    hour::Int=0, minute::Int=0, seconds::Float64=0.0)
    jd, jd1 = eraDtf2d(string(T),
    year, month, day, hour, minute, seconds)
    Epoch(scale, jd, jd1)
end

function Epoch{T<:Timescale}(scale::Type{T}, dt::DateTime)
    Epoch(scale, year(dt), month(dt), day(dt),
        hour(dt), minute(dt), second(dt) + millisecond(dt)/1000)
end

Epoch{T<:Timescale}(scale::Type{T}, str::AbstractString) = Epoch(scale, DateTime(str))

function isapprox{T<:Timescale}(a::Epoch{T}, b::Epoch{T})
    return juliandate(a) ≈ juliandate(b)
end

function (==){T<:Timescale}(a::Epoch{T}, b::Epoch{T})
    return DateTime(a) == DateTime(b)
end

leapseconds(ep::Epoch) = ep.leapseconds
dut1(ep::Epoch) = ep.ΔUT1
juliandate(ep::Epoch) = ep.jd + ep.jd1
mjd(ep::Epoch) = juliandate(ep) - MJD
jd2000(ep::Epoch) = juliandate(ep) - J2000
jd1950(ep::Epoch) = juliandate(ep) - J1950
jd(ep::Epoch) = ep.jd
jd1(ep::Epoch) = ep.jd1


Epoch{T<:Timescale, S<:Timescale}(::Type{T}, ep::Epoch{S}) = convert(Epoch{T}, ep)

convert{T<:Timescale}(::Type{Epoch{T}}, ep::Epoch{T}) = ep

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

function deltatr(ep::Epoch)
    eraDtdb(jd(ep), jd1(ep), 0.0, 0.0, 0.0, 0.0)
end

centuries(ep::Epoch, base=J2000) = (juliandate(ep) - base)/JULIAN_CENTURY
days(ep::Epoch, base=J2000) = juliandate(ep) - base
seconds(ep::Epoch, base=J2000) = (juliandate(ep) - base)*86400

type LSK
    t::Vector{DateTime}
    leapseconds::Vector{Float64}
end

function LSK(file)
    t = Vector{DateTime}()
    leapseconds = Vector{Float64}()
    re = r"(?<dat>[0-9]{2}),\s+@(?<date>[0-9]{4}-[A-Z]{3}-[0-9])"
    lines = open(readlines, file)
    for line in lines
        s = string(line)
        if ismatch(re, s)
            m = match(re, s)
            push!(leapseconds, float(m["dat"]))
            push!(t, DateTime(m["date"], "y-u-d"))
        end
    end
    LSK(t, leapseconds)
end

function fractionofday(dt)
    hour(dt)/24 + minute(dt)/(24*60) + second(dt)/86400 + millisecond(dt)/8.64e7
end

function leapseconds(lsk::LSK, dt::DateTime)
    if dt < DateTime(1960, 1, 1)
        return 0.0
    elseif dt < lsk.t[1]
        return eraDat(year(dt), month(dt), day(dt), fractionofday(dt))
    else
        return lsk.leapseconds[findlast(dt .>= lsk.t)]
    end
end
leapseconds(dt::DateTime) = leapseconds(DATA.leapseconds, dt)
leapseconds(jd::Float64) = leapseconds(DATA.leapseconds, julian2datetime(jd))
