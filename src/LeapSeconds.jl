module LeapSeconds

using ERFA
using OptionalData
using RemoteFiles


export leapseconds, LSK, LSK_FILE, LSK_DATA

function fetch()
    isfile(LSK_FILE) && push!(LSK_DATA, path(LSK_FILE))
end

struct LSK
    t::Vector{Float64}
    leapseconds::Vector{Float64}
end

function LSK(file)
    t = Vector{Float64}()
    leapseconds = Vector{Float64}()
    re = r"(?<dat>[0-9]{2}),\s+@(?<date>[0-9]{4}-[A-Z]{3}-[0-9])"
    lines = open(readlines, file)
    for line in lines
        s = string(line)
        if ismatch(re, s)
            m = match(re, s)
            push!(leapseconds, float(m["dat"]))
            push!(t, Dates.datetime2julian(DateTime(m["date"], "y-u-d")))
        end
    end
    LSK(t, leapseconds)
end

@RemoteFile LSK_FILE "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/naif0012.tls"
@OptionalData LSK_DATA LSK "Run 'AstroTime.update()' to load it."

function fractionofday(dt)
    Dates.hour(dt)/24 + Dates.minute(dt)/(24*60) + Dates.second(dt)/86400 + Dates.millisecond(dt)/8.64e7
end

function leapseconds(lsk::LSK, jd)
    # Before 1960-01-01
    if jd < 2.4369345e6
        return 0.0
    elseif jd < lsk.t[1]
        dt = Dates.julian2datetime(jd)
        return ERFA.dat(Dates.year(dt), Dates.month(dt), Dates.day(dt), fractionofday(dt))
    else
        return lsk.leapseconds[findlast(jd .>= lsk.t)]
    end
end
leapseconds(jd) = leapseconds(get(LSK_DATA), jd)
fetch()
end
