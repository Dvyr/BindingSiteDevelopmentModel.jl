module Structure

include("chain_geometry.jl")
include("chain_io.jl")
include("chain_enumeration.jl")

export enumerate_saw, iterate_chains, read_chain_at

end # module Structure