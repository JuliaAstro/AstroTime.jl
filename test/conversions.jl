@testset "TAI<->TT" begin
    ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TTEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 2.3735247436378273e+01
    in_ep = TAIEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TAI<->TDB" begin
    ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TDBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 2.3734205844955390e+01 atol=1e-6
    in_ep = TAIEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TAI<->TCB" begin
    ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 4.4097432701198270e+01 atol=1e-6
    in_ep = TAIEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TAI<->TCG" begin
    ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCGEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 2.4650535580099750e+01
    in_ep = TAIEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TAI<->UT1" begin
    ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = UT1Epoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 1.4617328996852756e+01 atol=1e-5
    in_ep = TAIEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "TT<->TAI" begin
    ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TAIEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 1.9367247436378280e+01
    in_ep = TTEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TT<->TDB" begin
    ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TDBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.1550205853115330e+01 atol=1e-6
    in_ep = TTEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TT<->TCB" begin
    ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 1.1913432210338932e+01 atol=1e-6
    in_ep = TTEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TT<->TCG" begin
    ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCGEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.2466535557669786e+01
    in_ep = TTEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TT<->UT1" begin
    ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = UT1Epoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 1
    @test second(Float64, out_ep) ≈ 4.2433329223481640e+01 atol=1e-5
    in_ep = TTEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "TDB<->TAI" begin
    ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TAIEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 1.9368289019641487e+01 atol=1e-6
    in_ep = TDBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TDB<->TT" begin
    ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TTEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.1552289019641485e+01 atol=1e-6
    in_ep = TDBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TDB<->TCB" begin
    ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 1.1914473793618030e+01 atol=1e-6
    in_ep = TDBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TDB<->TCG" begin
    ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCGEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.2467577140933720e+01 atol=1e-6
    in_ep = TDBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TDB<->UT1" begin
    ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = UT1Epoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 1
    @test second(Float64, out_ep) ≈ 4.2434370806737520e+01 atol=1e-5
    in_ep = TDBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "TCB<->TAI" begin
    ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TAIEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 1
    @test second(Float64, out_ep) ≈ 5.9005062972974656e+01 atol=1e-6
    in_ep = TCBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCB<->TT" begin
    ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TTEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 3.1189062972974654e+01 atol=1e-6
    in_ep = TCBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCB<->TDB" begin
    ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TDBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 3.1188021394874360e+01 atol=1e-6
    in_ep = TCBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCB<->TCG" begin
    ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCGEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 3.2104351080075170e+01 atol=1e-6
    in_ep = TCBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCB<->UT1" begin
    ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = UT1Epoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 1
    @test second(Float64, out_ep) ≈ 2.2071144903463825e+01 atol=1e-5
    in_ep = TCBEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "TCG<->TAI" begin
    ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TAIEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 1.8451959315724658e+01
    in_ep = TCGEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TCG<->TT" begin
    ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TTEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.0635959315724655e+01
    in_ep = TCGEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01
end

@testset "TCG<->TDB" begin
    ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TDBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 2
    @test second(Float64, out_ep) ≈ 5.0634917732693770e+01 atol=1e-6
    in_ep = TCGEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCG<->TCB" begin
    ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 1.0998144075725655e+01 atol=1e-6
    in_ep = TCGEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-6
end

@testset "TCG<->UT1" begin
    ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = UT1Epoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 1
    @test second(Float64, out_ep) ≈ 4.1518041109273234e+01 atol=1e-5
    in_ep = TCGEpoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "UT1<->TAI" begin
    ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TAIEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 3
    @test second(Float64, out_ep) ≈ 2.8485166135974850e+01 atol=1e-5
    in_ep = UT1Epoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "UT1<->TT" begin
    ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TTEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 4
    @test second(Float64, out_ep) ≈ 6.6916613597484800e-01 atol=1e-5
    in_ep = UT1Epoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "UT1<->TDB" begin
    ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TDBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 4
    @test second(Float64, out_ep) ≈ 6.6812453518777910e-01 atol=1e-5
    in_ep = UT1Epoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "UT1<->TCB" begin
    ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCBEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 4
    @test second(Float64, out_ep) ≈ 2.1031351964098377e+01 atol=1e-5
    in_ep = UT1Epoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

@testset "UT1<->TCG" begin
    ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
    out_ep = TCGEpoch(ep)
    @test year(out_ep) == 2018
    @test month(out_ep) == 8
    @test day(out_ep) == 14
    @test hour(out_ep) == 10
    @test minute(out_ep) == 4
    @test second(Float64, out_ep) ≈ 1.5844543054366440e+00 atol=1e-5
    in_ep = UT1Epoch(out_ep)
    @test year(in_ep) == 2018
    @test month(in_ep) == 8
    @test day(in_ep) == 14
    @test hour(in_ep) == 10
    @test minute(in_ep) == 2
    @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-5
end

