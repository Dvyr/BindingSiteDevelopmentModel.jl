using Test
using BindingSiteDevelopmentModel

@testset "Contacts and solvation points" begin
    mktempdir() do dir
        filename = joinpath(dir, "chains_N2.dat")
        n = enumerate_saw(2, filename)
        @test n == 3

        for idx in 1:3
            contacts, solvation_points = contacts_and_solvation_points(filename, idx)
            @test isempty(contacts)
            @test length(solvation_points) == 8
        end

        contacts_from_codes, solvation_from_codes =
            contacts_and_solvation_points(read_chain_at(filename, 1))
        contacts_from_file, solvation_from_file = contacts_and_solvation_points(filename, 1)
        @test contacts_from_codes == contacts_from_file
        @test solvation_from_codes == solvation_from_file

        filename6 = joinpath(dir, "chains_N6.dat")
        enumerate_saw(6, filename6)

        found_index = 0
        for (idx, codes) in enumerate(iterate_chains(filename6))
            contacts, _ = contacts_and_solvation_points(codes)
            if found_index == 0 && !isempty(contacts)
                found_index = idx

                @test all(pair[1] < pair[2] for pair in contacts)
                @test all(abs(pair[1] - pair[2]) > 1 for pair in contacts)

                contacts_by_file, solvation_by_file = contacts_and_solvation_points(filename6, idx)
                contacts_by_code, solvation_by_code = contacts_and_solvation_points(codes)
                @test contacts_by_file == contacts_by_code
                @test solvation_by_file == solvation_by_code
            end
        end

        @test found_index > 0
    end
end
