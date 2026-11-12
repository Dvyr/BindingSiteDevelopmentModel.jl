
const TRANSFORMATION_VECTORS = (
    (-1, 1, 1),
    (1, -1, 1),
    (1, 1, -1),
)

"""
    add_position(pos::NTuple{3,Int}, delta::NTuple{3,Int})

Return the lattice position obtained by adding a bond displacement to a current position.
"""
@inline function add_position(pos::NTuple{3,Int}, delta::NTuple{3,Int})
    return (pos[1] + delta[1], pos[2] + delta[2], pos[3] + delta[3])
end

"""
    continuation_vector(prev::NTuple{3,Int}, choice::Int)

Return the next bond vector by applying one of the three cotransformation generators to `prev`.

The transformation corresponds to multiplying each component of the previous bond vector by one
of the allowed generators:

- `(-1, 1, 1)`
- `(1, -1, 1)`
- `(1, 1, -1)`

This implements the three possible continuations in the tetrahedral chain model.
"""
@inline function continuation_vector(prev::NTuple{3,Int}, choice::Int)
    @inbounds v = TRANSFORMATION_VECTORS[choice]
    return (prev[1] * v[1], prev[2] * v[2], prev[3] * v[3])
end

"""
    pack_directions(codes::Vector{UInt8})

Pack a sequence of 2-bit continuation codes into a compact byte vector.

Each bond after the first is chosen from three possible continuations, so each code is stored in
2 bits. The returned vector contains the packed representation used to store a chain record.
"""
function pack_directions(codes::Vector{UInt8})
    nbytes = cld(2 * length(codes), 8)
    packed = zeros(UInt8, nbytes)

    for k in eachindex(codes)
        bitpos = 2 * (k - 1)
        bytepos = div(bitpos, 8) + 1
        shift = mod(bitpos, 8)

        value = UInt16(codes[k]) << shift

        packed[bytepos] |= UInt8(value & 0xff)

        if shift > 6
            packed[bytepos + 1] |= UInt8(value >> 8)
        end
    end

    return packed
end

"""
    unpack_directions(record::Vector{UInt8}, N::Int)

Unpack a compact chain record back into its 2-bit continuation codes.

This inverse of `pack_directions` reconstructs the original continuation choices for a chain of
length `N`. If `N == 1`, the returned vector is empty because there are no continuation codes.
"""
@inline function unpack_directions(record::Vector{UInt8}, N::Int)
    if N == 1
        return UInt8[]
    end

    codes = Vector{UInt8}(undef, N - 1)
    for k in eachindex(codes)
        bitpos = 2 * (k - 1)
        bytepos = div(bitpos, 8) + 1
        shift = mod(bitpos, 8)

        value = UInt16(record[bytepos])
        if shift > 6
            value |= UInt16(record[bytepos + 1]) << 8
        end

        codes[k] = UInt8((value >> shift) & 0x03)
    end
    return codes
end
