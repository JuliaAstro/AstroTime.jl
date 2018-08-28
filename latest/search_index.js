var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#AstroTime-1",
    "page": "Home",
    "title": "AstroTime",
    "category": "section",
    "text": "Astronomical time keeping in Julia"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia\'s package manager:Pkg.clone(\"https://github.com/JuliaAstro/AstroTime.jl\")"
},

{
    "location": "index.html#Quickstart-1",
    "page": "Home",
    "title": "Quickstart",
    "category": "section",
    "text": "# Create an Epoch based on the TT (Terrestial Time) scale\ntt = TTEpoch(\"2018-01-01T12:00:00\")\n\n# Transform to UTC (Universal Time Coordinated)\nutc = UTCEpoch(tt)\n\n# Transform to TDB (Barycentric Dynamical Time)\nutc = TDBEpoch(utc)Read the API docs."
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#AstroTime.@timescale-Tuple{Symbol,Symbol,Vararg{Any,N} where N}",
    "page": "API",
    "title": "AstroTime.@timescale",
    "category": "macro",
    "text": "@timescale scale\n\nDefine a new timescale and the corresponding Epoch type alias.\n\nExample\n\njulia> @timescale GMT ep tai_offset(UTC, ep)\n\njulia> GMT <: TimeScale\ntrue\n\njulia> GMTEpoch\nEpoch{GMT,T} where T\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{S}, Tuple{Epoch{S,T} where T,Any}} where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{T}, Tuple{T}, Tuple{S}, Tuple{T,T}} where T where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TAIEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCBEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCGEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TDBEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TTEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UT1Epoch",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UTCEpoch",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "type",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2).\n\n\n\n\n\nEpoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.now-Tuple{}",
    "page": "API",
    "title": "AstroTime.Epochs.now",
    "category": "method",
    "text": "now()\n\nGet the current date and time as a UTCEpoch.\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.tai_offset-Tuple{BarycentricDynamicalTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TDB, ep)\n\nComputes difference TDB-TAI in seconds at the epoch ep.\n\nThe accuracy of this routine is approx 40 microseconds in interval 1900-2100 AD. Note that an accurate transformation betweem TDB and TT depends on the trajectory of the observer. For two observers fixed on the earth surface the quantity TDB-TT can differ by as much as about 4 microseconds.\n\nReferences\n\nhttps://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB\nIssue #26\n\n\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AstroTime\nendModules = [AstroTime, AstroTime.Epochs]\nPrivate = false"
},

]}
