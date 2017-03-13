export leapseconds, LSK

type LSK
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

const LSK_FILE = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/naif0012.tls"
const LSK_DATA = Ref{LSK}()

function fractionofday(dt)
    Dates.hour(dt)/24 + Dates.minute(dt)/(24*60) + Dates.second(dt)/86400 + Dates.millisecond(dt)/8.64e7
end

function leapseconds(ep::Epoch)
    if !isassigned(LSK_DATA)
        error("No leapseconds kernel has been loaded. Run `AstronomicalTime.update()` or manually load an LSK.")
    end
    lsk = LSK_DATA[]
    jd = julian(ep)

    # Before 1960-01-01
    if jd < 2.4369345e6
        return 0.0
    elseif jd < lsk.t[1]
        dt = DateTime(ep)
        return eraDat(Dates.year(dt), Dates.month(dt), Dates.day(dt), fractionofday(dt))
    else
        return lsk.leapseconds[findlast(jd .>= lsk.t)]
    end
end

function load_lsk(file)
    LSK_DATA[] = LSK(file)
end
