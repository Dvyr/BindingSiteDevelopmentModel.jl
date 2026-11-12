

# This example demonstrates how to use the exported chain-enumeration API from the package.

using BindingSiteDevelopmentModel

N = 6
filename = joinpath(@__DIR__, "..", "data", "chains_N6.dat")

# Enumerate all self-avoiding chains of length N and write them to a file.
nchains = enumerate_saw(N, filename)

# Iterate over the chains and print their continuation codes.
println("Enumerated $(nchains) self-avoiding chains of length $(N).")
for (i, codes) in enumerate(iterate_chains(N, filename))
    # show only the first 10 chains to keep the example readable
    i > 20 && break

    compact = join(Int.(codes), " ")
    println("Chain $(i): $(compact)")
end