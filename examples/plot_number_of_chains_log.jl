using DelimitedFiles
using Plots

data_path = joinpath(@__DIR__, "..", "chain_storage", "number_of_chains.csv")

raw_data, _ = readdlm(data_path, '\t', Any, '\n'; header = true)

chain_lengths = Int[]
no_saw_chains = Float64[]

for row in eachrow(raw_data)
    push!(chain_lengths, parse(Int, string(row[1])))
    push!(no_saw_chains, parse(Float64, string(row[2])))
end

log_no_saw = log.(no_saw_chains)
reference_line = log(3.0) .* chain_lengths

plot(
    chain_lengths,
    log_no_saw;
    marker = :circle,
    label = "log(no_saw_chains)",
    xlabel = "chain_length",
    ylabel = "value",
    lw = 2,
)

plot!(
    chain_lengths,
    reference_line;
    label = "log(3) * chain_length",
    lw = 2,
    ls = :dash,
)

display(current())
