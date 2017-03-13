isless{T<:Timescale}(ep1::Epoch{T}, ep2::Epoch{T}) = juliandate(ep1) < juliandate(ep2)

dut1(ep::Epoch) = ep.ΔUT1
juliandate(ep::Epoch) = ep.jd + ep.jd1
mjd(ep::Epoch) = juliandate(ep) - MJD
jd2000(ep::Epoch) = juliandate(ep) - J2000
jd1950(ep::Epoch) = juliandate(ep) - J1950
jd(ep::Epoch) = ep.jd
jd1(ep::Epoch) = ep.jd1

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

function deltatr(ep::Epoch)
    eraDtdb(jd(ep), jd1(ep), 0.0, 0.0, 0.0, 0.0)
end

