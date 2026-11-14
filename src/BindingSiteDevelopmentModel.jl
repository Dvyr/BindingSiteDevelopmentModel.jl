module BindingSiteDevelopmentModel

include("Structure/Structure.jl")
include("FitnessCalculation/contacts_and_sovation_points.jl")

using .Structure: enumerate_saw, iterate_chains, read_chain_at

export enumerate_saw, iterate_chains, read_chain_at, contacts_and_solvation_points

end
