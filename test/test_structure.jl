using Test
using BindingSiteDevelopmentModel

@testset "Structure module" begin
    mktempdir() do dir
        filename = joinpath(dir, "chains_N1.dat")
        n = enumerate_saw(1, filename)
        @test n == 1

        chains = collect(iterate_chains(1, filename))
        @test length(chains) == 1
        @test chains[1] == UInt8[]

        filename2 = joinpath(dir, "chains_N2.dat")
        n2 = enumerate_saw(2, filename2)
        @test n2 == 3

        chains2 = collect(iterate_chains(2, filename2))
        @test length(chains2) == 3
        @test all(length(code) == 1 for code in chains2)
        @test sort(Int.(first.(chains2))) == [0, 1, 2]
    end
end
