const LATTICE_POINT = NTuple{3,Int}

"""
    add_lattice_points(a::LATTICE_POINT, b::LATTICE_POINT)

Return the element-wise sum of two lattice coordinates.
"""
@inline function add_lattice_points(a::LATTICE_POINT, b::LATTICE_POINT)
    return (a[1] + b[1], a[2] + b[2], a[3] + b[3])
end

"""
    reconstruct_chain_geometry(codes::Vector{UInt8})

Reconstruct residue coordinates and bond vectors from continuation codes.

Returns `(positions, bond_vectors)` where:
- `positions::Vector{LATTICE_POINT}` has length `length(codes) + 2`.
- `bond_vectors::Vector{LATTICE_POINT}` has length `length(codes) + 1`.
"""
function reconstruct_chain_geometry(codes::Vector{UInt8})
    nbonds = length(codes) + 1
    nresidues = nbonds + 1

    positions = Vector{LATTICE_POINT}(undef, nresidues)
    bond_vectors = Vector{LATTICE_POINT}(undef, nbonds)

    positions[1] = (0, 0, 0)
    positions[2] = (1, 1, 1)
    bond_vectors[1] = (1, 1, 1)

    for bond_idx in 2:nbonds
        code = codes[bond_idx - 1]
        code <= UInt8(2) || throw(ArgumentError("Invalid continuation code $(code); expected values in 0:2."))

        choice = Int(code) + 1
        bond_vectors[bond_idx] = Structure.continuation_vector(bond_vectors[bond_idx - 1], choice)
        positions[bond_idx + 1] = Structure.add_position(positions[bond_idx], bond_vectors[bond_idx])
    end

    return positions, bond_vectors
end

"""
    nonbonded_candidate_points(
        residue_index::Int,
        positions::Vector{LATTICE_POINT},
        bond_vectors::Vector{LATTICE_POINT},
    )

Compute candidate non-bonded contact lattice points for one residue.

For residue `1`, returns the three non-covalent nearest-neighbor points allowed by the fixed
first bond convention. For internal residues, returns two candidate points (the outgoing covalent
bond direction is excluded). For the terminal residue, returns three candidate points.
"""
function nonbonded_candidate_points(
    residue_index::Int,
    positions::Vector{LATTICE_POINT},
    bond_vectors::Vector{LATTICE_POINT},
)
    nresidues = length(positions)
    pos = positions[residue_index]

    if residue_index == 1
        return LATTICE_POINT[
            (pos[1] + 1, pos[2] - 1, pos[3] - 1),
            (pos[1] - 1, pos[2] + 1, pos[3] - 1),
            (pos[1] - 1, pos[2] - 1, pos[3] + 1),
        ]
    end

    incoming = bond_vectors[residue_index - 1]
    candidates = [add_lattice_points(pos, Structure.continuation_vector(incoming, choice)) for choice in 1:3]

    if residue_index == nresidues
        return candidates
    end

    outgoing = bond_vectors[residue_index]
    outgoing_position = add_lattice_points(pos, outgoing)
    return [candidate for candidate in candidates if candidate != outgoing_position]
end

"""
    contacts_and_solvation_points(codes::Vector{UInt8})
    contacts_and_solvation_points(filename::String, index::Int)
    contacts_and_solvation_points(N::Int, filename::String, index::Int)

Build residue-residue non-covalent contacts and solvation points for a chain in the tetrahedral
lattice model.

- `contacts` contains `(res_i, res_j)` with `res_i < res_j` and `|res_i - res_j| > 1`.
- `solvation_points` contains `(point_coordinates, res_i)` for candidate contact points not occupied by a residue.
"""
function contacts_and_solvation_points(codes::Vector{UInt8})
    positions, bond_vectors = reconstruct_chain_geometry(codes)

    occupied = Dict{LATTICE_POINT,Int}()
    for (residue_index, point) in enumerate(positions)
        haskey(occupied, point) && throw(ArgumentError("Input chain is self-intersecting at residue index $(residue_index)."))
        occupied[point] = residue_index
    end

    contacts = Set{NTuple{2,Int}}()
    solvation_points = Vector{Tuple{LATTICE_POINT,Int}}()

    for residue_index in eachindex(positions)
        for point in nonbonded_candidate_points(residue_index, positions, bond_vectors)
            contacted_residue = get(occupied, point, 0)

            if contacted_residue == 0
                push!(solvation_points, (point, residue_index))
            elseif abs(contacted_residue - residue_index) > 1
                pair = residue_index < contacted_residue ?
                    (residue_index, contacted_residue) :
                    (contacted_residue, residue_index)
                push!(contacts, pair)
            end
        end
    end

    return sort!(collect(contacts)), solvation_points
end

"""
    contacts_and_solvation_points(filename::String, index::Int)

Load chain `index` from a header-based binary chain file and compute contacts and solvation points.
"""
function contacts_and_solvation_points(filename::String, index::Int)
    return contacts_and_solvation_points(read_chain_at(filename, index))
end

"""
    contacts_and_solvation_points(N::Int, filename::String, index::Int)

Load chain `index` from a binary chain file, validating that the file header stores chain length
`N`, and compute contacts and solvation points.
"""
function contacts_and_solvation_points(N::Int, filename::String, index::Int)
    return contacts_and_solvation_points(read_chain_at(N, filename, index))
end