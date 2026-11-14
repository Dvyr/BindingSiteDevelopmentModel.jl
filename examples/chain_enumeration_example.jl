

# This example demonstrates how to use the exported chain-enumeration API from the package.

using BindingSiteDevelopmentModel

N = 16
filename = joinpath(@__DIR__, "..", "chain_storage", "chains_N16.dat")

# Enumerate all self-avoiding chains of length N and write them to a file.
nchains = enumerate_saw(N, filename)

# Iterate over the chains and build a histogram of contact counts.
println("Enumerated $(nchains) self-avoiding chains of length $(N).")
max_contacts = 0
contact_hist = Dict{Int,Int}()

for (i, codes) in enumerate(iterate_chains(N, filename))
    contacts, solvation_points = contacts_and_solvation_points(codes)
    nc = length(contacts)
    max_contacts = max(max_contacts, nc)
    contact_hist[nc] = get(contact_hist, nc, 0) + 1

    if i <= 5
        compact = join(Int.(codes), " ")
        println("Chain $(i): $(compact)")
        println("  contacts = $(nc)")
        println("  solvation points = $(length(solvation_points))")
    end
end

println("================================================")
println("Contact-count histogram")
println("contacts   number_of_chains")
for nc in sort!(collect(keys(contact_hist)))
    println("$(nc)         $(contact_hist[nc])")
end
println("================================================")
println("Maximum contact count observed: $(max_contacts)")