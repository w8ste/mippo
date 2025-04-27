struct Location
    path::String
    row::Int
    column::Int
end

function make_location(file_path::String, row::Int, column::Int)
    return Location(file_path, row, column)
end
