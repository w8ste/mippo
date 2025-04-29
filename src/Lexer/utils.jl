mutable struct Location
    path::String
    row::Int
    column::Int
end

function make_location(file_path::String, row::Int, column::Int)
    return Location(file_path, row, column)
end

# Overload Base.:== so i can compare mutable location
Base.:(==)(a::Location, b::Location) = begin
	a.path == b.path && a.row == b.row && a.column == b.column
end
