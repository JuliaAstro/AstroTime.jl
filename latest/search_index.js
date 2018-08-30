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
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{AbstractString}, Tuple{S}, Tuple{AbstractString,DateFormat}} where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(str[, format]) where S\n\nConstruct a new Epoch with time scale S from a string str.\n\nDateFormat\n\nExample\n\njulia> ep = Epoch{UTC}(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 UTC\n\njulia> Epoch{UTC}(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{S}, Tuple{Epoch{S,T} where T,Any}} where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(ep::Epoch{S}, Δt) where S\n\nConstruct a new Epoch with time scale S which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{T}, Tuple{T}, Tuple{S}, Tuple{T,T}} where T<:Number where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> Epoch{UTC}(0.0, 0.5)\n2000-01-02T00:00:00.000 UTC\n\njulia> Epoch{UTC}(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TAIEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "method",
    "text": "TAIEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a TAIEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TAI\n\njulia> TAIEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 TAI\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TAIEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "method",
    "text": "TAIEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TAIEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TAIEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TAI\n\njulia> TAIEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TAI\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCBEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "method",
    "text": "TCBEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a TCBEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = TCBEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TCB\n\njulia> TCBEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 TCB\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCBEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "method",
    "text": "TCBEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TCBEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TCBEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TCB\n\njulia> TCBEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TCB\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCGEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "method",
    "text": "TCGEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a TCGEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = TCGEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TCG\n\njulia> TCGEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 TCG\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TCGEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "method",
    "text": "TCGEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TCGEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TCGEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TCG\n\njulia> TCGEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TCG\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TDBEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "method",
    "text": "TDBEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a TDBEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = TDBEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TDB\n\njulia> TDBEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 TDB\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TDBEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "method",
    "text": "TDBEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TDBEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TDBEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TDB\n\njulia> TDBEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TDB\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TTEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "method",
    "text": "TTEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a TTEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = TTEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TT\n\njulia> TTEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 TT\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.TTEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "method",
    "text": "TTEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TTEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TTEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TT\n\njulia> TTEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TT\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UT1Epoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "method",
    "text": "UT1Epoch(ep::Epoch{S}, Δt) where S\n\nConstruct a UT1Epoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UT1Epoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UT1\n\njulia> UT1Epoch(ep, 20.0)\n2018-02-06T20:45:20.000 UT1\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UT1Epoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "method",
    "text": "UT1Epoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a UT1Epoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> UT1Epoch(0.0, 0.5)\n2000-01-02T00:00:00.000 UT1\n\njulia> UT1Epoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UT1\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UTCEpoch-Tuple{Epoch,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "method",
    "text": "UTCEpoch(ep::Epoch{S}, Δt) where S\n\nConstruct a UTCEpoch which is ep shifted by Δt seconds.\n\nExample\n\njulia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(ep, 20.0)\n2018-02-06T20:45:20.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.UTCEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "method",
    "text": "UTCEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a UTCEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:mjd: J2000 Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> UTCEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 UTC\n\njulia> UTCEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UTC\n\n\n\n\n\n"
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
