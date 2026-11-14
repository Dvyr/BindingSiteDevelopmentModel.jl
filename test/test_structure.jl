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

        chains2_from_header = collect(iterate_chains(filename2))
        @test chains2_from_header == chains2

        @test_throws TaskFailedException collect(iterate_chains(3, filename2))

        @test read_chain_at(filename2, 2) == chains2[2]
        @test read_chain_at(2, filename2, 3) == chains2[3]
        @test_throws ArgumentError read_chain_at(filename2, 4)

        @test read_chain_at(filename, 1) == UInt8[]
        @test_throws ArgumentError read_chain_at(filename, 2)

        invalid_file = joinpath(dir, "invalid.dat")
        open(invalid_file, "w") do io
            write(io, UInt8[0x00, 0x01, 0x02])
        end
        @test_throws ArgumentError collect(iterate_chains(invalid_file))
        @test_throws ArgumentError read_chain_at(invalid_file, 1)
    end
end
