
"""
    iterate_chains(filename::String)
    iterate_chains(N::Int, filename::String)
    read_chain_at(filename::String, index::Int)
    read_chain_at(N::Int, filename::String, index::Int)

Iterate over the packed chains written by `enumerate_saw`.

`iterate_chains(filename)` reads `N` from the binary file header.
`iterate_chains(N, filename)` verifies that `N` matches the header metadata.

Each iteration yields the continuation-code sequence for one chain as a `Vector{UInt8}`.
"""
const CHAIN_FILE_MAGIC = UInt8[0x42, 0x53, 0x44, 0x4d] # "BSDM"
const CHAIN_FILE_VERSION = UInt8(1)

function write_chain_file_header(io::IO, N::Int)
    write(io, CHAIN_FILE_MAGIC)
    write(io, CHAIN_FILE_VERSION)
    write(io, Int32(N))
    return nothing
end

function read_chain_file_header(io::IO)
    magic = read(io, length(CHAIN_FILE_MAGIC))
    length(magic) == length(CHAIN_FILE_MAGIC) || throw(ArgumentError("Missing or truncated chain file header magic."))
    magic == CHAIN_FILE_MAGIC || throw(ArgumentError("Invalid chain file magic."))

    version = read(io, UInt8)
    version == CHAIN_FILE_VERSION || throw(ArgumentError("Unsupported chain file version: $(version)"))

    stored_N = Int(read(io, Int32))
    stored_N >= 1 || throw(ArgumentError("Invalid chain length in header: $(stored_N)"))

    return stored_N
end

function iterate_chains(filename::String)
    N = open(filename, "r") do io
        return read_chain_file_header(io)
    end

    return iterate_chains(N, filename)
end

function iterate_chains(N::Int, filename::String)
    record_size = cld(2 * (N - 1), 8)

    return Channel{Vector{UInt8}}() do ch
        if N == 1
            put!(ch, UInt8[])
            return
        end

        open(filename, "r") do io
            stored_N = read_chain_file_header(io)
            if stored_N != N
                throw(ArgumentError("Chain length mismatch: file header stores N=$(stored_N), but N=$(N) was requested."))
            end

            while !eof(io)
                record = read(io, record_size)
                if length(record) == 0
                    break
                end
                if length(record) < record_size
                    break
                end
                put!(ch, unpack_directions(record, N))
            end
        end
    end
end

function read_chain_at(filename::String, index::Int)
    N = open(filename, "r") do io
        return read_chain_file_header(io)
    end

    return read_chain_at(N, filename, index)
end

function read_chain_at(N::Int, filename::String, index::Int)
    N >= 1 || throw(ArgumentError("N must be at least 1"))
    index >= 1 || throw(ArgumentError("Chain index must be at least 1, got $(index)."))

    record_size = cld(2 * (N - 1), 8)

    return open(filename, "r") do io
        stored_N = read_chain_file_header(io)
        if stored_N != N
            throw(ArgumentError("Chain length mismatch: file header stores N=$(stored_N), but N=$(N) was requested."))
        end

        if N == 1
            index == 1 || throw(ArgumentError("Requested chain index $(index), but only one chain exists for N=1."))
            return UInt8[]
        end

        data_start = position(io)
        record_start = data_start + (index - 1) * record_size
        file_end = filesize(filename)

        record_start + record_size <= file_end || throw(ArgumentError("Requested chain index $(index) is out of bounds for file $(filename)."))

        seek(io, record_start)
        return unpack_directions(read(io, record_size), N)
    end
end