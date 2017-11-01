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
    "text": "Astronomical time keeping in Julia[![Build Status Unix][travis-image]][travis-link] [![Build Status Windows][av-image]][av-link] [![Coveralls][coveralls-image]][coveralls-link] [![Codecov][codecov-image]][codecov-link] [![Docs Stable][docs-badge-stable]][docs-url-stable] [![Docs Latest][docs-badge-latest]][docs-url-latest]"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia's package manager:Pkg.add(\"AstronomicalTime\")"
},

{
    "location": "index.html#Quickstart-1",
    "page": "Home",
    "title": "Quickstart",
    "category": "section",
    "text": "[travis-badge]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl.svg?branch=master [travis-url]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl [av-badge]: https://ci.appveyor.com/api/projects/status/13l2bwswxbl1g8cq?svg=true [av-url]: https://ci.appveyor.com/project/helgee/astronomicaltime-jl [coveralls-badge]: https://coveralls.io/repos/github/JuliaAstro/AstronomicalTime.jl/badge.svg?branch=master [coveralls-url]: https://coveralls.io/github/JuliaAstro/AstronomicalTime.jl?branch=master [codecov-badge]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl/coverage.svg?branch=master [codecov-url]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl?branch=master [docs-badge-latest]: https://img.shields.io/badge/docs-latest-blue.svg [docs-url-latest]: https://juliaastro.github.io/AstronomicalTime.jl/latest [docs-badge-stable]: https://img.shields.io/badge/docs-stable-blue.svg [docs-url-stable]: https://juliaastro.github.io/AstronomicalTime.jl/stable"
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
    "category": "Macro",
    "text": "@timescale scale\n\nDefine a new timescale and the corresponding Epoch type alias.\n\nExample\n\njulia> @timescale Custom\n\njulia> Custom <: TimeScale\ntrue\njulia> CustomEpoch == Epoch{Custom, T} where T <: Number\ntrue\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{AbstractString}, Tuple{T}} where T<:TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "Method",
    "text": "Epoch{T}(timestamp::AbstractString) where T<:TimeScale\n\nConstruct an Epoch with timescale T from a timestamp.\n\nExample\n\njulia> Epoch{TT}(\"2017-03-14T07:18:20.325\")\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{AstronomicalTime.Epochs.Epoch{S,T} where T<:Number}, Tuple{S}, Tuple{T}} where S<:TimeScale where T<:TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "Method",
    "text": "Epoch{T}(ep::Epoch{S}) where {T<:TimeScale, S<:TimeScale}\n\nConvert an Epoch with timescale S to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))\n2000-01-01T00:00:32.184 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{DateTime}, Tuple{T}} where T<:TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "Method",
    "text": "Epoch{T}(dt::DateTime) where T<:TimeScale\n\nConvert a DateTime object to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstronomicalTime.Epochs.Epoch-Union{Tuple{T}, Tuple{Any,Any,Any}, NTuple{4,Any}, NTuple{5,Any}, NTuple{6,Any}, NTuple{7,Any}} where T<:TimeScale",
    "page": "API",
    "title": "AstronomicalTime.Epochs.Epoch",
    "category": "Method",
    "text": "Epoch{T}(year, month, day,\n    hour=0, minute=0, seconds=0, milliseconds=0) where T<:TimeScale\n\nConstruct an Epoch with timescale T at the given date and time.\n\nExample\n\njulia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AstronomicalTime\nendModules = [AstronomicalTime, AstronomicalTime.Epochs]\nPrivate = false"
},

]}
