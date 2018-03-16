var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#AstronomicalTime-1",
    "page": "Home",
    "title": "AstronomicalTime",
    "category": "section",
    "text": "Astronomical time keeping in Julia[![Build Status Unix][travis-badge]][travis-url] [![Build Status Windows][av-badge]][av-url] [![Coveralls][coveralls-badge]][coveralls-url] [![Codecov][codecov-badge]][codecov-url] [![Docs Stable][docs-badge-stable]][docs-url-stable] [![Docs Latest][docs-badge-latest]][docs-url-latest]"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia\'s package manager:Pkg.clone(\"https://github.com/JuliaAstro/AstronomicalTime.jl\")"
},

{
    "location": "index.html#Quickstart-1",
    "page": "Home",
    "title": "Quickstart",
    "category": "section",
    "text": "# Create an Epoch based on the TT (Terrestial Time) scale\ntt = TTEpoch(\"2018-01-01T12:00:00\")\n\n# Transform to UTC (Universal Time Coordinated)\nutc = UTCEpoch(tt)\n\n# Transform to TDB (Barycentric Dynamical Time)\nutc = TDBEpoch(utc)Read the API docs.[travis-badge]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl.svg?branch=master [travis-url]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl [av-badge]: https://ci.appveyor.com/api/projects/status/13l2bwswxbl1g8cq?svg=true [av-url]: https://ci.appveyor.com/project/helgee/astronomicaltime-jl [coveralls-badge]: https://coveralls.io/repos/github/JuliaAstro/AstronomicalTime.jl/badge.svg?branch=master [coveralls-url]: https://coveralls.io/github/JuliaAstro/AstronomicalTime.jl?branch=master [codecov-badge]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl/coverage.svg?branch=master [codecov-url]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl?branch=master [docs-badge-latest]: https://img.shields.io/badge/docs-latest-blue.svg [docs-url-latest]: https://juliaastro.github.io/AstronomicalTime.jl/latest [docs-badge-stable]: https://img.shields.io/badge/docs-stable-blue.svg [docs-url-stable]: https://juliaastro.github.io/AstronomicalTime.jl/stable"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#AstronomicalTime.@timescale-Tuple{Any}",
    "page": "API",
    "title": "AstronomicalTime.@timescale",
    "category": "macro",
    "text": "@timescale scale\n\nDefine a new timescale and the corresponding Epoch type alias.\n\nExample\n\njulia> @timescale Custom\n\njulia> Custom <: TimeScale\ntrue\njulia> CustomEpoch == Epoch{Custom, T} where T <: Number\ntrue\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{NTuple{4,Any}, NTuple{5,Any}, NTuple{6,Any}, NTuple{7,Any}, Tuple{Any,Any,Any}, Tuple{T}} where T<:AstronomicalTime.TimeScales.TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(year, month, day,\n    hour=0, minute=0, seconds=0, milliseconds=0) where T<:TimeScale\n\nConstruct an Epoch with timescale T at the given date and time.\n\nExample\n\njulia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{AbstractString,Any}, Tuple{AbstractString}, Tuple{T}} where T<:AstronomicalTime.TimeScales.TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(timestamp::AbstractString,\n    fmt::DateFormat=dateformat\"yyyy-mm-ddTHH:MM:SS.sss\") where T<:TimeScale\n\nConstruct an Epoch with timescale T from a timestamp. Optionally a DateFormat object can be passed which improves performance if many date strings need to be parsed and the format is known in advance.\n\nExample\n\njulia> Epoch{TT}(\"2017-03-14T07:18:20.325\")\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{AstronomicalTime.Epochs.Epoch{S,T} where T<:Number}, Tuple{S}, Tuple{T}} where S<:AstronomicalTime.TimeScales.TimeScale where T<:AstronomicalTime.TimeScales.TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(ep::Epoch{S}) where {T<:TimeScale, S<:TimeScale}\n\nConvert an Epoch with timescale S to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))\n2000-01-01T00:00:32.184 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{DateTime}, Tuple{T}} where T<:AstronomicalTime.TimeScales.TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(dt::DateTime) where T<:TimeScale\n\nConvert a DateTime object to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AstronomicalTime\nendModules = [AstronomicalTime, AstronomicalTime.Epochs]\nPrivate = false"
},

]}
