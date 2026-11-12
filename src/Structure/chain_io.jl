
"Iterate over the packed chains written by `enumerate_saw`.

Each iteration yields the continuation-code sequence for one chain as a `Vector{UInt8}`.
"
function iterate_chains(N::Int, filename::String)
    record_size = cld(2 * (N - 1), 8)

    return Channel{Vector{UInt8}}() do ch
        if N == 1
            put!(ch, UInt8[])
            return
        end

        open(filename, "r") do io
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