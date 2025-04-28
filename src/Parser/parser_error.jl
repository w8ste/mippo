include("../Lexer/utils.jl")

struct ParseError <: Exception
    m::String
    loc::Location
end

function Base.show(io::IO, loc::Location)
    print(io, "$(loc.path):$(loc.row):$(loc.column)")
end

struct UndefinedSymbolError <: Exception
    m::String
    s::Set{String}
end

function Base.show(io::IO, s::Set{String})
    for symbol in s
        println(io, symbol)

    end
end
